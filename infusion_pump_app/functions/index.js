/**
 * Firebase Cloud Functions for Infusion Pump FCM Push Notifications.
 *
 * This function triggers whenever any alarm value changes in the
 * Firebase Realtime Database and sends a push notification to the
 * user's device via FCM.
 *
 * SETUP:
 * 1. cd functions
 * 2. npm install
 * 3. firebase deploy --only functions
 *
 * NOTE: You need to store the device FCM token at /users/{userId}/fcmToken
 * The Flutter app should write its token there on startup.
 */

const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const ALARM_LABELS = {
  occlusion: {
    title: "Occlusion Detected",
    body: "Line blockage detected. Check IV tubing immediately.",
  },
  bubble: {
    title: "Air Bubble Detected",
    body: "Air detected in the IV line. Infusion paused for safety.",
  },
  bagEmpty: {
    title: "Bag Empty",
    body: "IV bag is empty. Replace fluid bag.",
  },
  complete: {
    title: "Infusion Complete",
    body: "The prescribed infusion volume has been delivered.",
  },
};

/**
 * Trigger on any write to /alarms/{alarmType}.
 * Sends FCM push notification if alarm becomes true.
 */
exports.onAlarmTriggered = functions.database
  .ref("/alarms/{alarmType}")
  .onWrite(async (change, context) => {
    const alarmType = context.params.alarmType;
    const newValue = change.after.val();

    // Only send notification when alarm is triggered (becomes true)
    if (newValue !== true) {
      console.log(`Alarm ${alarmType} cleared or unchanged.`);
      return null;
    }

    const alarmInfo = ALARM_LABELS[alarmType];
    if (!alarmInfo) {
      console.log(`Unknown alarm type: ${alarmType}`);
      return null;
    }

    console.log(`ALARM TRIGGERED: ${alarmType}`);

    // Get all registered device tokens
    const tokensSnapshot = await admin
      .database()
      .ref("/users")
      .once("value");

    const users = tokensSnapshot.val();
    if (!users) {
      console.log("No registered users found.");
      return null;
    }

    const tokens = [];
    Object.keys(users).forEach((userId) => {
      if (users[userId].fcmToken) {
        tokens.push(users[userId].fcmToken);
      }
    });

    if (tokens.length === 0) {
      console.log("No FCM tokens found.");
      return null;
    }

    // Build the FCM message
    const message = {
      notification: {
        title: alarmInfo.title,
        body: alarmInfo.body,
      },
      data: {
        alarmType: alarmType,
        timestamp: new Date().toISOString(),
      },
      android: {
        priority: "high",
        notification: {
          channelId: alarmType === "complete" ? "info_channel" : "alarms_channel",
          priority: alarmType === "complete" ? "default" : "max",
          sound: "default",
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1,
          },
        },
      },
    };

    // Send to all registered devices
    const promises = tokens.map((token) => {
      return admin.messaging().send({ ...message, token: token })
        .catch((error) => {
          console.error(`Error sending to token ${token}:`, error);
          // Remove invalid tokens
          if (
            error.code === "messaging/invalid-registration-token" ||
            error.code === "messaging/registration-token-not-registered"
          ) {
            console.log(`Removing invalid token: ${token}`);
          }
        });
    });

    await Promise.all(promises);
    console.log(`Sent ${alarmType} notification to ${tokens.length} device(s).`);
    return null;
  });
