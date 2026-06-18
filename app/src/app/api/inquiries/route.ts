import { NextResponse } from 'next/server';
import { db } from '@/lib/db';

export async function POST(req: Request) {
  try {
    const data = await req.json();

    const { firstName, lastName, email, phone, projectType, details, budget } = data;

    if (!firstName || !lastName || !email || !details) {
      return NextResponse.json({ error: 'Missing required fields' }, { status: 400 });
    }

    const inquiry = await db.inquiry.create({
      data: {
        type: 'CUSTOM',
        customerName: `${firstName} ${lastName}`,
        customerEmail: email,
        message: `Project Type: ${projectType}\nBudget: ${budget}\nPhone: ${phone || 'N/A'}\n\nDetails:\n${details}`,
        status: 'OPEN'
      }
    });

    // TODO: Wire up transactional email provider (e.g. Resend, Sendgrid)
    // For now, mock the email notification to the Admin.
    console.log(`[EMAIL NOTIFICATION MOCK] 
    To: admin@wroughtworks.com
    Subject: New Custom Commission Inquiry: ${inquiry.id}
    Body: ${firstName} ${lastName} has submitted a new inquiry.
    View in Admin Dashboard: https://wroughtworks.com/admin/inquiries
    `);

    return NextResponse.json({ success: true, id: inquiry.id });
  } catch (err) {
    console.error('Failed to create inquiry', err);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
