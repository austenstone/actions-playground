/**
 * Array utility functions
 */

function unique(arr) {
  return [...new Set(arr)];
}

function flatten(arr) {
  return arr.reduce((flat, item) => 
    flat.concat(Array.isArray(item) ? flatten(item) : item), []);
}

function chunk(arr, size) {
  const chunks = [];
  for (let i = 0; i < arr.length; i += size) {
    chunks.push(arr.slice(i, i + size));
  }
  return chunks;
}

function sum(arr) {
  return arr.reduce((total, num) => total + num, 0);
}

function average(arr) {
  if (arr.length === 0) return 0;
  return sum(arr) / arr.length;
}

module.exports = {
  unique,
  flatten,
  chunk,
  sum,
  average
};
