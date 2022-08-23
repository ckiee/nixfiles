#Requires: ripgrep netcat expect
read -rt 1 request
current="$(mpc -f '%album%\n%artist% - %title%')"

if echo "$request" | rg -q "^GET / HTTP/1.+"; then
    # TODO add: Cache-Control: max-age=2628000
    cat <<EOF
HTTP/1.1 200 OK

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="x-ua-compatible" content="ie=edge">
    <title>listen with ckie!</title>
    <meta name="description" content="">
    <meta name="viewport" content=
    "width=device-width, initial-scale=1">
    <style>
    main {
        margin: auto auto;
        max-width: 720px;
        line-height: 1.6;
        font-size: 18px;
        color: #444;
    }
    html {
        background: #EEEEEE;
    }

    body {
        margin: 20px;
    }
    </style>
</head>
<body>
    <main>
        <video autoplay="1" controls="1" style="height: 40px; width: 100%;" src=audio></video>
        <pre id=mpc>$current</pre>
        <script>
            setInterval(async () => {
                const res = await fetch("/mpc");
                document.querySelector("#mpc").innerText = await res.text();
            }, 500)
        </script>
    </main>
</body>
</html>
EOF

elif echo "$request" | rg -q "^GET /favicon.ico HTTP/1.+"; then
    cat <<EOF
HTTP/1.1 200 OK
Cache-Control: max-age=2628000

EOF
    # binary data gets mangled
    cat "${FAVICON:-favicon.ico}"

# Doesn't work because cantata stores covers separately
# elif echo "$request" | rg -q "^GET /art HTTP/1.+"; then
#     file=$(
#         expect <<EOF | rg 'file: (.+)' --replace '$1'
# set timeout 1
# spawn nc localhost 6600
# send "currentsong\n"
# expect -re "file: (.+)"
# exit
# EOF
# )

#     cat <<EOF
# HTTP/1.1 200 OK
# Cache-Control: no-cache, no-store

# EOF
#     mpc albumart "$file"
elif echo "$request" | rg -q "^GET /mpc HTTP/1.+"; then

    cat <<EOF
HTTP/1.1 200 OK
Cache-Control: no-cache, no-store

$current
EOF

else
    cat <<EOF
HTTP/1.1 404 Not Found
Cache-Control: no-cache, no-store

lol
EOF
fi
