# `app/tests/` — Application tests

Test suites for **this app's** behavior.

- **What goes here:** unit / integration / e2e tests for code in
  `app/src/`. Mirror the source layout where practical.
- **When to use:** alongside every feature — the meta-system's validation
  gates expect the app to carry its own tests.
- **How to build it out:** add tests as features land; wire them into the
  app's own test runner. Keep them independent from the meta-system's
  `_system/` smokes (those validate the operating layer, not your product).
- **Empty state:** `.gitkeep` here means the app has no tests yet.
