import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { requireAdmin } from "@/lib/requireAuth";

export async function GET(req: Request) {
  const auth = requireAdmin(req);
  if (auth instanceof NextResponse) return auth;

  const users = await prisma.user.findMany({
    orderBy: { createdAt: "desc" },
    select: {
      id: true,
      name: true,
      email: true,
      role: true,
      activeDeviceId: true,
      createdAt: true,
    },
  });

  return NextResponse.json({ users });
}
