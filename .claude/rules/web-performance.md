# Web Performance

> **Note:** This file covers browser/web performance for consumer-facing applications.
> For AI model selection and context window management, see `performance.md`.

---

## Core Web Vitals (MANDATORY)

Every consumer-facing page must meet these targets:

| Metric | Target | What It Measures |
|--------|--------|-----------------|
| LCP | < 2.5s | Largest Contentful Paint — how fast main content loads |
| FID | < 100ms | First Input Delay — responsiveness to first interaction |
| CLS | < 0.1 | Cumulative Layout Shift — visual stability |
| INP | < 200ms | Interaction to Next Paint — overall input responsiveness |

**Lighthouse Score: > 90** on Performance, Accessibility, Best Practices, and SEO.

---

## Bundle Budget

### JavaScript Budget

```
Total JS bundle: < 200KB gzipped
```

### Optimization Strategies

**Code Splitting** — Every route/page should be a separate bundle (most frameworks do this automatically).

**Dynamic Imports** — Lazy-load heavy components that are not visible on initial render:

```typescript
// Heavy components: modals, charts, video players, editors
const Chart = dynamic(() => import('@/components/Chart'), {
  loading: () => <Spinner />,
})

// Only load when needed
const Modal = dynamic(() => import('@/components/Modal'))
{showModal && <Modal />}
```

**Tree Shaking** — Import only what you use:

```typescript
// WRONG: imports entire library
import * as Icons from 'lucide-react'

// CORRECT: imports only used icons
import { ShoppingCart, User, Search } from 'lucide-react'
```

**Bundle Analysis** — Run bundle analyzer regularly to detect:
- Oversized packages
- Duplicate code
- Dependencies that don't tree-shake

---

## Image Optimization (CRITICAL)

Images are typically the largest assets on any page. Optimize aggressively.

### Rules

```
[ ] ALL images use the framework's image component (next/image, etc.)
[ ] ALL images served in WebP format (with AVIF as progressive enhancement)
[ ] ALL images have explicit width and height (prevents CLS)
[ ] Above-the-fold images use priority/eager loading
[ ] Below-the-fold images use lazy loading (default)
[ ] Blur placeholders for better perceived performance
[ ] Responsive sizes attribute for correct image selection
```

### Image Component Usage

```typescript
// Above the fold — priority loading
<Image
  src="/hero.webp"
  alt="Descriptive text"
  width={1920}
  height={1080}
  priority
  quality={85}
/>

// Below the fold — lazy loading (default)
<Image
  src="/product.webp"
  alt="Descriptive text"
  width={400}
  height={400}
  placeholder="blur"
  blurDataURL={blurData}
/>

// Responsive with fill
<Image
  src="/banner.webp"
  alt="Descriptive text"
  fill
  sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw"
  className="object-cover"
/>
```

### Image Format Priority

```
SVG   — Icons, logos, simple graphics
WebP  — All photographs and complex images (primary)
AVIF  — Progressive enhancement (better compression, lower support)
```

---

## Font Optimization

### Rules

```
[ ] Use framework font optimization (next/font, etc.)
[ ] display: swap — prevent Flash of Invisible Text (FOIT)
[ ] WOFF2 format only for custom fonts
[ ] Subset fonts — only include needed character sets
[ ] Preload critical fonts
[ ] Maximum 2-3 font families per project
[ ] Only load needed weights (don't import all 9 weights)
```

### Font Loading Pattern

```typescript
// Framework font optimization (auto-hosts, subsets, optimizes)
import { Inter, Roboto_Mono } from 'next/font/google'

const inter = Inter({
  subsets: ['latin'],
  display: 'swap',
  variable: '--font-inter',
  preload: true,
})

// Use only the weights you actually need
const robotoMono = Roboto_Mono({
  subsets: ['latin'],
  weight: ['400', '700'],
  variable: '--font-roboto-mono',
  display: 'swap',
})
```

### Custom Fonts

```html
<!-- Preload critical custom fonts -->
<link
  rel="preload"
  href="/fonts/CustomFont.woff2"
  as="font"
  type="font/woff2"
  crossOrigin="anonymous"
/>
```

---

## CSS Optimization

### Rules

```
[ ] Use utility-first CSS (Tailwind) — automatic tree-shaking/purging
[ ] Minimize custom CSS — use utilities when possible
[ ] No @import in CSS files (causes cascading requests)
[ ] Critical CSS inlined automatically (frameworks handle this)
[ ] No unused CSS in production
```

### Anti-Patterns

```css
/* WRONG: custom CSS for what utilities handle */
.custom-card {
  padding: 1rem;
  border-radius: 0.5rem;
  background: white;
}

/* CORRECT: use utilities */
/* <div className="p-4 rounded-lg bg-white"> */
```

---

## JavaScript Optimization

### Rendering Performance

