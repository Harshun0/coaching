import { S3Client, PutObjectCommand, GetObjectCommand } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";

const s3 = new S3Client({
  endpoint: process.env.NEON_STORAGE_ENDPOINT!,
  region: process.env.NEON_STORAGE_REGION!,
  credentials: {
    accessKeyId: process.env.NEON_STORAGE_ACCESS_KEY_ID!,
    secretAccessKey: process.env.NEON_STORAGE_SECRET_ACCESS_KEY!,
  },
  forcePathStyle: true,
});

const bucket = process.env.NEON_STORAGE_BUCKET!;

/** A short-lived URL (default 1 hour) for an enrolled student to stream one lesson's video. */
export function getLessonVideoUrl(objectKey: string, expiresInSeconds = 3600) {
  return getSignedUrl(s3, new GetObjectCommand({ Bucket: bucket, Key: objectKey }), {
    expiresIn: expiresInSeconds,
  });
}

/** A short-lived URL for the admin dashboard to upload a lesson video directly to storage. */
export function getLessonUploadUrl(objectKey: string, contentType: string, expiresInSeconds = 900) {
  return getSignedUrl(
    s3,
    new PutObjectCommand({ Bucket: bucket, Key: objectKey, ContentType: contentType }),
    { expiresIn: expiresInSeconds }
  );
}
