# Design System

## Responsive Design Fundamentals

### Mobile-First is Mandatory

Design for the smallest screen first, then progressively enhance for larger screens. Mobile is not a "cropped" version — it is a more focused version that prioritizes primary actions.

```
CORRECT FLOW:
1. Define minimum functional version (mobile)
2. Scale progressively toward larger sizes
3. Reorganize by reflow, not by hiding content

DO NOT: Hide critical content on mobile
DO NOT: Duplicate components per breakpoint
DO: Reorganize visual hierarchy
DO: Adjust information density
```

Desktop is not a "bigger" version — it is a version with more room to breathe and more visual complexity.

**Components do not change personality between screen sizes, only distribution and priority.**

### Standard Breakpoints

```
sm:   640px   — Large mobile / Small tablet
md:   768px   — Tablet
lg:   1024px  — Laptop
xl:   1280px  — Desktop
2xl:  1536px  — Large desktop
```

Always use mobile-first prefixes: base styles apply to mobile, `sm:` and up add enhancements.

```typescript
// Correct: mobile-first progressive enhancement
<div className="
  px-4 sm:px-6 md:px-8 lg:px-12 xl:px-16
  text-base sm:text-lg md:text-xl
  grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4
">
```

### Touch Targets and Accessibility

```typescript
// Minimum 44x44px for interactive elements
<button className="min-w-[44px] min-h-[44px] p-3">

// Minimum 16px gap between interactive elements
<nav className="flex gap-4">

// Minimum 16px base font size on mobile
<p className="text-base md:text-lg">

// WCAG AA contrast: 4.5:1 for text, 3:1 for large text
```

### Audit Before Writing

Before writing any UI code, audit the existing design configuration:

```
[ ] Design tokens defined and consistent (colors, spacing, typography)
[ ] Breakpoints clear and documented
[ ] Spacing scale coherent
[ ] Border radius consistent
[ ] Shadows and effects predefined
[ ] Layout patterns established
```

**Rules:**
- If the configuration is consistent — respect it 100%
- If there are inconsistencies — modify only the minimum necessary to fix them
- Never modify for personal taste or shortcuts
- Every change must strengthen the system, not fragment it

---

## Anti-Patterns (DO NOT)

### Banned Practices

```typescript
// NEVER: Arbitrary pixel values
<div className="w-[342px]">        // Use w-full max-w-md instead
<div className="text-[18.5px]">    // Use text-lg instead
<div className="mt-[23px]">        // Use mt-6 instead

// NEVER: Confusing breakpoint visibility logic
<div className="hidden md:block lg:hidden xl:block">  // Simplify

// NEVER: Inline style overrides
<div style={{ width: '342px' }}>   // Use design system classes

// NEVER: Magic numbers without explanation
<div className="top-[73px]">       // Why 73? Use a token
```

### Correct Alternatives

```typescript
// Containers from the system
<div className="w-full max-w-md">
<div className="container mx-auto px-4 md:px-6 lg:px-8">

// Typographic scale
<div className="text-lg md:text-xl">

// Simple visibility logic
<div className="hidden lg:block">

// Responsive grid with scaling gaps
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 md:gap-6 lg:gap-8">

// Stack to row
<div className="flex flex-col md:flex-row gap-4 items-start md:items-center">
```

---

## Component Architecture: Atomic Design

Organize all UI following five clear, reusable levels.

### Level 1: Atoms

**Basic, indivisible UI elements.**

Examples: Button, Input, Label, Icon, Badge, Avatar, Spinner, Divider

Characteristics:
- Single responsibility
- Do not contain other components (except HTML primitives)
- Highly reusable across the entire app
- Variants defined by props, not separate components
- Styles 100% from the design system / theme

### Level 2: Molecules

**Combine 2-5 atoms for a specific function.**

Examples: FormField (Label + Input + ErrorMessage), SearchBar (Input + Button + Icon), UserInfo (Avatar + Name + Role), RatingDisplay (Stars + Count)

Characteristics:
- Focused on one specific purpose
- Props describe their purpose, not their internals
- Unaware of page context

### Level 3: Organisms

**Group molecules into complete, functional sections.**

Examples: Header (Logo + Navigation + SearchBar + UserMenu), ProductCard (Image + Title + Price + Rating + AddToCartButton), ContactForm (FormFields + SubmitButton + States), Footer (Logo + LinkGroups + Newsletter + Social)

Characteristics:
- Complete, self-contained sections
- May have internal state
- Can contain simple business logic
- Reusable across pages

### Level 4: Templates

**Define page structure and layout without real content.**

Examples: HomeTemplate, ProductPageTemplate, DashboardTemplate

Characteristics:
- Define wireframe / structural layout
- Receive sections as props or children
- No hardcoded content
- No data fetching logic
- Establish visual hierarchy

### Level 5: Pages

**Final instances with real content and data.**

Characteristics:
- Real content and data fetching
- Compose templates with organisms
- Full end-to-end flow validation

### Folder Structure

```
components/
├── atoms/           # Level 1
│   ├── Button.tsx
│   ├── Input.tsx
│   ├── Label.tsx
│   └── index.ts     # Barrel exports
├── molecules/       # Level 2
│   ├── FormField.tsx
│   ├── SearchBar.tsx
│   └── index.ts
├── organisms/       # Level 3
│   ├── Header.tsx
│   ├── Footer.tsx
│   ├── ProductCard.tsx
│   └── index.ts
└── templates/       # Level 4
    ├── HomeTemplate.tsx
    ├── DashboardTemplate.tsx
    └── index.ts

app/                 # Level 5 (Pages)
├── page.tsx
├── shop/page.tsx
└── product/[id]/page.tsx
```

