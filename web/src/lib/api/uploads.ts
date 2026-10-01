/** uploads — POST /uploads/images (multipart) → { url } */
import { apiFetch } from "./client";

export const uploadsApi = {
  image: (file: Blob, filename = "image.jpg") => {
    const form = new FormData();
    form.append("file", file, filename);
    return apiFetch<{ url: string }>("/uploads/images", { method: "POST", body: form });
  },
};
