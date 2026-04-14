# Next.js — Project-specific Copilot Instructions

> **Override file cho dự án Next.js.**  
> Copy file này vào `.github/copilot-instructions.md` của project Next.js.  
> Các quy tắc trong file này kết hợp với global rules.

---

## Stack: Next.js + TypeScript

### Phiên bản tối thiểu
- Node.js: 20 LTS+
- Next.js: 15.x (App Router)
- TypeScript: 5.x strict mode
- Database ORM: Prisma 5.x (preferred) hoặc Drizzle

---

## Architecture

```
app/
├── (auth)/                    # Route group — auth pages, no URL segment
├── (dashboard)/               # Route group — authenticated pages
│   ├── layout.tsx             # Dashboard layout với auth guard
│   └── dashboard/
│       ├── page.tsx           # Server Component (default)
│       ├── loading.tsx        # Suspense skeleton
│       └── error.tsx          # Error boundary
├── api/                       # Route handlers (external APIs, webhooks)
│   └── webhooks/
│       └── stripe/route.ts
├── globals.css
└── layout.tsx                 # Root layout

components/
├── ui/                        # shadcn/ui primitives
└── features/                  # Feature-specific composites

lib/
├── auth.ts                    # next-auth config
├── db.ts                      # Prisma client singleton
├── validations/               # Zod schemas
└── <domain>/                  # Domain-specific DB functions

actions/                       # Server Actions (global, reusable)
├── auth-actions.ts
└── user-actions.ts

types/
└── index.ts                   # Shared TypeScript types
```

## Data Flow

```
User interaction
  → Server Action (mutation) hoặc Server Component (read)
  → lib/<domain>/db-function.ts (data access)
  → Prisma → Database
  → revalidatePath() / revalidateTag()
  → UI re-render
```

## Key rules

- **Server Components** là default — thêm `"use client"` chỉ khi cần hooks/events.
- **Server Actions** cho mutations — không tạo API route chỉ để gọi từ frontend.
- **Route handlers** (`route.ts`) chỉ cho external consumers (webhooks, mobile apps).
- **Prisma Client** dùng singleton pattern trong `lib/db.ts`.
- Mọi Server Action phải validate với **Zod** trước khi persist.

## TypeScript strict mode

```json
// tsconfig.json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true
  }
}
```

- Không dùng `any` — dùng `unknown` hoặc proper types.
- Mọi component props phải có type definition.
- Dùng `z.infer<typeof schema>` thay vì define type thủ công cho form data.

## Auth pattern (next-auth v5)

```ts
// lib/auth.ts
import NextAuth from 'next-auth'
export const { handlers, signIn, signOut, auth } = NextAuth({ ... })

// Middleware protection
// middleware.ts
export { auth as middleware } from './lib/auth'
```

## Environment Variables

```bash
# .env.local — không commit
DATABASE_URL="postgresql://..."
NEXTAUTH_SECRET="generated-secret"
NEXTAUTH_URL="http://localhost:3000"

# Public vars (bundle-safe)
NEXT_PUBLIC_APP_URL="http://localhost:3000"
```

Rule: chỉ `NEXT_PUBLIC_` cho values intentionally public.

## Performance checklist

- [ ] Images: `next/image` — không dùng raw `<img>`
- [ ] Fonts: `next/font` — không dùng CSS `@import`
- [ ] Heavy Client Components: `dynamic(() => import(...), { ssr: false })`
- [ ] Mọi async boundary: `<Suspense>` + `loading.tsx`
- [ ] DB queries: implement pagination — không fetch unlimited records

## Testing

- Unit/Integration: **Vitest** + React Testing Library
- E2E: **Playwright**
- Server Actions: test qua integration tests (mock DB với vitest)
- MSW (Mock Service Worker) cho mocking fetch trong tests

## Local development

```bash
# Start dev
npm run dev

# Type check
npm run type-check

# Lint
npm run lint

# Tests
npm run test          # vitest
npm run test:e2e      # playwright

# Database
npx prisma generate
npx prisma migrate dev
npx prisma studio
```

## Forbidden patterns

- ❌ `fetch('http://localhost:3000/api/...')` trong Server Components — import trực tiếp
- ❌ Sensitive data trong `NEXT_PUBLIC_*` vars
- ❌ `useEffect` chỉ để fetch data — dùng Server Component hoặc TanStack Query
- ❌ `any` type — define proper types
- ❌ Client Component wrapper toàn bộ page chỉ vì 1 button cần event handler
