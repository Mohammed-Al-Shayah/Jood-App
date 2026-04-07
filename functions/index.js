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
const crypto = require('crypto');
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

const OTP_RATE_LIMITS_COLLECTION = 'otpRateLimits';
const DEFAULT_OTP_RESEND_COOLDOWN_SECONDS = 60;
const DEFAULT_OTP_PHONE_LIMIT = 3;
const DEFAULT_OTP_PHONE_WINDOW_SECONDS = 600;
const DEFAULT_OTP_DEVICE_LIMIT = 5;
const DEFAULT_OTP_DEVICE_WINDOW_SECONDS = 600;
const DEFAULT_OTP_UID_LIMIT = 5;
const DEFAULT_OTP_UID_WINDOW_SECONDS = 600;
const DEFAULT_OTP_IP_LIMIT = 20;
const DEFAULT_OTP_IP_WINDOW_SECONDS = 600;
const DEFAULT_OTP_COUNTRY_LIMIT = 5;
const DEFAULT_OTP_COUNTRY_WINDOW_SECONDS = 60;
const GLOBAL_COUNTRY_CALLING_CODES = Object.freeze([
  '+998', '+996', '+995', '+994', '+993', '+992', '+977', '+976', '+975',
  '+974', '+973', '+972', '+971', '+970', '+968', '+967', '+966', '+965',
  '+964', '+963', '+962', '+961', '+960', '+886', '+856', '+855', '+853',
  '+852', '+850', '+692', '+691', '+690', '+689', '+688', '+687', '+686',
  '+685', '+683', '+682', '+681', '+680', '+679', '+678', '+677', '+676',
  '+675', '+674', '+673', '+672', '+670', '+599', '+598', '+597', '+596',
  '+595', '+594', '+593', '+592', '+591', '+590', '+509', '+508', '+507',
  '+506', '+505', '+504', '+503', '+502', '+501', '+500', '+423', '+421',
  '+420', '+389', '+387', '+386', '+385', '+383', '+382', '+381', '+380',
  '+378', '+377', '+376', '+375', '+374', '+373', '+372', '+371', '+370',
  '+359', '+358', '+357', '+356', '+355', '+354', '+353', '+352', '+351',
  '+350', '+299', '+298', '+297', '+291', '+290', '+269', '+268', '+267',
  '+266', '+265', '+264', '+263', '+262', '+261', '+260', '+258', '+257',
  '+256', '+255', '+254', '+253', '+252', '+251', '+250', '+249', '+248',
  '+247', '+246', '+245', '+244', '+243', '+242', '+241', '+240', '+239',
  '+238', '+237', '+236', '+235', '+234', '+233', '+232', '+231', '+230',
  '+229', '+228', '+227', '+226', '+225', '+224', '+223', '+222', '+221',
  '+220', '+218', '+216', '+213', '+212', '+211', '+98', '+95', '+94',
  '+93', '+92', '+91', '+90', '+89', '+88', '+86', '+84', '+82', '+81',
  '+66', '+65', '+64', '+63', '+62', '+61', '+60', '+58', '+57', '+56',
  '+55', '+54', '+53', '+52', '+51', '+49', '+48', '+47', '+46', '+45',
  '+44', '+43', '+41', '+40', '+39', '+36', '+34', '+33', '+32', '+31',
  '+30', '+27', '+20', '+7', '+1', '+800', '+808', '+870', '+878', '+879',
  '+881', '+882', '+883', '+888', '+979'
]);

function parsePositiveInt(value, fallback) {
  const parsed = Number.parseInt(String(value ?? '').trim(), 10);
  return Number.isFinite(parsed) && parsed > 0 ? parsed : fallback;
}

function normalizeCountryCode(code) {
  const digits = String(code || '').replace(/\D/g, '');
  return digits ? `+${digits}` : '';
}

function parseCountryCodeList(value) {
  if (String(value || '').trim() === '*') {
    return ['*'];
  }

  return Array.from(
    new Set(
      String(value || '')
        .split(',')
        .map((entry) => normalizeCountryCode(entry))
        .filter(Boolean)
        .sort((left, right) => right.length - left.length)
    )
  );
}

function parseBooleanFlag(value) {
  const normalized = String(value || '').trim().toLowerCase();
  return normalized === 'true' || normalized === '1' || normalized === 'yes';
}

function normalizeDeviceId(value) {
  const normalized = String(value || '').trim().replace(/\s+/g, '');
  if (!normalized) return '';
  return normalized.slice(0, 256);
}

