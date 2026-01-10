"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { searchDisputes } from "@/lib/api";

export default function DisputeListPage() {
    const [data, setData] = useState<any[]>([]);

    useEffect(() => {
        searchDisputes(1).then(setData);
    }, []);

    return (
        <div>
            <h1 className="text-xl font-bold mb-4">Disputes</h1>

            <table className="border w-full">
                <thead>
                <tr className="bg-gray-200">
                    <th>ID</th>
                    <th>Status</th>
                    <th>Amount</th>
                </tr>
                </thead>
                <tbody>
                {data.map(d => (
                    <tr key={d.disputeId} className="border-t">
                        <td>
                            <Link
                                className="text-blue-600 underline"
                                href={`/disputes/${d.disputeId}`}>
                                {d.disputeId}
                            </Link>
                        </td>
                        <td>{d.status}</td>
                        <td>{d.claimAmount}</td>
                    </tr>
                ))}
                </tbody>
            </table>
        </div>
    );
}