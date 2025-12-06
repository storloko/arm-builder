# Contributing to StorLoko ARM Builder

Thank you for your interest in contributing!

## Project Status

This project was developed by StorLoko Pty Ltd (2024-2025) and is now open source. The original company is no longer operating, but the codebase is maintained for community use.

## How to Contribute

### Reporting Issues

If you find a bug or have a feature request:

1. Check existing issues first
2. Open a new issue with:
   - Clear description of the problem
   - Steps to reproduce
   - Expected vs actual behavior
   - Your hardware/environment

### Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test your changes
5. Commit with clear messages (`git commit -m 'Add amazing feature'`)
6. Push to your fork (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Code Style

- Shell scripts: Use `shellcheck` for linting
- YAML: 2-space indentation
- Keep CI file readable with clear comments

### Areas for Contribution

- **New board support:** Add configurations for additional ARM SBCs
- **App manifests:** Add CasaOS YAML files for other self-hosted apps
- **Documentation:** Improve guides, add translations
- **GitHub Actions:** Port the GitLab CI to GitHub Actions
- **Testing:** Add automated testing for build process

## Development Setup

1. Clone the repo
2. Review the CI file to understand the build process
3. For local testing, use `./helper.sh` utilities

## Questions?

Open an issue with the `question` label.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
