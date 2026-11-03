package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import util.DBConnection;

public class CommentLikeDAO {

    /*
     * 현재 사용자가 해당 댓글에 좋아요를 눌렀는지 확인
     */
    public boolean exists(long memberId, long commentId) throws Exception {

        String sql =
            "SELECT 1 "
          + "FROM comment_like "
          + "WHERE member_id = ? "
          + "AND comment_id = ?";

        try (
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql)
        ) {

            ps.setLong(1, memberId);
            ps.setLong(2, commentId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }


    /*
     * 댓글 좋아요 토글
     *
     * 좋아요가 없으면 INSERT
     * 좋아요가 있으면 DELETE
     *
     * 처리 후 comment.like_count도 다시 계산
     *
     * return true  = 좋아요 상태
     * return false = 좋아요 취소 상태
     */
    public boolean toggle(long memberId, long commentId) throws Exception {

        try (
            Connection conn = DBConnection.getConnection()
        ) {

            conn.setAutoCommit(false);

            try {

                boolean alreadyLiked;

                try (
                    PreparedStatement ps =
                        conn.prepareStatement(
                            "SELECT 1 "
                          + "FROM comment_like "
                          + "WHERE member_id=? "
                          + "AND comment_id=? "
                          + "FOR UPDATE"
                        )
                ) {

                    ps.setLong(1, memberId);
                    ps.setLong(2, commentId);

                    try (ResultSet rs = ps.executeQuery()) {
                        alreadyLiked = rs.next();
                    }
                }


                if (alreadyLiked) {

                    try (
                        PreparedStatement ps =
                            conn.prepareStatement(
                                "DELETE FROM comment_like "
                              + "WHERE member_id=? "
                              + "AND comment_id=?"
                            )
                    ) {
                        ps.setLong(1, memberId);
                        ps.setLong(2, commentId);
                        ps.executeUpdate();
                    }

                    try (
                        PreparedStatement ps =
                            conn.prepareStatement(
                                "UPDATE comment "
                              + "SET like_count="
                              + "GREATEST(like_count - 1, 0) "
                              + "WHERE comment_id=?"
                            )
                    ) {
                        ps.setLong(1, commentId);
                        ps.executeUpdate();
                    }

                    conn.commit();
                    return false;
                }


                /*
                 * 싫어요가 있으면 먼저 해제.
                 */
                try (
                    PreparedStatement ps =
                        conn.prepareStatement(
                            "DELETE FROM comment_dislike "
                          + "WHERE member_id=? "
                          + "AND comment_id=?"
                        )
                ) {

                    ps.setLong(1, memberId);
                    ps.setLong(2, commentId);

                    int removed = ps.executeUpdate();

                    if (removed > 0) {
                        try (
                            PreparedStatement countPs =
                                conn.prepareStatement(
                                    "UPDATE comment "
                                  + "SET dislike_count="
                                  + "GREATEST(dislike_count - 1, 0) "
                                  + "WHERE comment_id=?"
                                )
                        ) {
                            countPs.setLong(1, commentId);
                            countPs.executeUpdate();
                        }
                    }
                }


                try (
                    PreparedStatement ps =
                        conn.prepareStatement(
                            "INSERT INTO comment_like("
                          + "member_id, comment_id"
                          + ") VALUES(?,?)"
                        )
                ) {
                    ps.setLong(1, memberId);
                    ps.setLong(2, commentId);
                    ps.executeUpdate();
                }


                try (
                    PreparedStatement ps =
                        conn.prepareStatement(
                            "UPDATE comment "
                          + "SET like_count=like_count + 1 "
                          + "WHERE comment_id=?"
                        )
                ) {
                    ps.setLong(1, commentId);
                    ps.executeUpdate();
                }


                conn.commit();
                return true;

            } catch (Exception e) {

                conn.rollback();
                throw e;

            } finally {

                conn.setAutoCommit(true);
            }
        }
    }


    /*
     * 댓글 좋아요 개수 직접 조회
     */
    public int count(long commentId) throws Exception {

        String sql =
            "SELECT COUNT(*) "
          + "FROM comment_like "
          + "WHERE comment_id = ?";


        try (
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql)
        ) {

            ps.setLong(1, commentId);

            try (
                ResultSet rs =
                    ps.executeQuery()
            ) {

                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }

        return 0;
    }
}
