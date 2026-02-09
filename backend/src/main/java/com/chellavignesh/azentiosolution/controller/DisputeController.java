package com.chellavignesh.azentiosolution.controller;

import com.chellavignesh.azentiosolution.dto.CreateDisputeRequest;
import com.chellavignesh.azentiosolution.dto.DisputeDecisionRequest;
import com.chellavignesh.azentiosolution.dto.RefundRequest;
import com.chellavignesh.azentiosolution.dto.response.DisputeDetailResponse;
import com.chellavignesh.azentiosolution.dto.response.DisputeSummaryResponse;
import com.chellavignesh.azentiosolution.service.DisputeService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/disputes")
public class DisputeController {

    private final DisputeService service;

    public DisputeController(DisputeService service) {
        this.service = service;
    }

    @PostMapping
    public void create(@RequestBody @Valid CreateDisputeRequest r) {
        service.create(r);
    }

    @GetMapping
    public List<DisputeSummaryResponse> search(
            @RequestParam Long custId,
            @RequestParam(required = false) String status
    ) {
        return service.search(custId, status);
    }

    @GetMapping("/{id}")
    public DisputeDetailResponse detail(@PathVariable Long id) {
        return service.detail(id);
    }

    @PostMapping("/{id}/decision")
    public void decide(
            @PathVariable Long id,
            @RequestBody @Valid DisputeDecisionRequest r
    ) {
        service.decide(id, r.actor());
    }

    @PostMapping("/{id}/refund")
    public void refund(
            @PathVariable Long id,
            @RequestBody @Valid RefundRequest r
    ) {
        service.refund(id, r.actor());
    }

}

