# Agent guide: SFDX project 

This project is a **Salesforce DX (SFDX) project** with two delivery models:
- `force-app` for standard metadata.
- `framework-pkg/main/*` for unlocked package sources.
Use this file when working in this directory.

## Project layout

- **Project root**: this directory — SFDX project root. Contains `sfdx-project.json`, `force-app/`, and (optionally) LWC/Aura.

Path convention: **applications** (lowercase).

## One package.json context

### 1. Project root (this directory)

Used for SFDX metadata (LWC, Aura, etc.). Scripts here are for the base SFDX template:

| Command | Purpose |
|---------|---------|
| `npm run lint` | ESLint for `aura/` and `lwc/` |
| `npm run test` | LWC Jest (passWithNoTests) |
| `npm run prettier` | Format supported metadata files |
| `npm run prettier:verify` | Check Prettier |

**Before finishing changes:** run `npm run lint` and `npm run test` from the project root when relevant.

## Agent rules (.github/copilot-instructions)

This project includes **.github/instructions/** at the project root. Follow them when generating or editing code.

## Deploying

From **this project root**:

```bash
# Standard metadata (force-app)
sf project deploy start --manifest manifest/force-app-package.xml --target-org <alias>

# Unlocked package sources (framework-pkg): use package lifecycle
sf package version create --package `package-name` --target-dev-hub <devhub> --wait 60 --code-coverage
sf package install --package <04t...> --target-org <alias> --wait 30 --publish-wait 10
```

## Conventions (quick reference)
