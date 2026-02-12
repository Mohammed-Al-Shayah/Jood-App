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
