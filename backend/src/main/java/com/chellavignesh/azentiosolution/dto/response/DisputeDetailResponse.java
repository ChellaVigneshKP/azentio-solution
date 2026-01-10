package com.chellavignesh.azentiosolution.dto.response;

import java.math.BigDecimal;

public record DisputeDetailResponse(
        Long disputeId,
        String status,
        BigDecimal claimAmount,
        BigDecimal txnAmount,
        String txnStatus
) {
}
