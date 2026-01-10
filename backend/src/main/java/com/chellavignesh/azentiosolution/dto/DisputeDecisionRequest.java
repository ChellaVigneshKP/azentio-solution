package com.chellavignesh.azentiosolution.dto;

import jakarta.validation.constraints.NotBlank;

public record DisputeDecisionRequest(
        @NotBlank String actor
) {}

