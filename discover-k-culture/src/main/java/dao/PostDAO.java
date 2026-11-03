package dao;

import dto.PostDTO;
import util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

public class PostDAO {

    private boolean isValidBoardType(String boardType) {
        return "KCULTURE".equals(boardType)
            || "FREE".equals(boardType)
            || "QUESTION".equals(boardType);
    }

    private String normalizeBoardType(String boardType) {
        return isValidBoardType(boardType) ? boardType : "KCULTURE";
    }

    public long insertAndGetId(PostDTO post) throws Exception {

        String boardType =
            normalizeBoardType(
                post.getBoardType()
            );

        String sql =
            "INSERT INTO post("
          + "member_id, "
          + "category_id, "
          + "board_type, "
          + "title, "
          + "content"
          + ") VALUES(?, ?, ?, ?, ?)";


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
                post.getMemberId()
            );


            if (
                "KCULTURE".equals(boardType)
                && post.getCategoryId() > 0
            ) {

                ps.setInt(
                    2,
                    post.getCategoryId()
                );

            } else {

                ps.setNull(
                    2,
                    Types.INTEGER
                );
            }


            ps.setString(
                3,
                boardType
            );


            ps.setString(
                4,
                post.getTitle()
            );


            ps.setString(
                5,
                post.getContent()
            );


            if (
                ps.executeUpdate() == 0
            ) {
                return 0;
            }


