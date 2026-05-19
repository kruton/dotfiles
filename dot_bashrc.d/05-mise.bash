# mise-en-place for dev tools

if command -v mise > /dev/null; then \
    eval "$(mise activate bash --shims)"

    _lazy_completion_register mise '. <(mise completion bash)'
fi
