# mise-en-place for dev tools

if command -v mise > /dev/null; then \
    eval "$(mise activate bash --shims)"

    # shellcheck disable=SC1090
    . <(mise completion bash)
fi
