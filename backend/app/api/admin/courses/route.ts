import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { requireAdmin } from "@/lib/requireAuth";

export async function GET(req: Request) {
  const auth = requireAdmin(req);
  if (auth instanceof NextResponse) return auth;

  const courses = await prisma.course.findMany({
    orderBy: { createdAt: "desc" },
    include: { _count: { select: { enrollments: true, lessons: true } } },
  });

  return NextResponse.json({ courses });
}

export async function POST(req: Request) {
  const auth = requireAdmin(req);
  if (auth instanceof NextResponse) return auth;

  const { title, description, priceInPaise } = await req.json();
  if (!title || !description || typeof priceInPaise !== "number") {
    return NextResponse.json(
      { error: "title, description, priceInPaise are required" },
      { status: 400 }
    );
  }

  const course = await prisma.course.create({
    data: { title, description, priceInPaise },
  });

  return NextResponse.json({ course });
}
