# Manifest boundaries

Use one manifest per deployment boundary.

- `manifest/force-app-package.xml`
  - Standard metadata for `force-app`.
  - Typical command:
    - `sf project deploy start --manifest manifest/force-app-package.xml --target-org <alias>`

- `manifest/framework-pkg-logging-utilities-core.xml`
  - Source for `framework-pkg/main/logging-utilities-core` unlocked package.
  - Use for validation/retrieval targeting this package source only.

- `manifest/framework-pkg-batch-template-core.xml`
  - Source for `framework-pkg/main/batch-template-core` unlocked package.
  - Use for validation/retrieval targeting this package source only.

- `manifest/all-metadata.xml`
  - Legacy consolidated manifest containing both app and framework metadata.
  - Prefer the split manifests above for routine work.
