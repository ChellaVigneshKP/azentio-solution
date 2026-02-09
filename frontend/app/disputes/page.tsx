"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { searchDisputes } from "@/lib/api";

export default function DisputeListPage() {
    const [data, setData] = useState<any[]>([]);
    const [error, setError] = useState<string | null>(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        searchDisputes(1)
            .then(setData)
            .catch(err => {
                console.error(err);
                setError(err.message);
            })
            .finally(() => setLoading(false));
    }, []);

    if (loading) {
        return <p>Loading disputes...</p>;
    }

    if (error) {
        return (
            <div className="text-red-600">
                Failed to load disputes: {error}
            </div>
        );
    }

    return (
        <div>
            <h1 className="text-xl font-bold mb-4">Disputes</h1>

            {data.length === 0 ? (
                <p>No disputes found.</p>
            ) : (
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
                                    href={`/disputes/${d.disputeId}`}
                                >
                                    {d.disputeId}
                                </Link>
                            </td>
                            <td>{d.status}</td>
                            <td>{d.claimAmount}</td>
                        </tr>
                    ))}
                    </tbody>
                </table>
            )}
        </div>
    );
}
