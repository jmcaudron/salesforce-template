# Instructions Index (.github/instructions)

Rules in this folder guide GitHub Copilot for this SFDX project. All files use the `.instructions.md` extension (GitHub Copilot standard).

## Context-specific rules (by file pattern or topic)

| File | Purpose |
| ------ | -------- |
| **general.instructions.md** | General Salesforce dev rules: always use `sf` CLI, create XML metadata files for all new objects/classes/triggers. |
| **app-dev.instructions.md** | App architecture rules: naming conventions, permissions model, REST/Platform Events, documentation requirements. |
| **lwc.instructions.md** | LWC rules: component architecture, SLDS, LDS-first data access (GraphQL → adapters → base components → Apex), MCP tools. |
| **mobile-lwc.instructions.disabled.md** *(disabled)* | Archived mobile LWC rules (not loaded by Copilot because filename no longer matches `.instructions.md`). |
| **agent-script.instructions.md** | Agent Script rules for `.agent` files: structure, block ordering, naming, actions, transitions, validation checklist. |
| **apex.instructions.md** | Apex classes/triggers rules: invocable design, trigger handler pattern, bulkification, security/FLS, testing and prohibited patterns. |
