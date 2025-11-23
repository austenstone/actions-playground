/**
 * Unit tests for validation utilities
 */

const validation = require('../../src/validation');

describe('Validation Functions', () => {
  describe('isEmail', () => {
    test('validates correct emails', () => {
      expect(validation.isEmail('user@example.com')).toBe(true);
      expect(validation.isEmail('test.user@domain.co.uk')).toBe(true);
    });
    
    test('rejects invalid emails', () => {
      expect(validation.isEmail('invalid')).toBe(false);
      expect(validation.isEmail('no@domain')).toBe(false);
      expect(validation.isEmail('@domain.com')).toBe(false);
    });
  });
  
  describe('isPhone', () => {
    test('validates phone numbers', () => {
      expect(validation.isPhone('+1 (555) 123-4567')).toBe(true);
      expect(validation.isPhone('5551234567')).toBe(true);
    });
    
    test('rejects invalid phone numbers', () => {
      expect(validation.isPhone('123')).toBe(false);
      expect(validation.isPhone('abc')).toBe(false);
    });
  });
  
  describe('isUrl', () => {
    test('validates URLs', () => {
      expect(validation.isUrl('https://example.com')).toBe(true);
      expect(validation.isUrl('http://test.com/path')).toBe(true);
    });
    
    test('rejects invalid URLs', () => {
      expect(validation.isUrl('not a url')).toBe(false);
      expect(validation.isUrl('example.com')).toBe(false);
    });
  });
  
  describe('isStrongPassword', () => {
    test('validates strong passwords', () => {
      expect(validation.isStrongPassword('Strong123')).toBe(true);
      expect(validation.isStrongPassword('P@ssw0rd!')).toBe(true);
    });
    
    test('rejects weak passwords', () => {
      expect(validation.isStrongPassword('weak')).toBe(false);
      expect(validation.isStrongPassword('noupppercase1')).toBe(false);
      expect(validation.isStrongPassword('NOLOWERCASE1')).toBe(false);
      expect(validation.isStrongPassword('NoNumbers')).toBe(false);
    });
  });
});
