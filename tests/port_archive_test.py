import importlib.util
from pathlib import Path
import struct
import tempfile
import unittest
from unittest import mock
import zipfile
import zlib

spec = importlib.util.spec_from_file_location('port_archive', Path(__file__).resolve().parents[1] / 'scripts/build-port-archive.py')
port = importlib.util.module_from_spec(spec)
spec.loader.exec_module(port)


def png(raw, width=2, height=1):
    def chunk(kind, data):
        return struct.pack('>I', len(data)) + kind + data + struct.pack('>I', zlib.crc32(kind + data) & 0xffffffff)
    return (b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', width, height, 8, 6, 0, 0, 0))
            + chunk(b'IDAT', zlib.compress(raw)) + chunk(b'IEND', b''))


class PortArchiveTests(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory(prefix='port archive ')
        self.addCleanup(tmp.cleanup)
        self.root = Path(tmp.name)
        self.output = self.root / 'private.o2r'

    def test_texture_formats_preserve_expected_pixel_values(self):
        pixels = bytes([255, 10, 20, 255, 128, 30, 40, 0])
        image = png(b'\0' + pixels)
        expected = {'rgba32': pixels, 'ia16': bytes([255, 255, 128, 0]),
                    'ia8': bytes([255, 128]), 'ia4': bytes([0xf8])}
        for name, payload in expected.items():
            with self.subTest(format=name):
                result = port.texture(image, name)
                self.assertEqual(result[80:], payload)
                self.assertEqual(struct.unpack('<III', result[68:80]), (2, 1, len(payload)))

    def test_png_sub_up_average_and_paeth_filters(self):
        # Identical rows of two identical RGBA pixels, encoded in each PNG filter.
        row = bytes([12, 24, 36, 48]) * 2
        for mode, second in [(0, row), (1, row[:4] + b'\0' * 4),
                             (2, b'\0' * 8), (3, bytes([6, 12, 18, 24]) + b'\0' * 4),
                             (4, b'\0' * 8)]:
            with self.subTest(filter=mode):
                self.assertEqual(port.png_rgba(png(b'\0' + row + bytes([mode]) + second, height=2)),
                                 (2, 2, row + row))

    def test_corrupt_png_is_rejected(self):
        data = bytearray(png(b'\0' + b'\xff' * 8))
        data[-1] ^= 1
        with self.assertRaises(ValueError):
            port.png_rgba(bytes(data))
        with self.assertRaises(ValueError):
            port.png_rgba(png(b'\x05' + b'\xff' * 8))

    def test_changed_inputs_preserve_existing_output(self):
        source, shaders = self.root / 'source', self.root / 'shaders'
        source.mkdir(); shaders.mkdir()
        (source / 'changed').write_bytes(b'unreviewed')
        self.output.write_bytes(b'keep original')
        with self.assertRaisesRegex(ValueError, 'inputs changed'):
            port.build_archive(source, shaders, self.output)
        self.assertEqual(self.output.read_bytes(), b'keep original')

    def test_existing_archive_retry_and_conflict(self):
        files = {'resource': b'original'}
        port.write_archive(files, self.output)
        before = self.output.read_bytes()
        port.write_archive(files, self.output)
        self.assertEqual(self.output.read_bytes(), before)
        with self.assertRaisesRegex(ValueError, 'differs'):
            port.write_archive({'resource': b'changed'}, self.output)
        self.assertEqual(self.output.read_bytes(), before)

    def test_failed_write_leaves_no_partial_output(self):
        with mock.patch.object(zipfile.ZipFile, 'writestr', side_effect=OSError('disk full')):
            with self.assertRaises(OSError):
                port.write_archive({'resource': b'original'}, self.output)
        self.assertFalse(self.output.exists())
        self.assertEqual(list(self.root.iterdir()), [])


if __name__ == '__main__':
    unittest.main()
