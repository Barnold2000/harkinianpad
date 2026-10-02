# Portable port-resource generation

The command below reproduces the pinned `soh.o2r` resources without
building native ZAPD. It uses only Python 3.9 or later. The normal build calls it
through `generate-port-archive.sh`, preserving the existing archive locations. Portable
resource generation does not establish a Windows, Linux or Android app-build route.

```sh
python3 scripts/build-port-archive.py \
  sources/Shipwright/soh/assets/custom \
  sources/Shipwright/libultraship/src/fast/shaders \
  /path/to/private/soh.o2r
```

The input digest covers the complete custom-resource set and runtime shaders.
Shaders are read directly from the pinned runtime, so the command does not copy
or remove files in the engine checkout. It reproduces the 31 PNG texture
conversions and the pinned 9.2.3 version record. Input drift or an unexpected
output digest fails before writing. An existing archive is retained and accepted
only when every entry matches; output must be outside the input directories.

Local comparison against the maintained native archive matched all 1,042 entry
names and bytes, including fresh inputs exported from the locked Git commits.
Python 3.9 and 3.11 passed conversion/filter, malformed-input, preservation and
interrupted-write tests. Native Windows/Linux x64 and ARM64 plus Mac ARM64
generation passes in
[run 36987010786](https://github.com/chrissotraidis/harkinianpad/actions/runs/36987010786).
The normal-build integration also passes a local unsigned iPhoneOS build and all
30 Python regression tests. These checks do not establish gameplay or publication
clearance.
