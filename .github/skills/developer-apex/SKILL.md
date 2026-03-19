---
name: developer-apex
description: 'Develop or update Salesforce Apex safely in this repository. Use when asked to create Apex classes or triggers, add tests, refactor Apex logic, validate governor/security patterns, and prepare deploy-ready metadata.'
argument-hint: 'Describe the Apex task, target metadata path, and whether to run tests/deploy.'
user-invocable: true
---

# Developer Apex

## Outcome

Produce deploy-ready Apex changes that are secure, bulkified, test-backed, and aligned with this repository's Salesforce DX conventions.

## When To Use

- Create or modify Apex classes in `framework-pkg/main/*/default/classes` and `force-app/main/default/classes`.
- Create or modify triggers in `force-app/main/default/triggers` (if requested).
- Add or update Apex tests and related metadata files.
- Review Apex for sharing, FLS, SOQL/DML limits, and async strategy.

## Workflow

1. Confirm scope and artifact type.
- Determine if the request is new code, refactor, bug fix, or review.
- Prefer metadata-only changes in `force-app` unless Apex is explicitly required.
- If the user is ambiguous, ask for target object/class and expected behavior.

2. Locate impacted metadata and dependencies.
- Read existing class/trigger and companion `*-meta.xml` files first.
- Identify related permission sets, manifest entries, and tests that need updates.
- Keep changes narrow and avoid unrelated metadata edits.

3. Design with Apex quality gates before implementation.
- Apply one-trigger-per-object with handler pattern for trigger work.
- Use bulk-safe collections; never put SOQL/DML in loops.
- Prefer `with sharing`, user mode operations, and FLS-conscious access.
- Avoid prohibited patterns: hardcoded IDs, `System.debug` in production logic, `@future` for async.

4. Implement minimal, readable changes.
- Use explicit naming and return-early flow.
- Add `ApexDocs` comments for classes/methods when adding non-trivial logic.
- Create/update `.cls-meta.xml` and `.trigger-meta.xml` alongside code changes.

5. Build tests as part of the same change.
- Add focused tests with meaningful assertions.
- Use `@TestSetup` where appropriate and keep data minimal.
- Cover bulk behavior and permission-sensitive behavior when relevant.
- Treat tests as mandatory by default; only skip when the user explicitly asks to skip.

6. Validate locally.
- Run targeted checks first, then broader checks if needed.
- Use project commands from repo root (for example, `npm run lint`, `npm run test`) when relevant.
- Use Salesforce commands with `sf` CLI only.

7. Prepare deploy-safe output.
- Summarize changed files and behavior impact.
- Note required org permissions/config dependencies.
- If asked to deploy, use `sf project deploy start` with minimal source scope.

## Decision Branches

- If no Apex currently exists in `force-app` for the feature:
Use declarative metadata first unless the user explicitly requests Apex.

- If a trigger is requested:
Implement or extend a handler; do not duplicate logic in trigger body.

- If requirements conflict with security best practices:
Block unsafe approach and propose secure alternatives.

- If tests are missing for touched logic:
Add tests before considering work complete.

- If tests are not requested explicitly:
Run them anyway, then report results or any environment blocker.

## Completion Checklist

- Apex logic is bulkified and governor-safe.
- Sharing/FLS/user-mode considerations are addressed.
- Required metadata companions exist and are consistent.
- Tests are present and meaningful for changed behavior.
- Tests were executed unless the user explicitly opted out.
- Validation commands were run, or any skipped validation is clearly stated.
- Change summary includes impact, risks, and next deployment steps.
