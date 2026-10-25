#!/usr/bin/env sh
set -eu

# Downloads a YK Editor release from GitHub and unpacks it into ~/.local/.
# Optional: YK_VERSION=1.2.3 (or WU_VERSION/ZED_VERSION) picks a release,
# YK_BUNDLE_PATH (or WU_BUNDLE_PATH/ZED_BUNDLE_PATH) installs a local bundle.

main() {
    platform="$(uname -s)"
    arch="$(uname -m)"
    channel="${YK_CHANNEL:-${WU_CHANNEL:-${ZED_CHANNEL:-stable}}}"
    repo="yathink3/yk-editor"
    upstream_repo="dstrml/wu"
    version="${YK_VERSION:-${WU_VERSION:-${ZED_VERSION:-latest}}}"
    bundle_path="${YK_BUNDLE_PATH:-${WU_BUNDLE_PATH:-${ZED_BUNDLE_PATH:-}}}"

    suffix=""
    if [ "$channel" != "stable" ]; then
        suffix="-$channel"
    fi

    case "$channel" in
      stable)
        appid="io.github.yathink3.yk-editor"
        app_name="YK Editor"
        ;;
      dev)
        appid="io.github.yathink3.yk-editor-dev"
        app_name="YK Editor Dev"
        ;;
      *)
        appid="io.github.yathink3.yk-editor"
        app_name="YK Editor"
        ;;
    esac

    if [ -n "${TMPDIR:-}" ] && [ -d "${TMPDIR}" ]; then
        temp="$(mktemp -d "$TMPDIR/yk-editor-XXXXXX")"
    else
        temp="$(mktemp -d "/tmp/yk-editor-XXXXXX")"
    fi

    if [ "$platform" = "Darwin" ]; then
        platform="macos"
    elif [ "$platform" = "Linux" ]; then
        platform="linux"
    else
        echo "Unsupported platform $platform"
        exit 1
    fi

    case "$platform-$arch" in
        macos-arm64* | linux-arm64* | linux-aarch64)
            arch="aarch64"
            ;;
        macos-x86* | linux-x86*)
            arch="x86_64"
            ;;
        *)
            echo "Unsupported platform or architecture"
            exit 1
            ;;
    esac

    download_file() {
        _url="$1"
        _output="$2"
        if command -v curl >/dev/null 2>&1; then
            curl -fsSL "$_url" -o "$_output"
        elif command -v wget >/dev/null 2>&1; then
            wget -q -O "$_output" "$_url"
        else
            echo "Could not find 'curl' or 'wget' in your path"
            exit 1
        fi
    }

    fetch_release_asset() {
        _primary_asset="$1"
        _fallback_asset="$2"
        _target_path="$3"

        if [ "$version" = "latest" ]; then
            _primary_url="https://github.com/$repo/releases/latest/download/$_primary_asset"
            _alt_url="https://github.com/$repo/releases/latest/download/$_fallback_asset"
            _upstream_url="https://github.com/$upstream_repo/releases/latest/download/$_fallback_asset"
        else
            _primary_url="https://github.com/$repo/releases/download/v$version/$_primary_asset"
            _alt_url="https://github.com/$repo/releases/download/v$version/$_fallback_asset"
            _upstream_url="https://github.com/$upstream_repo/releases/download/v$version/$_fallback_asset"
        fi

        echo "Downloading YK Editor ($version)..."
        if download_file "$_primary_url" "$_target_path" 2>/dev/null; then
            return 0
        fi

        if [ "$_primary_asset" != "$_fallback_asset" ]; then
            if download_file "$_alt_url" "$_target_path" 2>/dev/null; then
                return 0
            fi
        fi

        echo "Release asset not found in $repo, attempting upstream ($upstream_repo)..."
        if download_file "$_upstream_url" "$_target_path" 2>/dev/null; then
            return 0
        fi

        echo "Error: Failed to download release asset ($_primary_asset / $_fallback_asset)."
        echo "Checked URLs:"
        echo " - $_primary_url"
        echo " - $_upstream_url"
        exit 1
    }

    "$platform" "$@"

    if [ "$(command -v yk-editor 2>/dev/null)" = "$HOME/.local/bin/yk-editor" ]; then
        echo "YK Editor has been installed. Run with 'yk-editor'"
    else
        echo "To run YK Editor from your terminal, you must add ~/.local/bin to your PATH"
        echo "Run:"

        case "$SHELL" in
            *zsh)
                echo "   echo 'export PATH=\$HOME/.local/bin:\$PATH' >> ~/.zshrc"
                echo "   source ~/.zshrc"
                ;;
            *fish)
                echo "   fish_add_path -U $HOME/.local/bin"
                ;;
            *)
                echo "   echo 'export PATH=\$HOME/.local/bin:\$PATH' >> ~/.bashrc"
                echo "   source ~/.bashrc"
                ;;
        esac

        echo "To run YK Editor now, '~/.local/bin/yk-editor'"
    fi
}

