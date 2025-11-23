/**
 * Unit tests for math utilities
 */

const math = require('../../src/math');

describe('Math Operations', () => {
  describe('add', () => {
    test('adds two positive numbers', () => {
      expect(math.add(2, 3)).toBe(5);
    });
    
    test('adds positive and negative numbers', () => {
      expect(math.add(5, -3)).toBe(2);
    });
    
    test('adds zero', () => {
      expect(math.add(10, 0)).toBe(10);
    });
  });
  
  describe('multiply', () => {
    test('multiplies two positive numbers', () => {
      expect(math.multiply(3, 4)).toBe(12);
    });
    
    test('multiplies by zero', () => {
      expect(math.multiply(5, 0)).toBe(0);
    });
    
    test('multiplies negative numbers', () => {
      expect(math.multiply(-2, -3)).toBe(6);
    });
  });
  
  describe('divide', () => {
    test('divides two numbers', () => {
      expect(math.divide(10, 2)).toBe(5);
    });
    
    test('throws error on division by zero', () => {
      expect(() => math.divide(10, 0)).toThrow('Division by zero');
    });
    
    test('divides negative numbers', () => {
      expect(math.divide(-10, 2)).toBe(-5);
    });
  });
  
  describe('subtract', () => {
    test('subtracts two numbers', () => {
      expect(math.subtract(10, 3)).toBe(7);
    });
    
    test('subtracts negative numbers', () => {
      expect(math.subtract(5, -3)).toBe(8);
    });
  });
});
