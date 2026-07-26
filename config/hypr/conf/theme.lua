-- Catppuccin Mocha palette, in one place.
--
-- Every other file imports this, so changing the desktop's colour scheme means
-- editing this file only. Swapping to Gruvbox or Tokyo Night later is a matter
-- of replacing these values — nothing else references a raw colour.
--
-- Hyprland accepts colours as "rgb(rrggbb)" or "rgba(rrggbbaa)".
-- The `aa` suffix is alpha: ee ≈ 93%, cc ≈ 80%, 80 ≈ 50%.

return {
  -- backgrounds, darkest to lightest
  crust    = "rgb(11111b)",
  mantle   = "rgb(181825)",
  base     = "rgb(1e1e2e)",
  surface0 = "rgb(313244)",
  surface1 = "rgb(45475a)",
  surface2 = "rgb(585b70)",

  -- muted foregrounds
  overlay0 = "rgb(6c7086)",
  overlay1 = "rgb(7f849c)",
  overlay2 = "rgb(9399b2)",

  -- text
  subtext0 = "rgb(a6adc8)",
  subtext1 = "rgb(bac2de)",
  text     = "rgb(cdd6f4)",

  -- accents
  rosewater = "rgb(f5e0dc)",
  flamingo  = "rgb(f2cdcd)",
  pink      = "rgb(f5c2e7)",
  mauve     = "rgb(cba6f7)",
  red       = "rgb(f38ba8)",
  maroon    = "rgb(eba0ac)",
  peach     = "rgb(fab387)",
  yellow    = "rgb(f9e2af)",
  green     = "rgb(a6e3a1)",
  teal      = "rgb(94e2d5)",
  sky       = "rgb(89dceb)",
  sapphire  = "rgb(74c7ec)",
  blue      = "rgb(89b4fa)",
  lavender  = "rgb(b4befe)",

  -- semi-transparent variants, used for borders and shadows
  mauve_a   = "rgba(cba6f7ee)",
  blue_a    = "rgba(89b4faee)",
  surface_a = "rgba(45475aaa)",
  shadow    = "rgba(11111bee)",
}
