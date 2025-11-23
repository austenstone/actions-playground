/**
 * Number utility functions
 */

function clamp(num, min, max) {
  return Math.min(Math.max(num, min), max);
}

function random(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function percentage(value, total) {
  if (total === 0) return 0;
  return (value / total) * 100;
}

function round(num, decimals = 0) {
  const factor = Math.pow(10, decimals);
  return Math.round(num * factor) / factor;
}

module.exports = {
  clamp,
  random,
  percentage,
  round
};
