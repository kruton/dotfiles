status is-interactive || exit

if ! set -q _tide_configured;
	tide configure --auto --style=Classic --prompt_colors='True color' --classic_prompt_color=Dark --show_time='24-hour format' --classic_prompt_separators=Round --powerline_prompt_heads=Round --powerline_prompt_tails=Round --powerline_prompt_style='One line' --prompt_spacing=Compact --icons='Few icons' --transient=No
  set --universal _tide_configured true
end
