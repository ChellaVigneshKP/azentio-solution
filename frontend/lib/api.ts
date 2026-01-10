const BASE_URL = process.env.NEXT_PUBLIC_API_BASE_URL;

export async function createDispute(payload: any) {
    const res = await fetch(`${BASE_URL}/disputes`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
    });

    if (!res.ok) {
        const err = await res.json();
        throw err;
    }
}

export async function searchDisputes(custId: number, status?: string) {
    const params = new URLSearchParams({ custId: String(custId) });
    if (status) params.append("status", status);

    const res = await fetch(`${BASE_URL}/disputes?${params}`);
    return res.json();
}

export async function getDispute(id: number) {
    const res = await fetch(`${BASE_URL}/disputes/${id}`);
    return res.json();
}

export async function decideDispute(id: number, actor: string) {
    const res = await fetch(`${BASE_URL}/disputes/${id}/decision`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ actor }),
    });

    if (!res.ok) throw await res.json();
}

export async function refundDispute(id: number, actor: string) {
    const res = await fetch(`${BASE_URL}/disputes/${id}/refund`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ actor }),
    });

    if (!res.ok) throw await res.json();
}

export async function checkDbHealth() {
    const res = await fetch(`${BASE_URL}/health/db`);
    return res.text();
}
