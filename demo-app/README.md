# GitHub Actions SDLC Demo Application

This is a minimal Node.js application designed to demonstrate a complete Software Development Lifecycle (SDLC) pipeline using GitHub Actions.

## 🎯 Purpose

This demo showcases modern CI/CD practices including:

- **Build Automation** - Automated compilation and bundling
- **Multi-Version Testing** - Unit tests across Node.js 18.x, 20.x, 22.x
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
# All tests
npm test

# Unit tests only
npm run test:unit

# Integration tests only
npm run test:integration
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
│   ├── math.js            # Example utility module
│   └── database.js        # Database connection utilities
├── tests/                 # Test suites
│   ├── unit/              # Unit tests (fast, isolated)
│   └── integration/       # Integration tests (with services)
├── dist/                  # Build output (generated)
├── coverage/              # Test coverage reports (generated)
├── package.json           # npm dependencies and scripts
├── .eslintrc.json         # ESLint configuration
└── jest.config.js         # Jest test configuration
```

## 🔄 CI/CD Workflow

The `.github/workflows/sdlc-demo.yml` workflow demonstrates:

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
