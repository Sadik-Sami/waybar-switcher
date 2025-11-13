# Omarchy Waybar Theme Switcher
### A Beautiful, Cleaner Way to Manage Waybar Themes

**Repository:** https://github.com/Sadik-Sami/waybar-switcher.git
**Author:** Sadik Sami

This project brings theme-switching superpowers to Waybar on Hyprland + Omarchy installs.
With a single keybind, you can bring up a Walker menu and instantly switch between multiple Waybar themes stored in `~/.config/waybar/styles/<theme>/`.

The scripts are written to be:
- 🔥 Fast
- 🧩 Modular
- 🎨 Theme-friendly
- 💪 Robust with symlinks and backups
- 🧪 Safe (with `--dry-run` support)

---

# 🚀 Features

✔ **Walker-powered theme switcher launcher** (`omarchy-waybar`)
✔ **Symlink-based theme system** (clean, maintainable, theme-aware Waybar config)
✔ **Automatic backup** of overwritten files
✔ **Fun, interactive, colorful installer**
✔ **Supports `--dry-run`, `--yes`, and `--move-current` flags**
✔ **Hyprland keybind-ready**
✔ **Fully Omarchy-compatible structure**

---

# 📦 Included Scripts

| Script | Purpose |
|--------|---------|
| `omarchy-waybar` | Launcher — opens a Walker menu to select themes |
| `omarchy-waybar-list` | Lists all installed themes (prettified names) |
| `omarchy-waybar-current` | Displays current applied theme |
| `omarchy-waybar-set` | Applies a theme and restarts Waybar |
| `install.sh` | Interactive installer (colorful, safe, friendly) |

---

# 🎯 How Themes Work

Themes live inside:

```
~/.config/waybar/styles/<theme-name>/
```

Each theme folder can contain:

```
config.jsonc
style.css
scripts/
modules/
icons/
(any additional Waybar module assets)
```

The currently active theme is stored as a symlink:

```
~/.config/waybar/current -> ~/.config/waybar/styles/<theme-name>
```

And the theme files inside `current/` get linked into:

```
~/.config/waybar/config.jsonc     -> symlink
~/.config/waybar/style.css        -> symlink
~/.config/waybar/scripts/         -> symlink
~/.config/waybar/modules/         -> symlink
```

This keeps Waybar's config folder clean and makes switching instant.

---

# 📁 Example Theme Structure

```
~/.config/waybar/styles/catppuccin/
├── config.jsonc
├── style.css
├── scripts/
│   ├── weather.sh
│   └── cpu-temp.sh
├── modules/
│   └── custom-module.js
└── icons/
    └── logo.png
```

---

# 🛠 Installation

### Step 1 — Clone the repo

```bash
git clone https://github.com/Sadik-Sami/waybar-switcher.git
cd waybar-switcher
```

### Step 2 — Make installer executable

```bash
chmod +x install.sh
```

### Step 3 — (Optional) Preview everything with a dry run

```bash
./install.sh --dry-run
```

### Step 4 — Install interactively (recommended)

```bash
./install.sh
```

### Step 5 — Or install non-interactively

Auto-yes for all prompts:

```bash
./install.sh --yes
```

Automatically move current Waybar config into `styles/default`:

```bash
./install.sh --move-current
```

---

# 🎮 Usage

### List all themes

```bash
omarchy-waybar-list
```

### Show current theme

```bash
omarchy-waybar-current
```

### Apply a theme

```bash
omarchy-waybar-set "Catppuccin"
```

(Pretty Name = folder name → Title Case)

### Open the Waybar theme menu

```bash
omarchy-waybar
```

---

# ⌨ Hyprland Keybinding

Add to your **`hyprland.conf`**:

```
bind = SUPER SHIFT, W, exec, ~/.local/bin/omarchy-waybar
```

If Hyprland doesn’t see your `~/.local/bin` PATH, use:

```
bind = SUPER SHIFT, W, exec, /home/<username>/.local/bin/omarchy-waybar
```

---

# ⚠ Naming Rules for Themes

To avoid parsing issues:

- Use **lowercase**
- Use **no spaces**
- Use **dashes or underscores** if needed

Examples:

✔ `catppuccin`
✔ `nord`
✔ `my-theme`
✘ `my theme here`

---

# 🧪 Dry Run Mode

The installer supports a fully safe preview mode:

```bash
./install.sh --dry-run
```

It shows:
- Which files will be installed
- What will be moved
- Any directories that will be created
- How the symlinks will be changed

**No changes are made.**

---

# 📝 What the Installer Does

### ✔ Installs scripts into:
```
~/.local/bin/
```

### ✔ Makes them executable
### ✔ Optionally creates:
```
~/.config/waybar/styles/
```

### ✔ Optionally moves current Waybar config into:
```
~/.config/waybar/styles/default/
```

### ✔ Applies the Default theme
### ✔ Shows next-step instructions

---

# ❤️ Contributing

PRs welcome — you can help by:

- Adding new example Waybar themes
- Improving modules or UX
- Contributing screenshots
- Adding support for polybar/cava themes

---

# ✨ Credits

Made for Arch Linux + Hyprland + Omarchy users.
Created by **Sadik Sami**.

---

# ⭐ License

MIT License — free to use, free to modify.
