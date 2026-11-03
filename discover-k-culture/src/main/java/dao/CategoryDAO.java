package dao;

import dto.CategoryDTO;
import util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import java.util.ArrayList;
import java.util.List;


public class CategoryDAO {

    public List<CategoryDTO> selectAll()
        throws Exception {

        List<CategoryDTO> list =
            new ArrayList<CategoryDTO>();

        String sql =
            "SELECT "
          + "category_id, "
          + "name, "
          + "description, "
          + "created_at "
          + "FROM category "
          + "ORDER BY category_id";


        try (
            Connection conn =
                DBConnection.getConnection();

            PreparedStatement ps =
                conn.prepareStatement(sql);

            ResultSet rs =
                ps.executeQuery()
        ) {

            while (rs.next()) {

                CategoryDTO c =
                    new CategoryDTO();

                c.setCategoryId(
                    rs.getInt(
                        "category_id"
                    )
                );

                c.setName(
                    rs.getString(
                        "name"
                    )
                );

                c.setDescription(
                    rs.getString(
                        "description"
                    )
                );

                c.setCreatedAt(
                    rs.getTimestamp(
                        "created_at"
                    )
                );

                list.add(c);
            }
        }


        return list;
    }


    /*
     * home.jsp 인기 카테고리
     *
     * KCULTURE 게시글이 많은 카테고리 순으로 조회합니다.
     * category_id가 NULL인 FREE/QUESTION 게시글은 제외됩니다.
     */
    public List<CategoryDTO> selectPopularCategories(
        int limit
    ) throws Exception {

        if (limit <= 0) {
            limit = 3;
        }


        List<CategoryDTO> list =
            new ArrayList<CategoryDTO>();


        String sql =
            "SELECT "
          + "c.category_id, "
          + "c.name, "
          + "c.description, "
          + "c.created_at, "
          + "COUNT(p.post_id) AS post_count "
          + "FROM category c "
          + "LEFT JOIN post p "
          + "ON p.category_id=c.category_id "
          + "AND p.board_type='KCULTURE' "
          + "GROUP BY "
          + "c.category_id, "
          + "c.name, "
          + "c.description, "
          + "c.created_at "
          + "ORDER BY "
          + "post_count DESC, "
          + "c.category_id ASC "
          + "LIMIT ?";


        try (
            Connection conn =
                DBConnection.getConnection();

            PreparedStatement ps =
                conn.prepareStatement(sql)
        ) {

            ps.setInt(
                1,
                limit
            );


            try (
                ResultSet rs =
                    ps.executeQuery()
            ) {

                while (rs.next()) {

                    CategoryDTO c =
                        new CategoryDTO();

                    c.setCategoryId(
                        rs.getInt(
                            "category_id"
                        )
                    );

                    c.setName(
                        rs.getString(
                            "name"
                        )
                    );

                    c.setDescription(
                        rs.getString(
                            "description"
                        )
                    );

                    c.setCreatedAt(
                        rs.getTimestamp(
                            "created_at"
                        )
                    );

                    c.setPostCount(
                        rs.getInt(
                            "post_count"
                        )
                    );


                    list.add(c);
                }
            }
        }


        return list;
    }
}
