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
    # Catppuccin Mocha for fish's own syntax highlighting, matching kitty.
    set -g fish_color_normal        cdd6f4
    set -g fish_color_command       89b4fa
    set -g fish_color_keyword       f38ba8
    set -g fish_color_quote         a6e3a1
    set -g fish_color_redirection   f5c2e7
    set -g fish_color_end           fab387
    set -g fish_color_error         f38ba8
    set -g fish_color_param         cdd6f4
    set -g fish_color_comment       6c7086
    set -g fish_color_selection     --background=45475a
    set -g fish_color_search_match  --background=45475a
    set -g fish_color_operator      f5c2e7
    set -g fish_color_escape        eba0ac
    set -g fish_color_autosuggestion 6c7086

    set -g fish_pager_color_progress      6c7086
    set -g fish_pager_color_prefix        f5c2e7
    set -g fish_pager_color_completion    cdd6f4
    set -g fish_pager_color_description   6c7086
    set -g fish_pager_color_selected_background --background=45475a
end
