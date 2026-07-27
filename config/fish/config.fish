# ~/.config/fish/config.fish
#
# Kept deliberately small. The prompt comes from starship (config/starship.toml),
# so there is no fish_prompt function here to fight with it.

# Fish's own greeting, off — starship already draws a newline.
set -g fish_greeting

if status is-interactive
    # The prompt. Must come after the interactive check, or it slows down
    # every non-interactive fish invocation (scripts, completions).
    if type -q starship
        starship init fish | source
    end

    # --- Abbreviations -------------------------------------------------
    # Unlike aliases, these expand in place as you type, so you can see and
    # edit the real command before running it.
    abbr -a gs   git status
    abbr -a gd   git diff
    abbr -a ga   git add
    abbr -a gc   git commit
    abbr -a gp   git push
    abbr -a gl   git log --oneline --graph --decorate

    abbr -a ..   cd ..
    abbr -a ...  cd ../..

    # Pacman / AUR
    abbr -a pi   sudo pacman -S
    abbr -a pr   sudo pacman -Rns
    abbr -a pu   sudo pacman -Syu
    abbr -a ps-  pacman -Ss

    # Hyprland
    abbr -a hr   hyprctl reload
    abbr -a hc   hyprctl clients
    abbr -a hm   hyprctl monitors

    # --- Listing -------------------------------------------------------
    # eza is ls with git status, tree mode and sane colours. Real functions
    # rather than abbreviations, because these are what you want to run, not
    # commands you want to see expanded first.
    if type -q eza
        function ls  --wraps eza --description "eza, grouped directories first"
            eza --group-directories-first --icons=auto $argv
        end
        function ll  --wraps eza --description "long listing"
            eza -l --group-directories-first --icons=auto --git --time-style=long-iso $argv
        end
        function la  --wraps eza --description "long listing, including dotfiles"
            eza -la --group-directories-first --icons=auto --git --time-style=long-iso $argv
        end
        function lt  --wraps eza --description "tree, two levels"
            eza --tree --level=2 --group-directories-first --icons=auto $argv
        end
    end

    # --- Navigation ----------------------------------------------------
    # zoxide learns the directories you visit: `z proj` jumps to the one you
    # use most, `zi` picks from a list. `cd` is left alone on purpose — a
    # `cd` that guesses is surprising in scripts and over SSH.
    type -q zoxide; and zoxide init fish | source

    # --- Search --------------------------------------------------------
    # fzf's own fish integration: Ctrl+R over history, Ctrl+T for files,
    # Alt+C to cd. Shipped by fzf itself since 0.48, so no plugin manager.
    type -q fzf; and fzf --fish | source

    # Use fd for fzf's file walk: it respects .gitignore and skips .git,
    # which makes Ctrl+T useful inside a repo rather than a flood.
    if type -q fd
        set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
        set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
        set -gx FZF_ALT_C_COMMAND 'fd --type d --hidden --follow --exclude .git'
    end

    # --- Paging --------------------------------------------------------
    # bat is less with syntax highlighting and line numbers. As MANPAGER it
    # makes man pages readable; `cat` stays the real cat.
    if type -q bat
        set -gx MANPAGER 'sh -c "col -bx | bat -l man -p"'
        set -gx MANROFFOPT '-c'
    end

    # --- Colours -------------------------------------------------------
    # Generated from themes/<name>.toml by install/set-theme.py.
    source $__fish_config_dir/colors.fish

    # bat has its own theme names and doesn't read colors.fish; ansi-dark
    # follows the sixteen terminal colours, which colors.fish does set.
    set -gx BAT_THEME ansi
end
