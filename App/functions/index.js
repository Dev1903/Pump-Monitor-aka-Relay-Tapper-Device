const { onValueWritten } = require("firebase-functions/v2/database");
const { initializeApp } = require("firebase-admin/app");
const { getMessaging } = require("firebase-admin/messaging");

// Initialize Firebase Admin SDK
initializeApp();

// Listen for changes to /switch/state in asia-southeast1
exports.notifyPumpState = onValueWritten(
  { ref: "/switch/state", region: "asia-southeast1" },
  async (event) => {
    const data = event.data.after.val();
    const stateText = data ? "ON" : "OFF";

    const payload = {
      notification: {
        title: "Pump State Changed",
        body: `Pump is now ${stateText}`,
      },
      topic: "all",
    };

    try {
      await getMessaging().send(payload);
      console.log("✅ Notification sent! Pump is now", stateText);
    } catch (error) {
      console.error("❌ Error sending notification:", error);
    }
  }
);
