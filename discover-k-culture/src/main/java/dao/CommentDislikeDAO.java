package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import util.DBConnection;


public class CommentDislikeDAO {

    public boolean exists(
        long memberId,
        long commentId
    ) throws Exception {

        String sql =
            "SELECT 1 "
          + "FROM comment_dislike "
          + "WHERE member_id=? "
          + "AND comment_id=?";

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


    public boolean toggle(
        long memberId,
        long commentId
    ) throws Exception {

        try (
            Connection conn = DBConnection.getConnection()
        ) {

            conn.setAutoCommit(false);

            try {

                boolean alreadyDisliked;

                try (
                    PreparedStatement ps =
                        conn.prepareStatement(
                            "SELECT 1 "
                          + "FROM comment_dislike "
                          + "WHERE member_id=? "
                          + "AND comment_id=? "
                          + "FOR UPDATE"
                        )
                ) {

                    ps.setLong(1, memberId);
                    ps.setLong(2, commentId);

                    try (ResultSet rs = ps.executeQuery()) {
                        alreadyDisliked = rs.next();
                    }
                }


                if (alreadyDisliked) {

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
                        ps.executeUpdate();
                    }

                    try (
                        PreparedStatement ps =
                            conn.prepareStatement(
                                "UPDATE comment "
                              + "SET dislike_count="
                              + "GREATEST(dislike_count - 1, 0) "
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
                 * 좋아요가 있으면 먼저 해제.
                 */
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

                    int removed = ps.executeUpdate();

                    if (removed > 0) {
                        try (
                            PreparedStatement countPs =
                                conn.prepareStatement(
                                    "UPDATE comment "
                                  + "SET like_count="
                                  + "GREATEST(like_count - 1, 0) "
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
                            "INSERT INTO comment_dislike("
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
                          + "SET dislike_count=dislike_count + 1 "
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
}
