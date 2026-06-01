#!/bin/bash

# App Shortcuts Script
# Quick app launching functionality using keyboard shortcuts
# This script provides functions to launch applications

# Machine-specific browser (overridable via karabiner.local.sh, default Brave)
BROWSER_APP='Brave Browser'
_local_cfg="$(dirname "${BASH_SOURCE[0]}")/karabiner.local.sh"
[ -f "$_local_cfg" ] && source "$_local_cfg"

launch_app() {
    local app_name="$1"
    echo "Launching $app_name..."

    case "$app_name" in
        "terminal"|"ghostty")
            open -a "Ghostty"
            ;;
        "browser"|"brave"|"chrome")
            open -a "$BROWSER_APP"
            ;;
        "code"|"cursor")
            open -a "Cursor"
            ;;
        "finder")
            open -a "Finder"
            ;;
        "intellij"|"idea")
            open -a "IntelliJ IDEA"
            ;;
        "claude"|"ai")
            open -a "Claude"
            ;;
        "perplexity"|"search")
            if ! open -a "Perplexity" 2>/dev/null; then
                open "https://www.perplexity.ai"
            fi
            ;;
        "whatsapp")
            open -a "WhatsApp"
            ;;
        "messages")
            open -a "Messages"
            ;;
        "discord")
            open -a "Discord"
            ;;
        "telegram")
            open -a "Telegram"
            ;;
        "chatgpt")
            open "https://chat.openai.com"
            ;;
        "lightroom")
            open -a "Adobe Lightroom Classic"
            ;;
        "photoshop")
            open -a "Adobe Photoshop 2024"
            ;;
        "protonmail"|"mail"|"email")
            open -a "Proton Mail"
            ;;
        *)
            echo "Unknown app: $app_name"
            echo "Available apps: terminal, browser, code, finder, intellij, claude, perplexity, whatsapp, messages, discord, telegram, chatgpt, lightroom, photoshop, protonmail"
            ;;
    esac
}

# If script is run directly with an argument, launch that app
if [ "$#" -eq 1 ]; then
    launch_app "$1"
fi