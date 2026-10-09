"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import { getAdminToken } from "@/lib/adminApi";

export default function AdminIndexPage() {
  const router = useRouter();

  useEffect(() => {
    router.replace(getAdminToken() ? "/admin/courses" : "/admin/login");
  }, [router]);

  return null;
}
