"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { adminFetch } from "@/lib/adminApi";

type Course = {
  id: string;
  title: string;
  description: string;
  priceInPaise: number;
  published: boolean;
  _count: { enrollments: number; lessons: number };
};

export default function AdminCoursesPage() {
  const [courses, setCourses] = useState<Course[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [form, setForm] = useState({ title: "", description: "", price: "" });

  async function load() {
    try {
      const body = await adminFetch("/admin/courses");
      setCourses(body.courses);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to load");
    }
  }

  useEffect(() => {
    load();
  }, []);

  async function createCourse(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    try {
      await adminFetch("/admin/courses", {
        method: "POST",
        body: JSON.stringify({
          title: form.title,
          description: form.description,
          priceInPaise: Math.round(parseFloat(form.price) * 100),
        }),
      });
      setForm({ title: "", description: "", price: "" });
      load();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to create course");
    }
  }

  async function togglePublished(course: Course) {
    await adminFetch(`/admin/courses/${course.id}`, {
      method: "PATCH",
      body: JSON.stringify({ published: !course.published }),
    });
    load();
  }

  return (
    <div className="max-w-3xl mx-auto p-6">
      <nav className="flex gap-4 mb-6 text-sm">
        <Link href="/admin/courses" className="font-semibold">
          Courses
        </Link>
        <Link href="/admin/users">Users</Link>
      </nav>

      <h1 className="text-xl font-semibold mb-4">Courses</h1>
      {error && <p className="text-red-600 text-sm mb-4">{error}</p>}

      <form onSubmit={createCourse} className="flex flex-col gap-2 mb-8 border rounded p-4">
        <input
          className="border rounded px-3 py-2"
          placeholder="Title"
          value={form.title}
          onChange={(e) => setForm({ ...form, title: e.target.value })}
        />
        <textarea
          className="border rounded px-3 py-2"
          placeholder="Description"
          value={form.description}
          onChange={(e) => setForm({ ...form, description: e.target.value })}
        />
        <input
          className="border rounded px-3 py-2"
          placeholder="Price in ₹"
          type="number"
          value={form.price}
          onChange={(e) => setForm({ ...form, price: e.target.value })}
        />
        <button className="bg-black text-white rounded px-3 py-2 w-fit">Add course</button>
      </form>

      <ul className="flex flex-col gap-3">
        {courses.map((c) => (
          <li key={c.id} className="border rounded p-4 flex justify-between items-start">
            <div>
              <Link href={`/admin/courses/${c.id}`} className="font-medium hover:underline">
                {c.title}
              </Link>
              <p className="text-sm text-gray-600">{c.description}</p>
              <p className="text-sm text-gray-500">
                ₹{(c.priceInPaise / 100).toFixed(0)} · {c._count.lessons} lessons ·{" "}
                {c._count.enrollments} enrolled
              </p>
            </div>
            <button
              onClick={() => togglePublished(c)}
              className={`text-sm rounded px-3 py-1 ${
                c.published ? "bg-green-100 text-green-800" : "bg-gray-100 text-gray-600"
              }`}
            >
              {c.published ? "Published" : "Draft"}
            </button>
          </li>
        ))}
      </ul>
    </div>
  );
}
