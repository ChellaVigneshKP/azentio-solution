package com.chellavignesh.azentiosolution.dto;

import jakarta.validation.constraints.NotBlank;

public record RefundRequest(
        @NotBlank String actor
) {}

