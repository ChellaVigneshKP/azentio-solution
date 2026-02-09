"use client";

import { useEffect, useState } from "react";
import { useParams } from "next/navigation";
import { getDispute } from "@/lib/api";

export default function DisputeDetailPage() {
    const params = useParams();
    const id = params.id as string;

    const [data, setData] = useState<any>(null);

    useEffect(() => {
        if (!id) return;

        getDispute(Number(id)).then(setData);
    }, [id]);

    if (!data) return <div>Loading...</div>;

    return (
        <div>
            <h1 className="text-xl font-bold">Dispute #{data.disputeId}</h1>
            <p>Status: {data.status}</p>
            <p>Claim Amount: {data.claimAmount}</p>
            <p>Transaction Amount: {data.txnAmount}</p>
            <p>Transaction Status: {data.txnStatus}</p>
        </div>
    );
}