import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { getAuth } from "@/lib/requireAuth";
import { razorpay } from "@/lib/razorpay";

export async function POST(req: Request) {
  const auth = getAuth(req);
  if (!auth) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });

  const { courseId } = await req.json();
  if (!courseId) return NextResponse.json({ error: "courseId is required" }, { status: 400 });

  const course = await prisma.course.findUnique({ where: { id: courseId } });
  if (!course || !course.published) {
    return NextResponse.json({ error: "Course not found" }, { status: 404 });
  }

  const alreadyEnrolled = await prisma.enrollment.findUnique({
    where: { userId_courseId: { userId: auth.userId, courseId } },
  });
  if (alreadyEnrolled) {
    return NextResponse.json({ error: "Already enrolled" }, { status: 409 });
  }

  const order = await razorpay.orders.create({
    amount: course.priceInPaise,
    currency: "INR",
    notes: { userId: auth.userId, courseId },
  });

  await prisma.payment.create({
    data: {
      userId: auth.userId,
      courseId,
      razorpayOrderId: order.id,
      amountInPaise: course.priceInPaise,
    },
  });

  return NextResponse.json({
    orderId: order.id,
    amount: order.amount,
    currency: order.currency,
    keyId: process.env.RAZORPAY_KEY_ID,
  });
}
