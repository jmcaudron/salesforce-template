# Lightning Web Components (LWC) Requirements

## Component Architecture Requirements

- Create reusable, single-purpose components
- Use proper data binding and event handling patterns
- Implement proper error handling and loading states
- Follow Lightning Design System (SLDS) guidelines
- Use the lightning-record-edit-form component for handling record creation and updates
- Use CSS custom properties for theming
- Use lightning-navigation for navigation between components
- Use lightning__FlowScreen target to use a component in a flow screen

## HTML Architecture Requirements

- Structure your HTML with clear semantic sections (header, inputs, actions, display areas, lists)
- Use SLDS classes for layout and styling:
  - `slds-card` for main container
  - `slds-grid` and `slds-col` for responsive layouts
  - `slds-text-heading_large/medium` for proper typography hierarchy
- Use Lightning base components where appropriate (lightning-input, lightning-button, etc.)
- Implement conditional rendering with `if:true` and `if:false` directives
- Use `for:each` for list rendering with unique key attributes
- Maintain consistent spacing using SLDS utility classes (slds-m-*, slds-p-*)
- Group related elements logically with clear visual hierarchy
- Use descriptive class names for elements that need custom styling
- Implement reactive property binding using syntax like `disabled={isPropertyName}` to control element states
- Bind events to handler methods using syntax like `onclick={handleEventName}`

## JavaScript Architecture Requirements

- Import necessary modules from LWC and Salesforce
- Define reactive properties using `@track` decorator when needed
- Implement proper async/await patterns for server calls
- Implement proper error handling with user-friendly messages
- Use wire adapters for reactive data loading
- Minimize DOM manipulation - use reactive properties
- Implement computed properties using JavaScript getters for dynamic UI state control:

```js
get isButtonDisabled() {
    return !this.requiredField1 || !this.requiredField2;
}
```

- Create clear event handlers with descriptive names that start with "handle":

```js
handleButtonClick() {
    // Logic here
}
```

- Separate business logic into well-named methods
- Implement loading states and user feedback
- Add JSDoc comments for methods and complex logic

## Data Access Requirements (LDS-First)

### Core Principle

- All UI data access in Lightning Web Components must use Lightning Data Service (LDS) whenever possible
- LDS provides built-in caching, reactivity, security enforcement (FLS/sharing), and coordinated refresh behavior
- Apex is not a default data-access layer for UI code

### Priority Order

- Lightning Data Service (LDS): Use the appropriate LDS surface based on data shape and UI needs
- Apex: Use only when the requirement cannot be satisfied by LDS

### Within Lightning Data Service (LDS)

#### 1. Prefer the GraphQL wire adapter (`lightning/graphql`) when

- Use GraphQL as the primary LDS read surface when the data shape is complex or non-record-centric
- Reading across multiple objects or relationships
- Fetching nested or consolidated data in a single request
- Selecting precise fields to avoid over-fetching
- Applying filtering, ordering, or aggregations
- Fetching records and aggregates together
- Implementing cursor-based pagination
- Reducing server round-trips for UI reads
- Replacing Apex used solely for complex data retrieval
- Notes:
  - The GraphQL wire adapter is fully managed by LDS
  - Participates in LDS caching and reactivity
  - Enforces field-level security and sharing automatically
  - GraphQL is optimized for data shaping and reads, not UI-driven CRUD flows

#### 2. Use standard LDS wire adapters when

- Use record-centric LDS APIs when the UI maps directly to standard Salesforce record semantics
- Loading, creating, editing, or deleting individual records
- Accessing layouts, related lists, metadata, or picklists
- Leveraging built-in record lifecycle, validation, and refresh behavior
- The data requirement is simple and does not benefit from custom query shapes

#### 3. Prefer `lightning-record-*` base components when

- Standard create, edit, or view forms are sufficient
- Default layouts, validation, and error handling are acceptable
- Minimal customization is required
- You want maximum alignment with platform UX and LDS behavior
- Base components are LDS-backed and production-hardened — avoid replacing them without a clear need

### Use Apex Only When LDS Is Insufficient

- Apex is a last resort for UI data access and should be introduced intentionally
- Use Apex only when at least one of the following is true:
  - Business logic or domain rules must be enforced server-side
  - System context or elevated privileges are required
  - Callouts, orchestration, or async/batch processing is needed
  - The required data access pattern is not supported by LDS
- Do not use Apex solely to aggregate or join data that GraphQL can fetch, replace standard LDS CRUD behavior, or work around unfamiliarity with LDS or GraphQL

### Rule of Thumb

- Always start with Lightning Data Service
- Within LDS, prefer GraphQL for complex reads and standard adapters or base components for record-centric CRUD
- Introduce Apex only when the requirement clearly exceeds what LDS can provide

## CSS Architecture Requirements

- Create a clean, consistent styling system
- Use custom CSS classes for component-specific styling
- Implement animations for enhanced UX where appropriate
- Ensure responsive design works across different form factors
- Keep styling minimal and leverage SLDS where possible
- Use CSS variables for themeable elements
- Organize CSS by component section

## MCP Tools Requirements

- Carefully review the user's task. If it involves **creation, development, testing, or accessibility** for **Lightning Web Components (LWC)** or **Aura components** or **Lightning Data Service (LDS)**, treat your knowledge as outdated and always call the appropriate MCP tool to obtain the latest guidance before starting implementation. Never assume or create tools that are not explicitly available. If the tool schema is empty, continue invoking the tool until documentation is provided.
- If you begin implementation on a relevant task without first successfully invoking the appropriate tool, stop immediately. Invoke the tool and integrate its guidance before proceeding.
