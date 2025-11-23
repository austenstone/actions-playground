/**
 * Unit tests for string utilities
 */

const string = require('../../src/string');

describe('String Operations', () => {
  describe('capitalize', () => {
    test('capitalizes first letter', () => {
      expect(string.capitalize('hello')).toBe('Hello');
    });
    
    test('handles empty string', () => {
      expect(string.capitalize('')).toBe('');
    });
    
    test('converts rest to lowercase', () => {
      expect(string.capitalize('hELLO')).toBe('Hello');
    });
  });
  
  describe('reverse', () => {
    test('reverses a string', () => {
      expect(string.reverse('hello')).toBe('olleh');
    });
    
    test('handles single character', () => {
      expect(string.reverse('a')).toBe('a');
    });
  });
  
  describe('isPalindrome', () => {
    test('detects palindromes', () => {
      expect(string.isPalindrome('racecar')).toBe(true);
    });
    
    test('handles non-palindromes', () => {
      expect(string.isPalindrome('hello')).toBe(false);
    });
    
    test('ignores case and spaces', () => {
      expect(string.isPalindrome('A man a plan a canal Panama')).toBe(true);
    });
  });
  
  describe('truncate', () => {
    test('truncates long strings', () => {
      expect(string.truncate('This is a very long string', 10)).toBe('This is...');
    });
    
    test('leaves short strings unchanged', () => {
      expect(string.truncate('Short', 10)).toBe('Short');
    });
  });
});
