/**
 * Database utilities for integration testing
 * Demonstrates connection to PostgreSQL and Redis
 */

async function checkConnection() {
  try {
    if (!process.env.DATABASE_URL) {
      return false;
    }
    
    // In a real app, you'd use pg.Client here
    // For demo purposes, we just return true if env var exists
    return true;
  } catch (error) {
    console.error('Database connection error:', error);
    return false;
  }
}

async function checkRedis() {
  try {
    if (!process.env.REDIS_URL) {
      return false;
    }
    
    // In a real app, you'd use redis client here
    return true;
  } catch (error) {
    console.error('Redis connection error:', error);
    return false;
  }
}

module.exports = {
  checkConnection,
  checkRedis
};
