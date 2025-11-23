# GitHub Actions SDLC Demo Application

This is a minimal Node.js application designed to demonstrate a complete Software Development Lifecycle (SDLC) pipeline using GitHub Actions, now featuring **Vitest with test sharding** for parallel test execution.

## 🎯 Purpose

This demo showcases modern CI/CD practices including:

- **Build Automation** - Automated compilation and bundling
- **Test Sharding** - Parallel test execution across multiple runners 🆕
- **Multi-Version Testing** - Unit tests across Node.js versions
- **Integration Testing** - Real database tests with PostgreSQL and Redis
- **Code Quality** - ESLint for linting and code style
- **Security Scanning** - Trivy vulnerability detection
- **Automated Releases** - Semantic versioning and GitHub releases

## 🚀 Quick Start

### Prerequisites

- Node.js 18.x or higher
- npm (comes with Node.js)

### Installation

```bash
npm install
```

### Build

```bash
npm run build
```

### Run Tests

```bash
# All tests with coverage (Vitest)
npm test

# Unit tests only
npm run test:unit

# Integration tests only
npm run test:integration

# Run with test sharding (for CI/CD)
npm run test:shard -- --shard=1/4

# Merge blob reports (after sharding)
npm run test:merge
```

### Lint

```bash
npm run lint
```

### Run Application

```bash
npm start
```

## 📁 Project Structure

```
demo-app/
├── src/                    # Source code
│   ├── index.js           # Main application entry
│   ├── math.js            # Math utilities
│   ├── string.js          # String utilities
│   ├── array.js           # Array utilities
│   ├── validation.js      # Validation functions
│   ├── date.js            # Date utilities
│   ├── object.js          # Object utilities
│   ├── number.js          # Number utilities
│   └── database.js        # Database connection utilities
├── tests/                 # Test suites
│   ├── unit/              # Unit tests (fast, isolated)
│   │   ├── math.test.js
│   │   ├── string.test.js
│   │   ├── array.test.js
│   │   ├── validation.test.js
│   │   ├── date.test.js
│   │   ├── object.test.js
│   │   └── number.test.js
│   └── integration/       # Integration tests (with services)
│       └── api.test.js
├── dist/                  # Build output (generated)
├── coverage/              # Test coverage reports (generated)
├── .vitest-reports/       # Blob reports for sharding (generated)
├── package.json           # npm dependencies and scripts
├── .eslintrc.json         # ESLint configuration
└── vitest.config.js       # Vitest test configuration
```

## 🔄 CI/CD Workflow

### Test Sharding Workflow (`vitest-sharding-demo.yml`) 🆕

Demonstrates parallel test execution using Vitest's native sharding capability:

```
Test Shard 1/4  ┐
Test Shard 2/4  ├─► Run in parallel
Test Shard 3/4  │   (Each shard gets ~25% of test files)
Test Shard 4/4  ┘
     │
     └─► Merge Reports Job
         ├─► Combine test results
         ├─► Aggregate coverage data
         └─► Generate final report
```

**Key Features:**
- **4x Parallelization**: Tests split across 4 GitHub Actions runners
- **Blob Reporter**: Efficient binary format for test results
- **Coverage Merging**: Aggregates coverage from all shards
- **Smart Distribution**: Vitest automatically balances test files
- **Performance**: ~50-75% faster than sequential execution

**How it works:**
1. Each shard runs `vitest --reporter=blob --shard=N/4`
2. Results stored in `.vitest-reports/` directory
3. Artifacts uploaded from each shard
4. Merge job downloads all artifacts
5. `vitest --merge-reports` combines everything

### SDLC Workflow (`sdlc-demo.yml`)

The complete SDLC pipeline demonstrates:

### Job Flow

```
Build
├─► Unit Tests (Node 18, 20, 22)
├─► Integration Tests (PostgreSQL + Redis)
├─► Lint & Code Quality
└─► Security Scanning
    └─► Release (main branch only)
```

### Performance Features

- **Caching**: npm dependencies, build outputs, ESLint cache
- **Parallelization**: 5 jobs run concurrently (~3-4 min total)
- **Matrix Testing**: Unit tests across 3 Node.js versions
- **Service Containers**: Real PostgreSQL and Redis instances
- **Test Sharding**: Parallel test execution across multiple runners 🆕

### Security Features

- **SHA-Pinned Actions**: All actions pinned to commit SHA
- **Least Privilege**: Minimal permissions at workflow level
- **Secret Handling**: Environment variables for sensitive data
- **Vulnerability Scanning**: Trivy filesystem scan
- **Script Injection Prevention**: Demonstrated secure patterns

## 📊 Metrics

| Metric | Target | Actual |
|--------|--------|--------|
| **Workflow Runtime** | < 5 min | ~3-4 min |
| **Build Time** | < 2 min | ~1-2 min |
| **Test Coverage** | > 80% | 85%+ |
| **Unit Test Time** | < 1 min | ~30-45s |
| **Integration Test Time** | < 2 min | ~1-2 min |

## 🎓 Learning Resources

This demo teaches:

1. **Dependency Caching** - Reduce build times by 60-70%
2. **Job Parallelization** - Run independent work concurrently
3. **Matrix Strategies** - Test across multiple versions
4. **Service Containers** - Integration testing without external services
5. **Conditional Workflows** - Smart execution based on context
6. **Artifact Management** - Efficient storage and retention
7. **Security Best Practices** - Safe workflow patterns

## 🔗 Related Workflows

See other examples in `.github/workflows/`:

- `01-hello-world.yml` - Getting started
- `cache-node.yml` - Caching patterns
- `11-containers-and-services.yml` - Service containers
- `10-matrix.yml` - Matrix strategies

## 📝 License

MIT License - Free to use for learning and training purposes.

## 👥 Contributing

This is a demo/training repository. Feel free to fork and experiment!

---

**Built with ❤️ by the GitHub Actions community**
