import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "School OS — Sistem Manajemen Pendidikan",
  description: "Platform manajemen pendidikan modular untuk berbagai jenjang sekolah.",
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="id"><body>{children}</body></html>;
}
