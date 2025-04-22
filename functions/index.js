const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// Cloud Firestore triggers ref: https://firebase.google.com/docs/functions/firestore-events
exports.myFunction = functions.firestore
  .document(
    "chat_rooms/dtc.ismaik@gmail.com-firashedfi200@gmail.com/messages/{messageId}"
  )
  .onCreate((snapshot, context) => {
    // Return this function's promise, so this ensures the firebase function
    // will keep running, until the notification is scheduled.
    return admin.messaging().send({
      // Sending a notification message.
      notification: {
        title: snapshot.data()["senderUsername"],
        body: snapshot.data()["text"],
        imageUrl: snapshot.data()["senderProfilePicture"],
      },
      data: {
        // Data payload to be sent to the device.
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
      topic: "chat",
    });
  });
