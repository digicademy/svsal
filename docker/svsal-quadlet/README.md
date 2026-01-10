# School of Salamanca - CI/CD Automation Documentation

This documentation provides comprehensive information about automated derivative generation for the School of Salamanca project, including work resolution from changed TEI files and integration with CI/CD pipelines.

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Work Resolution Endpoint](#work-resolution-endpoint)
3. [CI/CD Integration](#cicd-integration)
4. [Example Scenarios](#example-scenarios)
5. [Troubleshooting](#troubleshooting)

---

## Architecture Overview

### How Changed File Detection Works

The CI/CD infrastructure provides intelligent automation to determine which works require regeneration based on changed TEI XML files. The system handles two main scenarios:

1. **Simple Case**: A changed file like `works/W0013.xml` directly regenerates work `W0013`
2. **Complex Case**: A changed file like `works/W0066_Vol_02.xml` regenerates the parent multivolume work `W0066` (detected via XInclude references)

### Components

```
┌─────────────────────┐
│  TEI Repository     │
│  Changed Files      │
└──────────┬──────────┘
           │ Git push triggers CI/CD
           ▼
┌─────────────────────────────────────────┐
│  CI/CD Pipeline (GitHub Actions/GitLab) │
│  1. Detect changed files                │
│  2. Mount TEI files to eXist-db         │
│  3. Call work-resolver endpoint         │
│  4. Generate derivatives                │
│  5. Deploy to webserver                 │
└──────────┬──────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────┐
│  eXist-db + Salamanca App               │
│  - work-resolver.xqm module             │
│  - webdata-resolve-works.xql endpoint   │
│  - webdata-admin.xql generation         │
└──────────┬──────────────────────────────┘
           │
           ▼
┌─────────────────────┐
│  Generated Files    │
│  (HTML, RDF, etc.)  │
└─────────────────────┘
```

### Work ID Resolution with XInclude Detection

The work resolver module (`modules/work-resolver.xqm`) provides three key functions:

1. **`resolver:extract-work-id($file-path)`**: Extracts work ID from file path using regex
2. **`resolver:find-parent-works($work-id)`**: Searches TEI collection for XInclude references
3. **`resolver:resolve-work-ids($file-paths)`**: Resolves file paths to work IDs with deduplication

When a volume file changes (e.g., `W0066_Vol_02.xml`), the resolver:
- Extracts the work ID (`W0066_Vol_02`)
- Searches for parent works that XInclude this file
- Returns both the volume ID and parent work ID (`W0066`)
- Ensures the parent work is regenerated to include the updated volume

---

## Work Resolution Endpoint

### API Documentation

**Endpoint**: `/webdata-resolve-works.xql`

**Purpose**: Accepts TEI file paths and returns work IDs that need regeneration

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `files` | string | Yes | Comma-separated list of file paths, or multiple `files` parameters |
| `format` | string | No | Output format: `json` (default), `csv`, or `text` |

### Response Formats

#### JSON (default)
```json
{
  "works": ["W0013", "W0066"]
}
```

#### CSV
```
W0013,W0066
```

#### Text (one per line)
```
W0013
W0066
```

### HTTP Status Codes

| Code | Meaning |
|------|---------|
| 200 | Success - work IDs returned |
| 400 | Bad Request - missing or invalid parameters |
| 500 | Internal Server Error |

### Example API Calls

#### Single File
```bash
curl "http://localhost:8080/exist/apps/salamanca/webdata-resolve-works.xql?files=works/W0013.xml"
```

Response:
```json
{"works": ["W0013"]}
```

#### Multiple Files (comma-separated)
```bash
curl "http://localhost:8080/exist/apps/salamanca/webdata-resolve-works.xql?files=works/W0013.xml,works/W0066_Vol_02.xml"
```

Response:
```json
{"works": ["W0013", "W0066", "W0066_Vol_02"]}
```

#### CSV Format
```bash
curl "http://localhost:8080/exist/apps/salamanca/webdata-resolve-works.xql?files=works/W0013.xml&format=csv"
```

Response:
```
W0013
```

#### With Authentication
```bash
curl -u admin:password "http://localhost:8080/exist/apps/salamanca/webdata-resolve-works.xql?files=works/W0013.xml"
```

---

## CI/CD Integration

### Prerequisites

1. **eXist-db instance** with Salamanca application deployed
2. **TEI repository** with source XML files
3. **CI/CD platform** (GitHub Actions, GitLab CI, Jenkins, etc.)
4. **Docker** or Podman for container orchestration

### Environment Variables

Configure these in your CI/CD secrets and environment:

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `EXISTDB_URL` | No | `http://localhost:8080/exist/apps/salamanca` | Base URL of eXist-db |
| `EXISTDB_USER` | No | `admin` | Admin username |
| `EXISTDB_PASSWORD` | **Yes** | - | Admin password (store in secrets) |
| `CHANGED_FILES` | No* | - | Comma-separated changed file paths |
| `WORK_IDS` | No* | - | Comma-separated work IDs (alternative to CHANGED_FILES) |
| `FORMAT` | No | `all` | Derivative format: `index`, `html`, `snippets`, `rdf`, `iiif`, `all` |
| `TIMEOUT` | No | `300` | Timeout in seconds for eXist-db readiness check |

*Either `CHANGED_FILES` or `WORK_IDS` must be provided

### Complete GitHub Actions Example

Create `.github/workflows/generate-derivatives.yml` in your TEI repository:

```yaml
name: Generate Derivatives

on:
  push:
    branches: [main]
    paths:
      - 'works/**/*.xml'
      - 'authors/**/*.xml'
      - 'lemmata/**/*.xml'

jobs:
  generate:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout TEI repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 2  # Need previous commit to detect changes

      - name: Detect changed files
        id: changes
        run: |
          # Get list of changed XML files
          CHANGED=$(git diff --name-only HEAD^ HEAD | grep '\.xml$' | tr '\n' ',' | sed 's/,$//')
          echo "files=$CHANGED" >> $GITHUB_OUTPUT
          echo "Changed files: $CHANGED"

      - name: Checkout Salamanca application
        uses: actions/checkout@v4
        with:
          repository: digicademy/svsal
          path: svsal-app

      - name: Start eXist-db
        run: |
          cd svsal-app
          docker-compose -f docker-compose.cicd.yml up -d existdb

          # Wait for eXist-db to be ready
          timeout 300 bash -c 'until curl -sf http://localhost:8080/exist/apps/salamanca; do sleep 5; done'
          echo "eXist-db is ready"

      - name: Mount TEI files
        run: |
          # Copy TEI files into volume
          docker cp . existdb-cicd:/exist/apps/salamanca-tei/

      - name: Generate derivatives
        env:
          EXISTDB_PASSWORD: ${{ secrets.EXISTDB_PASSWORD }}
          CHANGED_FILES: ${{ steps.changes.outputs.files }}
        run: |
          cd svsal-app
          docker-compose -f docker-compose.cicd.yml exec -T existdb \
            /docker/scripts/generate-derivatives.sh

      - name: Extract generated files
        run: |
          # Copy generated files from container
          docker cp existdb-cicd:/exist/data/export ./output

          # List generated files
          find ./output -type f

      - name: Deploy to webserver
        run: |
          # Your deployment logic here
          # Example: rsync, scp, cloud storage upload, etc.
          rsync -avz ./output/ user@webserver:/var/www/salamanca/

      - name: Cleanup
        if: always()
        run: |
          cd svsal-app
          docker-compose -f docker-compose.cicd.yml down -v
```

### Complete GitLab CI Example

Create `.gitlab-ci.yml` in your TEI repository:

```yaml
stages:
  - detect
  - generate
  - deploy

variables:
  EXISTDB_URL: "http://existdb-cicd:8080/exist/apps/salamanca"
  EXISTDB_USER: "admin"
  DOCKER_DRIVER: overlay2

# Detect changed files
detect-changes:
  stage: detect
  image: alpine/git
  script:
    - apk add --no-cache bash
    - |
      # Get changed XML files
      CHANGED=$(git diff --name-only $CI_COMMIT_BEFORE_SHA $CI_COMMIT_SHA | grep '\.xml$' | tr '\n' ',' | sed 's/,$//')
      echo "CHANGED_FILES=$CHANGED" >> variables.env
      echo "Changed files: $CHANGED"
  artifacts:
    reports:
      dotenv: variables.env

# Generate derivatives
generate-derivatives:
  stage: generate
  image: docker:latest
  services:
    - docker:dind
  needs:
    - detect-changes
  script:
    # Clone Salamanca application
    - apk add --no-cache git bash curl
    - git clone https://github.com/digicademy/svsal.git svsal-app
    - cd svsal-app

    # Start eXist-db
    - docker-compose -f docker-compose.cicd.yml up -d existdb

    # Wait for readiness
    - timeout 300 bash -c 'until curl -sf http://existdb-cicd:8080/exist/apps/salamanca; do sleep 5; done'

    # Copy TEI files
    - docker cp ../ existdb-cicd:/exist/apps/salamanca-tei/

    # Generate derivatives
    - |
      docker-compose -f docker-compose.cicd.yml exec -T existdb \
        env EXISTDB_PASSWORD="$EXISTDB_PASSWORD" \
        CHANGED_FILES="$CHANGED_FILES" \
        /docker/scripts/generate-derivatives.sh

    # Extract generated files
    - docker cp existdb-cicd:/exist/data/export ../output

    # Cleanup
    - docker-compose -f docker-compose.cicd.yml down -v
  artifacts:
    paths:
      - output/
    expire_in: 1 day
  variables:
    EXISTDB_PASSWORD: $EXISTDB_PASSWORD

# Deploy to webserver
deploy:
  stage: deploy
  image: alpine:latest
  needs:
    - generate-derivatives
  script:
    - apk add --no-cache rsync openssh
    - mkdir -p ~/.ssh
    - echo "$SSH_PRIVATE_KEY" > ~/.ssh/id_rsa
    - chmod 600 ~/.ssh/id_rsa
    - ssh-keyscan -H $DEPLOY_HOST >> ~/.ssh/known_hosts
    - rsync -avz output/ $DEPLOY_USER@$DEPLOY_HOST:$DEPLOY_PATH
  only:
    - main
```

### Jenkins Pipeline Example

```groovy
pipeline {
    agent any

    environment {
        EXISTDB_PASSWORD = credentials('existdb-password')
        DEPLOY_HOST = 'webserver.salamanca.school'
    }

    stages {
        stage('Detect Changes') {
            steps {
                script {
                    def changes = sh(
                        script: "git diff --name-only HEAD^ HEAD | grep '\\.xml\$' | tr '\\n' ',' | sed 's/,\$//'",
                        returnStdout: true
                    ).trim()
                    env.CHANGED_FILES = changes
                    echo "Changed files: ${changes}"
                }
            }
        }

        stage('Setup') {
            steps {
                sh 'git clone https://github.com/digicademy/svsal.git svsal-app'
            }
        }

        stage('Generate') {
            steps {
                dir('svsal-app') {
                    sh 'docker-compose -f docker-compose.cicd.yml up -d existdb'
                    sh 'timeout 300 bash -c "until curl -sf http://localhost:8080/exist/apps/salamanca; do sleep 5; done"'
                    sh 'docker cp ../ existdb-cicd:/exist/apps/salamanca-tei/'
                    sh '''
                        docker-compose -f docker-compose.cicd.yml exec -T existdb \
                            env EXISTDB_PASSWORD="$EXISTDB_PASSWORD" \
                            CHANGED_FILES="$CHANGED_FILES" \
                            /docker/scripts/generate-derivatives.sh
                    '''
                    sh 'docker cp existdb-cicd:/exist/data/export ../output'
                }
            }
        }

        stage('Deploy') {
            steps {
                sh "rsync -avz output/ user@${DEPLOY_HOST}:/var/www/salamanca/"
            }
        }
    }

    post {
        always {
            dir('svsal-app') {
                sh 'docker-compose -f docker-compose.cicd.yml down -v'
            }
        }
    }
}
```

---

## Example Scenarios

### Scenario 1: Simple Case - Single Work Changed

**Situation**: Editor modifies `works/W0013.xml`

**Steps**:

1. CI/CD detects change: `works/W0013.xml`
2. Calls resolver endpoint:
   ```bash
   curl "http://localhost:8080/exist/apps/salamanca/webdata-resolve-works.xql?files=works/W0013.xml&format=csv"
   ```
3. Resolver returns: `W0013`
4. Generates derivatives for `W0013`

**Result**: Only work W0013 is regenerated

### Scenario 2: Complex Case - Volume in Multivolume Work

**Situation**: Editor modifies `works/W0066_Vol_02.xml` (part of multivolume work W0066)

**Steps**:

1. CI/CD detects change: `works/W0066_Vol_02.xml`
2. Calls resolver endpoint:
   ```bash
   curl "http://localhost:8080/exist/apps/salamanca/webdata-resolve-works.xql?files=works/W0066_Vol_02.xml&format=csv"
   ```
3. Resolver:
   - Extracts work ID: `W0066_Vol_02`
   - Searches for parent works with XInclude
   - Finds `W0066.xml` includes this volume
   - Returns: `W0066,W0066_Vol_02`
4. Generates derivatives for both `W0066` and `W0066_Vol_02`

**Result**: Both the parent work and volume are regenerated

### Scenario 3: Multiple Files Changed

**Situation**: Editor commits changes to multiple files:
- `works/W0013.xml`
- `works/W0066_Vol_02.xml`
- `works/W0100.xml`

**Steps**:

1. CI/CD detects changes (comma-separated)
2. Calls resolver:
   ```bash
   curl "http://localhost:8080/exist/apps/salamanca/webdata-resolve-works.xql?files=works/W0013.xml,works/W0066_Vol_02.xml,works/W0100.xml&format=csv"
   ```
3. Resolver returns: `W0013,W0066,W0066_Vol_02,W0100`
4. Generates derivatives for all four works

**Result**: All affected works are regenerated

### Scenario 4: No TEI Changes (Skip Generation)

**Situation**: Commit contains only documentation changes

**Steps**:

1. CI/CD detects no `.xml` file changes
2. Skips generation workflow entirely

**Result**: No unnecessary regeneration

---

## Troubleshooting

### Common Issues and Solutions

#### Issue: "Work resolver returned empty result"

**Cause**: File paths don't match work ID pattern or TEI files not accessible

**Solution**:
1. Check file path format: Must match `W####.xml` or `W####_Vol_##.xml`
2. Verify TEI files are mounted correctly:
   ```bash
   docker exec existdb-cicd ls -la /exist/apps/salamanca-tei/works/
   ```
3. Check logs:
   ```bash
   docker logs existdb-cicd
   ```

#### Issue: "Failed to resolve work IDs from changed files"

**Cause**: Network issue, authentication failure, or endpoint not accessible

**Solution**:
1. Verify eXist-db is running:
   ```bash
   curl http://localhost:8080/exist/apps/salamanca
   ```
2. Test resolver endpoint manually:
   ```bash
   curl -u admin:password "http://localhost:8080/exist/apps/salamanca/webdata-resolve-works.xql?files=works/W0013.xml"
   ```
3. Check credentials are correct

#### Issue: "Timeout waiting for eXist-db"

**Cause**: eXist-db taking too long to start or resource constraints

**Solution**:
1. Increase timeout: `TIMEOUT=600`
2. Check container resources:
   ```bash
   docker stats existdb-cicd
   ```
3. Increase memory allocation in `docker-compose.cicd.yml`:
   ```yaml
   environment:
     JAVA_TOOL_OPTIONS: '-Xmx8g -Xms8g'
   ```

#### Issue: "Parent work not detected"

**Cause**: XInclude references not found or incorrect namespace

**Solution**:
1. Verify parent work contains XInclude:
   ```bash
   grep -r "xi:include.*W0066_Vol_02" /path/to/tei/works/
   ```
2. Check namespace declaration in parent TEI file:
   ```xml
   <TEI xmlns:xi="http://www.w3.org/2001/XInclude">
   ```
3. Enable trace logging in `modules/config.xqm`:
   ```xquery
   declare variable $config:debug := "trace";
   ```

#### Issue: "Permission denied" on script execution

**Cause**: Script not executable

**Solution**:
```bash
chmod +x docker/scripts/generate-derivatives.sh
```

#### Issue: Generated files not extracted

**Cause**: Wrong volume or path

**Solution**:
1. Verify export location:
   ```bash
   docker exec existdb-cicd ls -la /exist/data/export/
   ```
2. Check volume mounting:
   ```bash
   docker volume inspect existexport-cicd
   ```

### Debug Mode

Enable detailed logging for troubleshooting:

1. Set trace logging in XQuery:
   ```xquery
   declare variable $config:debug := "trace";
   ```

2. View eXist-db logs:
   ```bash
   docker logs -f existdb-cicd
   ```

3. Enable shell script verbose mode:
   ```bash
   bash -x docker/scripts/generate-derivatives.sh
   ```

### Testing Locally

Before deploying to CI/CD, test locally:

```bash
# 1. Start services
docker-compose -f docker-compose.cicd.yml up -d

# 2. Mount TEI files
docker cp /path/to/tei-repo existdb-cicd:/exist/apps/salamanca-tei/

# 3. Test resolver endpoint
curl "http://localhost:8080/exist/apps/salamanca/webdata-resolve-works.xql?files=works/W0013.xml"

# 4. Run generation script
docker-compose -f docker-compose.cicd.yml exec existdb \
  env EXISTDB_PASSWORD="admin" \
  CHANGED_FILES="works/W0013.xml" \
  /docker/scripts/generate-derivatives.sh

# 5. Check output
docker exec existdb-cicd ls -la /exist/data/export/

# 6. Cleanup
docker-compose -f docker-compose.cicd.yml down -v
```

### Getting Help

1. **Check logs**: Always check eXist-db and container logs first
2. **Test endpoints**: Manually test the resolver and admin endpoints
3. **Verify mounting**: Ensure TEI files are accessible in container
4. **Enable debug mode**: Use trace logging for detailed information
5. **Review examples**: Compare your setup with the provided examples

---

## Integration Steps

### Step-by-Step Setup

1. **Prepare Salamanca Application**
   - Ensure eXist-db has `work-resolver.xqm` module
   - Deploy `webdata-resolve-works.xql` endpoint
   - Verify `webdata-admin.xql` is accessible

2. **Configure CI/CD Secrets**
   - Set `EXISTDB_PASSWORD` in CI/CD secrets
   - Optionally set deployment credentials

3. **Add CI/CD Configuration**
   - Copy appropriate workflow file (GitHub Actions/GitLab CI)
   - Adjust paths and parameters as needed
   - Test with a single file change first

4. **Test the Workflow**
   - Make a small change to a TEI file
   - Push and monitor the CI/CD pipeline
   - Verify derivatives are generated
   - Check deployment to webserver

5. **Monitor and Optimize**
   - Review generation times
   - Adjust memory allocation if needed
   - Optimize for your specific workload
   - Set up alerting for failures

---

## Additional Resources

- [eXist-db Documentation](https://exist-db.org/exist/apps/doc/)
- [XQuery 3.1 Specification](https://www.w3.org/TR/xquery-31/)
- [XInclude Specification](https://www.w3.org/TR/xinclude/)
- [School of Salamanca Project](https://www.salamanca.school)

---

Last Updated: 2026-01-10
