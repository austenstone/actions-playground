import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    // Test environment
    environment: 'node',
    
    // Test file patterns
    include: ['tests/**/*.test.js'],
    
    // Coverage configuration
    coverage: {
      provider: 'v8',
      reporter: ['json', 'text', 'clover', 'json-summary'],  // Removed lcov to avoid Windows path issues
      reportsDirectory: './coverage',
      include: ['src/**/*.js'],
      exclude: [
        'src/**/*.test.js',
        '**/node_modules/**',
        '**/dist/**'
      ],
      thresholds: {
        branches: 70,
        functions: 80,
        lines: 80,
        statements: 80
      }
    },
    
    // Test execution
    globals: true,
    
    // Performance optimizations
    isolate: true,
    pool: 'forks',
    poolOptions: {
      forks: {
        singleFork: false
      }
    }
  }
});
