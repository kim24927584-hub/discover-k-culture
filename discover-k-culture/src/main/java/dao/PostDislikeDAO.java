package dao;

import util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;


public class PostDislikeDAO {

    public boolean exists(
        long memberId,
        long postId
    ) throws Exception {

        String sql =
            "SELECT 1 "
          + "FROM post_dislike "
          + "WHERE member_id=? "
          + "AND post_id=?";

        try (
            Connection c = DBConnection.getConnection();
            PreparedStatement p = c.prepareStatement(sql)
        ) {

            p.setLong(1, memberId);
            p.setLong(2, postId);

            try (ResultSet r = p.executeQuery()) {
                return r.next();
            }
        }
    }


    public boolean toggle(
        long memberId,
        long postId
    ) throws Exception {

        try (
            Connection c = DBConnection.getConnection()
        ) {

            c.setAutoCommit(false);

            try {

                boolean alreadyDisliked;

                try (
                    PreparedStatement p =
                        c.prepareStatement(
                            "SELECT 1 "
                          + "FROM post_dislike "
                          + "WHERE member_id=? "
                          + "AND post_id=? "
                          + "FOR UPDATE"
                        )
                ) {

                    p.setLong(1, memberId);
                    p.setLong(2, postId);

                    try (ResultSet r = p.executeQuery()) {
                        alreadyDisliked = r.next();
                    }
                }


                if (alreadyDisliked) {

                    try (
                        PreparedStatement p =
                            c.prepareStatement(
                                "DELETE FROM post_dislike "
                              + "WHERE member_id=? "
                              + "AND post_id=?"
                            )
                    ) {
                        p.setLong(1, memberId);
                        p.setLong(2, postId);
                        p.executeUpdate();
                    }

                    try (
                        PreparedStatement p =
                            c.prepareStatement(
                                "UPDATE post "
                              + "SET dislike_count="
                              + "GREATEST(dislike_count - 1, 0) "
                              + "WHERE post_id=?"
                            )
                    ) {
                        p.setLong(1, postId);
                        p.executeUpdate();
                    }

                    c.commit();
                    return false;
                }


                /*
                 * 추천 상태였다면 추천을 먼저 해제합니다.
                 */
                try (
                    PreparedStatement p =
                        c.prepareStatement(
                            "DELETE FROM post_like "
                          + "WHERE member_id=? "
                          + "AND post_id=?"
                        )
                ) {

                    p.setLong(1, memberId);
                    p.setLong(2, postId);

                    int removed = p.executeUpdate();

                    if (removed > 0) {
                        try (
                            PreparedStatement countPs =
                                c.prepareStatement(
                                    "UPDATE post "
                                  + "SET like_count="
                                  + "GREATEST(like_count - 1, 0) "
                                  + "WHERE post_id=?"
                                )
                        ) {
                            countPs.setLong(1, postId);
                            countPs.executeUpdate();
                        }
                    }
                }


                try (
                    PreparedStatement p =
                        c.prepareStatement(
                            "INSERT INTO post_dislike("
                          + "member_id, post_id"
                          + ") VALUES(?,?)"
                        )
                ) {
                    p.setLong(1, memberId);
                    p.setLong(2, postId);
                    p.executeUpdate();
                }


                try (
                    PreparedStatement p =
                        c.prepareStatement(
                            "UPDATE post "
                          + "SET dislike_count=dislike_count + 1 "
                          + "WHERE post_id=?"
                        )
                ) {
                    p.setLong(1, postId);
                    p.executeUpdate();
                }


                c.commit();
                return true;

            } catch (Exception e) {

                c.rollback();
                throw e;

            } finally {

                c.setAutoCommit(true);
            }
        }
    }
}
