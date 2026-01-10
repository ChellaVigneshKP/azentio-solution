"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { createDispute } from "@/lib/api";

export default function CreateDisputePage() {
    const router = useRouter();
    const [error, setError] = useState<string | null>(null);

    const [form, setForm] = useState({
        txnId: "",
        custId: "",
        disputeType: "DUPLICATE_CHARGE",
        claimAmount: "",
        actor: "CUSTOMER",
    });

    async function submit() {
        try {
            await createDispute({
                txnId: Number(form.txnId),
                custId: Number(form.custId),
                disputeType: form.disputeType,
                claimAmount: Number(form.claimAmount),
                actor: form.actor,
            });

            router.push("/disputes"); // ✅ redirect
        } catch (e: any) {
            setError(e.message || "Failed to create dispute");
        }
    }

    return (
        <div className="max-w-md space-y-4">
            <h1 className="text-xl font-bold">Create Dispute</h1>

            {error && <p className="text-red-600">{error}</p>}

            <input className="input" placeholder="Txn ID"
                   onChange={e => setForm({ ...form, txnId: e.target.value })} />

            <input className="input" placeholder="Customer ID"
                   onChange={e => setForm({ ...form, custId: e.target.value })} />

            <input className="input" placeholder="Claim Amount"
                   onChange={e => setForm({ ...form, claimAmount: e.target.value })} />

            <select className="input"
                    onChange={e => setForm({ ...form, disputeType: e.target.value })}>
                <option>DUPLICATE_CHARGE</option>
                <option>SERVICE_NOT_DELIVERED</option>
                <option>WRONG_AMOUNT</option>
                <option>FRAUD_SUSPECTED</option>
            </select>

            <button onClick={submit}
                    className="bg-black text-white px-4 py-2">
                Submit
            </button>
        </div>
    );
}