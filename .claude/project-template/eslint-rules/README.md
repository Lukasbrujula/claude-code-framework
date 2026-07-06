# eslint-rules/

Project-local ESLint rules. This is one of the four graduation targets for the
learning loop (see `/retro`): when a mistake recurs and it is statically
detectable in JS/TS, it becomes a rule here instead of a note in LEARNINGS.md.

Ships with one working example: `no-success-in-catch.js` — forbids returning
`{ success: true }` or a 2xx status from inside a catch block
(enforces `rules/pipeline-boundaries.md`).

## Wiring (flat config, ESLint 9+)

```js
// eslint.config.js
import noSuccessInCatch from './eslint-rules/no-success-in-catch.js';

export default [
  {
    plugins: {
      local: {
        rules: {
          'no-success-in-catch': noSuccessInCatch,
        },
      },
    },
    rules: {
      'local/no-success-in-catch': 'error',
    },
  },
];
```

CommonJS projects: `const noSuccessInCatch = require('./eslint-rules/no-success-in-catch');`
Legacy `.eslintrc` projects: use the `eslint-plugin-local-rules` package and
register rules from this directory.

## Adding a rule

1. One file per rule, named after the rule.
2. Header comment states which rules/ file or LEARNINGS entry it enforces and
   its known limits.
3. Register it in `eslint.config.js` at `error` severity — a warning is a note
   with extra steps, not enforcement.
4. Mark the LEARNINGS.md entry `GRADUATED → eslint-rules/<file>`.

Non-JS stacks: use the equivalent slot (ruff plugin, custom go vet analyzer,
ArchUnit test) and keep the same convention — one invariant, one file, named
after the mistake it prevents.
