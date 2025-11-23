/**
 * Validation utility functions
 */

function isEmail(email) {
  const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return regex.test(email);
}

function isPhone(phone) {
  const regex = /^\+?[\d\s\-()]+$/;
  return regex.test(phone) && phone.replace(/\D/g, '').length >= 10;
}

function isUrl(url) {
  try {
    new URL(url);
    return true;
  } catch {
    return false;
  }
}

function isStrongPassword(password) {
  if (password.length < 8) return false;
  if (!/[A-Z]/.test(password)) return false;
  if (!/[a-z]/.test(password)) return false;
  if (!/[0-9]/.test(password)) return false;
  return true;
}

module.exports = {
  isEmail,
  isPhone,
  isUrl,
  isStrongPassword
};
