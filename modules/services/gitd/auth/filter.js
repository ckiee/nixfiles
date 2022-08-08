// authenticate-cookie  GET   / git.ckie.dev    /cgit/ /cgit/?p=login
// action = actions[select(1, ...)]

// http = {}
// http["cookie"] = select(2, ...)
// http["method"] = select(3, ...)
// http["query"] = select(4, ...)
// http["referer"] = select(5, ...)
// http["path"] = select(6, ...)
// http["host"] = select(7, ...)
// http["https"] = select(8, ...)

// cgit = {}
// cgit["repo"] = select(9, ...)
// cgit["page"] = select(10, ...)
// cgit["url"] = select(11, ...)
// cgit["login"] = select(12, ...)
const fs = require("fs");
const crypto = require("crypto");
const path = require("path");


try {
    const stateDir = "/run/cgito";
    const cookieName = "cgitoauth";
    if (!fs.existsSync(stateDir)) fs.mkdirSync(stateDir);
    let [actionName, cookie, method, query, referer, upath, host, https, repo, page, url, login] = process.argv.slice(2);
    https = https == "on" || https == "yes" || https == "1";
    // reused later on client-side
    const cookiefn = c=> {
        const cookies = {}; c.split(";").map(x => x.split("=")).forEach(([k, v]) => cookies[k] = v); return cookies;
    };
    const cookies = cookiefn(cookie);

    let code = cookies[cookieName]
    if (code)code=code.replace(/[^0-9a-z]/g,"");

    let expiryMs = 2.628e+9; // month
    let state = {};
    let fpath;
    if (code) {
        fpath = path.join(stateDir, code);
        if (fs.existsSync(fpath)) {
            state = JSON.parse(fs.readFileSync(fpath));
            // if (state.at && !(Date.now() > state.at + expiryMs)) { state = {}; fs.unlinkSync(fpath); }
        } else fs.writeFileSync(fpath, JSON.stringify(state));
    }

    const actions = {
        "authenticate-cookie": [true, () => {
            if (!code) code = crypto.randomBytes(8).toString("hex");
            let expires = Date.now() + expiryMs;
            console.log(`Cache-Control: no-cache, no-store`);
            if (query == "check_auth") {
                console.log(`Status: ${state.user ? 201 : 403}`);
            }
            if (state.user) {
                if (query == "logout") {
                    expires = 1;
                    if (fpath) fs.unlinkSync(fpath);
                    state = {};
                    console.log(`Status: 302 Redirect
Location: /`);
                } else {
                    process.exit(177);
                }
            } else {
                console.log(`Status: 200 OK`);
            }
            console.log(`Set-Cookie: ${cookieName}=${code};path=/;expires=${new Date(expires).toUTCString()};${https ? "secure" : ""};SameSite=Strict`);
        }],
        "body": [false, () => {
            // look away... (cgit doesn't give us the cookie arg for cookies we just
            // set earlier in the request, this is a new process, and there's no request id)
            const fallbackedCode = code || `<script>
document.write((${cookiefn.toString()})(document.cookie).cgitoauth);
</script>`
            console.log(`
    <h2>Authenticate with SSH</h2>
    <p>
    Run <code>ssh git@ckie.dev webauth ${fallbackedCode}</code> to authenticate
    </p>
    <noscript>
        <meta http-equiv="refresh" content="10">
    </noscript>
    <script>
    setInterval(${(async () => {
        // Are we there yet?
        const res = await fetch("/cgit/?check_auth");
        if (res.status == 201) location.reload();
    })}, 500);
    </script>
    `);
        }],
        "root-header": [true, () => {
            console.log(state.user ? `logged in as ${state.user} * <a href=/cgit/?logout>logout</a>` : "");
        }],
    };

    const [check, action] = actions[actionName];

    if (check) {
        action();
    } else {
        // logged in (:
        if (state.user) {
            process.exit(177);
        } else {
            action();
        }
    }

} catch (err) {
    if (!process.argv[2].startsWith("authenticate-")) {
        console.log(err);
    }
}
