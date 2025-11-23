/**
 * Date utility functions
 */

function formatDate(dateStr, format = 'YYYY-MM-DD') {
  // Parse as UTC to avoid timezone issues
  const [year, month, day] = dateStr.split('-').map(Number);
  
  return format
    .replace('YYYY', year)
    .replace('MM', String(month).padStart(2, '0'))
    .replace('DD', String(day).padStart(2, '0'));
}

function daysBetween(date1, date2) {
  const d1 = new Date(date1);
  const d2 = new Date(date2);
  const diffTime = Math.abs(d2 - d1);
  return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
}

function isWeekend(dateStr) {
  // Parse as UTC to avoid timezone issues
  const d = new Date(dateStr + 'T00:00:00Z');
  const day = d.getUTCDay();
  return day === 0 || day === 6;
}

function addDays(dateStr, days) {
  // Parse as UTC to avoid timezone issues
  const d = new Date(dateStr + 'T00:00:00Z');
  d.setUTCDate(d.getUTCDate() + days);
  return d;
}

module.exports = {
  formatDate,
  daysBetween,
  isWeekend,
  addDays
};
