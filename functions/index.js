const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.checkThawaniPayment = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Authentication required.'
    );
  }

  const sessionId = (data && data.sessionId ? String(data.sessionId) : '').trim();
  if (!sessionId) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Missing sessionId.'
    );
  }

  const secret =
    (functions.config().thawani && functions.config().thawani.secret) ||
    process.env.THAWANI_SECRET;
  const baseUrl =
    (functions.config().thawani && functions.config().thawani.base_url) ||
    process.env.THAWANI_BASE_URL;

  if (!secret || !baseUrl) {
    throw new functions.https.HttpsError(
      'failed-precondition',
      'Thawani config missing. Set thawani.secret and thawani.base_url.'
    );
  }

  const url = `${baseUrl.replace(/\/$/, '')}/api/v1/checkout/session/${sessionId}`;
  const response = await fetch(url, {
    method: 'GET',
    headers: {
      'content-type': 'application/json',
      'thawani-api-key': secret,
      authorization: `Bearer ${secret}`
    }
  });

  const payload = await response.json().catch(() => ({}));
  if (!response.ok) {
    throw new functions.https.HttpsError(
      'unknown',
      payload && payload.message ? payload.message : 'Payment status check failed.'
    );
  }

  const rawStatus =
    (payload && payload.data && (payload.data.payment_status || payload.data.status)) ||
    (payload && payload.status) ||
    '';
  const normalized = String(rawStatus).toLowerCase();
  const status =
    normalized.includes('paid') ||
    normalized.includes('success') ||
    normalized.includes('captured')
      ? 'paid'
      : normalized.includes('pending') || normalized.includes('unpaid')
      ? 'pending'
      : normalized.includes('cancel') || normalized.includes('fail')
      ? 'failed'
      : normalized || 'unknown';

  return { status, rawStatus, sessionId };
});
