# `app/assets/` — Application assets

Static assets the **app** ships or uses at runtime.

- **What goes here:** images, icons, fonts, sample/fixture data, seed
  files, anything non-code the product needs.
- **When to use:** when the app needs bundled static resources.
- **How to build it out:** keep assets organized by type or feature;
  reference them from `app/src/`. Large binaries — prefer a documented
  fetch step over committing huge files.
- **Empty state:** `.gitkeep` means the app ships no assets yet.
