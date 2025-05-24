const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { getFirestore } = require("firebase-admin/firestore");

admin.initializeApp();

// Delete expired posts
// This function deletes posts older than the current date
exports.deleteExpiredPosts = onSchedule(
  {
    schedule: "0 7 * * *", // At minute 0, hour 7, every day
    timeZone: "Africa/Tunis", // Tunisia timezone
  },
  async (event) => {
    const db = getFirestore();
    const now = new Date();

    const snapshot = await db
      .collection("annonces")
      .where("date", "<", now)
      .get();

    const batch = db.batch();

    snapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });

    await batch.commit();
    console.log(`${snapshot.size} expired posts deleted.`);
  }
);

// Import and export user management routes from adminFunctions.js
const { userManagement } = require('./adminFunctions');
exports.userManagement = userManagement;
