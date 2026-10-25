## Install

All releases are available [here](https://github.com/yathink3/yk-editor/releases/latest).

### macOS (Apple Silicon and Intel)

1. Download the installer for your Mac, open it, and drag YK Editor into your Applications folder.
    - [**Apple Silicon**](https://github.com/yathink3/yk-editor/releases/latest/download/YK-Editor-aarch64.dmg) (M1 and later)
    - [**Intel**](https://github.com/yathink3/yk-editor/releases/latest/download/YK-Editor-x86_64.dmg)

   YK Editor is not signed with an Apple Developer certificate yet, so macOS will block it the first time you open it.
2. Open Terminal and run:

   ```sh
   xattr -d com.apple.quarantine "/Applications/YK Editor.app"
   ```

> If you'd rather not use Terminal: open YK Editor once (you'll see a "YK Editor can't be opened" or "Apple could not verify" message), then go to **System Settings → Privacy & Security**, scroll down, and click **Open Anyway** next to YK Editor. Confirm with your password.

3. Open YK Editor normally.

#### Command line

To open files and folders from Terminal with `yk-editor`, choose **YK Editor → Install CLI** from the menu bar. It adds `yk-editor` to `/usr/local/bin` and may ask for your password.

If that fails, for example because your account isn't an admin, add it yourself without a password:

```sh
mkdir -p ~/.local/bin
ln -sf "/Applications/YK Editor.app/Contents/MacOS/cli" ~/.local/bin/yk-editor
```

If `yk-editor` still isn't found, add `~/.local/bin` to your `PATH` by adding this line to `~/.zshrc`, then open a new Terminal window:

```sh
export PATH="$HOME/.local/bin:$PATH"
```

### Linux (x86-64 and AArch64)

Run this in a terminal:

```sh
curl -fsSL https://raw.githubusercontent.com/yathink3/yk-editor/main/script/install.sh | sh
```

It installs YK Editor into `~/.local`, adds the `yk-editor` command, and adds YK Editor to your app menu with its icon. Run it again any time to reinstall. YK Editor keeps itself up to date after that.

#### Manual install

1. Download the tarball for your platform.
    - [**Linux x86-64**](https://github.com/yathink3/yk-editor/releases/latest/download/yk-editor-linux-x86_64.tar.gz)
    - [**Linux AArch64**](https://github.com/yathink3/yk-editor/releases/latest/download/yk-editor-linux-aarch64.tar.gz)

2. Unpack its contents into `~/.local`:

```sh
tar -xzf yk-editor-linux-$(uname -m).tar.gz -C ~/.local
ln -sf ~/.local/yk-editor.app/bin/yk-editor ~/.local/bin/yk-editor
```

Make sure `~/.local/bin` is on your `PATH`, then run `yk-editor`. This doesn't add YK Editor to your app menu; the install command above does.

### Windows (x86-64)

Download the [installer](https://github.com/yathink3/yk-editor/releases/latest/download/YK-Editor-x86_64.exe) and click to run. The installer isn't code-signed, so Windows SmartScreen may warn you. Click **More info**, then **Run anyway**.
