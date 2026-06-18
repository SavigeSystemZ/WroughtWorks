# Non-Functional Requirements (NFR)

## 1. Performance
- **Core Web Vitals**: Target Lighthouse scores > 90 across Performance, Accessibility, Best Practices, and SEO.
- **Largest Contentful Paint (LCP)**: Must occur within 2.5 seconds on a fast 3G network. Product hero images must be preloaded and appropriately sized.
- **Time to Interactive (TTI)**: Must occur within 3.5 seconds.
- **Image Optimization**: All user-uploaded product imagery must be automatically compressed and served in modern formats (e.g., WebP, AVIF) with responsive `srcset` definitions.

## 2. SEO & Discoverability
- Every product must have unique, descriptive `<title>` and `<meta name="description">` tags.
- Use Semantic HTML tags (`<main>`, `<article>`, `<section>`, `<nav>`).
- Include JSON-LD Schema markup for `Product`, `Offer`, and `Organization` to enable rich snippets in Google Search.
- Ensure all public pages are fully indexable by search engine crawlers (Next.js server-side rendering).

## 3. Availability and Hosting
- Target 99.9% uptime.
- Deployment via Vercel (or equivalent PaaS) leveraging edge caching for static assets and CDN distribution.
- Database backups must be automated daily via the managed PostgreSQL provider.

## 4. Browser Support
- Support for all modern evergreen browsers (Chrome, Firefox, Safari, Edge) from the last 2 versions.
- Graceful degradation for older browsers where modern CSS features (like backdrop-filter) are unsupported.
