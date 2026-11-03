package dao;

import util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Timestamp;
import java.time.LocalDateTime;

public class RememberLoginDAO {

    private static final String CREATE_TABLE_SQL =
        "CREATE TABLE IF NOT EXISTS remember_login ("
      + "remember_login_id BIGINT NOT NULL AUTO_INCREMENT,"
      + "member_id BIGINT NOT NULL,"
      + "token_hash VARCHAR(64) NOT NULL,"
      + "expires_at DATETIME NOT NULL,"
      + "created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,"
      + "PRIMARY KEY (remember_login_id),"
      + "UNIQUE KEY uk_remember_login_token (token_hash),"
      + "KEY idx_remember_login_member (member_id),"
      + "KEY idx_remember_login_expires (expires_at)"
      + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";

    public void saveToken(long memberId, String tokenHash, LocalDateTime expiresAt) throws Exception {
        try (Connection c = DBConnection.getConnection()) {
            ensureTable(c);

            // 한 회원이 반복 로그인할 때 만료되지 않은 토큰이 계속 쌓이지 않게 정리합니다.
            try (PreparedStatement delete = c.prepareStatement(
                    "DELETE FROM remember_login WHERE member_id=?")) {
                delete.setLong(1, memberId);
                delete.executeUpdate();
            }

            String sql =
                "INSERT INTO remember_login(member_id,token_hash,expires_at) "
              + "VALUES(?,?,?)";

            try (PreparedStatement p = c.prepareStatement(sql)) {
                p.setLong(1, memberId);
                p.setString(2, tokenHash);
                p.setTimestamp(3, Timestamp.valueOf(expiresAt));
                p.executeUpdate();
            }
        }
    }

    public Long findMemberId(String tokenHash) throws Exception {
        try (Connection c = DBConnection.getConnection()) {
            ensureTable(c);
            deleteExpired(c);

            String sql =
                "SELECT member_id FROM remember_login "
              + "WHERE token_hash=? AND expires_at > NOW()";

            try (PreparedStatement p = c.prepareStatement(sql)) {
                p.setString(1, tokenHash);

                try (ResultSet r = p.executeQuery()) {
                    return r.next() ? r.getLong("member_id") : null;
                }
            }
        }
    }

    public void deleteToken(String tokenHash) throws Exception {
        try (Connection c = DBConnection.getConnection()) {
            ensureTable(c);

            try (PreparedStatement p = c.prepareStatement(
                    "DELETE FROM remember_login WHERE token_hash=?")) {
                p.setString(1, tokenHash);
                p.executeUpdate();
            }
        }
    }

    public void deleteMemberTokens(long memberId) throws Exception {
        try (Connection c = DBConnection.getConnection()) {
            ensureTable(c);

            try (PreparedStatement p = c.prepareStatement(
                    "DELETE FROM remember_login WHERE member_id=?")) {
                p.setLong(1, memberId);
                p.executeUpdate();
            }
        }
    }

    public int deleteExpired() throws Exception {
        try (Connection c = DBConnection.getConnection()) {
            ensureTable(c);
            return deleteExpired(c);
        }
    }

    private int deleteExpired(Connection c) throws Exception {
        try (PreparedStatement p = c.prepareStatement(
                "DELETE FROM remember_login WHERE expires_at <= NOW()")) {
            return p.executeUpdate();
        }
    }

    private void ensureTable(Connection c) throws Exception {
        try (Statement s = c.createStatement()) {
            s.executeUpdate(CREATE_TABLE_SQL);
        }
    }
}
