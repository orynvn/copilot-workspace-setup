---
applyTo: "**/migrations/**,**/database/migrations/**,**/db/migrations/**"
---

# Database Migrations — Coding Instructions

## General Rules

- Migrations must be **idempotent** and **reversible** — always implement both `up()` and `down()`.
- Never modify an existing migration that has been deployed — create a new one instead.
- One logical change per migration file.
- Test `down()` locally before committing.

## Naming Convention

| Operation | Pattern | Example |
|---|---|---|
| Create table | `create_<table>_table` | `create_users_table` |
| Add column | `add_<column>_to_<table>_table` | `add_avatar_to_users_table` |
| Remove column | `remove_<column>_from_<table>_table` | `remove_legacy_field_from_orders_table` |
| Add index | `add_index_to_<table>_<columns>` | `add_index_to_orders_user_id` |
| Add foreign key | `add_<fk>_foreign_to_<table>_table` | `add_user_id_foreign_to_posts_table` |
| Rename table | `rename_<old>_to_<new>_table` | `rename_items_to_products_table` |

## Column Conventions

- Primary key: `id` (auto-increment BIGINT unsigned).
- Foreign keys: `<related_model>_id` → `user_id`, `product_id`.
- Timestamps: always include `created_at` / `updated_at` (use `timestamps()`).
- Soft deletes: add `deleted_at` column when soft-delete is needed.
- Boolean columns: prefix `is_` or `has_` → `is_active`, `has_verified_email`.
- JSON columns: use only when structure is truly variable — prefer relational columns.

## Index Rules

- Add index on every **foreign key** column automatically.
- Add index on columns used in `WHERE`, `ORDER BY`, or `GROUP BY` with high frequency.
- Composite index order: most selective column first.
- Name indexes explicitly: `<table>_<column(s)>_index`.

```php
// Laravel example
$table->index(['user_id', 'created_at'], 'orders_user_id_created_at_index');
```

## Foreign Key Constraints

- Always define FK constraints at the DB level — not just in the ORM.
- Define `onDelete` behavior explicitly: `cascade`, `restrict`, or `set null`.
- Never use `cascade` on delete for business-critical records — use `restrict` and handle in application code.

```php
// Laravel example
$table->foreignId('user_id')->constrained()->onDelete('cascade');
```

## Data Migrations

- Never mix schema changes and data migrations in the same file.
- For data migrations, use a separate migration with a `-- DATA MIGRATION` comment at the top.
- Batch large data migrations — never process millions of rows without chunking.

## Security

- Never store plaintext passwords, secrets, or tokens in any column.
- Columns holding PII (email, phone, SSN) should be noted in a `PRIVACY.md` data map.
- Apply column-level encryption for sensitive fields where required by compliance.
