package com.chellavignesh.azentiosolution.service;

import com.chellavignesh.azentiosolution.dto.CreateDisputeRequest;
import com.chellavignesh.azentiosolution.dto.response.DisputeDetailResponse;
import com.chellavignesh.azentiosolution.dto.response.DisputeSummaryResponse;
import com.chellavignesh.azentiosolution.repository.DisputeCommandRepository;
import com.chellavignesh.azentiosolution.repository.DisputeQueryRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class DisputeService {

    private final DisputeCommandRepository commandRepo;
    private final DisputeQueryRepository queryRepo;

    public DisputeService(
            DisputeCommandRepository commandRepo,
            DisputeQueryRepository queryRepo
    ) {
        this.commandRepo = commandRepo;
        this.queryRepo = queryRepo;
    }

    public void create(CreateDisputeRequest r) {
        commandRepo.createDispute(r);
    }

    public void decide(Long id, String actor) {
        commandRepo.decideDispute(id, actor);
    }

    public void refund(Long id, String actor) {
        commandRepo.issueRefund(id, actor);
    }

    public List<DisputeSummaryResponse> search(Long custId, String status) {
        return queryRepo.search(custId, status);
    }

    public DisputeDetailResponse detail(Long id) {
        return queryRepo.getDetail(id);
    }
}

