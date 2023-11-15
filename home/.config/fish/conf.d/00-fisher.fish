status is-interactive || exit

if ! set -q _fisher_plugins
    fisher update
end
