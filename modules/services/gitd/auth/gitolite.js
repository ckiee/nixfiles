const fs = require("fs");
const path = require("path");
const stateDir = "/run/cgito";
const user = process.env.GL_USER;
const cmd = process.env.SSH_ORIGINAL_COMMAND.split(" ");
if (cmd.length !=2) {
    console.error("SYNTAX: webroot <code>");
} else {
    fs.writeFileSync(path.join(stateDir, cmd[1].replace(/[^0-9a-z]/g,"")), JSON.stringify({user, at: Date.now()}));
}
