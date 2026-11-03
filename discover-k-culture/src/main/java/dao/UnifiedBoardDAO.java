package dao;

import dto.UnifiedBoardDTO;
import util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import java.util.ArrayList;
import java.util.List;

public class UnifiedBoardDAO {

	private UnifiedBoardDTO map(ResultSet rs) throws Exception {

		UnifiedBoardDTO dto = new UnifiedBoardDTO();

		dto.setId(rs.getLong("id"));

		dto.setSourceType(rs.getString("source_type"));

		dto.setBoardType(rs.getString("board_type"));

		dto.setTitle(rs.getString("title"));

		dto.setWriterNickname(rs.getString("writer_nickname"));

		dto.setViewCount(rs.getInt("view_count"));

		dto.setLikeCount(rs.getInt("like_count"));

		dto.setDislikeCount(rs.getInt("dislike_count"));

		dto.setCreatedAt(rs.getTimestamp("created_at"));

		dto.setImagePath(rs.getString("image_path"));

		dto.setVideoPath(rs.getString("video_path"));

		dto.setVideoThumbnailPath(rs.getString("video_thumbnail_path"));

		return dto;
	}

	/*
	 * 모든 게시판: KCULTURE + FREE + QUESTION + NOTICE 관리자 문의(inquiry)는 포함하지 않습니다.
	 */
	public int countAll(String keyword) throws Exception {

		if (keyword == null) {
			keyword = "";
		}

		String like = "%" + keyword.trim() + "%";

		String sql = "SELECT COUNT(*) AS cnt " + "FROM ( " + "    SELECT p.title " + "    FROM post p "
				+ "    JOIN member m " + "      ON p.member_id=m.member_id " + "    WHERE p.board_type IN "
				+ "          ('KCULTURE','FREE','QUESTION') " + "      AND ( " + "          p.title LIKE ? "
				+ "          OR p.content LIKE ? " + "          OR m.nickname LIKE ? " + "      ) " + "    UNION ALL "
				+ "    SELECT n.title " + "    FROM notice n " + "    JOIN member m "
				+ "      ON n.member_id=m.member_id " + "    WHERE ( " + "        n.title LIKE ? "
				+ "        OR n.content LIKE ? " + "        OR m.nickname LIKE ? " + "    ) " + ") x";

		try (Connection conn = DBConnection.getConnection();

				PreparedStatement ps = conn.prepareStatement(sql)) {

			for (int i = 1; i <= 6; i++) {
				ps.setString(i, like);
			}

			try (ResultSet rs = ps.executeQuery()) {

				if (rs.next()) {
					return rs.getInt("cnt");
				}
			}
		}

		return 0;
	}

	public List<UnifiedBoardDTO> selectLatest(String keyword, int page, int pageSize) throws Exception {

		if (keyword == null) {
			keyword = "";
		}

		if (page < 1) {
			page = 1;
		}

		if (pageSize < 1) {
			pageSize = 10;
		}

		String like = "%" + keyword.trim() + "%";

		int offset = (page - 1) * pageSize;

		String sql = "SELECT * " + "FROM ( " + "    SELECT " + "        p.post_id AS id, "
				+ "        'POST' AS source_type, " + "        p.board_type, " + "        p.title, "
				+ "        m.nickname AS writer_nickname, " + "        p.view_count, " + "        p.like_count, "
				+ "        p.dislike_count, " + "        p.created_at, " + "        NULL AS image_path, "
				+ "        NULL AS video_path, " + "        NULL AS video_thumbnail_path " + "    FROM post p "
				+ "    JOIN member m " + "      ON p.member_id=m.member_id " + "    WHERE p.board_type IN "
				+ "          ('KCULTURE','FREE','QUESTION') " + "      AND ( " + "          p.title LIKE ? "
				+ "          OR p.content LIKE ? " + "          OR m.nickname LIKE ? " + "      ) " + "    UNION ALL "
				+ "    SELECT " + "        n.notice_id AS id, " + "        'NOTICE' AS source_type, "
				+ "        'NOTICE' AS board_type, " + "        n.title, " + "        m.nickname AS writer_nickname, "
				+ "        n.view_count, " + "        0 AS like_count, " + "        0 AS dislike_count, "
				+ "        n.created_at, " + "        NULL AS image_path, " + "        NULL AS video_path, "
				+ "        NULL AS video_thumbnail_path " + "    FROM notice n " + "    JOIN member m "
				+ "      ON n.member_id=m.member_id " + "    WHERE ( " + "        n.title LIKE ? "
				+ "        OR n.content LIKE ? " + "        OR m.nickname LIKE ? " + "    ) " + ") x " + "ORDER BY "
				+ "CASE " + "    WHEN source_type='NOTICE' THEN 0 " + "    ELSE 1 " + "END ASC, " + "created_at DESC, "
				+ "id DESC " + "LIMIT ? OFFSET ?";

		List<UnifiedBoardDTO> list = new ArrayList<UnifiedBoardDTO>();

		try (Connection conn = DBConnection.getConnection();

				PreparedStatement ps = conn.prepareStatement(sql)) {

			for (int i = 1; i <= 6; i++) {
				ps.setString(i, like);
			}

			ps.setInt(7, pageSize);
			ps.setInt(8, offset);

			try (ResultSet rs = ps.executeQuery()) {

				while (rs.next()) {
					list.add(map(rs));
				}
			}
		}

		return list;
	}


