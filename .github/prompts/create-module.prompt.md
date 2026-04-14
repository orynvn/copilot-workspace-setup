---
mode: agent
tools:
  - codebase
  - editFiles
  - readFile
  - runCommands
description: >
  Create a complete module following the current stack’s architecture.
  Includes: Controller/Component, Service, Repository/Store, Types, Tests.
---

# Create Module Prompt

Create a complete new module for the current stack.

## Module information

**Module name:** ${input:moduleName:Module name (PascalCase) — e.g. Product, Order, Invoice}
**Description:** ${input:description:What does this module do?}
**CRUD operations:** ${input:operations:Operations needed (e.g. list, show, create, update, delete)}

---

## Execution

### 1. Stack Detection & Planning

Identify stack:
- `composer.json` + `artisan` → **Laravel module**
- `package.json` dep `"next"` → **Next.js module**
- `package.json` dep `"vite"` + `"react"` → **React module**
- `package.json` dep `"vue"` → **Vue 3 module**

Display files to create per stack → **wait for confirmation**.

### 2. Laravel Module Structure

```
app/
├── Http/
│   ├── Controllers/${input:moduleName}Controller.php
│   ├── Requests/${input:moduleName}/Store${input:moduleName}Request.php
│   ├── Requests/${input:moduleName}/Update${input:moduleName}Request.php
│   └── Resources/${input:moduleName}Resource.php
├── Models/${input:moduleName}.php
├── Services/${input:moduleName}Service.php
└── Repositories/${input:moduleName}Repository.php
tests/
└── Feature/${input:moduleName}ControllerTest.php
```

### 3. Next.js Module Structure

```
app/${input:moduleName|lower}/
├── page.tsx              # List view (Server Component)
├── [id]/
│   └── page.tsx          # Detail view
├── _components/          # Module-private components
├── actions.ts            # Server Actions
└── loading.tsx
lib/${input:moduleName|lower}/
└── api.ts                # Data access functions
types/
└── ${input:moduleName|lower}.ts
```

### 4. React Module Structure

```
src/
├── features/${input:moduleName|lower}/
│   ├── components/
│   ├── hooks/use${input:moduleName}.ts
│   ├── services/${input:moduleName|lower}-service.ts
│   └── types.ts
└── store/${input:moduleName|lower}Store.ts
```

### 5. Vue 3 Module Structure

```
src/
├── views/${input:moduleName}View.vue
├── components/${input:moduleName}/
├── composables/use${input:moduleName}.ts
├── stores/${input:moduleName|lower}Store.ts
└── services/${input:moduleName|lower}Service.ts
```

### 6. Write Tests

After creating the module, run the `write-test-cases` prompt for this module.

### 7. Log

Append to `.context/HISTORY.md`:
```
[{{date}}] feat: ${input:moduleName} module created — <list of files>
```

---

**Start with Stack Detection → display plan → wait for confirmation.**
