/**
 * Unit tests for number utilities
 */

const number = require('../../src/number');

describe('Number Operations', () => {
  describe('clamp', () => {
    test('clamps value within range', () => {
      expect(number.clamp(15, 0, 10)).toBe(10);
      expect(number.clamp(-5, 0, 10)).toBe(0);
      expect(number.clamp(5, 0, 10)).toBe(5);
    });
  });
  
  describe('random', () => {
    test('generates number within range', () => {
      const result = number.random(1, 10);
      expect(result).toBeGreaterThanOrEqual(1);
      expect(result).toBeLessThanOrEqual(10);
    });
  });
  
  describe('percentage', () => {
    test('calculates percentage', () => {
      expect(number.percentage(25, 100)).toBe(25);
      expect(number.percentage(50, 200)).toBe(25);
    });
    
    test('handles zero total', () => {
      expect(number.percentage(10, 0)).toBe(0);
    });
  });
  
  describe('round', () => {
    test('rounds to specified decimals', () => {
      expect(number.round(3.14159, 2)).toBe(3.14);
      expect(number.round(3.14159, 0)).toBe(3);
    });
  });
});