    /*
     * 전체 게시글 화면용 검색 + 정렬 + 페이지 조회.
     * sortType: latest / likes / views
     */
    public List<UnifiedBoardDTO> selectAllSorted(
            String keyword,
            String sortType,
            int page,
            int pageSize) throws Exception {

        if (keyword == null) keyword = "";
        if (sortType == null) sortType = "latest";
        if (page < 1) page = 1;
        if (pageSize < 1) pageSize = 10;

        String like = "%" + keyword.trim() + "%";
        int offset = (page - 1) * pageSize;

        String orderBy;
        if ("likes".equals(sortType)) {
            orderBy = "like_count DESC, created_at DESC, id DESC";
        } else if ("views".equals(sortType)) {
            orderBy = "view_count DESC, created_at DESC, id DESC";
        } else {
            orderBy = "created_at DESC, id DESC";
        }

        String sql =
            "SELECT * FROM ( "
          + " SELECT p.post_id AS id, 'POST' AS source_type, p.board_type, p.title, "
          + "        m.nickname AS writer_nickname, p.view_count, p.like_count, p.dislike_count, "
          + "        p.created_at, NULL AS image_path, NULL AS video_path, NULL AS video_thumbnail_path "
          + " FROM post p JOIN member m ON p.member_id=m.member_id "
          + " WHERE p.board_type IN ('KCULTURE','FREE','QUESTION') "
          + "   AND (p.title LIKE ? OR p.content LIKE ? OR m.nickname LIKE ?) "
          + " UNION ALL "
          + " SELECT n.notice_id AS id, 'NOTICE' AS source_type, 'NOTICE' AS board_type, n.title, "
          + "        m.nickname AS writer_nickname, n.view_count, 0 AS like_count, 0 AS dislike_count, "
          + "        n.created_at, NULL AS image_path, NULL AS video_path, NULL AS video_thumbnail_path "
          + " FROM notice n JOIN member m ON n.member_id=m.member_id "
          + " WHERE (n.title LIKE ? OR n.content LIKE ? OR m.nickname LIKE ?) "
          + ") x "
          + "ORDER BY CASE WHEN source_type='NOTICE' THEN 0 ELSE 1 END ASC, " + orderBy
          + " LIMIT ? OFFSET ?";

        List<UnifiedBoardDTO> list = new ArrayList<UnifiedBoardDTO>();

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            for (int i = 1; i <= 6; i++) ps.setString(i, like);
            ps.setInt(7, pageSize);
            ps.setInt(8, offset);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }

