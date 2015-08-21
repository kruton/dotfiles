# PostgresApp on Mac

if [[ -d /Applications/Postgres.app/Contents/Versions ]]; then \
    for d in /Applications/Postgres.app/Contents/Versions/*/bin; do \
        PATH="$PATH:$d"
    done
fi
