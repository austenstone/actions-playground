/**
 * Object utility functions
 */

function deepClone(obj) {
  return JSON.parse(JSON.stringify(obj));
}

function merge(obj1, obj2) {
  return { ...obj1, ...obj2 };
}

function pick(obj, keys) {
  return keys.reduce((result, key) => {
    if (key in obj) result[key] = obj[key];
    return result;
  }, {});
}

function omit(obj, keys) {
  const result = { ...obj };
  keys.forEach(key => delete result[key]);
  return result;
}

module.exports = {
  deepClone,
  merge,
  pick,
  omit
};
