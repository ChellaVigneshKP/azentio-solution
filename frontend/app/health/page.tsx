"use client";

import { useEffect, useState } from "react";
import { checkDbHealth } from "@/lib/api";

export default function HealthPage() {
    const [status, setStatus] = useState("");

    useEffect(() => {
        checkDbHealth().then(setStatus);
    }, []);

    return (
        <div>
            <h1 className="text-xl font-bold">DB Health</h1>
            <p className="mt-2">{status}</p>
        </div>
    );
}
