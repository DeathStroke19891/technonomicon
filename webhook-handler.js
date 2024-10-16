require("dotenv").config({ path: "../.env" });
const express = require("express");
const crypto = require("crypto");
const { exec } = require("child_process");
const path = require("path");

const app = express();
const port = 4322;
const secret = process.env.WEBHOOK_SECRET;

app.use(express.json());

function verifySignature(req, res, buf, encoding) {
  const signature = `sha1=${crypto
    .createHmac("sha1", secret)
    .update(buf)
    .digest("hex")}`;

  if (req.headers["x-hub-signature"] !== signature) {
    res.status(401).send("Invalid signature");
    throw new Error("Invalid signature");
  }
}

app.post("/", express.json({ verify: verifySignature }), (req, res) => {
  const payload = req.body;

  if (payload.ref === "refs/heads/main") {
    const projectRoot = path.resolve(__dirname, "..");
    exec(
      `cd ${projectRoot} && git pull && npm install && npm build && pm2 restart blog`,
      (error, stdout, stderr) => {
        if (error) {
          console.error(`exec error: ${error}`);
          return;
        }
        console.log(`stdout: ${stdout}`);
        console.error(`stderr: ${stderr}`);
      },
    );
  }

  res.sendStatus(200);
});

app.listen(port, () => {
  console.log(`Webhook handler listening at http://localhost:${port}`);
});