        return list;
    }


    /*
     * 전체 게시글 검색 필터.
     * searchField: all / title / content / writer
     * boardFilter: ALL / NOTICE / KCULTURE / QUESTION / FREE
     */
    public int countFiltered(
            String keyword,
            String searchField,
            String boardFilter) throws Exception {

        String field = normalizeSearchField(searchField);
        String board = normalizeBoardFilter(boardFilter);
        String safeKeyword = keyword == null ? "" : keyword.trim();
        String like = "%" + safeKeyword + "%";

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) FROM ( ");
        sql.append(baseUnionSql());
        sql.append(") x WHERE 1=1 ");

        if (!"ALL".equals(board)) {
            sql.append("AND board_type=? ");
        }

        appendUnifiedSearchCondition(sql, safeKeyword, field);

        try (
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql.toString())
        ) {
            int index = 1;

            if (!"ALL".equals(board)) {
                ps.setString(index++, board);
            }

            index = bindUnifiedSearchCondition(
                ps,
                index,
                safeKeyword,
                field,
                like
            );

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    public List<UnifiedBoardDTO> selectFiltered(
            String keyword,
            String searchField,
            String boardFilter,
            String sortType,
            int page,
            int pageSize) throws Exception {

        String field = normalizeSearchField(searchField);
        String board = normalizeBoardFilter(boardFilter);
        String safeKeyword = keyword == null ? "" : keyword.trim();
        String like = "%" + safeKeyword + "%";

        if (page < 1) page = 1;
        if (pageSize < 1) pageSize = 10;

        int offset = (page - 1) * pageSize;

        String orderBy;
        if ("likes".equals(sortType)) {
            orderBy = "like_count DESC, created_at DESC, id DESC";
        } else if ("views".equals(sortType)) {
            orderBy = "view_count DESC, created_at DESC, id DESC";
        } else {
            orderBy = "created_at DESC, id DESC";
        }

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT * FROM ( ");
        sql.append(baseUnionSql());
        sql.append(") x WHERE 1=1 ");

        if (!"ALL".equals(board)) {
            sql.append("AND board_type=? ");
        }

        appendUnifiedSearchCondition(sql, safeKeyword, field);

        sql.append("ORDER BY CASE WHEN source_type='NOTICE' THEN 0 ELSE 1 END ASC, ");
        sql.append(orderBy);
        sql.append(" LIMIT ? OFFSET ?");

        List<UnifiedBoardDTO> list = new ArrayList<UnifiedBoardDTO>();

        try (
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql.toString())
        ) {
            int index = 1;

            if (!"ALL".equals(board)) {
                ps.setString(index++, board);
            }

            index = bindUnifiedSearchCondition(
                ps,
                index,
                safeKeyword,
                field,
                like
            );

            ps.setInt(index++, pageSize);
            ps.setInt(index++, offset);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(map(rs));
                }
            }
        }

        return list;
    }

    private String baseUnionSql() {
        return
            " SELECT p.post_id AS id, 'POST' AS source_type, p.board_type, p.title, "
          + "        p.content AS content, m.nickname AS writer_nickname, "
          + "        p.view_count, p.like_count, p.dislike_count, p.created_at, "
          + "        NULL AS image_path, NULL AS video_path, NULL AS video_thumbnail_path "
          + " FROM post p JOIN member m ON p.member_id=m.member_id "
          + " WHERE p.board_type IN ('KCULTURE','FREE','QUESTION') "
          + " UNION ALL "
          + " SELECT n.notice_id AS id, 'NOTICE' AS source_type, 'NOTICE' AS board_type, n.title, "
          + "        n.content AS content, m.nickname AS writer_nickname, "
          + "        n.view_count, 0 AS like_count, 0 AS dislike_count, n.created_at, "
          + "        NULL AS image_path, NULL AS video_path, NULL AS video_thumbnail_path "
          + " FROM notice n JOIN member m ON n.member_id=m.member_id ";
    }

    private String normalizeSearchField(String searchField) {
        if (
            "title".equals(searchField)
            || "content".equals(searchField)
            || "writer".equals(searchField)
        ) {
            return searchField;
        }
        return "all";
    }

    private String normalizeBoardFilter(String boardFilter) {
        if (
            "NOTICE".equals(boardFilter)
            || "KCULTURE".equals(boardFilter)
            || "QUESTION".equals(boardFilter)
            || "FREE".equals(boardFilter)
        ) {
            return boardFilter;
        }
        return "ALL";
    }

    private void appendUnifiedSearchCondition(
            StringBuilder sql,
            String safeKeyword,
            String field) {

        if (safeKeyword == null || safeKeyword.isEmpty()) {
            return;
        }

        if ("title".equals(field)) {
            sql.append("AND title LIKE ? ");
        } else if ("content".equals(field)) {
            sql.append("AND content LIKE ? ");
        } else if ("writer".equals(field)) {
            sql.append("AND writer_nickname LIKE ? ");
        } else {
            sql.append(
                "AND (title LIKE ? OR content LIKE ? OR writer_nickname LIKE ?) "
            );
        }
    }

    private int bindUnifiedSearchCondition(
            PreparedStatement ps,
            int index,
            String safeKeyword,
            String field,
            String like) throws Exception {

        if (safeKeyword == null || safeKeyword.isEmpty()) {
            return index;
        }

        if (
            "title".equals(field)
            || "content".equals(field)
            || "writer".equals(field)
        ) {
            ps.setString(index++, like);
            return index;
        }

        ps.setString(index++, like);
        ps.setString(index++, like);
        ps.setString(index++, like);
        return index;
    }


	/*
	 * 홈 조회수 TOP 게시글. 일반 게시글만 대상으로 하고 첫 번째 이미지를 함께 조회합니다.
	 */
	public List<UnifiedBoardDTO> selectTopViewedPosts(int limit) throws Exception {

		if (limit < 1) {
			limit = 4;
		}

		String sql = "SELECT " + "p.post_id AS id, " + "'POST' AS source_type, " + "p.board_type, " + "p.title, "
				+ "m.nickname AS writer_nickname, " + "p.view_count, " + "p.like_count, " + "p.dislike_count, "
				+ "p.created_at, " + "( " + "    SELECT pi.image_path " + "    FROM post_image pi "
				+ "    WHERE pi.post_id=p.post_id " + "    ORDER BY " + "        pi.image_order ASC, "
				+ "        pi.image_id ASC " + "    LIMIT 1 " + ") AS image_path, " + "( " + "    SELECT pv.video_path "
				+ "    FROM post_video pv " + "    WHERE pv.post_id=p.post_id " + "    ORDER BY "
				+ "        pv.video_order ASC, " + "        pv.video_id ASC " + "    LIMIT 1 " + ") AS video_path, "
				+ "( " + "    SELECT pv.thumbnail_path " + "    FROM post_video pv " + "    WHERE pv.post_id=p.post_id "
				+ "    ORDER BY " + "        pv.video_order ASC, " + "        pv.video_id ASC " + "    LIMIT 1 "
				+ ") AS video_thumbnail_path " + "FROM post p " + "JOIN member m " + "  ON p.member_id=m.member_id "
				+ "WHERE p.board_type IN " + "      ('KCULTURE','FREE','QUESTION') " + "ORDER BY "
				+ "p.view_count DESC, " + "p.created_at DESC " + "LIMIT ?";

		List<UnifiedBoardDTO> list = new ArrayList<UnifiedBoardDTO>();

		try (Connection conn = DBConnection.getConnection();

				PreparedStatement ps = conn.prepareStatement(sql)) {

			ps.setInt(1, limit);

			try (ResultSet rs = ps.executeQuery()) {

				while (rs.next()) {
					list.add(map(rs));
				}
			}
		}

		return list;
	}

	/*
	 * 홈 추천 게시글. 추천 수가 높은 일반 게시글 순.
	 */
	public List<UnifiedBoardDTO> selectRecommended(int limit) throws Exception {

		if (limit < 1) {
			limit = 5;
		}

		String sql = "SELECT " + "p.post_id AS id, " + "'POST' AS source_type, " + "p.board_type, " + "p.title, "
				+ "m.nickname AS writer_nickname, " + "p.view_count, " + "p.like_count, " + "p.dislike_count, "
				+ "p.created_at, " + "NULL AS image_path, " + "NULL AS video_path, " + "NULL AS video_thumbnail_path "
				+ "FROM post p " + "JOIN member m " + "  ON p.member_id=m.member_id " + "WHERE p.board_type IN "
				+ "      ('KCULTURE','FREE','QUESTION') " + "ORDER BY " + "p.like_count DESC, " + "p.created_at DESC "
				+ "LIMIT ?";

		List<UnifiedBoardDTO> list = new ArrayList<UnifiedBoardDTO>();

		try (Connection conn = DBConnection.getConnection();

				PreparedStatement ps = conn.prepareStatement(sql)) {

			ps.setInt(1, limit);

			try (ResultSet rs = ps.executeQuery()) {

				while (rs.next()) {
					list.add(map(rs));
				}
			}
		}

		return list;
	}
}
