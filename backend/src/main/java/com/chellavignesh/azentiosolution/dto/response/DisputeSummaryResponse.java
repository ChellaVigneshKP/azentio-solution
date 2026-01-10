package com.chellavignesh.azentiosolution.dto.response;

import java.math.BigDecimal;

public record DisputeSummaryResponse(
        Long disputeId,
        String status,
        BigDecimal claimAmount
) {}
