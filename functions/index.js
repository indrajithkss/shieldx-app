const { onValueUpdated } = require("firebase-functions/v2/database");
const admin = require("firebase-admin");
const twilio = require("twilio");

admin.initializeApp();

// 🔥 ADD YOUR TWILIO KEYS
const client = twilio("TWILIO_SID","TWILIO_TOKEN");
exports.sendEmergencySMS = onValueUpdated(
  {
    ref: "/deviceData/accident",
    region: "asia-southeast1"
  },
  async (event) => {
  const accident = event.data.after.val();

  if (accident !== true) return;

  console.log("🚨 Accident detected!");

  const db = admin.database();

  const deviceSnap = await db.ref("/deviceData").once("value");
  const device = deviceSnap.val();

  const lat = device.latitude;
  const lng = device.longitude;

  const usersSnap = await db.ref("/users").once("value");
  const users = usersSnap.val();

  for (const uid in users) {

    const profile = users[uid].profile || {};
    const contacts = users[uid].contacts || {};

    const name = profile.fullName || "Rider";
    const blood = profile.bloodGroup || "N/A";
    const medical = profile.medicalDescription || "N/A";

   const message = `
🚨 SHIELDX ALERT 🚨
Rider: ${name}
Blood Group: ${blood}
Condition: ${medical}

Location:
https://maps.google.com/?q=${lat},${lng}
`;

const userSettingsSnap = await db
  .ref(`/users/${uid}/settings/smsAlerts`)
  .once("value");

const smsEnabled = userSettingsSnap.val() ?? true;

    for (const key in contacts) {
      const phone = contacts[key].phone;

      // ✅ ADD THIS CONDITION (IMPORTANT)
  if (smsEnabled === false) {
    console.log("🚫 SMS DISABLED FROM APP");
    continue; // skip sending
  }

      try {
        await client.messages.create({
          body: message,
          from: "+12602523265",
          to: phone,
        });

        console.log("SMS sent to:", phone);

      } catch (err) {
        console.error("SMS failed:", err);
      }
    }
  }
});