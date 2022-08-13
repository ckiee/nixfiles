#!/usr/bin/env bash
#Requires: inotify-tools gnused coreutils ripgrep inetutils
touch pending-jobs
mkdir build-logs 2>/dev/null || true
eval_job() {
    job="$1"
    name="$(echo "$job" | cut -d'-' -f2- | sed -e 's/.drv$//')"
    echo evaluating job "$job"
    echo '===' evaluating job "$job" on host "$(hostname)" >> build-logs/"$(basename "$job")"
    nix-store --realise "$job" --add-root ./"$name" $NIX_OPTS >> build-logs/"$(basename "$job")" 2>&1
}

if rg '.+' current_job >/dev/null 2>&1; then
    eval_job "$(cat current-job)"
fi

while true; do
    if wc -l new-jobs | rg "0 new-jobs" >/dev/null; then
        if wc -l pending-jobs | rg "0 pending-jobs" >/dev/null; then
            inotifywait -q new-jobs -e MODIFY
        fi
    else
        cat new-jobs >> pending-jobs
        truncate -s0 new-jobs
    fi
    job="$(head -n1 pending-jobs)"
    echo "$job" >current-job
    sed -i 1d pending-jobs
    eval_job "$job"
    echo $? > build-logs/"$(basename "$job")".exitcode
    rm current-job
    sleep 0.1
done
