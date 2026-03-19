# Copilot instructions for this repository

This is a Salesforce DX project (API 66.0) with three package directories:
- `force-app` (default package): property management app managed as standard metadata.
- `framework-pkg/main/logging-utilities-core` (unlocked package source): logging framework artifacts.
- `framework-pkg/main/batch-template-core` (unlocked package source): batch framework artifacts.


## Big picture (what exists today)
- Core app is a custom Lightning app: `Property_Management` in `force-app/main/default/applications`.
- Domain is modeled with 6 custom objects under `force-app/main/default/objects`:
	- `Property__c` (inventory)
	- `Application__c` (rental applications)
	- `Tenant__c` (lease records)
	- `Maintenance_Request__c` (work orders)
	- `Maintenance_Worker__c` (worker directory)
	- `Notification__c` (in-app messages)
- Relationship pattern is mostly lookup-based (`Property__c`, `User`/`Contact` links in field metadata files).
- Security baseline is centralized in `Property_Management_Access.permissionset-meta.xml` (object/field + tab visibility).

## Important project reality
- `force-app` is deployed as standard metadata (source deploy/retrieve workflows).
- `framework-pkg/*` folders are unlocked package sources. Changes there must follow unlocked package lifecycle:
	- update source under the relevant package directory,
	- create a new package version,
	- update `sfdx-project.json` aliases/version references when needed,
	- validate by installing the package version where appropriate.
- Do not mix force-app metadata changes with unlocked package source changes in the same manifest unless explicitly requested.

## Developer workflows (repo-specific)
- Install deps once at root: `npm install`.
- Lint/format/test from root:
	- `npm run lint`
	- `npm run test`
	- `npm run prettier` / `npm run prettier:verify`
- `npm run build` is intentionally a no-op in this template.
	- Deploy standard metadata (`force-app`) from root with `sf` CLI, e.g.:
		- `sf project deploy start --source-dir force-app --target-org <alias>`
	- For unlocked package source in `framework-pkg`, prefer package workflows (`sf package version create` and installation/validation), not generic metadata deploy as the release path.
- Seed sample records via tree import plan in `force-app/main/default/data/data-plan.json`.

## Deployment playbooks
- Standard metadata (`force-app`) playbook:
	1) confirm scope is only `force-app`,
	2) use `manifest/force-app-package.xml`,
	3) run `sf project deploy start --manifest manifest/force-app-package.xml --target-org <alias>`,
	4) optionally run retrieve sanity check and post-deploy verification.
- Unlocked package (`framework-pkg/*`) playbook:
	1) confirm scope per package source directory,
	2) create package version (`sf package version create`),
	3) install version in validation org (`sf package install`),
	4) update `sfdx-project.json` references when needed.
- Mixed changes (`force-app` + `framework-pkg`) must be processed as two independent delivery streams.
- Detailed runbook lives in `docs/deployment-mode-operatoire.md`.

## Conventions to preserve
- Keep Salesforce metadata structure and naming (`__c`, `*-meta.xml`) intact.
- When adding/changing fields on these objects, update in tandem:
	1) object field metadata, 2) permission set field/object access, 3) tab/app exposure when relevant, 4) manifest entries.
- Keep changes narrow and avoid touching unrelated metadata.
- Use explicit, business-meaningful labels/API names consistent with existing object vocabulary.

## Integration points and known edges
- Manifest files are split by deploy boundary:
	- `manifest/force-app-package.xml` for standard metadata in `force-app`.
	- `manifest/framework-pkg-logging-utilities-core.xml` for `framework-pkg/main/logging-utilities-core`.
	- `manifest/framework-pkg-batch-template-core.xml` for `framework-pkg/main/batch-template-core`.
- Prefer the manifest that matches the changed package directory; avoid cross-package manifests for routine work.
- Data files in `force-app/main/default/data/*.json` depend on reference IDs (`@PropertyRef...`) and import order in `data-plan.json`; do not reorder casually.
- Existing AI guidance in `.github/instructions/*.instructions.md` is authoritative for Apex, LWC, agent scripts, and general Salesforce rules.

## Objectives
- Produce small, safe, and readable changes.
- Preserve the Salesforce metadata structure (`force-app/main/default`).
- Prioritize maintainability and clarity.

## Contribution rules
- Keep changes limited to the requested need.
- Do not modify unrelated files.
- Respect the existing style.
- Add comments only when they provide real value.

## Expected quality
- Ensure code compiles/lints when applicable.
- Avoid unrequested breaking changes.
- Use explicit names for classes, methods, and variables.
