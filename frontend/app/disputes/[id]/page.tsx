"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { getDispute, decideDispute, refundDispute } from "@/lib/api";

export default function DisputeDetail({ params }: any) {
    const router = useRouter();
    const [data, setData] = useState<any>();
    const [error, setError] = useState<string | null>(null);

    async function load() {
        const d = await getDispute(params.id);
        setData(d);
    }

    useEffect(() => {
        load();
    }, []);

    if (!data) return <p>Loading...</p>;

    async function decide() {
        try {
            await decideDispute(data.disputeId, "SYSTEM");
            load(); // ✅ refresh state
        } catch (e: any) {
            setError(e.message);
        }
    }

    async function refund() {
        try {
            await refundDispute(data.disputeId, "SYSTEM");
            router.push("/disputes"); // ✅ redirect after refund
        } catch (e: any) {
            setError(e.message);
        }
    }

    return (
        <div className="space-y-3">
            <h1 className="text-xl font-bold">
                Dispute #{data.disputeId}
            </h1>

            {error && <p className="text-red-600">{error}</p>}

            <p>Status: {data.status}</p>
            <p>Transaction Amount: {data.txnAmount}</p>
            <p>Transaction Status: {data.txnStatus}</p>

            <div className="flex gap-3 mt-4">
                <button onClick={decide}
                        className="bg-blue-600 text-white px-3 py-1">
                    Decide
                </button>

                {data.status === "APPROVED" && (
                    <button onClick={refund}
                            className="bg-green-600 text-white px-3 py-1">
                        Refund
                    </button>
                )}
            </div>
        </div>
    );
}