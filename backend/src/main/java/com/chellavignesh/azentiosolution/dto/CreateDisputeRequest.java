package com.chellavignesh.azentiosolution.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;

public record CreateDisputeRequest(
        @NotNull Long txnId,
        @NotNull Long custId,
        @NotBlank String disputeType,
        @NotNull BigDecimal claimAmount,
        @NotBlank String actor
) {
}
