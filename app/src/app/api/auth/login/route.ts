import { NextResponse } from 'next/server';

export async function POST(req: Request) {
  try {
    const { password } = await req.json();

    const expectedPassword = process.env.ADMIN_PASSWORD || 'wroughtworks-admin';
    const adminToken = process.env.ADMIN_SECRET_TOKEN || 'mock-admin-token-123';

    if (password === expectedPassword) {
      const response = NextResponse.json({ success: true });
      response.cookies.set({
        name: 'admin_token',
        value: adminToken,
        httpOnly: true,
        path: '/',
        secure: process.env.NODE_ENV === 'production',
        maxAge: 60 * 60 * 24 * 7, // 1 week
      });
      return response;
    }

    return NextResponse.json({ error: 'Invalid password' }, { status: 401 });
  } catch (err) {
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}
