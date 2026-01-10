export default function Dashboard() {
  return (
      <div className="space-y-4">
        <h1 className="text-2xl font-bold">
          Smart Dispute & Refund Orchestrator
        </h1>

        <p>
          This UI demonstrates an end-to-end dispute lifecycle driven entirely by
          database business rules.
        </p>

        <ul className="list-disc ml-6">
          <li>Create disputes</li>
          <li>Search & review disputes</li>
          <li>Decide (approve / manual)</li>
          <li>Issue refunds</li>
        </ul>
      </div>
  );
}