```typescript
// useMemo for expensive calculations
const sorted = useMemo(() => {
  return items.sort((a, b) => b.score - a.score)
}, [items])

// useCallback for functions passed to children
const handleClick = useCallback((id: string) => {
  addToCart(id)
}, [addToCart])

// React.memo for pure components that receive stable props
export const ProductCard = React.memo(({ product }: Props) => {
  return <div>{/* render */}</div>
})
```

### Virtualization for Long Lists

For lists with 100+ items, use virtualization instead of rendering everything:

```typescript
import { useVirtualizer } from '@tanstack/react-virtual'

function VirtualList({ items }: { items: Item[] }) {
  const parentRef = useRef<HTMLDivElement>(null)

  const virtualizer = useVirtualizer({
    count: items.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 100,
  })

  return (
    <div ref={parentRef} style={{ height: '600px', overflow: 'auto' }}>
      {virtualizer.getVirtualItems().map((row) => (
        <div key={row.index}>{items[row.index].name}</div>
      ))}
    </div>
  )
}
```

### Input Debouncing

Debounce search inputs, filter changes, and other rapid user interactions:

```typescript
// 300ms debounce on search input
const debouncedSearch = useMemo(
  () => debounce((query: string) => fetchResults(query), 300),
  [fetchResults]
)
```

---

## Caching Strategy

### Static Content

For content that changes infrequently, use static generation with periodic revalidation:

```typescript
// Revalidate every hour
export const revalidate = 3600

// Pre-generate known pages at build time
export async function generateStaticParams() {
  const items = await getItems()
  return items.map((item) => ({ id: item.id }))
}
```

### API Responses

```typescript
// Cache-Control for API routes
return Response.json(data, {
  headers: {
    'Cache-Control': 'public, s-maxage=3600, stale-while-revalidate=86400',
  },
})
```

### Static Assets

- Use CDN for all static assets (images, fonts, scripts)
- Set long cache TTL for versioned/hashed assets
- Use framework's built-in asset optimization

---

## Lighthouse CI

### Integration

Run Lighthouse on every pull request to prevent performance regressions:

```yaml
# .github/workflows/lighthouse.yml
name: Lighthouse CI

on:
  pull_request:
    branches: [main]

jobs:
  lighthouse:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: npm ci && npm run build
      - uses: treosh/lighthouse-ci-action@v12
        with:
          urls: |
            http://localhost:3000
            http://localhost:3000/key-page
          budgetPath: ./budget.json
          uploadArtifacts: true
```

### Performance Budget

```json
{
  "budgets": [
    {
      "path": "/*",
      "timings": [
        { "metric": "interactive", "budget": 3000 },
        { "metric": "first-contentful-paint", "budget": 1000 }
      ],
      "resourceSizes": [
        { "resourceType": "script", "budget": 200 },
        { "resourceType": "total", "budget": 500 }
      ]
    }
  ]
}
```

---

## Anti-Patterns (DO NOT)

```
NEVER: Import entire icon/utility libraries
NEVER: Use raw <img> tags instead of framework image components
NEVER: Skip width/height on images (causes CLS)
NEVER: Load all font weights when you only need 2
NEVER: Use @import in CSS (cascading requests)
NEVER: Ship unminified CSS/JS to production
NEVER: Render 500+ items without virtualization
NEVER: Skip lazy loading for below-the-fold content
NEVER: Use blocking third-party scripts in <head>
NEVER: Ignore Lighthouse regressions in CI
```

---

## Performance Audit Checklist

Before launch or major release:

```
BUNDLE
[ ] Total JS < 200KB gzipped
[ ] Code splitting implemented (per route)
[ ] Dynamic imports for heavy components
[ ] Tree shaking verified (no full library imports)
[ ] No duplicate code in bundles
[ ] Bundle analyzer run, no surprises

IMAGES
[ ] All images use framework image component
[ ] All images in WebP format
[ ] Width/height defined on all images
[ ] Priority on above-the-fold images
[ ] Lazy load on below-the-fold images
[ ] Blur placeholders implemented
[ ] Responsive sizes attribute set

FONTS
[ ] Framework font optimization used
[ ] display: swap configured
[ ] Only needed weights loaded
[ ] WOFF2 format for custom fonts
[ ] Preload for critical fonts

CSS
[ ] Utility-first CSS with automatic purging
[ ] No unused CSS in production
[ ] No @import statements
[ ] Critical CSS inlined

JAVASCRIPT
[ ] useMemo for expensive calculations
[ ] useCallback for stable function references
[ ] Virtualization for long lists
[ ] Debouncing on rapid inputs

CACHING
[ ] Static generation where possible
[ ] Revalidation configured
[ ] API routes with Cache-Control headers
[ ] CDN for static assets

CORE WEB VITALS
[ ] LCP < 2.5s
[ ] FID < 100ms
[ ] CLS < 0.1
[ ] INP < 200ms
[ ] Lighthouse score > 90

MONITORING
[ ] Lighthouse CI on pull requests
[ ] Performance budgets defined
[ ] Regression alerts configured
```
