# Apex Requirements

Apply these rules when creating or modifying Apex classes and Apex triggers in this repository, especially under `force-app/main/default/classes` and `force-app/main/default/triggers`.

## General Requirements

- Write Invocable Apex that can be called from flows when possible.
- Use enums over string constants whenever possible.
- Enum values must follow ALL_CAPS_SNAKE_CASE without spaces.
- Use Database methods for DML operations with exception handling.
- Use the Return Early pattern.
- Use ApexDocs comments to document Apex classes for maintainability and readability.

## Apex Trigger Requirements

- Follow the One Trigger Per Object pattern.
- Implement a trigger handler class to separate trigger logic from the trigger itself.
- Use trigger context variables (`Trigger.new`, `Trigger.old`, etc.) efficiently.
- Avoid recursive triggers (for example with a static guard flag).
- Bulkify trigger logic to handle large data volumes efficiently.
- Implement before/after logic based on operation requirements.

## Governor Limits Compliance Requirements

- Always write bulkified code. Never perform SOQL or DML operations in loops.
- Use collections for bulk processing.
- Implement proper exception handling with try-catch blocks.
- Limit SOQL queries to 100 per transaction.
- Limit DML statements to 150 per transaction.
- Use `Database.Stateful` only when necessary for batch jobs.

## SOQL Optimization Requirements

- Use selective queries with proper WHERE clauses.
- Do not use `SELECT *` (not supported in SOQL).
- Use indexed fields in WHERE clauses when possible.
- Apply SOQL best practices: LIMIT clauses and proper ordering.
- Use `WITH SECURITY_ENFORCED` for user-context queries where appropriate.

## Security & Access Control Requirements

- Run database operations in user mode instead of default system mode where appropriate.
  - `List<Account> acc = [SELECT Id FROM Account WITH USER_MODE];`
  - `Database.insert(accts, AccessLevel.USER_MODE);`
- Always check field-level security (FLS) before accessing fields.
- Implement proper sharing behavior and respect organization-wide defaults.
- Use `with sharing` for classes that should enforce sharing rules.
- Validate user permissions before performing operations.
- Sanitize user inputs to prevent injection attacks.

## Prohibited Practices

- No hardcoded IDs or URLs.
- No SOQL or DML operations inside loops.
- No `System.debug()` statements in production code.
- No `@future` methods from batch jobs.
- No recursive triggers.
- Never use or suggest `@future` for async processes. Use queueables and suggest implementing `System.Finalizer`.

## Required Patterns

- Use Builder pattern for complex object construction.
- Implement Factory pattern for object creation.
- Use Dependency Injection for testability.
- Follow MVC pattern in Lightning components.
- Use Command pattern for complex business operations.

## Unit Testing Requirements

- Maintain minimum 75% code coverage.
- Write meaningful test assertions, not only coverage.
- Use `Test.startTest()` and `Test.stopTest()` appropriately.
- Create test data using `@TestSetup` where possible.
- Mock external services and callouts.
- Do not use `SeeAllData=true`.
- Test bulk trigger functionality.

## Test Data Management Requirements

- Use `Test.loadData()` for large datasets.
- Create the minimum test data needed for each scenario.
- Use `System.runAs()` to test different user contexts.
- Ensure proper test isolation (no test interdependencies).

## Naming Conventions & Code Organization Requirements
- Class names: PascalCase with descriptive names (e.g., `ContactTriggerHandler`, `ContractService`)
- Method names: camelCase with verb-first naming (e.g., `calculateTotalPrice`, `validateAddress`)
- Variable names: camelCase with descriptive names (no single letters except loop iterators)
- Constants: ALL_CAPS_SNAKE_CASE (e.g., `MAX_RETRY_ATTEMPTS`, `DEFAULT_TIMEOUT`)
- Test classes: Append `Test` suffix (e.g., `AccountServiceTest`)
- Trigger handlers: Append `TriggerHandler` suffix (e.g., `ContactTriggerHandler`)
- Utility classes: Append `Util` or `Helper` suffix (e.g., `DateTimeUtil`, `ValidationHelper`)
- Prefix test methods with `test` or use `@IsTest` annotation
- Group related classes in packages/folders when possible
- Keep classes focused on single responsibility (SRP)
- Limit class size to 500 lines of code maximum