function getOtpSecurityConfig() {
  const cfg = (functions.config() && functions.config().otp) || {};
  const configuredCountryCodes = parseCountryCodeList(
    cfg.allowed_country_codes || process.env.OTP_ALLOWED_COUNTRY_CODES
  );
  const allowAllCountries =
    configuredCountryCodes.includes('*') ||
    parseBooleanFlag(cfg.allow_all_countries || process.env.OTP_ALLOW_ALL_COUNTRIES);
  const allowedCountryCodes = allowAllCountries ? [] : configuredCountryCodes;

  if (!allowAllCountries && !allowedCountryCodes.length) {
    throw new functions.https.HttpsError(
      'failed-precondition',
      'OTP allowed country codes are not configured.'
    );
  }

  return {
    allowAllCountries,
    allowedCountryCodes,
    resendCooldownSeconds: parsePositiveInt(
      cfg.resend_cooldown_seconds || process.env.OTP_RESEND_COOLDOWN_SECONDS,
      DEFAULT_OTP_RESEND_COOLDOWN_SECONDS
    ),
    phoneLimit: parsePositiveInt(
      cfg.phone_limit || process.env.OTP_PHONE_LIMIT,
      DEFAULT_OTP_PHONE_LIMIT
    ),
    phoneWindowSeconds: parsePositiveInt(
      cfg.phone_window_seconds || process.env.OTP_PHONE_WINDOW_SECONDS,
      DEFAULT_OTP_PHONE_WINDOW_SECONDS
    ),
    deviceLimit: parsePositiveInt(
      cfg.device_limit || process.env.OTP_DEVICE_LIMIT,
      DEFAULT_OTP_DEVICE_LIMIT
    ),
    deviceWindowSeconds: parsePositiveInt(
      cfg.device_window_seconds || process.env.OTP_DEVICE_WINDOW_SECONDS,
      DEFAULT_OTP_DEVICE_WINDOW_SECONDS
    ),
    uidLimit: parsePositiveInt(
      cfg.uid_limit || process.env.OTP_UID_LIMIT,
      DEFAULT_OTP_UID_LIMIT
    ),
    uidWindowSeconds: parsePositiveInt(
      cfg.uid_window_seconds || process.env.OTP_UID_WINDOW_SECONDS,
      DEFAULT_OTP_UID_WINDOW_SECONDS
    ),
    ipLimit: parsePositiveInt(
      cfg.ip_limit || process.env.OTP_IP_LIMIT,
      DEFAULT_OTP_IP_LIMIT
    ),
    ipWindowSeconds: parsePositiveInt(
      cfg.ip_window_seconds || process.env.OTP_IP_WINDOW_SECONDS,
      DEFAULT_OTP_IP_WINDOW_SECONDS
    ),
    countryLimit: parsePositiveInt(
      cfg.country_limit || process.env.OTP_COUNTRY_LIMIT,
      DEFAULT_OTP_COUNTRY_LIMIT
    ),
    countryWindowSeconds: parsePositiveInt(
      cfg.country_window_seconds || process.env.OTP_COUNTRY_WINDOW_SECONDS,
      DEFAULT_OTP_COUNTRY_WINDOW_SECONDS
    ),
  };
}

function shouldEnforceOtpAppCheck() {
  const cfg = (functions.config() && functions.config().otp) || {};
  const rawValue = cfg.enforce_app_check || process.env.OTP_ENFORCE_APP_CHECK;
  if (rawValue === undefined || rawValue === null || String(rawValue).trim() === '') {
    return false;
  }
  return parseBooleanFlag(rawValue);
}

function extractCountryCode(phoneNumber, config) {
  const source = config.allowAllCountries
    ? GLOBAL_COUNTRY_CALLING_CODES
    : config.allowedCountryCodes;

  return source.find((countryCode) => phoneNumber.startsWith(countryCode)) || '';
}

function getClientIp(rawRequest) {
  if (!rawRequest) return '';

  const forwardedFor = rawRequest.headers && rawRequest.headers['x-forwarded-for'];
  if (Array.isArray(forwardedFor) && forwardedFor.length) {
    return String(forwardedFor[0] || '').split(',')[0].trim();
  }

  if (typeof forwardedFor === 'string' && forwardedFor.trim()) {
    return forwardedFor.split(',')[0].trim();
  }

  return String(
    rawRequest.ip ||
      (rawRequest.connection && rawRequest.connection.remoteAddress) ||
      (rawRequest.socket && rawRequest.socket.remoteAddress) ||
      ''
  ).trim();
}

function getRateLimitDocRef(scope, key) {
  const hash = crypto
    .createHash('sha256')
    .update(`${scope}:${String(key || '').trim()}`)
    .digest('hex');
  return admin.firestore().collection(OTP_RATE_LIMITS_COLLECTION).doc(`${scope}_${hash}`);
}

function toMillis(value) {
  if (typeof value === 'number' && Number.isFinite(value)) {
    return value;
  }

  if (value && typeof value.toMillis === 'function') {
    return value.toMillis();
  }

  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : 0;
}

function getRecentAttempts(attempts, nowMs, windowMs) {
  const cutoff = nowMs - windowMs;
  return Array.isArray(attempts)
    ? attempts.map((entry) => toMillis(entry)).filter((entry) => entry > cutoff)
    : [];
}

