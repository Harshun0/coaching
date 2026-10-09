import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { getAuth } from "@/lib/requireAuth";

export async function GET(req: Request) {
  const auth = getAuth(req);
  if (!auth) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });

  const courses = await prisma.course.findMany({
    where: { published: true },
    select: {
      id: true,
      title: true,
      description: true,
      priceInPaise: true,
      enrollments: { where: { userId: auth.userId }, select: { id: true } },
    },
  });

  return NextResponse.json({
    courses: courses.map(({ enrollments, ...course }) => ({
      ...course,
      enrolled: enrollments.length > 0,
    })),
  });
}
