if command -v velero > /dev/null; then
    _lazy_completion_register velero 'source <(velero completion bash)'
fi
