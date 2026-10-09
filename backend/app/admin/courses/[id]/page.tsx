"use client";

import { useEffect, useState, use } from "react";
import Link from "next/link";
import { adminFetch } from "@/lib/adminApi";

type Lesson = { id: string; title: string; order: number };

export default function AdminCourseLessonsPage({ params }: { params: Promise<{ id: string }> }) {
  const { id: courseId } = use(params);
  const [lessons, setLessons] = useState<Lesson[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [uploading, setUploading] = useState(false);
  const [title, setTitle] = useState("");
  const [file, setFile] = useState<File | null>(null);

  async function load() {
    try {
      const body = await adminFetch(`/admin/courses/${courseId}/lessons`);
      setLessons(body.lessons);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to load lessons");
    }
  }

  useEffect(() => {
    load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [courseId]);

  async function addLesson(e: React.FormEvent) {
    e.preventDefault();
    if (!file) {
      setError("Pick a video file first");
      return;
    }
    setUploading(true);
    setError(null);
    try {
      const { uploadUrl } = await adminFetch(`/admin/courses/${courseId}/lessons`, {
        method: "POST",
        body: JSON.stringify({
          title,
          order: lessons.length + 1,
          contentType: file.type || "video/mp4",
        }),
      });

      const putRes = await fetch(uploadUrl, {
        method: "PUT",
        headers: { "Content-Type": file.type || "video/mp4" },
        body: file,
      });
      if (!putRes.ok) throw new Error("Video upload to storage failed");

      setTitle("");
      setFile(null);
      load();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to add lesson");
    } finally {
      setUploading(false);
    }
  }

  return (
    <div className="max-w-2xl mx-auto p-6">
      <Link href="/admin/courses" className="text-sm text-gray-500">
        ← Back to courses
      </Link>
      <h1 className="text-xl font-semibold mt-2 mb-4">Lessons</h1>
      {error && <p className="text-red-600 text-sm mb-4">{error}</p>}

      <form onSubmit={addLesson} className="flex flex-col gap-2 mb-8 border rounded p-4">
        <input
          className="border rounded px-3 py-2"
          placeholder="Lesson title"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
        />
        <input
          type="file"
          accept="video/*"
          onChange={(e) => setFile(e.target.files?.[0] ?? null)}
        />
        <button
          disabled={uploading}
          className="bg-black text-white rounded px-3 py-2 w-fit disabled:opacity-50"
        >
          {uploading ? "Uploading..." : "Add lesson"}
        </button>
      </form>

      <ol className="flex flex-col gap-2">
        {lessons.map((l) => (
          <li key={l.id} className="border rounded p-3">
            {l.order}. {l.title}
          </li>
        ))}
      </ol>
    </div>
  );
}
