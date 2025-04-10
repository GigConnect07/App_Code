// functions/index.js
exports.sendJobNotification = functions.firestore
  .document('applications/{appId}')
  .onCreate(async (snap, context) => {
    const application = snap.data();
    const recruiterToken = await getRecruiterToken(application.recruiterId);

    return admin.messaging().send({
      token: recruiterToken,
      notification: {
        title: 'New Application Received',
        body: `${application.applicantName} applied for ${application.jobTitle}`
      }
    });
  });