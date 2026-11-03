package dao;

import util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import java.util.ArrayList;
import java.util.List;

import dto.PostDTO;

public class PostLikeDAO {

	public boolean exists(long memberId, long postId) throws Exception {

		String sql = "SELECT 1 " + "FROM post_like " + "WHERE member_id=? " + "AND post_id=?";

		try (Connection c = DBConnection.getConnection();

				PreparedStatement p = c.prepareStatement(sql)) {

			p.setLong(1, memberId);
			p.setLong(2, postId);

			try (ResultSet r = p.executeQuery()) {
				return r.next();
			}
		}
	}

	/*
	 * 중요:
	 *
	 * 기존 코드는 좋아요를 누를 때마다 post_like의 COUNT(*)로 post.like_count를 덮어썼습니다.
	 *
	 * 더미데이터처럼 post.like_count = 13인데 post_like 행이 0개인 경우 첫 좋아요가 1로 초기화되는 문제가 생깁니다.
	 *
	 * 수정 방식:
	 *
	 * 좋아요 추가 post_like INSERT like_count = like_count + 1
	 *
	 * 좋아요 취소 post_like DELETE like_count = like_count - 1
	 *
	 * 따라서 13 -> 좋아요 -> 14 14 -> 취소 -> 13 로 동작합니다.
	 */
	public boolean toggle(long memberId, long postId) throws Exception {

		try (Connection c = DBConnection.getConnection()) {

			c.setAutoCommit(false);

			try {

				boolean alreadyLiked;

				String existsSql = "SELECT 1 " + "FROM post_like " + "WHERE member_id=? " + "AND post_id=? "
						+ "FOR UPDATE";

				try (PreparedStatement p = c.prepareStatement(existsSql)) {

					p.setLong(1, memberId);
					p.setLong(2, postId);

					try (ResultSet r = p.executeQuery()) {

						alreadyLiked = r.next();
					}
				}

				if (alreadyLiked) {

					try (PreparedStatement p = c
							.prepareStatement("DELETE FROM post_like " + "WHERE member_id=? " + "AND post_id=?")) {

						p.setLong(1, memberId);
						p.setLong(2, postId);
						p.executeUpdate();
					}

					/*
					 * 음수 방지
					 */
					try (PreparedStatement p = c.prepareStatement(
							"UPDATE post " + "SET like_count=" + "GREATEST(like_count - 1, 0) " + "WHERE post_id=?")) {

						p.setLong(1, postId);
						p.executeUpdate();
					}

					c.commit();

					return false;

				} else {

					/*
					 * 비추천 상태였다면 먼저 해제합니다. 추천과 비추천은 동시에 유지되지 않습니다.
					 */
					try (PreparedStatement p = c
							.prepareStatement("DELETE FROM post_dislike " + "WHERE member_id=? " + "AND post_id=?")) {

						p.setLong(1, memberId);
						p.setLong(2, postId);

						int removed = p.executeUpdate();

						if (removed > 0) {

							try (PreparedStatement countPs = c.prepareStatement("UPDATE post " + "SET dislike_count="
									+ "GREATEST(dislike_count - 1, 0) " + "WHERE post_id=?")) {

								countPs.setLong(1, postId);
								countPs.executeUpdate();
							}
						}
					}

					try (PreparedStatement p = c
							.prepareStatement("INSERT INTO post_like(" + "member_id, post_id" + ") VALUES(?,?)")) {

						p.setLong(1, memberId);
						p.setLong(2, postId);
						p.executeUpdate();
					}

					try (PreparedStatement p = c
							.prepareStatement("UPDATE post " + "SET like_count=like_count + 1 " + "WHERE post_id=?")) {

						p.setLong(1, postId);
						p.executeUpdate();
					}

					c.commit();

					return true;
				}

			} catch (Exception e) {

				c.rollback();

				throw e;

			} finally {

				c.setAutoCommit(true);
			}
		}
	}

	/*
	 * ========================================== 마이페이지: 내가 추천한 게시글 목록
	 * ==========================================
	 */
	public List<PostDTO> selectPostsByMemberId(long memberId) throws Exception {

		List<PostDTO> list = new ArrayList<PostDTO>();

		String sql = "SELECT " + "p.*, " + "m.nickname AS member_nickname, " + "c.name AS category_name, "
				+ "(SELECT COUNT(*) " + "   FROM comment cm " + "  WHERE cm.post_id=p.post_id" + ") AS comment_count "
				+ "FROM post_like pl " + "JOIN post p " + "ON pl.post_id=p.post_id " + "JOIN member m "
				+ "ON p.member_id=m.member_id " + "LEFT JOIN category c " + "ON p.category_id=c.category_id "
				+ "WHERE pl.member_id=? " + "ORDER BY pl.created_at DESC";

		try (Connection conn = DBConnection.getConnection();

				PreparedStatement ps = conn.prepareStatement(sql)) {

			ps.setLong(1, memberId);

			try (ResultSet rs = ps.executeQuery()) {

				while (rs.next()) {

					list.add(mapPost(rs));
				}
			}
		}

		return list;
	}

	private PostDTO mapPost(ResultSet rs) throws SQLException {

		PostDTO p = new PostDTO();

		p.setPostId(rs.getLong("post_id"));

		p.setMemberId(rs.getLong("member_id"));

		Object categoryId = rs.getObject("category_id");

		if (categoryId != null) {

			p.setCategoryId(((Number) categoryId).intValue());
		}

		p.setBoardType(rs.getString("board_type"));

		p.setTitle(rs.getString("title"));

		p.setContent(rs.getString("content"));

		p.setViewCount(rs.getInt("view_count"));

		p.setLikeCount(rs.getInt("like_count"));

		p.setDislikeCount(rs.getInt("dislike_count"));

		p.setCreatedAt(rs.getTimestamp("created_at"));

		p.setUpdatedAt(rs.getTimestamp("updated_at"));

		p.setMemberNickname(rs.getString("member_nickname"));

		p.setCategoryName(rs.getString("category_name"));

		p.setCommentCount(rs.getInt("comment_count"));

		return p;
	}

}
