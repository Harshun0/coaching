import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { requireAdmin } from "@/lib/requireAuth";

export async function PATCH(req: Request, { params }: { params: Promise<{ id: string }> }) {
  const auth = requireAdmin(req);
  if (auth instanceof NextResponse) return auth;

  const { id } = await params;
  const body = await req.json();

  const course = await prisma.course.update({
    where: { id },
    data: {
      ...(typeof body.title === "string" && { title: body.title }),
      ...(typeof body.description === "string" && { description: body.description }),
      ...(typeof body.priceInPaise === "number" && { priceInPaise: body.priceInPaise }),
      ...(typeof body.published === "boolean" && { published: body.published }),
    },
  });

  return NextResponse.json({ course });
}

export async function DELETE(req: Request, { params }: { params: Promise<{ id: string }> }) {
  const auth = requireAdmin(req);
  if (auth instanceof NextResponse) return auth;

  const { id } = await params;
  await prisma.course.delete({ where: { id } });

  return NextResponse.json({ ok: true });
}
