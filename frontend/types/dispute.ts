export interface DisputeSummary {
    disputeId: number;
    status: string;
    claimAmount: number;
}

export interface DisputeDetail {
    disputeId: number;
    status: string;
    claimAmount: number;
    txnAmount: number;
    txnStatus: string;
}
