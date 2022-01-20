#!/usr/bin/env bash
#Requires: ripgrep
[ -f pending-jobs ] || touch pending-jobs
resp_headers="server: aldhy
date: $(date +"%a, %d %b %Y %H:%M:%S %Z")"
resp_head_html="content-type: text/html; charset=UTF-8"
resp_head_json="content-type: application/json; charset=UTF-8"
resp_head_cache="cache-control: max-age=2628000" # a month
cssjs="
<style>
* { font-size: 1.035em; }
p, pre { margin: 0px; }
img { vertical-align: middle; }
</style>
<script>
const currentJobLogsEle = document.getElementById('current-job-logs');
if (currentJobLogsEle && currentJobLogsEle.innerText.trim().length > 0) {
    setInterval(async () => {
    currentJobLogsEle.innerText = await (await fetch('logs/current')).text();
    }, 700);
}
</script>
"
[ -f current-job ] && current_job_name="$(cut -d'/' -f4- < current-job)"
read request
if echo "$request" | rg -q "^GET / HTTP/1.+"; then
    current_job="<p style=color:red>no job running</p>"
    if [ -f current-job ]; then
        current_job="
<details open>
<summary>currently building $(cat current-job) (<a href=logs/$current_job_name>logs</a>)</summary>
<pre style=background:black;color:#00ff00;overflow-wrap:break-word;font-size:0.95em; id=current-job-logs>
$(tail -n20 build-logs/$current_job_name)
</pre>
</details>"

    fi
    queued_jobs="<u>queued (<b>$(wc -l pending-jobs | cut -d' ' -f1)</b>)</u>"
    for job in $(tr '\n' ' ' < pending-jobs); do
        queued_jobs="$queued_jobs
- $job"
    done
    past_jobs="<u>completed (<b>$(ls build-logs/*.drv | wc -l | cut -d' ' -f1)</b>)</u>"
    for job in $(ls build-logs | rg -v '\.exitcode$' | tr '\n' ' '); do
        if ! [ "$job" == "$current_job_name" ]; then
        build_unix="$(stat -c'%Y' build-logs/"$job")"
        job_exitcode="$(cat build-logs/"$job".exitcode)"
        job_status="finished"
        [ "$job_exitcode" -ne 0 ] && job_status="failed with exit code $job_exitcode"
        past_jobs="$past_jobs
- <a href=logs/$job>$job</a> <script>document.write('(build $job_status at '+new Date(1000*$build_unix).toLocaleString()+')')</script>"
        fi
    done
    cat <<EOF
HTTP/1.1 200 OK
$resp_headers
$resp_head_html

<pre>
<b><u>aldhy job status</u><img src=favicon.ico></b>
$current_job
$queued_jobs
$past_jobs
</pre>
$cssjs
EOF
elif [ "$current_job_name" != "" ] && echo "$request" | rg -q "^GET /logs/current HTTP/1.+"; then
    cat <<EOF
HTTP/1.1 200 OK
$resp_headers

$(tail -n20 build-logs/$current_job_name)
EOF
elif log="$(echo "$request" | rg '^GET /logs/([a-z0-9][a-z-0-9.]+) HTTP/1.+' --replace '$1')"; then
    log_path="build-logs/$(basename "$log")"
    if [ -f "$log_path" ]; then
        cat <<EOF
HTTP/1.1 200 OK
$resp_headers

$(cat "$log_path")
EOF
    else
        cat <<EOF
HTTP/1.1 404 Not Found
$resp_headers

no job currently running
EOF
    fi
elif host="$(echo "$request" | rg '^GET /hosts/([a-z]+) HTTP/1.+' --replace '$1')"; then
    nixos_path=$(realpath $PWD/nixos-system-$host-*)
    if [ -d "$nixos_path" ]; then
        cat <<EOF
HTTP/1.1 200 OK
$resp_headers
$resp_head_json

{"path":"$nixos_path","unix":$(stat -c'%Y' nixos-system-$host-*)}
EOF
    else
        cat <<EOF
HTTP/1.1 404 Not Found
$resp_headers
$resp_head_json

{"error":"not_found"}
EOF
    fi
elif echo "$request" | rg -q "^GET /favicon.ico HTTP/1.+"; then
    cat <<EOF
HTTP/1.1 200 OK
$resp_headers
$resp_head_cache

EOF
    # its binary data so no inlining into the rest of the response
    cat "$FAVICON"
else
    cat <<EOF
HTTP/1.1 404 Not Found
$resp_headers
$resp_head_html
$resp_head_cache

<pre style="color: red; font-weight: bold;">404</pre>
$css
EOF
fi
