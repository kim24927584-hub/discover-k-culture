package dao;

import dto.NoticeDTO;
import util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import java.util.ArrayList;
import java.util.List;


public class NoticeDAO {

    public int insert(
        NoticeDTO notice
    ) throws Exception {

        return insertAndGetId(notice) > 0
            ? 1
            : 0;
    }


    /*
     * 첨부파일 저장을 위해
     * 새 공지의 PK를 반환합니다.
     */
    public long insertAndGetId(
        NoticeDTO notice
    ) throws Exception {

        String sql =
            "INSERT INTO notice("
          + "member_id, title, content"
          + ") VALUES(?,?,?)";

        try (
            Connection conn =
                DBConnection.getConnection();

            PreparedStatement ps =
                conn.prepareStatement(
                    sql,
                    Statement.RETURN_GENERATED_KEYS
                )
        ) {

            ps.setLong(
                1,
                notice.getMemberId()
            );

            ps.setString(
                2,
                notice.getTitle()
            );

            ps.setString(
                3,
                notice.getContent()
            );

            int result =
                ps.executeUpdate();

            if (result != 1) {
                return 0;
            }

            try (
                ResultSet rs =
                    ps.getGeneratedKeys()
            ) {

                if (rs.next()) {
                    return rs.getLong(1);
                }
            }
        }

        return 0;
    }


    public List<NoticeDTO> selectAll()
        throws Exception {

        List<NoticeDTO> list =
            new ArrayList<NoticeDTO>();

        String sql =
            baseSql()
          + " ORDER BY n.notice_id DESC";

        try (
            Connection conn =
                DBConnection.getConnection();

            PreparedStatement ps =
                conn.prepareStatement(sql);

            ResultSet rs =
                ps.executeQuery()
        ) {

            while (rs.next()) {
                list.add(map(rs));
            }
        }

        return list;
    }


    public int countAll()
        throws Exception {

        String sql =
            "SELECT COUNT(*) "
          + "FROM notice";

        try (
            Connection conn =
                DBConnection.getConnection();

            PreparedStatement ps =
                conn.prepareStatement(sql);

            ResultSet rs =
                ps.executeQuery()
        ) {

            if (rs.next()) {
                return rs.getInt(1);
            }
        }

        return 0;
    }


    public List<NoticeDTO> selectPage(
        int page,
        int pageSize
    ) throws Exception {

        if (page < 1) {
            page = 1;
        }

        if (
            pageSize != 10
            && pageSize != 20
            && pageSize != 30
        ) {
            pageSize = 10;
        }

        int offset =
            (page - 1)
            * pageSize;

        List<NoticeDTO> list =
            new ArrayList<NoticeDTO>();

        String sql =
            baseSql()
          + " ORDER BY n.notice_id DESC "
          + "LIMIT ? OFFSET ?";

        try (
            Connection conn =
                DBConnection.getConnection();

            PreparedStatement ps =
                conn.prepareStatement(sql)
        ) {

            ps.setInt(1, pageSize);
            ps.setInt(2, offset);

            try (
                ResultSet rs =
                    ps.executeQuery()
            ) {

                while (rs.next()) {
                    list.add(map(rs));
                }
            }
        }

        return list;
    }


    public NoticeDTO selectById(
        long noticeId
    ) throws Exception {

        String sql =
            baseSql()
          + " WHERE n.notice_id=?";

        try (
            Connection conn =
                DBConnection.getConnection();

            PreparedStatement ps =
                conn.prepareStatement(sql)
        ) {

            ps.setLong(1, noticeId);

            try (
                ResultSet rs =
                    ps.executeQuery()
            ) {

                return rs.next()
                    ? map(rs)
                    : null;
            }
        }
    }


    public int update(
        NoticeDTO notice
    ) throws Exception {

        String sql =
            "UPDATE notice "
          + "SET title=?, content=? "
          + "WHERE notice_id=?";

        try (
            Connection conn =
                DBConnection.getConnection();

            PreparedStatement ps =
                conn.prepareStatement(sql)
        ) {

            ps.setString(
                1,
                notice.getTitle()
            );

            ps.setString(
                2,
                notice.getContent()
            );

            ps.setLong(
                3,
                notice.getNoticeId()
            );

            return ps.executeUpdate();
        }
    }


    public int delete(
        long noticeId
    ) throws Exception {

        String sql =
            "DELETE FROM notice "
          + "WHERE notice_id=?";

        try (
            Connection conn =
                DBConnection.getConnection();

            PreparedStatement ps =
                conn.prepareStatement(sql)
        ) {

            ps.setLong(1, noticeId);

            return ps.executeUpdate();
        }
    }


    public int increaseView(
        long noticeId
    ) throws Exception {

        String sql =
            "UPDATE notice "
          + "SET view_count=view_count+1 "
          + "WHERE notice_id=?";

        try (
            Connection conn =
                DBConnection.getConnection();

            PreparedStatement ps =
                conn.prepareStatement(sql)
        ) {

            ps.setLong(1, noticeId);

            return ps.executeUpdate();
        }
    }


    private String baseSql() {

        return "SELECT "
             + "n.*, "
             + "m.nickname AS writer_nickname "
             + "FROM notice n "
             + "JOIN member m "
             + "ON n.member_id=m.member_id";
    }


    private NoticeDTO map(
        ResultSet rs
    ) throws SQLException {

        NoticeDTO notice =
            new NoticeDTO();

        notice.setNoticeId(
            rs.getLong("notice_id")
        );

        notice.setMemberId(
            rs.getLong("member_id")
        );

        notice.setTitle(
            rs.getString("title")
        );

        notice.setContent(
            rs.getString("content")
        );

        notice.setViewCount(
            rs.getInt("view_count")
        );

        notice.setCreatedAt(
            rs.getTimestamp("created_at")
        );

        notice.setUpdatedAt(
            rs.getTimestamp("updated_at")
        );

        notice.setWriterNickname(
            rs.getString("writer_nickname")
        );

        return notice;
    }
}
