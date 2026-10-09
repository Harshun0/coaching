import { NextResponse } from "next/server";
import { verifyToken, type TokenPayload } from "@/lib/auth";

export function getAuth(req: Request): TokenPayload | null {
  const authHeader = req.headers.get("authorization");
  if (!authHeader?.startsWith("Bearer ")) return null;

  try {
    return verifyToken(authHeader.slice("Bearer ".length));
  } catch {
    return null;
  }
}

export function requireAdmin(req: Request): TokenPayload | NextResponse {
  const auth = getAuth(req);
  if (!auth) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  if (auth.role !== "ADMIN") return NextResponse.json({ error: "Forbidden" }, { status: 403 });
  return auth;
}
