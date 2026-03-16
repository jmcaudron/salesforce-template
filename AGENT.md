# Agent guide: SFDX project 

This project is a **Salesforce DX (SFDX) project**. The structure is generated; the project lives under `force-app/main/default/`. Use this file when working in this directory.

## Project layout

- **Project root**: this directory — SFDX project root. Contains `sfdx-project.json`, `force-app/`, and (optionally) LWC/Aura.

Path convention: **applications** (lowercase).

## One package.json contexts

### 1. Project root (this directory)

Used for SFDX metadata (LWC, Aura, etc.). Scripts here are for the base SFDX template:

| Command | Purpose |
|---------|---------|
| `npm run lint` | ESLint for `aura/` and `lwc/` |
| `npm run test` | LWC Jest (passWithNoTests) |
| `npm run prettier` | Format supported metadata files |
| `npm run prettier:verify` | Check Prettier |

Root **does not** run the React app. The root `npm run build` is a no-op for the base SFDX project.

**Before finishing changes:** run `npm run build` and `npm run lint` from the web app directory; both must succeed.

## Agent rules (.github/instructions)

This project includes **.github/instructions/** at the project root. Follow them when generating or editing code.

## Deploying

From **this project root**:

```bash
# Deploy all metadata
sf project deploy start --source-dir force-app --target-org <alias>
```

## Conventions (quick reference)
