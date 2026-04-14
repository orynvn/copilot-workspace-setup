---
mode: agent
tools:
  - codebase
  - editFiles
  - readFile
  - runCommands
description: >
  Tạo migration file cho Laravel. Tự động detect tên bảng, columns, indexes,
  foreign keys và sinh ra migration + model fillable nếu cần.
---

# Create Migration Prompt (Laravel)

Tạo migration mới cho Laravel theo đúng convention.

## Thông tin migration

**Loại:** ${input:type:create | add_column | remove_column | add_index | add_foreign_key}
**Tên bảng:** ${input:table:Tên bảng (snake_case, plural) — vd: user_profiles}
**Mô tả:** ${input:description:Mô tả ngắn — vd: Thêm cột avatar_url vào users}

---

## Thực thi

### 1. Xác nhận context

Đọc `.context/DECISIONS.md` để check xem có quy tắc đặc biệt cho DB không.

### 2. Tạo migration

**Naming convention:**
- Create table: `create_<table>_table`
- Add column: `add_<column>_to_<table>_table`
- Remove column: `remove_<column>_from_<table>_table`
- Add index: `add_index_to_<table>_<columns>`
- Add foreign key: `add_<fk>_foreign_to_<table>_table`

Chạy lệnh:
```bash
php artisan make:migration <migration_name>
```

### 3. Nội dung migration

Tuân thủ `database.instructions.md`:
- Luôn implement cả `up()` và `down()`.
- Thêm index cho tất cả foreign key columns.
- Định nghĩa `onDelete` behavior rõ ràng.
- Không mix schema và data migration.

Template cho CREATE TABLE:
```php
public function up(): void
{
    Schema::create('${input:table}', function (Blueprint $table) {
        $table->id();
        // columns here
        $table->timestamps();
    });
}

public function down(): void
{
    Schema::dropIfExists('${input:table}');
}
```

### 4. Cập nhật Model (nếu create table)

Nếu đây là migration tạo bảng mới, tạo hoặc cập nhật Model:
```bash
php artisan make:model <ModelName>
```
Thêm `$fillable` array vào Model.

### 5. Log

Append vào `.context/HISTORY.md`:
```
[{{date}}] migration: ${input:description} — database/migrations/<filename>
```

---

**Bắt đầu: Hiển thị migration sẽ tạo → chờ confirm → tạo file.**
