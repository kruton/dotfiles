if command -v ngrok &>/dev/null; then
  _lazy_completion_register ngrok "eval \"\$(ngrok completion)\""
fi
