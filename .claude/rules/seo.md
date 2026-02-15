# SEO

## When This Applies

These rules apply to any consumer-facing web application that needs organic search visibility. For internal tools, admin panels, or authenticated-only apps, SEO may not be relevant — but HTML semantics and accessibility still are.

---

## HTML Semantics (CRITICAL)

### Use Semantic Elements

```html
<article>    <!-- Self-contained content (blog post, product, comment) -->
<section>    <!-- Thematic grouping with a heading -->
<nav>        <!-- Navigation links -->
<header>     <!-- Introductory content, typically with heading -->
<footer>     <!-- Footer content -->
<aside>      <!-- Related but tangential content (sidebar, callout) -->
<main>       <!-- Primary content (one per page) -->
```

**DO NOT** use only `<div>` and `<span>` for structural content. Search engines and screen readers rely on semantic elements to understand page structure.

### Heading Hierarchy

```
<h1>  — ONE per page (main page title / primary keyword)
  <h2>  — Major sections
    <h3>  — Subsections
      <h4>  — Details within subsections
```

**Rules:**
- Exactly one `<h1>` per page
- Never skip levels (`<h1>` then `<h3>` without `<h2>`)
- Headings describe content structure, not visual styling
- Use CSS for visual sizing, not heading level

---

## URL Structure

### Clean, Descriptive URLs

```
CORRECT:
/products/electronics/wireless-headphones
/blog/2026/seo-optimization-guide
/about/team

WRONG:
/page?id=123&cat=4
/products/item/12345
/p/abc123
```

### Architecture Rules

- Maximum 3 clicks from homepage to any content
- HTTPS everywhere (no mixed content)
- Consistent trailing slash policy (pick one and enforce)
- No unnecessary query parameters in canonical URLs
- Lowercase only, hyphens for word separation

---

## Metadata Patterns

### Every Page Must Have

```typescript
// Required metadata per page
{
  title: string       // 50-60 characters, includes primary keyword
  description: string // 150-160 characters, includes call-to-action
  canonical: string   // Full absolute URL
}
```

### Title Guidelines

- 50-60 characters maximum
- Primary keyword near the beginning
- Brand name at the end: `Page Title | Brand Name`
- Unique per page — never duplicate titles across pages

### Description Guidelines

- 150-160 characters maximum
- Summarize page content clearly
- Include a call-to-action when appropriate
- Unique per page — never duplicate descriptions

### Open Graph (Social Sharing)

Every public page should include:

```
og:title        — Same as or similar to page title
og:description  — Same as or similar to meta description
og:image        — 1200x630px image
og:type         — "website" (default) or "article"
og:url          — Canonical URL
```

### Twitter Card

```
twitter:card         — "summary_large_image" (preferred)
twitter:title        — Page title
twitter:description  — Page description
twitter:image        — Same as og:image
```

### Dynamic Metadata

For data-driven pages (products, articles, profiles), generate metadata dynamically from the content. Never use generic placeholder text.

---

## Structured Data (Schema.org)

### Format

Use JSON-LD (preferred by Google) embedded in the page:

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Product",
  "name": "Product Name",
  "description": "Product description",
  "offers": {
    "@type": "Offer",
    "price": "99.99",
    "priceCurrency": "USD",
    "availability": "https://schema.org/InStock"
  }
}
</script>
```

### Common Schema Types

| Page Type | Schema Type | Key Properties |
|-----------|------------|----------------|
| Product | Product | name, description, offers, aggregateRating |
| Article/Blog | Article | headline, author, datePublished, image |
| Company | Organization | name, url, logo, contactPoint |
| FAQ | FAQPage | mainEntity (array of Questions) |
| Breadcrumbs | BreadcrumbList | itemListElement |
| Local Business | LocalBusiness | name, address, telephone, openingHours |
| Person | Person | name, jobTitle, image, sameAs |

### Validation

Always validate structured data with Google's Rich Results Test before shipping.

---

## Sitemap & Robots

### Sitemap

Auto-generate `sitemap.xml` with:

```
- All public pages
- lastModified date (from content update)
- changeFrequency: daily (home), weekly (content), monthly (static)
- priority: 1.0 (home), 0.8 (key pages), 0.5 (secondary)
```

**DO NOT** include:
- Admin pages
- API routes
- Authentication pages
- Pages with `noindex`

### Robots.txt

```
User-agent: *
Allow: /
Disallow: /admin/
Disallow: /api/
Disallow: /auth/
Disallow: /dashboard/

