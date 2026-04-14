---
applyTo: "src/**/*.{ts,tsx}"
---

# React (Vite) — Coding Instructions

> **TypeScript strict mode required.** `tsconfig.json` must have `"strict": true`. No `any`, no implicit returns, no non-null assertions without justification.

## Component Conventions

- Prefer **functional components** with hooks — no class components.
- One component per file; export as default.
- Keep components under ~100 lines — extract sub-components or hooks if longer.
- Props interface directly above the component:

```tsx
interface UserCardProps {
  userId: string
  onSelect: (id: string) => void
}

export default function UserCard({ userId, onSelect }: UserCardProps) { ... }
```

## File & Folder Structure

```
src/
├── components/
│   ├── ui/          # Primitives (Button, Input, Modal)
│   └── features/    # Feature composites (UserCard, ProductList)
├── hooks/           # Custom hooks: useAuth, useCart
├── pages/           # Route-level components (React Router)
├── services/        # API call functions
├── store/           # State management (Zustand / Redux)
├── types/           # Shared TypeScript types
└── utils/           # Pure utility functions
```

## State Management

- **Local UI state**: `useState` / `useReducer`.
- **Shared/global state**: Zustand (preferred) or Redux Toolkit.
- **Server state**: TanStack Query (`useQuery`, `useMutation`) — never fetch in `useEffect` for data fetching.
- Never store derived data in state — compute it.

```tsx
// ✅ Good — TanStack Query
const { data: user } = useQuery({ queryKey: ['user', id], queryFn: () => getUser(id) })

// ❌ Bad — manual fetch in useEffect
useEffect(() => { fetch('/api/user/' + id).then(...) }, [id])
```

## Custom Hooks

- Name: `use` prefix, camelCase → `useUserProfile`, `useDebounce`.
- One responsibility per hook.
- Return an object (not array) when returning multiple values:

```ts
// ✅ Good
return { data, isLoading, error, refetch }

// ❌ Bad (hard to destructure selectively)
return [data, isLoading, error]
```

## Performance

- Wrap expensive computations in `useMemo`.
- Stabilize callbacks with `useCallback` when passing to memoized children.
- Use `React.lazy` + `<Suspense>` for route-level code splitting.
- Avoid anonymous functions / object literals in JSX props for stable references.

## Forms

- Use **React Hook Form** + **Zod** for all forms.
- Never manage form state with `useState` per field.

```tsx
const schema = z.object({ email: z.string().email() })
const form = useForm<z.infer<typeof schema>>({ resolver: zodResolver(schema) })
```

## TypeScript Strict Rules

- `strict: true` — no exceptions. This includes `noImplicitAny`, `strictNullChecks`, `strictFunctionTypes`.
- `noUncheckedIndexedAccess: true` in tsconfig — prevents unsafe array/object index access.
- Never use `as SomeType` casts unless interfacing with untyped external APIs — use type guards instead.
- Never use `!` (non-null assertion) without a comment explaining why it's safe.
- Use `z.infer<typeof schema>` from Zod as the single source of truth for form/API data shapes.
- Use `satisfies` operator to validate literal objects against a type without widening.

```ts
// ✅ Type guard instead of cast
function isApiError(val: unknown): val is ApiError {
  return typeof val === 'object' && val !== null && 'message' in val
}

// ❌ Avoid
const error = data as ApiError
```

## Security

- Sanitize user-generated HTML with DOMPurify before rendering with `dangerouslySetInnerHTML`.
- Never include secrets in the Vite bundle — use `VITE_` prefix only for public config.
- Validate all inputs before submitting to an API.

## Testing

- Unit tests: Vitest + React Testing Library.
- Test by behavior, not implementation: query by role/label, not CSS class.
- Mock API calls at the `services/` boundary, not inside components.
