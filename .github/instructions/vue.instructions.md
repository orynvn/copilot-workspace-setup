---
applyTo: "**/*.vue"
---

# Vue 3 — Coding Instructions

## Composition API

- Always use `<script setup>` syntax — never Options API for new code.
- Use `defineProps` and `defineEmits` with TypeScript generics:

```vue
<script setup lang="ts">
const props = defineProps<{ userId: string; label?: string }>()
const emit = defineEmits<{ select: [id: string] }>()
</script>
```

- Avoid `this` — it does not exist in `<script setup>`.

## File Structure Convention

```
src/
├── components/
│   ├── ui/           # Primitives (BaseButton, BaseInput)
│   └── features/     # Feature-specific (UserCard.vue, ProductList.vue)
├── composables/      # useAuth.ts, useCart.ts
├── views/            # Route-level components
├── stores/           # Pinia stores
├── services/         # API call functions
├── types/            # Shared TypeScript interfaces
└── utils/            # Pure utility functions
```

## Component Naming

- Single-file components: PascalCase filename → `UserProfile.vue`.
- Base/UI components: prefix `Base` → `BaseButton.vue`, `BaseModal.vue`.
- View components: suffix `View` → `DashboardView.vue`.
- Use multi-word names — never single-word to avoid HTML conflicts.

## State Management (Pinia)

- One store per domain: `useUserStore`, `useCartStore`.
- Define stores with `defineStore` using the **setup store** syntax (Composition API style):

```ts
export const useUserStore = defineStore('user', () => {
  const user = ref<User | null>(null)
  const isLoggedIn = computed(() => !!user.value)
  async function fetchUser(id: string) { ... }
  return { user, isLoggedIn, fetchUser }
})
```

- Never access stores outside of components/composables without `storeToRefs`.

## Composables

- File: `src/composables/useXxx.ts`.
- Always return reactive refs, not raw values.
- Clean up side effects in `onUnmounted`.

```ts
export function useDebounce<T>(value: Ref<T>, delay = 300) {
  const debouncedValue = ref<T>(value.value) as Ref<T>
  // ...
  return { debouncedValue }
}
```

## Reactivity Rules

- Use `ref()` for primitives, `reactive()` for plain objects (avoid destructuring reactive objects).
- Use `computed()` for derived values — never compute in templates.
- Prefer `watchEffect` for side effects that depend on reactive state automatically.

## Performance

- Use `defineAsyncComponent` for heavy or rarely used components.
- Apply `v-memo` on high-frequency list renders.
- Use `shallowRef` / `shallowReactive` for large, non-deep-watched data.

## Security

- Never use `v-html` with untrusted content — sanitize with DOMPurify first.
- Validate env vars at startup: `VITE_` prefix only for public config.
- Validate API inputs in the service layer, not in components.

## Testing

- Unit: Vitest + Vue Test Utils.
- Test behavior: mount component, interact, assert DOM state.
- Stub heavy child components with `stubs` option.
