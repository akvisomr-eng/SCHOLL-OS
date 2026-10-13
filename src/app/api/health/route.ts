import { neon } from "@neondatabase/serverless";
import { NextResponse } from "next/server";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

function response(
  status: "ok" | "degraded",
  database: "ok" | "unconfigured" | "unavailable",
  httpStatus: number,
) {
  return NextResponse.json(
    {
      service: "school-os",
      status,
      checks: { database },
      timestamp: new Date().toISOString(),
    },
    {
      status: httpStatus,
      headers: { "Cache-Control": "no-store, max-age=0" },
    },
  );
}

/**
 * Minimal liveness/readiness endpoint for uptime monitors.
 * It deliberately returns no hostnames, connection details, stack traces, or SQL errors.
 */
export async function GET() {
  const connectionString = process.env.DATABASE_URL;
  if (!connectionString) {
    return response("degraded", "unconfigured", 503);
  }

  try {
    const sql = neon(connectionString);
    await sql`SELECT 1`;
    return response("ok", "ok", 200);
  } catch {
    return response("degraded", "unavailable", 503);
  }
}