linux() {
    tar_file="$temp/yk-editor-linux.tar.gz"
    if [ -n "$bundle_path" ]; then
        cp "$bundle_path" "$tar_file"
    else
        fetch_release_asset "yk-editor-linux-$arch.tar.gz" "wu-linux-$arch.tar.gz" "$tar_file"
    fi

    # Unpack into temp directory first to isolate from existing applications
    mkdir -p "$temp/unpack"
    tar -xzf "$tar_file" -C "$temp/unpack/"

    unpacked_app="$(cd "$temp/unpack/"; echo *.app)"
    target_dir="$HOME/.local/yk-editor$suffix.app"
    rm -rf "$target_dir"
    mkdir -p "$HOME/.local"
    mv "$temp/unpack/$unpacked_app" "$target_dir"

    editor_binary="$target_dir/libexec/yk-editor"
    if [ ! -f "$editor_binary" ]; then
        editor_binary="$target_dir/libexec/wu-editor"
    fi
    if [ -f "$editor_binary" ] && command -v ldd >/dev/null 2>&1; then
        missing="$(ldd "$editor_binary" 2>/dev/null | sed -n 's/^[[:space:]]*\(.*\) => not found$/\1/p')"
        if [ -n "$missing" ]; then
            echo "Warning: your system is missing libraries that YK Editor needs:"
            echo "$missing" | sed 's/^/    /'
            echo "Install them with your package manager, or YK Editor will fail to start."
        fi
    fi

    # Setup ~/.local directories
    mkdir -p "$HOME/.local/bin" "$HOME/.local/share/applications"

    # Link the binary as yk-editor (independent from any existing editors)
    cli_bin="$target_dir/bin/yk-editor"
    if [ ! -f "$cli_bin" ]; then
        cli_bin="$target_dir/bin/wu"
    fi
    ln -sf "$cli_bin" "$HOME/.local/bin/yk-editor"

    # Copy .desktop file
    desktop_file_path="$HOME/.local/share/applications/${appid}.desktop"
    src_dir="$target_dir/share/applications"
    if [ -f "$src_dir/${appid}.desktop" ]; then
        cp "$src_dir/${appid}.desktop" "${desktop_file_path}"
    elif [ -f "$src_dir/me.farshed.Wu.desktop" ]; then
        cp "$src_dir/me.farshed.Wu.desktop" "${desktop_file_path}"
    fi

    if [ -f "${desktop_file_path}" ]; then
        icon_path="$target_dir/share/icons/hicolor/512x512/apps/yk-editor.png"
        if [ ! -f "$icon_path" ]; then
            icon_path="$target_dir/share/icons/hicolor/512x512/apps/wu.png"
        fi
        sed -i "s|Icon=.*|Icon=${icon_path}|g" "${desktop_file_path}"
        sed -i "s|Exec=.*|Exec=$HOME/.local/bin/yk-editor|g" "${desktop_file_path}"
    fi
}

macos() {
    dmg_file="$temp/YK-Editor.dmg"
    if [ -n "$bundle_path" ]; then
        cp "$bundle_path" "$dmg_file"
    else
        fetch_release_asset "YK-Editor-$arch.dmg" "Wu-$arch.dmg" "$dmg_file"
    fi

    mkdir -p "$temp/mount"
    hdiutil attach -quiet "$dmg_file" -mountpoint "$temp/mount"

    target_app="/Applications/${app_name}.app"
    source_app="$(cd "$temp/mount/"; echo *.app)"

    echo "Installing ${app_name}"
    if [ -d "$target_app" ]; then
        echo "Removing existing $target_app"
        rm -rf "$target_app"
    fi
    ditto "$temp/mount/$source_app" "$target_app"
    hdiutil detach -quiet "$temp/mount"

    # If installed from fallback DMG, adjust bundle display name and identifier
    if [ "$source_app" != "${app_name}.app" ]; then
        if command -v plutil >/dev/null 2>&1; then
            plutil -replace CFBundleDisplayName -string "$app_name" "$target_app/Contents/Info.plist" 2>/dev/null || true
            plutil -replace CFBundleName -string "$app_name" "$target_app/Contents/Info.plist" 2>/dev/null || true
            plutil -replace CFBundleIdentifier -string "$appid" "$target_app/Contents/Info.plist" 2>/dev/null || true
        fi
        if command -v codesign >/dev/null 2>&1; then
            codesign --force --deep -s - "$target_app" 2>/dev/null || true
        fi
    fi

    mkdir -p "$HOME/.local/bin"
    # Link only the yk-editor command so existing tools remain untouched
    ln -sf "$target_app/Contents/MacOS/cli" "$HOME/.local/bin/yk-editor"
}

main "$@"
