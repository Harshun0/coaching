"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { adminFetch } from "@/lib/adminApi";

type User = {
  id: string;
  name: string;
  email: string;
  role: "STUDENT" | "ADMIN";
  activeDeviceId: string | null;
};

export default function AdminUsersPage() {
  const [users, setUsers] = useState<User[]>([]);
  const [error, setError] = useState<string | null>(null);

  async function load() {
    try {
      const body = await adminFetch("/admin/users");
      setUsers(body.users);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to load");
    }
  }

  useEffect(() => {
    load();
  }, []);

  async function resetDevice(id: string) {
    await adminFetch(`/admin/users/${id}/reset-device`, { method: "POST" });
    load();
  }

  return (
    <div className="max-w-3xl mx-auto p-6">
      <nav className="flex gap-4 mb-6 text-sm">
        <Link href="/admin/courses">Courses</Link>
        <Link href="/admin/users" className="font-semibold">
          Users
        </Link>
      </nav>

      <h1 className="text-xl font-semibold mb-4">Users</h1>
      {error && <p className="text-red-600 text-sm mb-4">{error}</p>}

      <table className="w-full text-sm border-collapse">
        <thead>
          <tr className="text-left border-b">
            <th className="py-2">Name</th>
            <th>Email</th>
            <th>Role</th>
            <th>Device</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          {users.map((u) => (
            <tr key={u.id} className="border-b">
              <td className="py-2">{u.name}</td>
              <td>{u.email}</td>
              <td>{u.role}</td>
              <td>{u.activeDeviceId ? "Locked" : "—"}</td>
              <td>
                {u.activeDeviceId && (
                  <button
                    onClick={() => resetDevice(u.id)}
                    className="bg-gray-100 rounded px-3 py-1"
                  >
                    Reset device
                  </button>
                )}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
