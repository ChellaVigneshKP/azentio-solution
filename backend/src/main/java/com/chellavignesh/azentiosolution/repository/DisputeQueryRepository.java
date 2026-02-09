package com.chellavignesh.azentiosolution.repository;

import com.chellavignesh.azentiosolution.dto.response.DisputeDetailResponse;
import com.chellavignesh.azentiosolution.dto.response.DisputeSummaryResponse;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public class DisputeQueryRepository {

    private final JdbcTemplate jdbc;

    public DisputeQueryRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public List<DisputeSummaryResponse> search(Long custId, String status) {
        return jdbc.query("""
                            SELECT dispute_id, status, claim_amount
                            FROM dispute
                            WHERE cust_id = ?
                              AND (CAST(? AS VARCHAR) IS NULL OR status = CAST(? AS VARCHAR))
                        """, (rs, i) ->
                        new DisputeSummaryResponse(
                                rs.getLong("dispute_id"),
                                rs.getString("status"),
                                rs.getBigDecimal("claim_amount")
                        ),
                custId, status, status
        );
    }

    public DisputeDetailResponse getDetail(Long disputeId) {
        return jdbc.queryForObject("""
                    SELECT d.*, t.amount AS txn_amount, t.status AS txn_status
                    FROM dispute d
                    JOIN txn t ON t.txn_id = d.txn_id
                    WHERE d.dispute_id = ?
                """, (rs, i) -> new DisputeDetailResponse(
                rs.getLong("dispute_id"),
                rs.getString("status"),
                rs.getBigDecimal("claim_amount"),
                rs.getBigDecimal("txn_amount"),
                rs.getString("txn_status")
        ), disputeId);
    }
}

