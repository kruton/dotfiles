if command -v velero > /dev/null; then
    # shellcheck disable=SC1090
    source <(velero completion bash)
fi
