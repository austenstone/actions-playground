/**
 * Integration tests for database connectivity
 * Tests actual PostgreSQL and Redis connections
 */

const database = require('../../src/database');

describe('Integration Tests', () => {
  describe('Database Connection', () => {
    test('should connect to PostgreSQL', async () => {
      const isConnected = await database.checkConnection();
      
      if (process.env.DATABASE_URL) {
        expect(isConnected).toBe(true);
      } else {
        expect(isConnected).toBe(false);
      }
    });
    
    test('should connect to Redis', async () => {
      const isConnected = await database.checkRedis();
      
      if (process.env.REDIS_URL) {
        expect(isConnected).toBe(true);
      } else {
        expect(isConnected).toBe(false);
      }
    });
  });
  
  describe('Application Startup', () => {
    test('should initialize without errors', async () => {
      const { main } = require('../../src/index');
      
      // Just verify it doesn't throw
      await expect(main()).resolves.not.toThrow();
    });
  });
});
