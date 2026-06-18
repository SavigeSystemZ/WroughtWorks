# Wrought Works Prompt Pack

This prompt pack ensures that agents working on Wrought Works maintain the core aesthetic, architecture, and intent of the application. 

You operate within a specific orchestration context only and are bound by repo-local authority.

## 1. Startup and Precedence
When beginning a new task, always verify your understanding of the app by reading the core system files in the following sequence:
1. `AGENTS.md`
2. `_system/LOAD_ORDER.md`
3. `_system/INSTRUCTION_PRECEDENCE_CONTRACT.md`
4. `_system/REPO_OPERATING_PROFILE.md`
5. `PRODUCT_BRIEF.md`
6. `_system/personas/APP_PERSONA.md`
7. `_system/PROJECT_PROFILE.md`

You must treat the local AIAST copy and instruction files as having strict repo-local authority.

## 2. Core Architecture Rules
- **Stack**: Next.js App Router, TypeScript, Tailwind CSS, Prisma.
- **Server vs Client**: Default to React Server Components. Only add `"use client"` when interactivity or browser APIs are explicitly required.
- **Data Fetching**: Fetch data directly in Server Components using Prisma. Do not build `/api` routes for internal data fetching.
- **Mutations**: Use Next.js Server Actions with Zod validation for all form submissions and data modifications.

## 3. UI/UX Rules
- **Aesthetic**: Follow the "Deep Glass" aesthetic defined in `docs/UX_SYSTEM.md`. Use deep earthy tones, subtle blur filters (`backdrop-blur`), and high-quality image presentation.
- **Components**: Prefer leveraging and customizing existing `shadcn/ui` components before building completely custom elements.
- **Responsive**: Ensure mobile-first styling using Tailwind classes.

## 4. Feature specific instructions
- **E-Commerce**: Do NOT attempt to build a multi-seller marketplace. All products belong to the single Wrought Works brand.
- **Payments**: Standard size items go through Stripe Checkout. Oversized/Freight items go through a custom Quote Inquiry form.
- **Admin**: All admin routes and Server Actions must enforce role-based authentication checking.
