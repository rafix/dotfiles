#!/bin/bash

# Setup Script for App Shortcuts
# Quick app launching using Karabiner Elements keyboard shortcuts

set -e

echo "🔧 Setting up app shortcuts using Karabiner Elements..."

DOTFILES_DIR="$HOME/.dotfiles"
SCRIPT_DIR="$DOTFILES_DIR/os/mac"
KARABINER_ASSETS="$HOME/.config/karabiner/assets/complex_modifications"
KARABINER_CONFIG="$HOME/.config/karabiner/karabiner.json"
ASSET_SRC="$SCRIPT_DIR/karabiner_app_shortcuts.json"
RULE_DESC="App Shortcuts - Launch Applications with Cmd+Alt combinations"

# --- Machine-specific browser binding -------------------------------------
# Defaults match the personal machine; override per-machine in karabiner.local.sh
BROWSER_APP='Brave Browser'
BROWSER_KEY='b'
BROWSER_MODS='left_command,left_shift,left_option'
if [ -f "$SCRIPT_DIR/karabiner.local.sh" ]; then
    # shellcheck source=/dev/null
    source "$SCRIPT_DIR/karabiner.local.sh"
    echo "✅ Loaded machine config: $BROWSER_KEY ($BROWSER_MODS) → $BROWSER_APP"
else
    echo "ℹ️  No karabiner.local.sh found — using defaults ($BROWSER_APP)."
    echo "   Copy karabiner.local.sh.example → karabiner.local.sh to customize."
fi

apply_karabiner_shortcuts() {
    if ! command -v jq >/dev/null 2>&1; then
        echo "⚠️  jq is required to patch the live Karabiner config (brew install jq)."
        return 1
    fi
    if [ ! -f "$ASSET_SRC" ]; then
        echo "⚠️  Canonical ruleset not found at $ASSET_SRC"
        return 1
    fi
    if [ ! -f "$KARABINER_CONFIG" ]; then
        echo "⚠️  $KARABINER_CONFIG not found."
        echo "   Launch Karabiner-Elements once (it generates the default config), then re-run."
        return 1
    fi

    # Build the browser manipulator from the machine config.
    local mods_json
    mods_json=$(printf '%s' "$BROWSER_MODS" | jq -R 'split(",")')
    local browser_manip
    browser_manip=$(jq -n \
        --arg key "$BROWSER_KEY" \
        --argjson mods "$mods_json" \
        --arg cmd "open -a '$BROWSER_APP'" \
        '{type:"basic", from:{key_code:$key, modifiers:{mandatory:$mods}}, to:[{shell_command:$cmd}]}')

    # Assemble the full rule: canonical manipulators (browser-free) + browser manipulator.
    local rule_json
    rule_json=$(jq \
        --arg desc "$RULE_DESC" \
        --argjson browser "$browser_manip" \
        '{description:$desc, manipulators:(.rules[0].manipulators + [$browser])}' \
        "$ASSET_SRC")

    # Back up, then patch every profile: replace the matching rule, else append it.
    cp "$KARABINER_CONFIG" "$KARABINER_CONFIG.bak"
    local tmp
    tmp=$(mktemp)
    jq \
        --arg desc "$RULE_DESC" \
        --argjson rule "$rule_json" \
        '.profiles |= map(
            .complex_modifications.rules =
                ((.complex_modifications.rules // [] | map(select(.description != $desc))) + [$rule])
         )' \
        "$KARABINER_CONFIG" > "$tmp" && mv "$tmp" "$KARABINER_CONFIG"

    echo "✅ Patched live config: $KARABINER_CONFIG (backup at $KARABINER_CONFIG.bak)"
    echo "   Karabiner-Elements auto-reloads on file change."

    # Also refresh the importable asset (machine-specific) for transparency.
    mkdir -p "$KARABINER_ASSETS"
    jq --argjson rule "$rule_json" \
        '{title:"App Shortcuts - Quick App Launching", rules:[$rule]}' \
        "$ASSET_SRC" > "$KARABINER_ASSETS/karabiner_app_shortcuts.json"
    echo "✅ Refreshed importable asset in $KARABINER_ASSETS/"
}

apply_karabiner_shortcuts || echo "⚠️  Skipped live Karabiner patch (see message above)."

# Function to create macOS keyboard shortcuts
create_macos_shortcut() {
    local shortcut_name="$1"
    local app_name="$2"
    local key_combo="$3"
    
    echo "Creating shortcut: $shortcut_name -> $app_name"
    
    # Create Automator service (this requires manual setup in System Settings)
    echo "📝 Manual step required: Add '$key_combo' -> '$app_name' in System Settings → Keyboard → Shortcuts"
}

echo
echo "🚀 App Shortcuts Setup Complete!"
echo
echo "📱 Available launch commands:"
echo "   $SCRIPT_DIR/app_shortcuts.sh terminal    # Ghostty"
echo "   $SCRIPT_DIR/app_shortcuts.sh browser     # Brave Browser"
echo "   $SCRIPT_DIR/app_shortcuts.sh code        # Cursor"
echo "   $SCRIPT_DIR/app_shortcuts.sh finder      # Finder"
echo "   $SCRIPT_DIR/app_shortcuts.sh intellij    # IntelliJ IDEA"
echo "   $SCRIPT_DIR/app_shortcuts.sh claude      # Claude AI"
echo "   $SCRIPT_DIR/app_shortcuts.sh perplexity  # Perplexity AI"
echo "   $SCRIPT_DIR/app_shortcuts.sh whatsapp    # WhatsApp"
echo "   $SCRIPT_DIR/app_shortcuts.sh messages    # Messages"
echo "   $SCRIPT_DIR/app_shortcuts.sh discord     # Discord"
echo "   $SCRIPT_DIR/app_shortcuts.sh telegram    # Telegram"

echo
echo "⚙️  To set up keyboard shortcuts, choose ONE of these options:"
echo
echo "🟢 Option 1: Karabiner-Elements (Recommended)"
echo "   1. Install manually: Download from https://karabiner-elements.pqrs.org/"
echo "   2. Open Karabiner-Elements"
echo "   3. Import the configuration file that will be created"
echo
echo "🟡 Option 2: macOS Shortcuts App (Built-in)"
echo "   1. Open Shortcuts app"
echo "   2. Create new shortcuts for each app"
echo "   3. Assign keyboard shortcuts in System Settings"
echo
echo "🔵 Option 3: Use the shell script directly"
echo "   Create aliases in your shell config (.zshrc, .bashrc, etc.):"
echo "   alias launch-terminal='$SCRIPT_DIR/app_shortcuts.sh terminal'"
echo "   alias launch-browser='$SCRIPT_DIR/app_shortcuts.sh browser'"
echo "   # ... etc for other apps"

echo
echo "✅ Next steps:"
echo "   1. Choose your preferred option above"
echo "   2. Test the shortcuts work correctly"
echo "   3. Mission Control is already restored and working"

# Test if apps exist
echo
echo "🔍 Checking installed applications..."
APPS_TO_CHECK=(
    "Ghostty"
    "Brave Browser"
    "Cursor"
    "IntelliJ IDEA"
    "Claude"
    "Perplexity"
    "WhatsApp"
    "Discord"
    "Telegram"
)

for app in "${APPS_TO_CHECK[@]}"; do
    if [[ -d "/Applications/${app}.app" ]]; then
        echo "   ✅ $app found"
    else
        echo "   ❌ $app not found"
    fi
done