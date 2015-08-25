dedupe_path_list() {
    local _raw_list="${1#*:}"
    local _deduped_list="${1%%:*}"
    local _next_entry
    
    while [[ -n "$_raw_list" ]]; do
        if [[ "$_raw_list" =~ ":" ]]; then
            _next_entry="${_raw_list%%:*}"
            _raw_list="${_raw_list#*:}"
        else
            _next_entry="$_raw_list"
            _raw_list=""
        fi
    
        case ":${_deduped_list}:" in
            *:${_next_entry}:*) ;; # discard
            *) _deduped_list="${_deduped_list}:${_next_entry}" ;;
        esac
    done

    echo "${_deduped_list}"
}