            try (
                ResultSet rs =
                    ps.getGeneratedKeys()
            ) {

                return rs.next()
                    ? rs.getLong(1)
                    : 0;
            }
        }
    }


    public PostDTO selectById(
        long postId
    ) throws Exception {

        String sql =
            baseSql()
            + " WHERE p.post_id = ?";


        try (
            Connection conn =
                DBConnection.getConnection();

            PreparedStatement ps =
                conn.prepareStatement(sql)
        ) {

            ps.setLong(
                1,
                postId
            );


            try (
                ResultSet rs =
                    ps.executeQuery()
            ) {

                return rs.next()
                    ? mapPost(rs)
                    : null;
            }
        }
    }


    /*
     * ==========================================
     * 기존 전체 검색
     * ==========================================
     *
     * home.jsp 추천게시글 등 기존 코드 호환용
     */
    public List<PostDTO> searchBoard(
        String boardType,
        Integer categoryId,
        String keyword,
        String sort
    ) throws Exception {

        return searchBoardInternal(
            boardType,
            categoryId,
            keyword,
            sort,
            null,
            null
        );
    }


    /*
     * ==========================================
     * 게시판 페이지 검색
     * ==========================================
     *
     * page     : 1부터 시작
     * pageSize : 10 / 20 / 30
     */
    public List<PostDTO> searchBoardPaged(
        String boardType,
        Integer categoryId,
        String keyword,
        String sort,
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


        return searchBoardInternal(
            boardType,
            categoryId,
            keyword,
            sort,
            Integer.valueOf(pageSize),
            Integer.valueOf(offset)
        );
    }


    /*
     * ==========================================
     * 검색 조건에 맞는 전체 게시글 수
     * ==========================================
     *
     * 페이지 개수 계산용
     */
    public int countSearchBoard(
        String boardType,
        Integer categoryId,
        String keyword
    ) throws Exception {

        String type =
            normalizeBoardType(
                boardType
            );


        String safeKeyword =
            keyword == null
            ? ""
            : keyword.trim();


        String likeKeyword =
            "%"
            + safeKeyword
            + "%";


        StringBuilder sql =
            new StringBuilder();


        sql.append(
            "SELECT COUNT(*) "
        );


        sql.append(
            "FROM post p "
        );


        sql.append(
            "JOIN member m "
          + "ON p.member_id = m.member_id "
        );


        sql.append(
            "LEFT JOIN category c "
          + "ON p.category_id = c.category_id "
        );


        sql.append(
            "WHERE p.board_type = ? "
        );


        if (
            "KCULTURE".equals(type)
            && categoryId != null
        ) {

            sql.append(
                "AND p.category_id = ? "
            );
        }


        if (
            !safeKeyword.isEmpty()
        ) {

            sql.append(
                "AND ("
              + "p.title LIKE ? "
              + "OR p.content LIKE ? "
              + "OR m.nickname LIKE ? "
              + "OR c.name LIKE ?"
              + ") "
            );
        }


        try (
            Connection conn =
                DBConnection.getConnection();

            PreparedStatement ps =
                conn.prepareStatement(
                    sql.toString()
                )
        ) {

            int index =
                1;


            ps.setString(
                index++,
                type
            );


            if (
                "KCULTURE".equals(type)
                && categoryId != null
            ) {

                ps.setInt(
                    index++,
                    categoryId.intValue()
                );
            }


            if (
                !safeKeyword.isEmpty()
            ) {

                ps.setString(
                    index++,
                    likeKeyword
                );

                ps.setString(
                    index++,
                    likeKeyword
                );

                ps.setString(
                    index++,
                    likeKeyword
                );

                ps.setString(
                    index++,
                    likeKeyword
                );
            }


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


    /*
     * ==========================================
     * 공통 검색 처리
     * ==========================================
     */
    private List<PostDTO> searchBoardInternal(
        String boardType,
        Integer categoryId,
        String keyword,
        String sort,
        Integer limit,
        Integer offset
    ) throws Exception {

        String type =
            normalizeBoardType(
                boardType
            );


        String safeKeyword =
            keyword == null
            ? ""
            : keyword.trim();


        String likeKeyword =
            "%"
            + safeKeyword
            + "%";


        List<PostDTO> list =
            new ArrayList<PostDTO>();


        StringBuilder sql =
            new StringBuilder();


        sql.append(
            baseSql()
        );


        sql.append(
            " WHERE p.board_type = ? "
        );


        if (
            "KCULTURE".equals(type)
            && categoryId != null
        ) {

            sql.append(
                "AND p.category_id = ? "
            );
        }


        if (
            !safeKeyword.isEmpty()
        ) {

            sql.append(
                "AND ("
              + "p.title LIKE ? "
              + "OR p.content LIKE ? "
              + "OR m.nickname LIKE ? "
              + "OR c.name LIKE ?"
              + ") "
            );
        }


        if (
            "views".equals(sort)
        ) {

            sql.append(
                "ORDER BY "
              + "p.view_count DESC, "
              + "p.post_id DESC "
            );

        } else if (
            "likes".equals(sort)
        ) {

            sql.append(
                "ORDER BY "
              + "p.like_count DESC, "
              + "p.post_id DESC "
            );

        } else {

            sql.append(
                "ORDER BY "
              + "p.created_at DESC, "
              + "p.post_id DESC "
            );
        }


        if (
            limit != null
            && offset != null
        ) {

            sql.append(
                "LIMIT ? OFFSET ?"
            );
        }


        try (
            Connection conn =
                DBConnection.getConnection();

            PreparedStatement ps =
                conn.prepareStatement(
                    sql.toString()
                )
        ) {

            int index =
                1;


            ps.setString(
                index++,
                type
            );


            if (
                "KCULTURE".equals(type)
                && categoryId != null
            ) {

                ps.setInt(
                    index++,
                    categoryId.intValue()
                );
            }


            if (
                !safeKeyword.isEmpty()
            ) {

                ps.setString(
                    index++,
                    likeKeyword
                );

                ps.setString(
                    index++,
                    likeKeyword
                );

                ps.setString(
                    index++,
                    likeKeyword
                );

                ps.setString(
                    index++,
                    likeKeyword
                );
            }


            if (
                limit != null
                && offset != null
            ) {

                ps.setInt(
                    index++,
                    limit.intValue()
                );

                ps.setInt(
                    index++,
                    offset.intValue()
                );
            }


            try (
                ResultSet rs =
                    ps.executeQuery()
            ) {

                while (
                    rs.next()
                ) {

                    list.add(
                        mapPost(rs)
                    );
                }
            }
        }


        return list;
    }



    /*
     * 검색 대상 필터 지원
     * searchField: all / title / content / writer
     */
    public int countSearchBoard(
        String boardType,
        Integer categoryId,
        String keyword,
        String searchField
    ) throws Exception {

        String type = normalizeBoardType(boardType);
        String safeKeyword = keyword == null ? "" : keyword.trim();
        String field = normalizeSearchField(searchField);
        String likeKeyword = "%" + safeKeyword + "%";

        StringBuilder sql = new StringBuilder();

        sql.append("SELECT COUNT(*) ");
        sql.append("FROM post p ");
        sql.append("JOIN member m ON p.member_id = m.member_id ");
        sql.append("LEFT JOIN category c ON p.category_id = c.category_id ");
        sql.append("WHERE p.board_type = ? ");

        if ("KCULTURE".equals(type) && categoryId != null) {
            sql.append("AND p.category_id = ? ");
        }

        appendSearchCondition(sql, safeKeyword, field, "p", "m", "c");

        try (
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql.toString())
        ) {
            int index = 1;
            ps.setString(index++, type);

            if ("KCULTURE".equals(type) && categoryId != null) {
                ps.setInt(index++, categoryId.intValue());
            }

            index = bindSearchCondition(ps, index, safeKeyword, field, likeKeyword);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    public List<PostDTO> searchBoardPaged(
        String boardType,
        Integer categoryId,
        String keyword,
        String searchField,
        String sort,
        int page,
        int pageSize
    ) throws Exception {

        if (page < 1) page = 1;

        if (pageSize != 10 && pageSize != 20 && pageSize != 30) {
            pageSize = 10;
        }

        int offset = (page - 1) * pageSize;

        return searchBoardInternalFiltered(
            boardType,
            categoryId,
            keyword,
            searchField,
            sort,
            Integer.valueOf(pageSize),
            Integer.valueOf(offset)
        );
    }

    public List<PostDTO> searchBoard(
        String boardType,
        Integer categoryId,
        String keyword,
        String searchField,
        String sort
    ) throws Exception {

        return searchBoardInternalFiltered(
            boardType,
            categoryId,
            keyword,
            searchField,
            sort,
            null,
            null
        );
    }

    private List<PostDTO> searchBoardInternalFiltered(
        String boardType,
        Integer categoryId,
        String keyword,
        String searchField,
        String sort,
        Integer limit,
        Integer offset
    ) throws Exception {

        String type = normalizeBoardType(boardType);
        String safeKeyword = keyword == null ? "" : keyword.trim();
        String field = normalizeSearchField(searchField);
        String likeKeyword = "%" + safeKeyword + "%";

        List<PostDTO> list = new ArrayList<PostDTO>();
        StringBuilder sql = new StringBuilder();

        sql.append(baseSql());
        sql.append(" WHERE p.board_type = ? ");

        if ("KCULTURE".equals(type) && categoryId != null) {
            sql.append("AND p.category_id = ? ");
        }

        appendSearchCondition(sql, safeKeyword, field, "p", "m", "c");

        if ("views".equals(sort)) {
            sql.append("ORDER BY p.view_count DESC, p.post_id DESC ");
        } else if ("likes".equals(sort)) {
            sql.append("ORDER BY p.like_count DESC, p.post_id DESC ");
        } else {
            sql.append("ORDER BY p.created_at DESC, p.post_id DESC ");
        }

        if (limit != null && offset != null) {
            sql.append("LIMIT ? OFFSET ?");
        }

        try (
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql.toString())
        ) {
            int index = 1;
            ps.setString(index++, type);

            if ("KCULTURE".equals(type) && categoryId != null) {
                ps.setInt(index++, categoryId.intValue());
            }

            index = bindSearchCondition(ps, index, safeKeyword, field, likeKeyword);

            if (limit != null && offset != null) {
                ps.setInt(index++, limit.intValue());
                ps.setInt(index++, offset.intValue());
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapPost(rs));
                }
            }
        }

        return list;
    }

    private String normalizeSearchField(String searchField) {
        if ("title".equals(searchField) || "content".equals(searchField) || "writer".equals(searchField)) {
            return searchField;
        }
        return "all";
    }

    private void appendSearchCondition(
        StringBuilder sql,
        String safeKeyword,
        String field,
        String postAlias,
        String memberAlias,
        String categoryAlias
    ) {
        if (safeKeyword == null || safeKeyword.isEmpty()) return;

        if ("title".equals(field)) {
            sql.append("AND " + postAlias + ".title LIKE ? ");
        } else if ("content".equals(field)) {
            sql.append("AND " + postAlias + ".content LIKE ? ");
        } else if ("writer".equals(field)) {
            sql.append("AND " + memberAlias + ".nickname LIKE ? ");
        } else {
            sql.append(
                "AND ("
              + postAlias + ".title LIKE ? "
              + "OR " + postAlias + ".content LIKE ? "
              + "OR " + memberAlias + ".nickname LIKE ? "
              + "OR " + categoryAlias + ".name LIKE ?"
              + ") "
            );
        }
    }

    private int bindSearchCondition(
        PreparedStatement ps,
        int index,
        String safeKeyword,
        String field,
        String likeKeyword
    ) throws SQLException {
        if (safeKeyword == null || safeKeyword.isEmpty()) return index;

        if ("title".equals(field) || "content".equals(field) || "writer".equals(field)) {
            ps.setString(index++, likeKeyword);
            return index;
        }

        ps.setString(index++, likeKeyword);
        ps.setString(index++, likeKeyword);
        ps.setString(index++, likeKeyword);
        ps.setString(index++, likeKeyword);
        return index;
    }


    // 기존 JSP/코드 호환용
    public List<PostDTO> search(
        String boardType,
        Integer categoryId,
        String keyword,
        String sort
    ) throws Exception {

        return searchBoard(
            boardType,
            categoryId,
            keyword,
            sort
        );
    }


    public List<PostDTO> selectAll()
        throws Exception {

        return searchBoard(
            "KCULTURE",
            null,
            "",
            "latest"
        );
    }


    public List<PostDTO> selectByMember(
        long memberId
    ) throws Exception {

        List<PostDTO> list =
            new ArrayList<PostDTO>();


        String sql =
            baseSql()
            + " WHERE p.member_id = ? "
            + "ORDER BY p.created_at DESC, "
            + "p.post_id DESC";


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

                while (
                    rs.next()
                ) {

                    list.add(
                        mapPost(rs)
                    );
                }
            }
        }


        return list;
    }


    public int update(
        PostDTO post
    ) throws Exception {

        String boardType =
            normalizeBoardType(
                post.getBoardType()
            );


        String sql =
            "UPDATE post "
          + "SET category_id = ?, "
          + "board_type = ?, "
          + "title = ?, "
          + "content = ? "
          + "WHERE post_id = ? "
          + "AND member_id = ?";


        try (
            Connection conn =
                DBConnection.getConnection();

            PreparedStatement ps =
                conn.prepareStatement(sql)
        ) {

            if (
                "KCULTURE".equals(boardType)
                && post.getCategoryId() > 0
            ) {

                ps.setInt(
                    1,
                    post.getCategoryId()
                );

            } else {

                ps.setNull(
                    1,
                    Types.INTEGER
                );
            }


            ps.setString(
                2,
                boardType
            );


            ps.setString(
                3,
                post.getTitle()
            );


            ps.setString(
                4,
                post.getContent()
            );


            ps.setLong(
                5,
                post.getPostId()
            );


            ps.setLong(
                6,
                post.getMemberId()
            );


            return ps.executeUpdate();
        }
    }


    public int delete(
        long postId,
        long memberId
    ) throws Exception {

        String sql =
            "DELETE FROM post "
          + "WHERE post_id = ? "
          + "AND member_id = ?";


        try (
            Connection conn =
                DBConnection.getConnection();

            PreparedStatement ps =
                conn.prepareStatement(sql)
        ) {

            ps.setLong(
                1,
                postId
            );


            ps.setLong(
                2,
                memberId
            );


            return ps.executeUpdate();
        }
    }


    public int increaseViewCount(
        long postId
    ) throws Exception {

        String sql =
            "UPDATE post "
          + "SET view_count = view_count + 1 "
          + "WHERE post_id = ?";


        try (
            Connection conn =
                DBConnection.getConnection();

            PreparedStatement ps =
                conn.prepareStatement(sql)
        ) {

            ps.setLong(
                1,
                postId
            );


            return ps.executeUpdate();
        }
    }


    private String baseSql() {

        return "SELECT p.*, "
             + "m.nickname AS member_nickname, "
             + "c.name AS category_name, "
             + "(SELECT COUNT(*) "
             + " FROM comment cm "
             + " WHERE cm.post_id = p.post_id) "
             + "AS comment_count "
             + "FROM post p "
             + "JOIN member m "
             + "ON p.member_id = m.member_id "
             + "LEFT JOIN category c "
             + "ON p.category_id = c.category_id";
    }


    private PostDTO mapPost(
        ResultSet rs
    ) throws SQLException {

        PostDTO post =
            new PostDTO();


        post.setPostId(
            rs.getLong("post_id")
        );


        post.setMemberId(
            rs.getLong("member_id")
        );


        post.setCategoryId(
            rs.getInt("category_id")
        );


        post.setBoardType(
            rs.getString("board_type")
        );


        post.setTitle(
            rs.getString("title")
        );


        post.setContent(
            rs.getString("content")
        );


        post.setViewCount(
            rs.getInt("view_count")
        );


        post.setLikeCount(
            rs.getInt("like_count")
        );


        post.setDislikeCount(
            rs.getInt("dislike_count")
        );


        post.setCreatedAt(
            rs.getTimestamp("created_at")
        );


        post.setUpdatedAt(
            rs.getTimestamp("updated_at")
        );


        post.setMemberNickname(
            rs.getString("member_nickname")
        );


        post.setCategoryName(
            rs.getString("category_name")
        );


        post.setCommentCount(
            rs.getInt("comment_count")
        );


        return post;
    }


    /*
     * 마이페이지 / 홈 내 활동:
     * 특정 회원이 작성한 게시글을 최신순으로 조회합니다.
     */
    public List<PostDTO> selectByMemberId(
        long memberId
    ) throws Exception {

        List<PostDTO> list =
            new ArrayList<PostDTO>();


        String sql =
            "SELECT "
          + "p.*, "
          + "m.nickname AS member_nickname, "
          + "c.name AS category_name, "
          + "(SELECT COUNT(*) "
          + "   FROM comment cm "
          + "  WHERE cm.post_id=p.post_id"
          + ") AS comment_count "
          + "FROM post p "
          + "JOIN member m "
          + "  ON p.member_id=m.member_id "
          + "LEFT JOIN category c "
          + "  ON p.category_id=c.category_id "
          + "WHERE p.member_id=? "
          + "ORDER BY p.created_at DESC, p.post_id DESC";


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

                while (
                    rs.next()
                ) {

                    list.add(
                        mapPost(
                            rs
                        )
                    );
                }
            }
        }


        return list;
    }

}
