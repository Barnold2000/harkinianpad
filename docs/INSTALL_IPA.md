# Install your HarkinianPad IPA

> [!IMPORTANT]
> **Make your own IPA first.** Current releases provide a PadMint recipe, not
> a public IPA. Follow [Get started](../README.md#get-started) on a Mac, then
> install the completed unsigned IPA saved in Downloads. Building requires
> a Mac; the Windows instructions below are for signing and installation only.

The IPA you made is an unsigned personal build. It is not an
App Store or TestFlight build. AltStore Classic re-signs it with your Apple ID
for your own iPhone or iPad.

The IPA does not include Ocarina of Time, a ROM, or generated game data.

## Install

1. Install AltStore Classic by following its official
   [macOS](https://faq.altstore.io/altstore-classic/how-to-install-altstore-macos)
   or [Windows](https://faq.altstore.io/altstore-classic/how-to-install-altstore-windows)
   guide.
2. Trust the computer and your Apple ID on the device when prompted. On iOS or
   iPadOS 16 and later, enable **Settings → Privacy & Security → Developer
   Mode**.
3. Copy the completed HarkinianPad `.ipa` from your Mac's Downloads folder to
   the Files app. If you built by hand, use the IPA written under `artifacts/`.
4. Keep AltServer running on the computer. Connect the device by USB, or keep
   both devices on the same Wi-Fi network.
5. Open AltStore Classic, choose **My Apps**, tap **+**, select your personal
   IPA, and let AltStore sign and install it.
6. Launch HarkinianPad once, then follow the README's
   [first-launch instructions](../README.md#first-launch) to import your own
   supported ROM through Files.

Your Apple ID credentials are handled by AltStore/AltServer and Apple, not by
HarkinianPad. The
[official AltStore installation guide](https://faq.altstore.io/altstore-classic/how-to-install-altstore-macos)
states that the credentials are sent to Apple.

## Refresh and update

Apps signed with a free Apple ID expire after seven days. AltStore can refresh
them while AltServer is available; you can also use **Refresh All** in
**My Apps**. Free accounts are limited to three active sideloaded apps. See
AltStore's official [Getting Started](https://faq.altstore.io/altstore-classic/your-altstore)
and [AltServer](https://faq.altstore.io/altstore-classic/altserver) pages for
the current rules.

Refreshing extends the current signature; it does not install a newer
HarkinianPad build. To update:

1. Run PadMint again for the newer release and use the newly completed IPA.
2. Install it from **My Apps** using the same Apple ID and sideload tool.
3. Do not delete HarkinianPad first. Replacing it in place gives iPadOS the
   opportunity to preserve the Files-visible Documents container.

Back up the HarkinianPad folder in Files before any preview update. Personal
signing and sideload tools can still fail, expire, or replace an app container;
the project cannot guarantee preservation outside its own tested update path.

## What the personal build means

- It is early test software and may contain bugs.
- It is re-signed by the installer; the unsigned IPA contains no maintainer
  provisioning profile or certificate.
- No jailbreak or JIT is required by HarkinianPad.
- App Store, TestFlight, AltStore PAL, and SideStore support are not part of
  this installation guide.

## Historical Preview 6

HarkinianPad `0.1.0`, build `6`, and its prebuilt download are retired. Its
recorded IPA SHA-256 was
`e24b948b8e40d76132c89016c8c9546a5b7486ad790365e7cb8cfc61777b3c17`.
That hash identifies the old artifact only; it does not verify a new personal
build. Historical testing does not establish acceptance of your new build.
