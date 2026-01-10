package com.chellavignesh.azentiosolution.repository;

import com.chellavignesh.azentiosolution.dto.CreateDisputeRequest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import org.springframework.jdbc.core.PreparedStatementCallback;


@Repository
public class DisputeCommandRepository {

    private final JdbcTemplate jdbc;

    public DisputeCommandRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public void createDispute(CreateDisputeRequest r) {
        jdbc.execute(
                "CALL dispute_pkg.sp_create_dispute(?,?,?,?,?)",
                (PreparedStatementCallback<Void>) ps -> {
                    ps.setLong(1, r.txnId());
                    ps.setLong(2, r.custId());
                    ps.setString(3, r.disputeType());
                    ps.setBigDecimal(4, r.claimAmount());
                    ps.setString(5, r.actor());
                    ps.execute();
                    return null;
                }
        );
    }

    public void decideDispute(Long disputeId, String actor) {
        jdbc.execute(
                "CALL dispute_pkg.sp_decide_dispute(?,?)",
                (PreparedStatementCallback<Void>) ps -> {
                    ps.setLong(1, disputeId);
                    ps.setString(2, actor);
                    ps.execute();
                    return null;
                }
        );
    }

    public void issueRefund(Long disputeId, String actor) {
        jdbc.execute(
                "CALL dispute_pkg.sp_issue_refund(?,?)",
                (PreparedStatementCallback<Void>) ps -> {
                    ps.setLong(1, disputeId);
                    ps.setString(2, actor);
                    ps.execute();
                    return null;
                }
        );
    }
}