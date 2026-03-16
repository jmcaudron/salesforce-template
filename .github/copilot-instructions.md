# Copilot instructions for this repository

This is a Salesforce DX project (API 66.0) with two package directories:
- `force-app` (metadata-first property management app) : default package for this porject
- `batch-framework-app` (package directory for batch framework)


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
- `force-app` currently contains no Apex classes, triggers, LWC, or Aura folders.
- `batch-framework-app` contains Apex classes and related metadata for the batch framework package.
- Prefer metadata changes unless the task explicitly requires new code artifacts.

## Developer workflows (repo-specific)
- Install deps once at root: `npm install`.
- Lint/format/test from root:
	- `npm run lint`
	- `npm run test`
	- `npm run prettier` / `npm run prettier:verify`
- `npm run build` is intentionally a no-op in this template.
- Deploy metadata from root with `sf` CLI (not `sfdx`), e.g.:
	- `sf project deploy start --source-dir force-app --target-org <alias>`
- Seed sample records via tree import plan in `force-app/main/default/data/data-plan.json`.

## Conventions to preserve
- Keep Salesforce metadata structure and naming (`__c`, `*-meta.xml`) intact.
- When adding/changing fields on these objects, update in tandem:
	1) object field metadata, 2) permission set field/object access, 3) tab/app exposure when relevant, 4) manifest entries.
- Keep changes narrow and avoid touching unrelated metadata.
- Use explicit, business-meaningful labels/API names consistent with existing object vocabulary.

## Integration points and known edges
- Manifest files (`manifest/all-metadata*.xml`) are the packaging/deploy boundary; verify entries before deploy.
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
