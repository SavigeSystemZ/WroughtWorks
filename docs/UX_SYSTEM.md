# UX and Design System

Wrought Works uses a custom visual identity internally referred to as the "Deep Glass" aesthetic.

## 1. Visual Language: "Deep Glass"
- **Colors**: Rich earthy tones (deep umber, forest green, charcoal) combined with translucent "glassmorphism" surfaces over high-resolution wood textures.
- **Typography**: Modern, readable sans-serif or elegant serif that conveys premium quality (e.g., Inter, Playfair Display).
- **Surfaces**: Use subtle backdrop filters, frosted glass effects, and soft, directional shadows to create depth.
- **Imagery**: Photography is the hero. Product images must be large, high-resolution, and uncropped where possible.

## 2. Component System
We use **Tailwind CSS** for utility-first styling and **shadcn/ui** for accessible, customizable primitive components.

- All interactive elements must have clear focus states.
- Buttons should have distinct hover and active states (micro-animations like slight scaling or color shifts).
- Forms must use clear validation messages and avoid placeholder-only labels.

## 3. Core States
Every user-facing screen MUST account for the following states:
1. **Loading**: Skeletons or elegant spinners that prevent layout shift.
2. **Empty**: Beautifully designed empty states (e.g., "No products match this filter") with clear calls to action to reset.
3. **Error**: User-friendly error boundaries that do not expose technical stack traces.
4. **Success**: Toast notifications or dedicated success pages (e.g., Order Success).

## 4. Accessibility (A11y)
- Full keyboard navigability.
- ARIA labels on all icon-only buttons.
- Minimum contrast ratios (WCAG AA) enforced across text and background layers.
- Screen-reader friendly alt-text required on all product images.

## 5. Responsive Design
- Mobile-first approach using Tailwind's responsive breakpoints (`sm:`, `md:`, `lg:`).
- Complex filters should collapse into drawers on mobile.
- Product galleries should use swipeable carousels on touch devices.