Sitemap: https://yourdomain.com/sitemap.xml
```

---

## Image SEO

### Alt Text

- **Descriptive and specific** — describe what the image shows
- **Include keywords naturally** — don't force them
- **Don't start with** "Image of..." or "Photo of..."
- **Empty alt=""** only for purely decorative images
- Every content image must have alt text

### Image Format

- WebP as primary format (best compression-to-quality ratio)
- AVIF as progressive enhancement (even better, lower browser support)
- SVG for icons and logos
- Always define `width` and `height` to prevent layout shift

### Image Sizing

```
// Use responsive sizes attribute
sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw"
```

---

## Internal Linking

### Anchor Text

- Descriptive and relevant: `Learn about our pricing` not `click here`
- Varies naturally across the site
- Links to related content within articles/pages

### Breadcrumbs

Implement breadcrumbs on all content pages deeper than the homepage:

```
Home > Category > Subcategory > Current Page
```

Use BreadcrumbList Schema.org markup for rich snippets.

### Site Architecture

- Flat hierarchy: important pages within 2-3 clicks of homepage
- Category pages link to children
- Related content linked within page body
- No orphan pages (every page reachable via at least one internal link)
- No broken links (404s)

---

## Indexation Control

### Meta Robots

```html
<!-- Default: allow indexing -->
<meta name="robots" content="index, follow">

<!-- Prevent indexing (admin, auth, temporary pages) -->
<meta name="robots" content="noindex, nofollow">
```

### Canonical URLs

Every page must have a canonical URL pointing to the preferred version:

```html
<link rel="canonical" href="https://yourdomain.com/page-slug" />
```

**Use canonicals to:**
- Prevent duplicate content from query parameters
- Choose preferred URL when content is accessible via multiple paths
- Handle www vs non-www, http vs https

---

## SEO Audit Checklist

Before launching or after significant changes:

```
TECHNICAL
[ ] Sitemap.xml generated and accessible
[ ] Robots.txt configured correctly
[ ] HTTPS everywhere, no mixed content
[ ] No broken links (internal or external)
[ ] Clean URL structure
[ ] Canonical URLs on all pages

HTML & CONTENT
[ ] One <h1> per page
[ ] Heading hierarchy correct (no skipped levels)
[ ] Semantic HTML elements used
[ ] Unique title and description per page
[ ] Titles 50-60 chars, descriptions 150-160 chars

STRUCTURED DATA
[ ] JSON-LD Schema.org on key pages
[ ] Validated with Rich Results Test
[ ] Breadcrumb markup implemented

IMAGES
[ ] Alt text on all content images
[ ] WebP format used
[ ] Width and height defined
[ ] Responsive sizes attribute

SOCIAL
[ ] Open Graph tags on all public pages
[ ] Twitter Card tags on all public pages
[ ] OG image (1200x630) for key pages

PERFORMANCE (see web-performance.md)
[ ] Core Web Vitals passing
[ ] Lighthouse SEO score > 90
```

---

## SEO Audit Report Format

```markdown
## SEO AUDIT — [Page/Site]

### VERDICT: OPTIMAL / NEEDS IMPROVEMENT / CRITICAL

### 1. TECHNICAL SEO
- URLs: [status]
- Sitemap: [status]
- Robots.txt: [status]
- HTTPS: [status]
- Canonicals: [status]

### 2. ON-PAGE SEO
- Titles: [status] (any > 60 chars?)
- Descriptions: [status]
- Headings: [status] (any pages with multiple h1?)
- Schema markup: [status]

### 3. IMAGES
- Alt text coverage: [percentage]
- WebP format: [status]
- Dimensions defined: [status]

### 4. CRITICAL ISSUES
1. [Description] — Impact: High/Medium/Low — Fix: [action]

### 5. OPPORTUNITIES
1. [Description] — Impact: [level] — Effort: [level]

### CONCLUSION
[Summary with prioritized actions]
```
