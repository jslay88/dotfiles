# ╔══════════════════════════════════════════════════════════════════════════╗
# ║                      Custom Gallois Theme (No OMZ)                       ║
# ╚══════════════════════════════════════════════════════════════════════════╝
#
# Features:
# - No username@host (single user machine)
# - Git branch: green for clean, red for dirty
# - $ prompt: green for exit 0, red for non-zero
# - Command duration tracking with color-coded output

autoload -U colors && colors

# ─────────────────────────────────────────────────────────────────────────────
# Git Functions (standalone, no oh-my-zsh dependency)
# ─────────────────────────────────────────────────────────────────────────────

# Get current git branch name
git_current_branch() {
    local ref
    ref=$(git symbolic-ref --quiet HEAD 2>/dev/null) || \
    ref=$(git rev-parse --short HEAD 2>/dev/null) || return 0
    echo "${ref#refs/heads/}"
}

# Check if git repo is dirty (has uncommitted changes)
git_is_dirty() {
    local git_status
    git_status=$(git status --porcelain 2>/dev/null | head -1)
    [[ -n "$git_status" ]]
}

# Build git status prompt segment
git_prompt_info() {
    local branch=$(git_current_branch)
    [[ -z "$branch" ]] && return 0
    
    local branch_color
    if git_is_dirty; then
        branch_color="%{$fg[red]%}"
    else
        branch_color="%{$fg[green]%}"
    fi
    
    echo "%{$fg[cyan]%}[${branch_color}${branch}%{$fg[cyan]%}]"
}

# ─────────────────────────────────────────────────────────────────────────────
# Duration Tracking
# ─────────────────────────────────────────────────────────────────────────────

_cmd_start_time=""

# Track command start time
preexec() {
    _cmd_start_time=$(perl -MTime::HiRes=time -e 'printf "%.9f\n", time' 2>/dev/null || date +%s)
}

# Calculate and format command duration
_calc_duration() {
    local now=$(perl -MTime::HiRes=time -e 'printf "%.9f\n", time' 2>/dev/null || date +%s)
    local start=$1
    
    # Parse timestamps
    local start_sec=${start%.*}
    local start_ns=${start#*.}
    local now_sec=${now%.*}
    local now_ns=${now#*.}
    
    # Calculate difference
    local T=$((now_sec - start_sec))
    local D=$((T/60/60/24))
    local H=$((T/60/60%24))
    local M=$((T/60%60))
    local S=$((T%60))
    
    local duration=""
    (( D > 0 )) && duration+="${D}d"
    (( H > 0 )) && duration+="${H}h"
    (( M > 0 )) && duration+="${M}m"
    
    if [[ $T -le 0 ]]; then
        # Sub-second, show milliseconds
        local ms=$(( (now_ns - start_ns) / 1000000 ))
        [[ $ms -lt 0 ]] && ms=$((ms + 1000))
        printf "%dms" "$ms"
    else
        printf "%s%.3fs" "$duration" "$((S + (now_ns - start_ns) / 1000000000.0))"
    fi
}

# Get duration color based on elapsed time
_duration_color() {
    local start=$1
    local now=$(perl -MTime::HiRes=time -e 'printf "%.9f\n", time' 2>/dev/null || date +%s)
    local diff=$((${now%.*} - ${start%.*}))
    
    if [[ $diff -gt 120 ]]; then
        echo "%{$fg[magenta]%}"
    elif [[ $diff -gt 60 ]]; then
        echo "%{$fg[red]%}"
    elif [[ $diff -gt 10 ]]; then
        echo "%{$fg[yellow]%}"
    else
        echo "%{$fg[green]%}"
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# Pipe Status Handling
# ─────────────────────────────────────────────────────────────────────────────

_pipestatus_parse() {
    local ps="$pipestatus"
    local has_error=0
    
    for code in ${(z)ps}; do
        [[ "$code" -ne 0 ]] && has_error=1
    done
    
    if [[ "$has_error" -ne 0 ]]; then
        echo "[%{$fg[red]%}${ps}%{$fg[cyan]%}]"
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# Prompt Construction
# ─────────────────────────────────────────────────────────────────────────────

_custom_prompt=""
_last_git_info=""

# Base prompt: [working directory] colored $
# $ is green for exit 0, red for non-zero
_base_prompt="%{$fg[cyan]%}[%~%{$fg[cyan]%}]%(?.%{$fg[green]%}.%{$fg[red]%})%B$%b "

precmd() {
    local retval=$(_pipestatus_parse)
    local info=""
    
    # Show duration if we have a start time
    if [[ -n "$_cmd_start_time" ]]; then
        local elapsed=$(_calc_duration "$_cmd_start_time")
        local elapsed_color=$(_duration_color "$_cmd_start_time")
        info="%{$fg[cyan]%}[${elapsed_color}${elapsed}%{$fg[cyan]%}]${retval}"
        _cmd_start_time=""
    fi
    
    # Cache git info (only update on new command, not just Enter)
    if [[ -z "$info" && -n "$_last_git_info" ]]; then
        _custom_prompt="${_last_git_info}${_base_prompt}"
        return
    fi
    
    # Get git status
    local git_info=$(git_prompt_info)
    _last_git_info="$git_info"
    
    if [[ -n "$git_info" ]]; then
        if [[ -z "$info" ]]; then
            info="$git_info"
        else
            info="${info}${git_info}"
        fi
    fi
    
    if [[ -z "$info" ]]; then
        _custom_prompt="$_base_prompt"
    else
        _custom_prompt="${info}${_base_prompt}"
    fi
}

setopt PROMPT_SUBST
PROMPT='$_custom_prompt'
