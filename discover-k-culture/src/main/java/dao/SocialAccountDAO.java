package dao;

import util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

public class SocialAccountDAO {

    public Long findMemberId(String provider, String providerUserId) throws Exception {
        String sql =
            "SELECT member_id "
          + "FROM social_account "
          + "WHERE provider=? "
          + "AND provider_user_id=?";

        try (Connection c = DBConnection.getConnection()) {
            ensureTable(c);

            try (PreparedStatement p = c.prepareStatement(sql)) {
                p.setString(1, provider);
                p.setString(2, providerUserId);

                try (ResultSet r = p.executeQuery()) {
                    return r.next() ? r.getLong("member_id") : null;
                }
            }
        }
    }

    public void link(
        long memberId,
        String provider,
        String providerUserId,
        String providerEmail
    ) throws Exception {

        String sql =
            "INSERT INTO social_account("
          + "member_id,provider,provider_user_id,provider_email"
          + ") VALUES(?,?,?,?)";

        try (Connection c = DBConnection.getConnection()) {
            ensureTable(c);

            try (PreparedStatement p = c.prepareStatement(sql)) {
                p.setLong(1, memberId);
                p.setString(2, provider);
                p.setString(3, providerUserId);
                p.setString(4, providerEmail);
                p.executeUpdate();
            }
        }
    }

    private void ensureTable(Connection c) throws Exception {
        String sql =
            "CREATE TABLE IF NOT EXISTS social_account ("
          + "social_account_id BIGINT NOT NULL AUTO_INCREMENT, "
          + "member_id BIGINT NOT NULL, "
          + "provider VARCHAR(20) NOT NULL, "
          + "provider_user_id VARCHAR(255) NOT NULL, "
          + "provider_email VARCHAR(255) NULL, "
          + "created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, "
          + "PRIMARY KEY (social_account_id), "
          + "UNIQUE KEY uk_social_provider_user (provider, provider_user_id), "
          + "KEY idx_social_member (member_id)"
          + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";

        try (Statement s = c.createStatement()) {
            s.execute(sql);
        }
    }
}
