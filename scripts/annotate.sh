# Turns failures into error annotations, so the run summary shows why the action failed without opening the log.
# The steps of action.yaml source this file.

# Annotations go to the output of the step on file descriptor 3, which a command substitution does not capture.
exec 3>&1

# Writes an error annotation with the message.
annotate_error() {
    local message=$1
    message=${message//'%'/'%25'}
    message=${message//$'\r'/'%0D'}
    message=${message//$'\n'/'%0A'}
    echo "::error::$message" >&3
}

# Writes a notice annotation with the message, for a push that the action skips on purpose.
annotate_notice() {
    local message=$1
    message=${message//'%'/'%25'}
    message=${message//$'\r'/'%0D'}
    message=${message//$'\n'/'%0A'}
    echo "::notice::$message" >&3
}

# Runs a command. When it fails, its error output becomes one error annotation.
run_annotated() {
    local errors message status=0
    errors=$(mktemp)
    "$@" 2> "$errors" || status=$?

    if [ "$status" -eq 0 ]; then
        cat "$errors" >&2
    else
        message=$(< "$errors")
        annotate_error "${message:-$1 failed with exit code $status}"
    fi
    rm -f "$errors"
    return "$status"
}
