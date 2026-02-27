# CI/CD Setup

## GitHub Actions Pipeline

The CI pipeline (`.github/workflows/ci.yml`) runs on push/PR to main branches and:
- Installs dependencies with Node.js 12.22.7
- Runs tests in headless Chrome
- Builds the production app
- Uploads build artifacts (retained for 30 days)

## Download and Run Artifacts Locally

### Prerequisites
- GitHub personal access token with `repo` scope
- `http-server` (installed automatically by script)

### Usage

```bash
export GITHUB_TOKEN=your_github_token
export GITHUB_REPOSITORY=owner/repo
./download-artifacts.sh
```

The script will:
1. Fetch the latest successful CI run
2. Download the build artifact
3. Extract it to `./downloaded-artifacts`
4. Start a local server on http://localhost:8080
