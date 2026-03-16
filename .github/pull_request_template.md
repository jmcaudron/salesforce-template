# Pull Request Template

## Business Intent (required)

<!-- What business or technical outcome is this change intended to deliver? -->

## Scope (required)

- Package scope:
  - [ ] force-app
  - [ ] batch-framework-app
  - [ ] both
- Changed areas:
  - [ ] Custom Objects / Fields
  - [ ] Permission Sets
  - [ ] Tabs / App / Flexipages / Layouts
  - [ ] Apex classes / tests
  - [ ] Data plan / sample data
  - [ ] Other (describe below)

## Change Summary (required)

<!-- 2-6 bullets of what was changed and why -->

- 
- 
- 

## Reviewer Inputs (required)

- PR diff / changed files summary: <!-- link or paste -->
- Requested business intent: <!-- concise statement -->
- Target org alias for validation: <!-- e.g. dev-sandbox or N/A -->
- Validation scope: <!-- force-app | batch-framework-app | both -->

## Salesforce Metadata Consistency (required when metadata changes)

- [ ] Manifest/package entries updated consistently
- [ ] Permission set updates included where needed
- [ ] Tab/App visibility updates included where needed
- [ ] API names and labels are business-meaningful and consistent
- [ ] Data plan/reference IDs/order validated when data files changed

## Security Review (required)

- [ ] No security regression introduced
- [ ] Apex sharing model reviewed (`with/inherited sharing` as appropriate)
- [ ] CRUD/FLS handling reviewed for Apex data access paths
- [ ] No unnecessary metadata overexposure

## Validation Evidence (required)

Paste command and result summary (success/failure + key output):

1. `sf project deploy start --source-dir force-app --target-org <alias>`
2. `sf project deploy start --source-dir batch-framework-app --target-org <alias>`
3. `npm run lint`
4. `npm run test`

If only one package changed, include only the relevant deploy command.
If validation was not run, explain why.

## Risks and Rollback (required)

- Runtime/deploy risk:
- Data integrity risk:
- Rollback approach:

## Fail-Fast Acknowledgement (required)

Confirm none of these are present, otherwise PR should be marked request changes:
- [ ] No metadata dependency break (manifest/object/field/tab mismatch)
- [ ] No unresolved deployment validation errors
- [ ] No data-plan/reference integrity break
- [ ] No unrelated file changes without justification

## Optional Notes

<!-- screenshots, follow-up items, known limitations -->