### Decision Rules

| Question | Answer |
|----------|--------|
| Is it a single HTML element with variants? | Atom |
| Does it combine 2-5 atoms for one purpose? | Molecule |
| Is it a complete section with multiple molecules? | Organism |
| Does it define page layout without content? | Template |
| Does it fetch data and compose a full view? | Page |

---

## Component Design Principles

1. **Single Responsibility** — A Button only renders a button. It does NOT handle checkout logic.

2. **Variants via Props** — Use one component with variant props, not separate components:
   ```typescript
   // CORRECT: <Button variant="primary">
   // WRONG:  <PrimaryButton>, <SecondaryButton>, <TertiaryButton>
   ```

3. **Styles Decoupled from Content** — Components receive content via props/children, never hardcode text or data.

4. **Semantic, Consistent Naming**:
   ```typescript
   // CORRECT: UserAvatar, ProductCard, CheckoutForm
   // WRONG:  Avatar2, Card_v3, Form1
   ```

5. **Document Variants and States** — Every component should clearly define its available variants, sizes, and states.

6. **Test in Real Context** — Don't consider a component done until tested with:
   - Multiple breakpoints
   - Real content (short and long text)
   - Different contexts (light/dark mode)
   - All states (loading, error, success, empty, disabled)

---

## Accessibility (WCAG AA)

### Non-Negotiable Requirements

```
CONTRAST
- Text: 4.5:1 minimum contrast ratio
- Large text (18px+ bold or 24px+): 3:1 minimum
- Interactive elements: 3:1 against adjacent colors

TOUCH TARGETS
- Minimum size: 44x44px
- Minimum gap between interactive elements: 16px (gap-4)

KEYBOARD NAVIGATION
- All interactive elements must be focusable
- Visible focus indicators on all focusable elements
- Logical tab order (follows visual layout)
- No keyboard traps

SEMANTIC HTML
- Use <article>, <section>, <nav>, <header>, <footer>, <aside>, <main>
- Do NOT use only <div> and <span> for structure
- One <h1> per page
- No skipped heading levels (h1 -> h3 without h2)

ARIA
- Labels on all interactive elements without visible text
- aria-invalid on form fields with errors
- aria-describedby linking errors to their fields
- role="alert" on dynamic error messages
- Screen reader text (sr-only) for icon-only buttons
```

### Accessibility Checklist

Before marking any UI component complete:

```
[ ] Color contrast meets WCAG AA (4.5:1 text, 3:1 large text)
[ ] Interactive elements are at least 44x44px
[ ] All interactive elements are keyboard-focusable
[ ] Focus indicators are visible
[ ] Tab order is logical
[ ] Semantic HTML elements used
[ ] Heading hierarchy correct (no skips)
[ ] ARIA labels on icon-only buttons and inputs
[ ] Form errors linked with aria-describedby
[ ] Tested with keyboard-only navigation
```

---

## UI Audit Process

### When to Audit

Run a UI audit:
- Before marking any UI work as complete
- After significant visual changes
- When adding new pages or components
- Before shipping to production

### What to Check Per Component

```
IDENTITY
- Maintains personality across all breakpoints?
- Changes are layout/order/spacing, not style?
- Does not transform into something different between screens?

TYPOGRAPHY
- Respects the typographic scale from the design system?
- Legible at all sizes?
- Headings maintain relative proportion?

SPACING
- Uses spacing scale from theme?
- Spacing scales proportionally?
- No collapsed spaces on mobile?

INTERACTIVE STATES
- Hover/focus/active work on desktop?
- Touch targets are 44x44px+ on mobile?
- States are visible and predictable?

CRITICAL CONTENT
- Nothing critical is hidden?
- Primary CTAs visible at all sizes?
- Essential information accessible?
```

### Audit Report Format

Use the **ui-reviewer** agent for structured audits. Reports follow this format:

```markdown
## UI AUDIT — [Component/Page Name]

### VERDICT: APPROVED / NEEDS ADJUSTMENTS / DOES NOT COMPLY

### FINDINGS

#### Breakpoints
- Mobile: [status]
- Tablet: [status]
- Desktop: [status]

#### Design System Fidelity
- Theme compliance: [percentage]
- Arbitrary values found: [count]
- Unnecessary overrides: [list]

#### Components
**[Component 1]**
- [status] Maintains visual identity
- [status] Spacing consistent
- [status] CTAs visible

### CRITICAL DEVIATIONS
1. **[Description]**
   - Impact: High/Medium/Low
   - Location: [component/page]
   - Fix: [minimum required action]

### CORRECTIONS REQUIRED
// BEFORE (incorrect):
<div className="w-[342px] px-3">

// AFTER (correct):
<div className="w-full max-w-sm px-4">
```

---

## Scalable System Goal

A well-built design system enables:

- Growing the product without visual debt
- Adding features without constant redesigns
- Maintaining consistency without manual effort
- Fast onboarding of new developers
- Predictable testing across all screen sizes

**Everything adapts because everything was designed as a system from the start.**
