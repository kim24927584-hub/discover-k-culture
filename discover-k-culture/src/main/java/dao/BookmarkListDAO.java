package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import dto.BookmarkPostDTO;
import util.DBConnection;

/**
 * 북마크 목록 전용 DAO
 *
 * 기존 BookmarkDAO의 toggle(), exists() 기능은 그대로 사용하고,
 * 이 DAO는 "내가 북마크한 게시글 목록 조회"와
 * "북마크 목록에서 바로 삭제" 기능만 담당합니다.
 *
 * 기존 BookmarkDAO를 수정하지 않기 때문에
 * 기존 상세보기의 북마크 기능과 충돌하지 않습니다.
 */
public class BookmarkListDAO {


    /**
     * 현재 회원이 북마크한 모든 게시글 조회
     *
     * bookmark -> post -> member -> category 순으로 JOIN하여
     * 목록 화면에서 필요한 정보를 한 번에 조회합니다.
     *
     * @param memberId 로그인 회원 번호
     * @return 북마크한 게시글 목록
     */
    public List<BookmarkPostDTO> selectByMemberId(long memberId)
            throws Exception {

        List<BookmarkPostDTO> list =
            new ArrayList<>();

        String sql =
            "SELECT "
          + "p.post_id, "
          + "p.board_type, "
          + "p.title, "
          + "p.view_count, "
          + "p.like_count, "
          + "p.created_at, "
          + "m.nickname AS member_nickname, "
          + "c.name AS category_name, "
          + "b.created_at AS bookmarked_at "
          + "FROM bookmark b "
          + "JOIN post p "
          + "ON b.post_id = p.post_id "
          + "JOIN member m "
          + "ON p.member_id = m.member_id "
          + "LEFT JOIN category c "
          + "ON p.category_id = c.category_id "
          + "WHERE b.member_id = ? "
          + "ORDER BY b.created_at DESC";

        try (
            Connection conn =
                DBConnection.getConnection();

            PreparedStatement ps =
                conn.prepareStatement(sql)
        ) {

            ps.setLong(
                1,
                memberId
            );

            try (
                ResultSet rs =
                    ps.executeQuery()
            ) {

                while (rs.next()) {

                    BookmarkPostDTO dto =
                        new BookmarkPostDTO();

                    dto.setPostId(
                        rs.getLong(
                            "post_id"
                        )
                    );

                    dto.setBoardType(
                        rs.getString(
                            "board_type"
                        )
                    );

                    dto.setTitle(
                        rs.getString(
                            "title"
                        )
                    );

                    dto.setMemberNickname(
                        rs.getString(
                            "member_nickname"
                        )
                    );

                    dto.setCategoryName(
                        rs.getString(
                            "category_name"
                        )
                    );

                    dto.setViewCount(
                        rs.getInt(
                            "view_count"
                        )
                    );

                    dto.setLikeCount(
                        rs.getInt(
                            "like_count"
                        )
                    );

                    dto.setCreatedAt(
                        rs.getTimestamp(
                            "created_at"
                        )
                    );

                    dto.setBookmarkedAt(
                        rs.getTimestamp(
                            "bookmarked_at"
                        )
                    );

                    list.add(dto);
                }
            }
        }

        return list;
    }


    /**
     * 북마크 목록 화면에서 북마크 하나 삭제
     *
     * 반드시 member_id와 post_id를 함께 조건으로 사용합니다.
     * 다른 사용자의 북마크를 삭제하지 못하게 하기 위함입니다.
     *
     * @param memberId 로그인 회원 번호
     * @param postId 게시글 번호
     * @return 삭제된 행 수
     */
    public int delete(
        long memberId,
        long postId
    ) throws Exception {

        String sql =
            "DELETE FROM bookmark "
          + "WHERE member_id = ? "
          + "AND post_id = ?";

        try (
            Connection conn =
                DBConnection.getConnection();

            PreparedStatement ps =
                conn.prepareStatement(sql)
        ) {

            ps.setLong(
                1,
                memberId
            );

            ps.setLong(
                2,
                postId
            );

            return ps.executeUpdate();
        }
    }
}
