/**
 * Unit tests for date utilities
 */

const date = require('../../src/date');

describe('Date Operations', () => {
  describe('formatDate', () => {
    test('formats date in default format', () => {
      expect(date.formatDate('2024-03-15')).toBe('2024-03-15');
    });
    
    test('formats date in custom format', () => {
      expect(date.formatDate('2024-03-15', 'DD/MM/YYYY')).toBe('15/03/2024');
    });
  });
  
  describe('daysBetween', () => {
    test('calculates days between dates', () => {
      expect(date.daysBetween('2024-01-01', '2024-01-10')).toBe(9);
    });
    
    test('handles reversed dates', () => {
      expect(date.daysBetween('2024-01-10', '2024-01-01')).toBe(9);
    });
  });
  
  describe('isWeekend', () => {
    test('identifies weekends', () => {
      expect(date.isWeekend('2024-11-23')).toBe(true); // Saturday
      expect(date.isWeekend('2024-11-24')).toBe(true); // Sunday
    });
    
    test('identifies weekdays', () => {
      expect(date.isWeekend('2024-11-22')).toBe(false); // Friday
    });
  });
  
  describe('addDays', () => {
    test('adds days to date', () => {
      const result = date.addDays('2024-01-01', 5);
      expect(result.getUTCDate()).toBe(6);
    });
    
    test('handles negative days', () => {
      const result = date.addDays('2024-01-10', -5);
      expect(result.getUTCDate()).toBe(5);
    });
  });
});
