# No --wraps here: the function has the same name as the binary, so fastfetch's
# own completions already apply. Pointing --wraps at itself is a self-reference.
function fastfetch --description "fastfetch, with a layout that fits the terminal"
    # fastfetch has no responsive mode. Its config commits to a logo and a
    # module list up front, and there is nothing to hang a width rule on: a
    # module's `condition` only tests system, arch and whether the module
    # succeeded, and `display` has no width key at all. So the choice has to
    # be made out here, where the terminal width is knowable.
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

    # Width, from the kernel rather than from a shell variable. `tput cols`
    # does a TIOCGWINSZ ioctl on the terminal, so it cannot go stale; fish's
    # $COLUMNS is only refreshed on SIGWINCH and is unset entirely in a
    # non-interactive shell.
    #
    # Not a tty (piped, redirected, run from a script): assume a normal window
    # rather than the narrowest layout, because tput would report terminfo's
    # 80-column default and silently pick compact. A script redirecting to a
    # file wants the full output.
    set -l cols 120
    if isatty stdout
        set -l w (command tput cols 2>/dev/null)
        string match -qr '^\d+$' -- "$w"; and set cols $w
    end

    # Escape hatch. `set -x FASTFETCH_LAYOUT wide` forces one, and `debug`
    # prints the decision instead of running — which is the only way to tell
    # "the width is wrong" apart from "the threshold is wrong" without
    # counting columns by eye.
    set -l want auto
    set -q FASTFETCH_LAYOUT; and set want $FASTFETCH_LAYOUT

    set -l layout
    switch "$want"
        case wide medium compact
            set layout $want
        case '*'
            if test $cols -ge 108
                set layout wide
            else if test $cols -ge 68
                set layout medium
            else
                set layout compact
            end
    end

    set -l cfg
    switch "$layout"
        case wide
            set cfg $dir/config.jsonc
        case medium
            set cfg $dir/medium.jsonc
        case '*'
            set cfg $dir/compact.jsonc
    end

    if test "$want" = debug
        echo "tput cols     $cols"
        echo "COLUMNS       $COLUMNS"
        echo "layout        $layout"
        echo "config        $cfg"
        test -f "$cfg"; and echo "exists        yes"; or echo "exists        NO"
        return
    end

    # If the configs are not linked yet (install/link.sh not re-run after the
    # pull that added them), fall back rather than erroring out.
    if not test -f "$cfg"
        command fastfetch $argv
        return
    end

    command fastfetch --config "$cfg" $argv
end
