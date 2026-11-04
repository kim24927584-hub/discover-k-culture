package dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import dto.MemberDTO;
import util.DBConnection;
import util.PasswordUtil;

public class MemberDAO {

    private static final String MEMBER_COLUMNS =
            "member_id, login_id, password, nickname, email, nationality, " +
            "language_id, profile_image, role, status, suspended_until, " +
            "suspension_reason, created_at, updated_at, " +
            "(SELECT l.name_native FROM language l WHERE l.language_id = member.language_id) AS language_name";

    /**
     * 일반 로그인.
     *
     * 새 계정은 PBKDF2 해시를 사용합니다. 기존 DB의 평문 비밀번호 계정은
     * 기존 비밀번호로 한 번 정상 로그인하면 즉시 해시값으로 자동 전환합니다.
     */
    public MemberDTO authenticate(String loginId, String password) throws Exception {
        String sql = "SELECT " + MEMBER_COLUMNS +
                " FROM member WHERE login_id = ? " +
                "AND status IN ('ACTIVE', 'SUSPENDED')";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, loginId);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }

                long memberId = rs.getLong("member_id");
                String storedPassword = rs.getString("password");

                if (!PasswordUtil.verify(password, storedPassword)) {
                    return null;
                }

                MemberDTO member = map(rs);

                // 예전 평문 비밀번호는 정상 로그인 시 안전한 해시로 자동 전환합니다.
                if (!PasswordUtil.isHashed(storedPassword)) {
                    updatePasswordHash(memberId, PasswordUtil.hash(password));
                    member.setPassword(null);
                }

                if (isExpiredSuspension(member)) {
                    releaseExpiredSuspension(memberId);
                    return selectById(memberId);
                }

                return member;
            }
        }
    }

    /** 기존 코드와 호환용 */
    public MemberDTO login(String loginId, String password) throws Exception {
        return authenticate(loginId, password);
    }

    public MemberDTO selectById(long memberId) throws Exception {
        releaseExpiredSuspension(memberId);

        String sql = "SELECT " + MEMBER_COLUMNS + " FROM member WHERE member_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, memberId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    public MemberDTO selectByEmail(String email) throws Exception {
        String sql = "SELECT " + MEMBER_COLUMNS +
                " FROM member WHERE email = ? AND status IN ('ACTIVE', 'SUSPENDED')";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }

                long memberId = rs.getLong("member_id");
                MemberDTO member = map(rs);

                if (isExpiredSuspension(member)) {
                    releaseExpiredSuspension(memberId);
                    return selectById(memberId);
                }

                return member;
            }
        }
    }

    /** 관리자 회원 목록 */
    public List<MemberDTO> selectAll() throws Exception {
        releaseExpiredSuspensions();

        List<MemberDTO> list = new ArrayList<MemberDTO>();
        String sql = "SELECT " + MEMBER_COLUMNS + " FROM member ORDER BY member_id ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(map(rs));
            }
        }

        return list;
    }

    public int insert(MemberDTO member) throws Exception {
        String sql = "INSERT INTO member " +
                "(login_id, password, nickname, email, nationality, language_id, profile_image) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, member.getLoginId());
            ps.setString(2, PasswordUtil.isHashed(member.getPassword())
                    ? member.getPassword()
                    : PasswordUtil.hash(member.getPassword()));
            ps.setString(3, member.getNickname());
            ps.setString(4, member.getEmail());
            ps.setString(5, member.getNationality());
            ps.setInt(6, member.getLanguageId() <= 0 ? 1 : member.getLanguageId());
            ps.setString(7, member.getProfileImage());

            return ps.executeUpdate();
        }
    }

    /** 마이페이지 회원정보 수정 */
    public int update(MemberDTO member) throws Exception {
        String sql =
                "UPDATE member SET nickname=?, email=?, nationality=?, language_id=?, updated_at=CURRENT_TIMESTAMP " +
                "WHERE member_id=? AND status <> 'WITHDRAWN'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, member.getNickname());
            ps.setString(2, member.getEmail());
            ps.setString(3, member.getNationality());
            ps.setInt(4, member.getLanguageId());
            ps.setLong(5, member.getMemberId());

            return ps.executeUpdate();
        }
    }

    public boolean existsLoginId(String loginId) throws Exception {
        return exists("login_id", loginId);
    }

    public boolean existsNickname(String nickname) throws Exception {
        return exists("nickname", nickname);
    }

    public boolean existsEmail(String email) throws Exception {
        return exists("email", email);
    }

    public int updateProfileImage(long memberId, String profileImage) throws Exception {
        String sql = "UPDATE member SET profile_image = ?, updated_at=CURRENT_TIMESTAMP WHERE member_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, profileImage);
            ps.setLong(2, memberId);
            return ps.executeUpdate();
        }
    }

    /**
     * 관리자 회원 상태 변경.
     * ADMIN 계정은 이 메서드로 변경할 수 없습니다.
     */
    public int updateStatus(long memberId, String status, Date suspendedUntil, String suspensionReason)
            throws Exception {

        if (!"ACTIVE".equals(status) && !"SUSPENDED".equals(status)) {
            return 0;
        }

        if ("SUSPENDED".equals(status)
                && (suspendedUntil == null
                    || suspensionReason == null
                    || suspensionReason.trim().isEmpty())) {
            return 0;
        }

        String sql =
                "UPDATE member SET status=?, suspended_until=?, suspension_reason=?, updated_at=CURRENT_TIMESTAMP " +
                "WHERE member_id=? AND role <> 'ADMIN' AND status <> 'WITHDRAWN'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);

            if ("ACTIVE".equals(status)) {
                ps.setNull(2, java.sql.Types.DATE);
                ps.setNull(3, java.sql.Types.VARCHAR);
            } else {
                ps.setDate(2, suspendedUntil);
                ps.setString(3, suspensionReason.trim());
            }

            ps.setLong(4, memberId);
            return ps.executeUpdate();
        }
    }


    /**
     * 관리자용 완전 삭제.
     * ADMIN 계정은 보호하고, 회원이 작성/반응한 게시판 데이터도 같이 정리합니다.
     */
    public int deleteMember(long memberId) throws Exception {
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);

            try {
                String role = null;
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT role FROM member WHERE member_id=? FOR UPDATE")) {
                    ps.setLong(1, memberId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            role = rs.getString("role");
                        }
                    }
                }

                if (role == null || "ADMIN".equals(role)) {
                    conn.rollback();
                    return 0;
                }

                // 대상 회원이 남긴 댓글 반응 및 대상 회원의 댓글/게시글에 달린 반응 제거
                execute(conn,
                        "DELETE FROM comment_like " +
                        "WHERE member_id=? OR comment_id IN (" +
                        " SELECT comment_id FROM comment WHERE member_id=? " +
                        " OR post_id IN (SELECT post_id FROM post WHERE member_id=?)" +
                        ")",
                        memberId, memberId, memberId);

                execute(conn,
                        "DELETE FROM comment_dislike " +
                        "WHERE member_id=? OR comment_id IN (" +
                        " SELECT comment_id FROM comment WHERE member_id=? " +
                        " OR post_id IN (SELECT post_id FROM post WHERE member_id=?)" +
                        ")",
                        memberId, memberId, memberId);

                // 대상 회원의 게시글 반응 및 대상 회원 게시글에 달린 반응 제거
                execute(conn,
                        "DELETE FROM post_like WHERE member_id=? " +
                        "OR post_id IN (SELECT post_id FROM post WHERE member_id=?)",
                        memberId, memberId);

                execute(conn,
                        "DELETE FROM post_dislike WHERE member_id=? " +
                        "OR post_id IN (SELECT post_id FROM post WHERE member_id=?)",
                        memberId, memberId);

                execute(conn,
                        "DELETE FROM bookmark WHERE member_id=? " +
                        "OR post_id IN (SELECT post_id FROM post WHERE member_id=?)",
                        memberId, memberId);

                // 게시글 첨부와 댓글
                execute(conn,
                        "DELETE FROM post_image WHERE post_id IN " +
                        "(SELECT post_id FROM post WHERE member_id=?)",
                        memberId);

                execute(conn,
                        "DELETE FROM post_video WHERE post_id IN " +
                        "(SELECT post_id FROM post WHERE member_id=?)",
                        memberId);

                execute(conn,
                        "DELETE FROM comment WHERE member_id=? " +
                        "OR post_id IN (SELECT post_id FROM post WHERE member_id=?)",
                        memberId, memberId);

                execute(conn, "DELETE FROM inquiry WHERE member_id=?", memberId);
                execute(conn, "DELETE FROM remember_login WHERE member_id=?", memberId);
                execute(conn, "DELETE FROM social_account WHERE member_id=?", memberId);
                execute(conn, "DELETE FROM post WHERE member_id=?", memberId);

                int deleted = execute(conn,
                        "DELETE FROM member WHERE member_id=? AND role <> 'ADMIN'",
                        memberId);

                conn.commit();
                return deleted;

            } catch (Exception e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    /**
     * 본인 회원탈퇴: 실제 게시글/댓글 및 회원 레코드는 보존(상태: WITHDRAWN)합니다.
     * 자동로그인 토큰 삭제와 상태 변경을 같은 트랜잭션으로 처리합니다.
     * 관리자 및 이미 탈퇴한 회원은 탈퇴 처리되지 않습니다.
     */
    public int withdraw(long memberId) throws Exception {
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int updated;
                String sql = "UPDATE member SET status='WITHDRAWN', " +
                        "suspended_until=NULL, suspension_reason=NULL, " +
                        "updated_at=CURRENT_TIMESTAMP " +
                        "WHERE member_id=? AND role <> 'ADMIN' AND status IN ('ACTIVE','SUSPENDED')";

                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setLong(1, memberId);
                    updated = ps.executeUpdate();
                }

                if (updated != 1) {
                    conn.rollback();
                    return 0;
                }

                try (PreparedStatement ps = conn.prepareStatement(
                        "DELETE FROM remember_login WHERE member_id=?")) {
                    ps.setLong(1, memberId);
                    ps.executeUpdate();
                }

                conn.commit();
                return updated;
            } catch (Exception e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    /**
     * 현재 회원이 정지 상태인지 확인합니다.
     * 정지 종료일이 지난 경우 먼저 ACTIVE 상태로 자동 복구한 뒤 검사합니다.
     */
    public boolean isSuspended(long memberId) throws Exception {
        releaseExpiredSuspension(memberId);

        String sql = "SELECT status FROM member WHERE member_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, memberId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && "SUSPENDED".equals(rs.getString("status"));
            }
        }
    }

    public void releaseExpiredSuspensions() throws Exception {
        String sql =
                "UPDATE member SET status='ACTIVE', suspended_until=NULL, suspension_reason=NULL, " +
                "updated_at=CURRENT_TIMESTAMP " +
                "WHERE status='SUSPENDED' AND suspended_until IS NOT NULL AND suspended_until < CURDATE()";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.executeUpdate();
        }
    }


    /** 기존 평문 비밀번호 계정을 로그인 시 해시로 전환할 때 사용합니다. */
    private int updatePasswordHash(long memberId, String passwordHash) throws Exception {
        String sql = "UPDATE member SET password=?, updated_at=CURRENT_TIMESTAMP WHERE member_id=?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, passwordHash);
            ps.setLong(2, memberId);
            return ps.executeUpdate();
        }
    }

    private boolean exists(String column, String value) throws Exception {
        if (!"login_id".equals(column) && !"nickname".equals(column) && !"email".equals(column)) {
            throw new IllegalArgumentException("허용되지 않은 컬럼입니다: " + column);
        }

        String sql = "SELECT 1 FROM member WHERE " + column + " = ? LIMIT 1";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, value);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private boolean isExpiredSuspension(MemberDTO member) {
        return "SUSPENDED".equals(member.getStatus())
                && member.getSuspendedUntil() != null
                && member.getSuspendedUntil().before(new Date(System.currentTimeMillis()));
    }

    private void releaseExpiredSuspension(long memberId) throws Exception {
        String sql =
                "UPDATE member SET status='ACTIVE', suspended_until=NULL, suspension_reason=NULL, " +
                "updated_at=CURRENT_TIMESTAMP " +
                "WHERE member_id=? AND status='SUSPENDED' " +
                "AND suspended_until IS NOT NULL AND suspended_until < CURDATE()";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, memberId);
            ps.executeUpdate();
        }
    }

    private int execute(Connection conn, String sql, long... values) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < values.length; i++) {
                ps.setLong(i + 1, values[i]);
            }
            return ps.executeUpdate();
        }
    }

    private MemberDTO map(ResultSet rs) throws Exception {
        MemberDTO member = new MemberDTO();

        member.setMemberId(rs.getLong("member_id"));
        member.setLoginId(rs.getString("login_id"));
        member.setPassword(rs.getString("password"));
        member.setNickname(rs.getString("nickname"));
        member.setEmail(rs.getString("email"));
        member.setNationality(rs.getString("nationality"));
        member.setLanguageId(rs.getInt("language_id"));
        member.setLanguageName(rs.getString("language_name"));
        member.setProfileImage(rs.getString("profile_image"));
        member.setRole(rs.getString("role"));
        member.setStatus(rs.getString("status"));
        member.setSuspendedUntil(rs.getDate("suspended_until"));
        member.setSuspensionReason(rs.getString("suspension_reason"));
        member.setCreatedAt(rs.getTimestamp("created_at"));
        member.setUpdatedAt(rs.getTimestamp("updated_at"));

        return member;
    }
}
