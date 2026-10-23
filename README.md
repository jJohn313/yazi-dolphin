# 🐬 Yazi Dolphin Drop-in Suite

> **The Ultimate Terminal File Manager with Complete GUI Desktop Parity for Linux & Hyprland**

A fully integrated, battle-tested configuration suite that transforms **[Yazi](https://github.com/sxyazi/yazi)** into a complete, instantaneous replacement for GUI file managers like KDE Dolphin and Nautilus.

Designed for modern Wayland environments (Hyprland, Sway, GNOME), this suite delivers the keyboard velocity and low memory footprint of a TUI file manager without sacrificing any of Dolphin's desktop conveniences.

---

## ⚡ Feature Parity Matrix: Dolphin vs. Yazi Dolphin

| GUI Desktop Feature (Dolphin) | Yazi Dolphin Drop-in Solution | Keybinding / Mechanism |
| :--- | :--- | :--- |
| **Cross-Instance Yank & Move (DDS)** | Real-time copy/cut/paste across multiple terminal windows | `y` (copy) / `x` (cut) in Win 1 ➔ `p` in Win 2 via native DDS |
| **Reactive Context Island** | Real-time action suggestions badge matching hovered MIME | Dynamic Header Island (`[l] Play`, `[o] Unpack`, `[^d] Drag`) |
| **Instant "Send To" Movement** | Move or copy files to any zoxide folder without navigating | `m v` (Move To) / `c p` (Copy To) via `zoxide` + `fzf` |
| **Terminal-Native Archive Extraction** | Fast fuzzy directory picker for archive decompression | `o` ➔ `Extract to chosen folder (fzf)...` |
| **In-Archive Folder Browsing** | Seamless virtual inspection without extracting | `l` / `<Enter>` via `smart-enter.yazi` & `ouch` |
| **Contextual "Actions / Open With"** | Filtered interactive action prompt matching file MIME | `o` (`open --interactive`) |
| **Per-Folder Sorting Rules** | Downloads by newest date; Home & projects alphabetical | Automated DDS `cd` listener in `init.lua` |
| **Live Free Disk Space Gauge** | Non-blocking real-time filesystem capacity meter | `ya.async` `Command("df")` in status bar |
| **Breadcrumb / Smart Jumping** | Deep path jumping and interactive fuzzy directory picker | `z <query>` (direct) / `Z` (fzf) via `zoxide` |
| **System-Wide Clipboard Sync** | Bidirectional copy/cut/paste with Wayland clipboard | `y` (yank), `x` (cut), `<C-p>` (paste) via `wl-copy` |
| **Drag & Drop to GUI Windows** | Floating drag source for browsers, Discord, GIMP | `<C-d>` via `ripdrag` |
| **In-Terminal Markdown Viewing** | Render Markdown with tables, styled headers, and code | `o` -> `glow -p` (rendered) or `bat` (syntax) |
| **Modern Text Editing** | Full mouse support, standard shortcuts (`Ctrl+S`, `Ctrl+C`) | `micro` (intuitive modern nano replacement) |
| **Default Image Viewer** | Fast, hardware-accelerated Wayland viewer | `imv` (replaces video editors as default image app) |
| **Universal File Search** | Fuzzy search by name or recursive ripgrep file content | `fg` (content search), `ff` (filename search) |
| **Desktop "Show in Folder"** | GUI apps (Zen, Firefox, Discord) open Yazi in terminal | `yazi.desktop` registered for `inode/directory` |

---

## 🎹 Interactive Keybinding Cheat Sheet

### Essential Operations
| Key | Action | Description |
| :--- | :--- | :--- |
| **`i`** | **Qutebrowser Hint Jump** | Spawns visual letter badges on every file; press the letter to jump to it instantly. |
| **`I`** | **Hint Jump & Open** | Spawns visual hints, jumps to target file, and immediately opens/enters it. |
| **`<C-l>`** | **Location / Path Bar** | Opens Dolphin-style address prompt at the bottom (`cd: `) with Tab-completion to paste paths. |
| **`o`** | **Open With...** | Context-aware action menu tailored to the current file type. |
| **`l`** | **Smart Enter** | Enters directory or triggers smart file opener. |
| **`h`** | **Parent Dir** | Navigates up to parent directory. |
| **`j` / `k`** | **Navigate** | Move down / up (or relative numbers `1`-`9`). |
| **`F1`** or **`~`** | **Help** | Searchable full-screen cheatsheet of all active bindings. |

### Search & Filtering
| Key | Action | Description |
| :--- | :--- | :--- |
| **`/`** | **Filter** | Real-time in-place directory filtering (narrows list as you type). |
| **`f` `g`** | **Fuzzy Ripgrep** | Interactive full-text search across files via `fzf` + `rg`. |
| **`f` `G`** | **Exact Ripgrep** | Exact content search across files. |
| **`f` `f`** | **Find by Name** | Recursive filename fuzzy search via `fzf`. |

### Navigation & Bookmarks
| Key | Action | Description |
| :--- | :--- | :--- |
| **`z <dir>`** | **Zoxide Jump** | Instant jump to any frequently visited folder. |
| **`Z`** | **Fuzzy Jump** | Open interactive `fzf` picker of all tracked directories. |
| **`m` `v`** | **Move To (SendTo)** | Throw selected/hovered files into any zoxide directory via `fzf`. |
| **`c` `p`** | **Copy To (SendTo)** | Copy selected/hovered files into any zoxide directory via `fzf`. |
| **`b` `m`** or **`b` `s`** | **Bookmark** | Bookmark the current directory (Yamb). |
| **`'`** | **Jump Bookmark** | Jump to saved bookmark by assigned key. |
| **`"`** | **FZF Bookmarks** | Fuzzy search all saved bookmarks. |

### File Actions & Clipboard
| Key | Action | Description |
| :--- | :--- | :--- |
| **`y`** | **Yank (Copy)** | Yanks file; automatically syncs across Yazi instances (DDS) & Wayland clipboard. |
| **`x`** | **Cut (Move)** | Cuts file; automatically syncs across Yazi instances (DDS) & Wayland clipboard. |
| **`p`** | **Paste (DDS)** | Natively pastes yanked/cut files across any running Yazi terminal instance. |
| **`<C-p>`** | **Paste (GUI)** | Pastes files copied from external GUI file managers (Dolphin, Zen, Firefox). |
| **`<C-d>`** | **Ripdrag** | Spawns a drag-and-drop window to drag files into GUI apps. |
| **`C`** | **Compress** | Multi-file compression dialog using `ouch`. |
| **`c` `m`** | **Chmod** | Interactive file permissions editor. |
| **`d` `f`** | **Diff** | Visual file diff against hovered file. |
| **`M`** | **Mount** | Disk mount / unmount storage manager. |
| **`T`** | **Maximize** | Toggles preview pane fullscreen. |

---

## 📂 Contextual Quick-Action System (`o` Key)

Pressing **`o`** on any file displays actions strictly relevant to its MIME type:

```text
── Archives (.zip, .tar.gz, .7z, .rar) ─────────────────────────────────────────
1. Extract to subfolder              (ouch d -y %s)
2. Extract here (current directory)  (ouch d -y --here %s)
3. Extract to chosen folder (fzf)... (fuzzy folder picker via zoxide + fd + fzf)
4. Extract and remove archive        (ouch d -y -r %s)
5. Reveal in file manager

── Markdown (.md) ─────────────────────────────────────────────────────────────
1. Render Markdown (glow)            (beautiful CLI reader with tables & code)
2. View formatted text (bat)         (syntax-highlighted paging)
3. Edit with micro                   (intuitive nano replacement)
4. Edit with Kate                    (GUI editor)

── Documents & Media ──────────────────────────────────────────────────────────
• PDF:   xdg-open / OnlyOffice Desktop Editors
• Audio: mpv background playback (no GUI window)
• Video: mpv video player
• Image: imv Wayland viewer
```

---

## 🛠️ Installation & Setup

### 1. Clone & Install
```bash
git clone https://github.com/jJohn313/yazi-dolphin.git
cd yazi-dolphin
./install.sh
```

The installer automatically:
1. Backs up any pre-existing `~/.config/yazi` configuration.
2. Symlinks `config/` into `~/.config/yazi`.
3. Symlinks `bin/yazi-dolphin` into `~/.local/bin/yazi-dolphin`.
4. Registers `yazi.desktop` as your system-wide `inode/directory` handler in `~/.config/mimeapps.list`.
5. Pre-seeds `zoxide` with standard user directories.

### 2. Verify Status
```bash
./install.sh --status
```

### 3. Recommended Tools (Arch Linux)
To enjoy the complete suite experience:
```bash
sudo pacman -S yazi ouch fzf ripgrep zoxide imv glow bat mpv micro kdialog
```

---

## 🔧 Upstream Bugfixes Included

This suite includes patched and audited versions of popular community plugins:
* **`fg.yazi` Exit-Crash Fix**: Fixed a fatal terminal desync where cancelling `fzf` with `<Esc>` (status code 1) left `ui.hide()` unreleased, causing Yazi to hang or crash. UI suppression is now guaranteed to drop cleanly on exit.
* **`system-clipboard.yazi` Deprecation Migration**: Renamed from `clipboard.yazi` to prevent namespace collisions with Yazi 26.9+ internal APIs.

---

## 📄 License

MIT License. Plugins and sub-utilities retain their respective upstream licenses.
