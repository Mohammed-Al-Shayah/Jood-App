// const functions = require('firebase-functions');
// const admin = require('firebase-admin');

// admin.initializeApp();

// exports.checkThawaniPayment = functions.https.onCall(async (data, context) => {
//   if (!context.auth) {
//     throw new functions.https.HttpsError(
//       'unauthenticated',
//       'Authentication required.'
//     );
//   }

//   const sessionId = (data && data.sessionId ? String(data.sessionId) : '').trim();
//   if (!sessionId) {
//     throw new functions.https.HttpsError(
//       'invalid-argument',
//       'Missing sessionId.'
//     );
//   }

//   const secret =
//     (functions.config().thawani && functions.config().thawani.secret) ||
//     process.env.THAWANI_SECRET;
//   const baseUrl =
//     (functions.config().thawani && functions.config().thawani.base_url) ||
//     process.env.THAWANI_BASE_URL;

//   if (!secret || !baseUrl) {
//     throw new functions.https.HttpsError(
//       'failed-precondition',
//       'Thawani config missing. Set thawani.secret and thawani.base_url.'
//     );
//   }

//   const url = `${baseUrl.replace(/\/$/, '')}/api/v1/checkout/session/${sessionId}`;
//   const response = await fetch(url, {
//     method: 'GET',
//     headers: {
//       'content-type': 'application/json',
//       'thawani-api-key': secret,
//       authorization: `Bearer ${secret}`
//     }
//   });

//   const payload = await response.json().catch(() => ({}));
//   if (!response.ok) {
//     throw new functions.https.HttpsError(
//       'unknown',
//       payload && payload.message ? payload.message : 'Payment status check failed.'
//     );
//   }

//   const rawStatus =
//     (payload && payload.data && (payload.data.payment_status || payload.data.status)) ||
//     (payload && payload.status) ||
//     '';
//   const normalized = String(rawStatus).toLowerCase();
//   const status =
//     normalized.includes('paid') ||
//     normalized.includes('success') ||
//     normalized.includes('captured')
//       ? 'paid'
//       : normalized.includes('pending') || normalized.includes('unpaid')
//       ? 'pending'
//       : normalized.includes('cancel') || normalized.includes('fail')
//       ? 'failed'
//       : normalized || 'unknown';

//   return { status, rawStatus, sessionId };
// });
const functions = require('firebase-functions');
const admin = require('firebase-admin');

// تأكد من تهيئة التطبيق مرة واحدة
if (admin.apps.length === 0) {
  admin.initializeApp();
}

exports.checkThawaniPayment = functions.https.onCall(async (data, context) => {
  // 1. طباعة البيانات الواصلة للتحقق
  console.log("🚀 START: checkThawaniPayment invoked");
  console.log("📦 INCOMING DATA:", JSON.stringify(data));
  console.log("👤 AUTH STATUS:", context.auth ? `User ID: ${context.auth.uid}` : "Unauthenticated");

  // التحقق من المصادقة
  if (!context.auth) {
    console.error("❌ ERROR: User not authenticated");
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Authentication required.'
    );
  }

  // استخراج Session ID
  const sessionId = (data && data.sessionId ? String(data.sessionId) : '').trim();
  console.log("🔑 PARSED SESSION ID:", sessionId);

  if (!sessionId) {
    console.error("❌ ERROR: Session ID is missing/empty");
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Missing sessionId.'
    );
  }

  // جلب الإعدادات
  const secret =
    (functions.config().thawani && functions.config().thawani.secret) ||
    process.env.THAWANI_SECRET;
  const baseUrl =
    (functions.config().thawani && functions.config().thawani.base_url) ||
    process.env.THAWANI_BASE_URL;

  // طباعة حالة الإعدادات (بدون طباعة السر نفسه للأمان)
  console.log("⚙️ CONFIG CHECK -> Secret exists:", !!secret, "| BaseURL exists:", !!baseUrl);

  if (!secret || !baseUrl) {
    console.error("❌ ERROR: Thawani configuration is missing on server");
    throw new functions.https.HttpsError(
      'failed-precondition',
      'Thawani config missing. Set thawani.secret and thawani.base_url.'
    );
  }

  // تجهيز الرابط
  // ملاحظة: تأكد أن الرابط لا ينتهي بـ / لتجنب التكرار //
  const cleanBaseUrl = baseUrl.replace(/\/$/, '');
  const url = `${cleanBaseUrl}/api/v1/checkout/session/${sessionId}`;
  
  console.log("ww CONNECTING TO:", url);

  try {
    const response = await fetch(url, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'thawani-api-key': secret
      }
    });

    const payload = await response.json().catch(() => ({}));
    console.log("📥 THAWANI RESPONSE STATUS:", response.status);
    console.log("📥 THAWANI PAYLOAD:", JSON.stringify(payload));

    if (!response.ok) {
      console.error("❌ THAWANI API ERROR:", payload);
      throw new functions.https.HttpsError(
        'unknown',
        payload && payload.description ? payload.description : 'Payment status check failed from Thawani.'
      );
    }

    // تحليل الحالة
    // ملاحظة: بعض الردود تحتوي على status = "success" على مستوى الـ API
    // وهذا لا يعني أن الدفع تم. نعتمد فقط على حالة الدفع داخل data.
    const rawStatus =
      (payload && payload.data && (payload.data.payment_status || payload.data.status)) ||
      '';
      
    const normalized = String(rawStatus).toLowerCase();
    
    let status = 'unknown';
    if (
      normalized.includes('unpaid') ||
      normalized.includes('pending') ||
      normalized.includes('created') ||
      normalized.includes('processing')
    ) {
      status = 'pending';
    } else if (
      normalized.includes('cancel') ||
      normalized.includes('canceled') ||
      normalized.includes('cancelled') ||
      normalized.includes('fail') ||
      normalized.includes('declined')
    ) {
      status = 'failed';
    } else if (
      normalized === 'paid' ||
      normalized === 'success' ||
      normalized === 'captured' ||
      normalized === 'succeeded'
    ) {
      status = 'paid';
    }

    console.log(`✅ FINAL RESULT: ID=${sessionId}, Status=${status}`);
    return { status, rawStatus, sessionId };

  } catch (error) {
    console.error("🔥 EXCEPTION:", error);
    // إعادة رمي الخطأ إذا كان من نوع HttpsError، وإلا تحويله لخطأ internal
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    throw new functions.https.HttpsError('internal', error.message);
  }
});

