const PROCESSNAME = "ganache-cli";
require("dotenv").config();
const execSync = require("child_process").execSync;
const path = require("path");

/**
 * Creates a path to an executable in the node_modules/.bin directory. Each
 * path segment is joined with the appropriate platform-specific separator as
 * a delimiter.
 * @param {String} cmd The name of the executable.
 * @returns {String} The path to the executable.
 */
function getBinFile(cmd) {
  return path.join("node_modules", ".bin", cmd);
}

// Execute the command...
execSync(`${getBinFile(PROCESSNAME)} -m \"${process.env.MNEMONIC}\" -v`, {
  stdio: "inherit"
});
