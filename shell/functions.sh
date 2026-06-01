function cdd() {
	cd "$(ls -d -- */ | fzf)" || echo "Invalid directory"
}

function j() {
	fname=$(declare -f -F _z)

	[ -n "$fname" ] || source "$DOTLY_PATH/modules/z/z.sh"

	_z "$1"
}

function recent_dirs() {
	# This script depends on pushd. It works better with autopush enabled in ZSH
	escaped_home=$(echo $HOME | sed 's/\//\\\//g')
	selected=$(dirs -p | sort -u | fzf)

	cd "$(echo "$selected" | sed "s/\~/$escaped_home/")" || echo "Invalid directory"
}

# Tmux functions for better Ghostty integration
function tmux_new_session() {
	local session_name="${1:-$(basename $PWD)}"
	tmux new-session -d -s "$session_name" -c "$PWD"
	tmux attach-session -t "$session_name"
}

function tmux_attach_or_new() {
	local session_name="${1:-$(basename $PWD)}"
	if tmux has-session -t "$session_name" 2>/dev/null; then
		tmux attach-session -t "$session_name"
	else
		tmux_new_session "$session_name"
	fi
}

function tmux_kill_all() {
	tmux list-sessions | awk 'BEGIN{FS=":"}{print $1}' | xargs -n 1 tmux kill-session -t
}

function tmux_session_list() {
	tmux list-sessions -F '#{session_name}: #{session_windows} windows (created #{session_created_string})'
}
