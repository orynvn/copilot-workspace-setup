---
applyTo: "app/**/*.{ts,tsx}"
---

# Next.js — Coding Instructions

## App Router Conventions

- All routes live inside `app/` using the file-system router.
- **Server Components** are the default — add `"use client"` only when necessary (hooks, event handlers, browser APIs).
- Use **Server Actions** (`"use server"`) for form mutations instead of API routes when possible.
- Route handlers (`route.ts`) for external API consumers or webhook endpoints only.

## Component Architecture

```
app/
├── (auth)/              # Route group — no URL segment
├── dashboard/
│   ├── page.tsx         # Server Component (default)
│   ├── loading.tsx      # Suspense fallback
│   └── error.tsx        # Error boundary
components/
├── ui/                  # Primitive, reusable (shadcn/radix)
└── features/            # Feature-specific composites
```

## Data Fetching

- Fetch in Server Components; pass data as props to Client Components.
- Use `cache()` and `revalidatePath()` / `revalidateTag()` for ISR.
- Never call an internal API route from a Server Component — import the function directly.

```ts
// ✅ Good — direct import in Server Component
import { getUser } from '@/lib/db/users'
const user = await getUser(id)

// ❌ Bad
const res = await fetch('http://localhost:3000/api/users/' + id)
```

## Naming

| Entity | Convention | Example |
|---|---|---|
| Page file | `page.tsx` | `app/dashboard/page.tsx` |
| Layout file | `layout.tsx` | `app/layout.tsx` |
| Server Action file | `actions.ts` | `app/dashboard/actions.ts` |
| Component file | PascalCase | `UserCard.tsx` |
| Hook file | camelCase + `use` prefix | `useUserSession.ts` |
| Utility | kebab-case | `format-date.ts` |

## TypeScript

- Always define types/interfaces for props: no implicit `any`.
- Use `z.infer<typeof schema>` from Zod for form/API data shapes.
- Prefer `type` aliases for unions/intersections, `interface` for object shapes.

## Server Actions Pattern

```ts
"use server"
import { z } from 'zod'
import { revalidatePath } from 'next/cache'

const schema = z.object({ name: z.string().min(1) })

export async function updateUser(formData: FormData) {
  const parsed = schema.safeParse(Object.fromEntries(formData))
  if (!parsed.success) return { error: parsed.error.flatten() }
  // persist...
  revalidatePath('/dashboard')
}
```

## Security

- Never expose sensitive env vars to the client — use `NEXT_PUBLIC_` prefix only for intentionally public values.
- Validate ALL inputs in Server Actions with Zod before persisting.
- Use `next-auth` or equivalent — never implement custom session management.
- Set appropriate `Cache-Control` / `no-store` for sensitive pages.

## Performance

- Use `next/image` for all images — never raw `<img>`.
- Use `next/font` for fonts — never external CSS `@import`.
- Wrap heavy Client Components in `dynamic(() => import(...), { ssr: false })`.
- Add `loading.tsx` at every suspense boundary.