async function assertOtpSendAllowed({
  phoneNumber,
  deviceId,
  uid,
  ip,
  countryCode,
  config,
}) {
  const nowMs = Date.now();
  const now = admin.firestore.Timestamp.fromMillis(nowMs);
  const scopes = [
    {
      scope: 'cooldown',
      key: phoneNumber,
      limit: 1,
      windowSeconds: config.resendCooldownSeconds,
      message: 'Please wait before requesting another verification code.',
      reason: 'cooldown',
    },
    {
      scope: 'phone',
      key: phoneNumber,
      limit: config.phoneLimit,
      windowSeconds: config.phoneWindowSeconds,
      message: 'Too many OTP requests for this phone number. Please try again later.',
      reason: 'phone-rate-limit',
    },
    {
      scope: 'device',
      key: deviceId,
      limit: config.deviceLimit,
      windowSeconds: config.deviceWindowSeconds,
      message: 'Too many OTP requests from this device. Please try again later.',
      reason: 'device-rate-limit',
    },
    {
      scope: 'uid',
      key: uid,
      limit: config.uidLimit,
      windowSeconds: config.uidWindowSeconds,
      message: 'Too many OTP requests for this account. Please try again later.',
      reason: 'user-rate-limit',
    },
    {
      scope: 'ip',
      key: ip,
      limit: config.ipLimit,
      windowSeconds: config.ipWindowSeconds,
      message: 'Too many OTP requests from this network. Please try again later.',
      reason: 'ip-rate-limit',
    },
    {
      scope: 'country',
      key: countryCode,
      limit: config.countryLimit,
      windowSeconds: config.countryWindowSeconds,
      message: `Too many OTP requests for ${countryCode}. Please try again later.`,
      reason: 'country-rate-limit',
    },
  ].filter((entry) => entry.key && entry.limit > 0 && entry.windowSeconds > 0);

  await admin.firestore().runTransaction(async (transaction) => {
    for (const entry of scopes) {
      const windowMs = entry.windowSeconds * 1000;
      const ref = getRateLimitDocRef(entry.scope, entry.key);
      const snapshot = await transaction.get(ref);
      const attempts = getRecentAttempts(
        snapshot.exists ? snapshot.get('attempts') : [],
        nowMs,
        windowMs
      );

      if (attempts.length >= entry.limit) {
        const earliestActiveAttempt = attempts[0];
        const retryAfterSeconds = Math.max(
          1,
          Math.ceil((earliestActiveAttempt + windowMs - nowMs) / 1000)
        );

        throw new functions.https.HttpsError('resource-exhausted', entry.message, {
          reason: entry.reason,
          scope: entry.scope,
          retryAfterSeconds,
          countryCode,
          cooldownSeconds: config.resendCooldownSeconds,
        });
      }

      attempts.push(nowMs);
      transaction.set(
        ref,
        {
          scope: entry.scope,
          attempts,
          updatedAt: now,
          expiresAt: admin.firestore.Timestamp.fromMillis(nowMs + windowMs),
        },
        { merge: true }
      );
    }
  });
}

function validateOtpSendRequest({ data, context, config }) {
  const phoneNumber = normalizePhone(data && data.phoneNumber);
  const mode = (data && data.mode ? String(data.mode) : 'auth').trim();
  const deviceId = normalizeDeviceId(data && data.deviceId);
  const uid = context.auth ? String(context.auth.uid || '').trim() : '';
  const ip = getClientIp(context.rawRequest);

  if (!phoneNumber) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing phoneNumber.');
  }

  if (mode === 'update_phone' && !context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Authentication required.'
    );
  }

  const countryCode = extractCountryCode(phoneNumber, config);
  if (!countryCode) {
    throw new functions.https.HttpsError(
      config.allowAllCountries ? 'invalid-argument' : 'failed-precondition',
      config.allowAllCountries
        ? 'Invalid or unsupported phone country code.'
        : 'OTP is available only for supported country codes.',
      {
        reason: config.allowAllCountries
          ? 'invalid-country-code'
          : 'unsupported-country',
      }
    );
  }

  return {
    phoneNumber,
    mode,
    deviceId,
    uid,
    ip,
    countryCode,
  };
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

exports.sendSmsOtp = functions
  .runWith({ enforceAppCheck: shouldEnforceOtpAppCheck() })
  .https.onCall(async (data, context) => {
  const config = getOtpSecurityConfig();
  const request = validateOtpSendRequest({ data, context, config });
  await assertOtpSendAllowed({
    phoneNumber: request.phoneNumber,
    deviceId: request.deviceId,
    uid: request.uid,
    ip: request.ip,
    countryCode: request.countryCode,
    config,
  });

  const twilio = getTwilioVerifyConfig();
  const verification = await sendVerifyRequest({
    accountSid: twilio.accountSid,
    authToken: twilio.authToken,
    verifyServiceSid: twilio.verifyServiceSid,
    phoneNumber: request.phoneNumber,
  });

  return {
    verificationId: verification.sid || request.phoneNumber,
    status: verification.status || 'pending',
    cooldownSeconds: config.resendCooldownSeconds,
    countryCode: request.countryCode,
  };
});

exports.verifySmsOtp = functions
  .runWith({ enforceAppCheck: shouldEnforceOtpAppCheck() })
  .https.onCall(async (data, context) => {
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
