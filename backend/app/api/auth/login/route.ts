import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { verifyPassword, signToken } from "@/lib/auth";

export async function POST(req: Request) {
  const { email, password, deviceId } = await req.json();

  if (!email || !password || !deviceId) {
    return NextResponse.json(
      { error: "email, password, deviceId are required" },
      { status: 400 }
    );
  }

  const user = await prisma.user.findUnique({ where: { email } });
  if (!user || !(await verifyPassword(password, user.passwordHash))) {
    return NextResponse.json({ error: "Invalid email or password" }, { status: 401 });
  }

  // Single-device login applies to students only — admins need to log in from
  // anywhere (dashboard, different machines) without locking each other out.
  if (user.role === "STUDENT") {
    if (user.activeDeviceId && user.activeDeviceId !== deviceId) {
      return NextResponse.json(
        {
          error:
            "This account is already logged in on another device. Ask an admin to reset your device.",
        },
        { status: 409 }
      );
    }

    if (user.activeDeviceId !== deviceId) {
      await prisma.user.update({ where: { id: user.id }, data: { activeDeviceId: deviceId } });
    }
  }

  const token = signToken({ userId: user.id, role: user.role, deviceId });

  return NextResponse.json({ token, user: { id: user.id, name: user.name, role: user.role } });
}
