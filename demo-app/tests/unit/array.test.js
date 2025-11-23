/**
 * Unit tests for array utilities
 */

const array = require('../../src/array');

describe('Array Operations', () => {
  describe('unique', () => {
    test('removes duplicates', () => {
      expect(array.unique([1, 2, 2, 3, 3, 3])).toEqual([1, 2, 3]);
    });
    
    test('handles empty array', () => {
      expect(array.unique([])).toEqual([]);
    });
    
    test('preserves strings', () => {
      expect(array.unique(['a', 'b', 'a', 'c'])).toEqual(['a', 'b', 'c']);
    });
  });
  
  describe('flatten', () => {
    test('flattens nested arrays', () => {
      expect(array.flatten([1, [2, [3, 4]], 5])).toEqual([1, 2, 3, 4, 5]);
    });
    
    test('handles already flat arrays', () => {
      expect(array.flatten([1, 2, 3])).toEqual([1, 2, 3]);
    });
  });
  
  describe('chunk', () => {
    test('chunks array into groups', () => {
      expect(array.chunk([1, 2, 3, 4, 5], 2)).toEqual([[1, 2], [3, 4], [5]]);
    });
    
    test('handles exact divisions', () => {
      expect(array.chunk([1, 2, 3, 4], 2)).toEqual([[1, 2], [3, 4]]);
    });
  });
  
  describe('sum', () => {
    test('sums array of numbers', () => {
      expect(array.sum([1, 2, 3, 4, 5])).toBe(15);
    });
    
    test('handles empty array', () => {
      expect(array.sum([])).toBe(0);
    });
  });
  
  describe('average', () => {
    test('calculates average', () => {
      expect(array.average([10, 20, 30])).toBe(20);
    });
    
    test('handles empty array', () => {
      expect(array.average([])).toBe(0);
    });
  });
});
