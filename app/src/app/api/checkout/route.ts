import { NextResponse } from 'next/server';
import Stripe from 'stripe';
import { db } from '@/lib/db';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY || 'sk_test_mock', {
  apiVersion: '2026-05-27.dahlia', // Latest API version
});

export async function POST(req: Request) {
  try {
    const { items } = await req.json();

    if (!items || items.length === 0) {
      return NextResponse.json({ error: 'Cart is empty' }, { status: 400 });
    }

    // Verify products exist and are AVAILABLE
    const productIds = items.map((i: any) => i.id);
    const dbProducts = await db.product.findMany({
      where: {
        id: { in: productIds },
        status: 'AVAILABLE'
      }
    });

    if (dbProducts.length !== items.length) {
      return NextResponse.json({ 
        error: 'One or more items are no longer available.' 
      }, { status: 400 });
    }

    // Create a new Order in Prisma with PENDING status
    const totalAmount = dbProducts.reduce((sum, p) => sum + Number(p.price), 0);
    
    // Using a simple customer email/name for now or relying on Stripe's collection
    const order = await db.order.create({
      data: {
        status: 'PENDING',
        totalAmount,
        customerEmail: 'pending@checkout.com',
        customerName: 'Pending Checkout',
        items: {
          create: dbProducts.map((p) => ({
            productId: p.id,
            priceSnapshot: p.price
          }))
        }
      }
    });

    // Create Stripe Checkout Session
    const lineItems = dbProducts.map((p) => ({
      price_data: {
        currency: 'usd',
        product_data: {
          name: p.title,
          description: p.description.substring(0, 255),
        },
        unit_amount: Math.round(Number(p.price) * 100), // Stripe uses cents
      },
      quantity: 1,
    }));

    // Generate origin URL
    const origin = req.headers.get('origin') || 'http://localhost:3000';

    const session = await stripe.checkout.sessions.create({
      payment_method_types: ['card'],
      line_items: lineItems,
      mode: 'payment',
      success_url: `${origin}/success?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: `${origin}/catalog`,
      metadata: {
        orderId: order.id
      }
    });

    return NextResponse.json({ url: session.url });
  } catch (err: any) {
    console.error('Stripe Checkout Error:', err);
    return NextResponse.json(
      { error: 'Internal server error during checkout' },
      { status: 500 }
    );
  }
}
