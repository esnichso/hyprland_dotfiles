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

    # --- Colours -------------------------------------------------------
    # Generated from themes/<name>.toml by install/set-theme.py.
    source $__fish_config_dir/colors.fish
end