exports.deleteAccount = functions.https.onCall(async (data, context) => {
  console.log("🧨 START: deleteAccount invoked");
  if (!context.auth) {
    console.error("❌ ERROR: User not authenticated");
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Authentication required.'
    );
  }

  const uid = context.auth.uid;
  console.log("👤 Deleting account for UID:", uid);

  try {
    // 1) Delete Firestore user document + subcollections
    const userRef = admin.firestore().doc(`users/${uid}`);
    await admin.firestore().recursiveDelete(userRef);
    console.log("✅ Firestore user data deleted");

    // 2) Delete Storage files under users/{uid}/
    try {
      const bucket = admin.storage().bucket();
      await bucket.deleteFiles({ prefix: `users/${uid}/` });
      console.log("✅ Storage files deleted");
    } catch (storageError) {
      // Don't fail the whole process if storage cleanup fails
      console.warn("⚠️ Storage delete failed:", storageError.message);
    }

    // 3) Delete Auth user
    await admin.auth().deleteUser(uid);
    console.log("✅ Auth user deleted");

    return { ok: true };
  } catch (error) {
    console.error("🔥 deleteAccount failed:", error);
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    throw new functions.https.HttpsError(
      'internal',
      error.message || 'Delete account failed.'
    );
  }
});

function normalizePhone(phone) {
  const trimmed = String(phone || '').trim();
  if (!trimmed) return '';
  return trimmed.startsWith('+') ? trimmed : `+${trimmed}`;
}

function getTwilioVerifyConfig() {
  const cfg = (functions.config() && functions.config().twilio) || {};
  const accountSid = cfg.account_sid || process.env.TWILIO_ACCOUNT_SID;
  const authToken = cfg.auth_token || process.env.TWILIO_AUTH_TOKEN;
  const verifyServiceSid =
    cfg.verify_service_sid || process.env.TWILIO_VERIFY_SERVICE_SID;

  if (!accountSid || !authToken || !verifyServiceSid) {
    throw new functions.https.HttpsError(
      'failed-precondition',
      'Twilio Verify config missing. Set twilio.account_sid, twilio.auth_token, twilio.verify_service_sid.'
    );
  }

  return { accountSid, authToken, verifyServiceSid };
}

