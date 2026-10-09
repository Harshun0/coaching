import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { requireAdmin } from "@/lib/requireAuth";
import { getLessonUploadUrl } from "@/lib/storage";

export async function GET(req: Request, { params }: { params: Promise<{ id: string }> }) {
  const auth = requireAdmin(req);
  if (auth instanceof NextResponse) return auth;

  const { id: courseId } = await params;
  const lessons = await prisma.lesson.findMany({ where: { courseId }, orderBy: { order: "asc" } });
  return NextResponse.json({ lessons });
}

export async function POST(req: Request, { params }: { params: Promise<{ id: string }> }) {
  const auth = requireAdmin(req);
  if (auth instanceof NextResponse) return auth;

  const { id: courseId } = await params;
  const { title, order, contentType } = await req.json();
  if (!title || typeof order !== "number" || !contentType) {
    return NextResponse.json(
      { error: "title, order, contentType are required" },
      { status: 400 }
    );
  }

  // Create the row first so we have a stable lesson id to key the object by.
  const lesson = await prisma.lesson.create({
    data: { courseId, title, order, videoId: "" },
  });

  const objectKey = `${courseId}/${lesson.id}`;
  await prisma.lesson.update({ where: { id: lesson.id }, data: { videoId: objectKey } });

  const uploadUrl = await getLessonUploadUrl(objectKey, contentType);

  return NextResponse.json({ lesson: { ...lesson, videoId: objectKey }, uploadUrl });
}
