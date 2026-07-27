# No --wraps here: the function has the same name as the binary, so fastfetch's
# own completions already apply. Pointing --wraps at itself is a self-reference.
function fastfetch --description "fastfetch, with a layout that fits the terminal"
    # fastfetch has no responsive mode. Its config commits to a logo and a
    # module list up front, and there is nothing to hang a width rule on: a
    # module's `condition` only tests system, arch and whether the module
    # succeeded, and `display` has no width key at all. So the choice has to
    # be made out here, where $COLUMNS is known.
    #
    # Three configs live in ~/.config/fastfetch. The thresholds come from
    # measuring the built-in ASCII art rather than from taste:
    #
    #   config.jsonc   54-column logo + 4 padding + 15 key + ~35 value  ~108
    #   medium.jsonc   24-column logo + 4 padding + 12 key + ~35 value   ~75
    #   compact.jsonc  no logo,          2-column icon key + ~35 value   ~40
    #
    # Below the threshold the layout does not degrade gracefully — the text
    # column is clipped at the right margin, because fastfetch disables line
    # wrap while it draws so that long values cannot run under the logo.

    # Anything that names its own config wins, as do --help, --version and
    # friends: passing --config as well would either conflict or be confusing.
    if contains -- -c $argv; or contains -- --config $argv
        command fastfetch $argv
        return
    end

    set -l base $XDG_CONFIG_HOME
    test -n "$base"; or set base $HOME/.config
    set -l dir $base/fastfetch

    # $COLUMNS is unset in a non-interactive shell. Assume a normal window
    # rather than the narrowest layout — a script redirecting to a file wants
    # the full output, not the one trimmed for a split pane.
    set -l cols $COLUMNS
    string match -qr '^\d+$' -- "$cols"; or set cols 120

    set -l cfg
    if test $cols -ge 108
        set cfg $dir/config.jsonc
    else if test $cols -ge 68
        set cfg $dir/medium.jsonc
    else
        set cfg $dir/compact.jsonc
    end

    # If the configs are not linked yet (install/link.sh not re-run after the
    # pull that added them), fall back rather than erroring out.
    if not test -f "$cfg"
        command fastfetch $argv
        return
    end

    command fastfetch --config "$cfg" $argv
end
