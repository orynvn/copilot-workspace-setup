# Next.js — Project-specific Copilot Instructions

> **Override file for Next.js projects.**
> Copy this file to `.github/copilot-instructions.md` in your Next.js project.
> Rules in this file combine with the global rules.

---

## Stack: Next.js + TypeScript

### Minimum version
- Node.js: 20 LTS+
- Next.js: 15.x (App Router)
- TypeScript: 5.x strict mode
- Database ORM: Prisma 5.x (preferred) or Drizzle

---

## Architecture

```
app/
├── (auth)/                    # Route group — auth pages, no URL segment
├── (dashboard)/               # Route group — authenticated pages
│   ├── layout.tsx             # Dashboard layout with auth guard
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
  → Server Action (mutation) or Server Component (read)
  → lib/<domain>/db-function.ts (data access)
  → Prisma → Database
  → revalidatePath() / revalidateTag()
  → UI re-render
```

## Key rules

- **Server Components** are the default — add `"use client"` only when hooks/events are needed.
- **Server Actions** for mutations — do not create API routes just to call from the frontend.
- **Route handlers** (`route.ts`) only for external consumers (webhooks, mobile apps).
- **Prisma Client** uses the singleton pattern in `lib/db.ts`.
- Every Server Action must validate with **Zod** before persisting.

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

- Do not use `any` — use `unknown` or proper types.
- Every component prop must have a type definition.
- Use `z.infer<typeof schema>` instead of defining types manually for form data.

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
# .env.local — do not commit
DATABASE_URL="postgresql://..."
NEXTAUTH_SECRET="generated-secret"
NEXTAUTH_URL="http://localhost:3000"

# Public vars (bundle-safe)
NEXT_PUBLIC_APP_URL="http://localhost:3000"
```

Rule: only `NEXT_PUBLIC_` for intentionally public values.

## Performance checklist

- [ ] Images: `next/image` — do not use raw `<img>`
- [ ] Fonts: `next/font` — do not use CSS `@import`
- [ ] Heavy Client Components: `dynamic(() => import(...), { ssr: false })`
- [ ] Every async boundary: `<Suspense>` + `loading.tsx`
- [ ] DB queries: implement pagination — do not fetch unlimited records

## Testing

- Unit/Integration: **Vitest** + React Testing Library
- E2E: **Playwright**
- Server Actions: test via integration tests (mock DB with vitest)
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

- ❌ `fetch('http://localhost:3000/api/...')` in Server Components — import directly
- ❌ Sensitive data in `NEXT_PUBLIC_*` vars
- ❌ `useEffect` only to fetch data — use Server Component or TanStack Query
- ❌ `any` type — define proper types
- ❌ Client Component wrapping an entire page just because 1 button needs an event handler
