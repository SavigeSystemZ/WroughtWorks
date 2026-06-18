import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function proxy(request: NextRequest) {
  // Only protect /admin routes
  if (request.nextUrl.pathname.startsWith('/admin')) {
    // Skip protection for the login page itself
    if (request.nextUrl.pathname === '/admin/login') {
      return NextResponse.next();
    }

    const adminToken = request.cookies.get('admin_token')?.value;
    
    // In a real app, verify the token signature (JWT) or check DB.
    // For MVP, if the token exists and equals the expected secret, allow access.
    if (!adminToken || adminToken !== process.env.ADMIN_SECRET_TOKEN) {
      const url = request.nextUrl.clone();
      url.pathname = '/admin/login';
      return NextResponse.redirect(url);
    }
  }

  return NextResponse.next();
}

export const config = {
  matcher: ['/admin/:path*'],
};
