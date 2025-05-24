const functions = require("firebase-functions");
const admin = require("firebase-admin");
const express = require("express");
const cors = require("cors");

// Initialize Firebase Admin if not already initialized
if (!admin.apps.length) {
  admin.initializeApp();
}

const app = express();
app.use(cors({ origin: true }));
app.use(express.json());

app.post("/disableUser", async (req, res) => {
  const uid = req.body.uid;
  if (typeof uid !== "string" || uid.trim() === "" || uid.length > 128) {
    return res.status(400).json({ error: "Invalid UID" });
  }

  try {
    await admin.auth().updateUser(uid, { disabled: true });
    res.json({ success: true });
  } catch (error) {
    console.error("Disable user error:", error.message);
    res.status(500).json({ error: error.message });
  }
});

app.post("/enableUser", async (req, res) => {
  const uid = req.body.uid;
  if (typeof uid !== "string" || uid.trim() === "" || uid.length > 128) {
    return res.status(400).json({ error: "Invalid UID" });
  }

  try {
    await admin.auth().updateUser(uid, { disabled: false });
    res.json({ success: true });
  } catch (error) {
    console.error("Enable user error:", error.message);
    res.status(500).json({ error: error.message });
  }
});

exports.userManagement = functions.https.onRequest(app);
