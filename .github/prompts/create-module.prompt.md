---
mode: agent
tools:
  - codebase
  - editFiles
  - readFile
  - runCommands
description: >
  Tạo một module hoàn chỉnh theo đúng architecture của stack hiện tại.
  Bao gồm: Controller/Component, Service, Repository/Store, Types, Tests.
---

# Create Module Prompt

Tạo module mới hoàn chỉnh cho stack hiện tại.

## Thông tin module

**Tên module:** ${input:moduleName:Tên module (PascalCase) — vd: Product, Order, Invoice}
**Mô tả:** ${input:description:Module này làm gì?}
**CRUD operations:** ${input:operations:Các operations cần (vd: list, show, create, update, delete)}

---

## Thực thi

### 1. Stack Detection & Planning

Xác định stack:
- `composer.json` + `artisan` → **Laravel module**
- `package.json` dep `"next"` → **Next.js module**
- `package.json` dep `"vite"` + `"react"` → **React module**
- `package.json` dep `"vue"` → **Vue 3 module**

Hiển thị files sẽ tạo theo stack → **chờ confirm**.

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

### 6. Viết Tests

Sau khi tạo xong module, chạy `write-test-cases` prompt cho module này.

### 7. Log

Append vào `.context/HISTORY.md`:
```
[{{date}}] feat: ${input:moduleName} module created — <list of files>
```

---

**Bắt đầu với Stack Detection → hiển thị plan → chờ confirm.**
