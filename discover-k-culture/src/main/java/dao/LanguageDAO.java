package dao;

import dto.LanguageDTO;
import util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class LanguageDAO {

    public List<LanguageDTO> selectAllActive() throws Exception {
        List<LanguageDTO> list = new ArrayList<>();
        String sql = """
            SELECT language_id, code, name_ko, name_native, is_active, created_at
            FROM language
            WHERE is_active = TRUE
            ORDER BY language_id
            """;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                LanguageDTO l = new LanguageDTO();
                l.setLanguageId(rs.getInt("language_id"));
                l.setCode(rs.getString("code"));
                l.setNameKo(rs.getString("name_ko"));
                l.setNameNative(rs.getString("name_native"));
                l.setActive(rs.getBoolean("is_active"));
                l.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(l);
            }
        }
        return list;
    }
}
