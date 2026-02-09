const BASE_URL = process.env.NEXT_PUBLIC_API_BASE_URL!;

/* ---------------- CREATE ---------------- */

export async function createDispute(payload: any): Promise<void> {
    const res = await fetch(`${BASE_URL}/disputes`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
    });

    if (!res.ok) {
        throw new Error(await res.text());
    }
}

/* ---------------- SEARCH ---------------- */

export async function searchDisputes(
    custId: number,
    status?: string
): Promise<any[]> {
    const params = new URLSearchParams({ custId: String(custId) });
    if (status) params.append("status", status);

    const res = await fetch(`${BASE_URL}/disputes?${params}`);

    if (!res.ok) {
        throw new Error(await res.text());
    }

    const data = await res.json();
    if (!Array.isArray(data)) {
        throw new Error("Invalid response format");
    }

    return data;
}

/* ---------------- DETAIL ---------------- */

export async function getDispute(id: number): Promise<any> {
    const res = await fetch(`${BASE_URL}/disputes/${id}`);
    if (!res.ok) throw new Error(await res.text());
    return res.json();
}

/* ---------------- DECISION ---------------- */

export async function decideDispute(
    id: number,
    actor: string
): Promise<void> {
    const res = await fetch(`${BASE_URL}/disputes/${id}/decision`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ actor }),
    });

    if (!res.ok) throw new Error(await res.text());
}

/* ---------------- REFUND ---------------- */

export async function refundDispute(
    id: number,
    actor: string
): Promise<void> {
    const res = await fetch(`${BASE_URL}/disputes/${id}/refund`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ actor }),
    });

    if (!res.ok) throw new Error(await res.text());
}

/* ---------------- HEALTH ---------------- */

export async function checkDbHealth(): Promise<string> {
    const res = await fetch(`${BASE_URL}/health/db`);
    if (!res.ok) throw new Error("DB health check failed");
    return res.text();
}