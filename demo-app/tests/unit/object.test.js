/**
 * Unit tests for object utilities
 */

const object = require('../../src/object');

describe('Object Operations', () => {
  describe('deepClone', () => {
    test('creates deep copy', () => {
      const original = { a: 1, b: { c: 2 } };
      const cloned = object.deepClone(original);
      cloned.b.c = 3;
      expect(original.b.c).toBe(2);
    });
  });
  
  describe('merge', () => {
    test('merges two objects', () => {
      expect(object.merge({ a: 1 }, { b: 2 })).toEqual({ a: 1, b: 2 });
    });
    
    test('overwrites existing keys', () => {
      expect(object.merge({ a: 1 }, { a: 2 })).toEqual({ a: 2 });
    });
  });
  
  describe('pick', () => {
    test('picks specified keys', () => {
      const obj = { a: 1, b: 2, c: 3 };
      expect(object.pick(obj, ['a', 'c'])).toEqual({ a: 1, c: 3 });
    });
    
    test('ignores missing keys', () => {
      const obj = { a: 1 };
      expect(object.pick(obj, ['a', 'b'])).toEqual({ a: 1 });
    });
  });
  
  describe('omit', () => {
    test('omits specified keys', () => {
      const obj = { a: 1, b: 2, c: 3 };
      expect(object.omit(obj, ['b'])).toEqual({ a: 1, c: 3 });
    });
  });
});
