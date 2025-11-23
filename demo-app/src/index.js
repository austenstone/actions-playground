/**
 * GitHub Actions SDLC Demo - Main Application
 * 
 * This is a minimal Node.js application demonstrating a complete
 * CI/CD pipeline with GitHub Actions.
 */

const math = require('./math');
const database = require('./database');

async function main() {
  console.log('🚀 GitHub Actions SDLC Demo Application');
  console.log('========================================');
  
  // Demonstrate math operations
  console.log('\n📊 Math Operations:');
  console.log(`  Add: 5 + 3 = ${math.add(5, 3)}`);
  console.log(`  Multiply: 4 × 7 = ${math.multiply(4, 7)}`);
  console.log(`  Divide: 20 ÷ 4 = ${math.divide(20, 4)}`);
  
  // Check database connection (if configured)
  if (process.env.DATABASE_URL) {
    console.log('\n🐘 Database Connection:');
    const dbStatus = await database.checkConnection();
    console.log(`  PostgreSQL: ${dbStatus ? '✅ Connected' : '❌ Disconnected'}`);
  }
  
  console.log('\n✅ Application running successfully!');
  console.log('📦 Built with GitHub Actions');
}

// Run if executed directly
if (require.main === module) {
  main().catch(console.error);
}

module.exports = { main };
