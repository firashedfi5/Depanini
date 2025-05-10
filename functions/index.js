const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// Disable user
exports.setUserDisabledStatus = functions.https.onCall(
  async (data, context) => {
    // Optional: Add admin auth check here using context.auth.token
    const uid = data.uid;
    const disable = data.disable;

    if (!uid || typeof disable !== "boolean") {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Missing uid or disable flag."
      );
    }

    try {
      await admin.auth().updateUser(uid, { disabled: disable });
      return { success: true, status: disable ? "disabled" : "enabled" };
    } catch (error) {
      throw new functions.https.HttpsError("unknown", error.message);
    }
  }
);