async function sendVerifyRequest({ accountSid, authToken, verifyServiceSid, phoneNumber }) {
  const url = `https://verify.twilio.com/v2/Services/${verifyServiceSid}/Verifications`;
  const payload = new URLSearchParams();
  payload.append('To', phoneNumber);
  payload.append('Channel', 'sms');

  const auth = Buffer.from(`${accountSid}:${authToken}`).toString('base64');
  const response = await fetch(url, {
    method: 'POST',
    headers: {
      Authorization: `Basic ${auth}`,
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: payload.toString(),
  });

  const data = await response.json().catch(() => ({}));
  if (!response.ok) {
    const message =
      data && data.message ? data.message : 'Failed to send verification code.';
    const status = Number(data && data.status) || response.status;
    const code = Number(data && data.code) || 0;
    throw mapTwilioErrorToHttpsError({ status, code, message });
  }

  return data;
}

async function checkVerifyRequest({
  accountSid,
  authToken,
  verifyServiceSid,
  phoneNumber,
  code,
}) {
  const url = `https://verify.twilio.com/v2/Services/${verifyServiceSid}/VerificationCheck`;
  const payload = new URLSearchParams();
  payload.append('To', phoneNumber);
  payload.append('Code', code);

  const auth = Buffer.from(`${accountSid}:${authToken}`).toString('base64');
  const response = await fetch(url, {
    method: 'POST',
    headers: {
      Authorization: `Basic ${auth}`,
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: payload.toString(),
  });

  const data = await response.json().catch(() => ({}));
  if (!response.ok) {
    const message =
      data && data.message ? data.message : 'Failed to verify code.';
    const status = Number(data && data.status) || response.status;
    const twilioCode = Number(data && data.code) || 0;
    throw mapTwilioErrorToHttpsError({ status, code: twilioCode, message });
  }

  if (String(data && data.status).toLowerCase() !== 'approved') {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Invalid verification code.'
    );
  }

  return data;
}

function mapTwilioErrorToHttpsError({ status, code, message }) {
  if (status === 429 || code === 60203 || code === 20429) {
    return new functions.https.HttpsError(
      'resource-exhausted',
      'Too many verification attempts. Please try again later.'
    );
  }

  if (code === 60202) {
    return new functions.https.HttpsError(
      'resource-exhausted',
      'Please wait before requesting another code.'
    );
  }

  if (code === 60200 || code === 60214 || code === 21211) {
    return new functions.https.HttpsError(
      'invalid-argument',
      message || 'Invalid phone number.'
    );
  }

  if (code === 60212 || code === 60213 || code === 20404) {
    return new functions.https.HttpsError(
      'deadline-exceeded',
      'Verification code expired. Please request a new code.'
    );
  }

  if (code === 60207 || code === 60208 || code === 20404) {
    return new functions.https.HttpsError(
      'permission-denied',
      'Invalid verification code.'
    );
  }

  if (status >= 500) {
    return new functions.https.HttpsError(
      'internal',
      message || 'Twilio Verify request failed.'
    );
  }

  return new functions.https.HttpsError(
    'failed-precondition',
    message || 'Twilio Verify request failed.'
  );
}

exports.sendSmsOtp = functions.https.onCall(async (data, context) => {
  const phoneNumber = normalizePhone(data && data.phoneNumber);
  const mode = (data && data.mode ? String(data.mode) : 'auth').trim();
  if (!phoneNumber) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing phoneNumber.');
  }

  if (mode === 'update_phone' && !context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Authentication required.'
    );
  }

  const twilio = getTwilioVerifyConfig();
  const verification = await sendVerifyRequest({
    accountSid: twilio.accountSid,
    authToken: twilio.authToken,
    verifyServiceSid: twilio.verifyServiceSid,
    phoneNumber,
  });

  return {
    verificationId: verification.sid || phoneNumber,
    status: verification.status || 'pending',
  };
});

exports.verifySmsOtp = functions.https.onCall(async (data, context) => {
  const verificationId = String(data && data.verificationId ? data.verificationId : '').trim();
  const code = String(data && data.code ? data.code : '').trim();
  const mode = (data && data.mode ? String(data.mode) : 'auth').trim();
  const requestedPhone = normalizePhone(data && data.phoneNumber);

  if (!verificationId || !code || !requestedPhone) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Missing verificationId, phoneNumber, or code.'
    );
  }

  const phoneNumber = requestedPhone;
  const twilio = getTwilioVerifyConfig();
  await checkVerifyRequest({
    accountSid: twilio.accountSid,
    authToken: twilio.authToken,
    verifyServiceSid: twilio.verifyServiceSid,
    phoneNumber,
    code,
  });

  if (mode === 'update_phone') {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'Authentication required.');
    }
    await admin.auth().updateUser(context.auth.uid, { phoneNumber });
    return { ok: true };
  }

  let user;
  try {
    user = await admin.auth().getUserByPhoneNumber(phoneNumber);
  } catch (error) {
    if (error && error.code === 'auth/user-not-found') {
      user = await admin.auth().createUser({ phoneNumber });
    } else {
      throw new functions.https.HttpsError('internal', 'Failed to fetch user.');
    }
  }

  const customToken = await admin.auth().createCustomToken(user.uid, {
    phoneNumber,
  });
  return { customToken, uid: user.uid };
});
