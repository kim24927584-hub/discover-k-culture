package dao;

import dto.InquiryDTO;
import util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import java.util.ArrayList;
import java.util.List;

public class InquiryDAO {

	public int insert(InquiryDTO inquiry) throws Exception {

		String sql = "INSERT INTO inquiry(" + "member_id, title, content" + ") VALUES(?,?,?)";

		try (Connection conn = DBConnection.getConnection();

				PreparedStatement ps = conn.prepareStatement(sql)) {

			ps.setLong(1, inquiry.getMemberId());

			ps.setString(2, inquiry.getTitle());

			ps.setString(3, inquiry.getContent());

			return ps.executeUpdate();
		}
	}

	public InquiryDTO selectById(long inquiryId) throws Exception {

		String sql = baseSql() + " WHERE i.inquiry_id=?";

		try (Connection conn = DBConnection.getConnection();

				PreparedStatement ps = conn.prepareStatement(sql)) {

			ps.setLong(1, inquiryId);

			try (ResultSet rs = ps.executeQuery()) {

				return rs.next() ? map(rs) : null;
			}
		}
	}

	/*
	 * 기존 전체 회원 문의 조회
	 */
	public List<InquiryDTO> selectByMemberId(long memberId) throws Exception {

		return selectByMemberPage(memberId, 1, Integer.MAX_VALUE);
	}

	// 기존 JSP 호환용
	public List<InquiryDTO> selectByMember(long memberId) throws Exception {

		return selectByMemberId(memberId);
	}

	/*
	 * 기존 관리자 전체 조회
	 */
	public List<InquiryDTO> selectAll() throws Exception {

		List<InquiryDTO> list = new ArrayList<InquiryDTO>();

		String sql = baseSql() + " ORDER BY " + "CASE WHEN i.status='WAITING' " + "THEN 0 ELSE 1 END, "
				+ "i.inquiry_id DESC";

		try (Connection conn = DBConnection.getConnection();

				PreparedStatement ps = conn.prepareStatement(sql);

				ResultSet rs = ps.executeQuery()) {

			while (rs.next()) {
				list.add(map(rs));
			}
		}

		return list;
	}

	/*
	 * 관리자가 보는 전체 문의 개수
	 */
	public int countAll() throws Exception {

		String sql = "SELECT COUNT(*) " + "FROM inquiry";

		try (Connection conn = DBConnection.getConnection();

				PreparedStatement ps = conn.prepareStatement(sql);

				ResultSet rs = ps.executeQuery()) {

			if (rs.next()) {
				return rs.getInt(1);
			}
		}

		return 0;
	}

	/*
	 * 특정 회원 문의 개수
	 */
	public int countByMemberId(long memberId) throws Exception {

		String sql = "SELECT COUNT(*) " + "FROM inquiry " + "WHERE member_id=?";

		try (Connection conn = DBConnection.getConnection();

				PreparedStatement ps = conn.prepareStatement(sql)) {

			ps.setLong(1, memberId);

			try (ResultSet rs = ps.executeQuery()) {

				if (rs.next()) {
					return rs.getInt(1);
				}
			}
		}

		return 0;
	}

	/*
	 * 관리자 전체 문의 페이지 조회
	 */
	public List<InquiryDTO> selectAllPage(int page, int pageSize) throws Exception {

		normalizePageSizeHolder holder = normalize(page, pageSize);

		List<InquiryDTO> list = new ArrayList<InquiryDTO>();

		String sql = baseSql() + " ORDER BY " + "CASE WHEN i.status='WAITING' " + "THEN 0 ELSE 1 END, "
				+ "i.inquiry_id DESC " + "LIMIT ? OFFSET ?";

		try (Connection conn = DBConnection.getConnection();

				PreparedStatement ps = conn.prepareStatement(sql)) {

			ps.setInt(1, holder.pageSize);

			ps.setInt(2, holder.offset);

			try (ResultSet rs = ps.executeQuery()) {

				while (rs.next()) {
					list.add(map(rs));
				}
			}
		}

		return list;
	}

	/*
	 * 회원 본인 문의 페이지 조회
	 */
	public List<InquiryDTO> selectByMemberPage(long memberId, int page, int pageSize) throws Exception {

		normalizePageSizeHolder holder = normalize(page, pageSize);

		List<InquiryDTO> list = new ArrayList<InquiryDTO>();

		String sql = baseSql() + " WHERE i.member_id=? " + "ORDER BY i.inquiry_id DESC " + "LIMIT ? OFFSET ?";

		try (Connection conn = DBConnection.getConnection();

				PreparedStatement ps = conn.prepareStatement(sql)) {

			ps.setLong(1, memberId);

			ps.setInt(2, holder.pageSize);

			ps.setInt(3, holder.offset);

			try (ResultSet rs = ps.executeQuery()) {

				while (rs.next()) {
					list.add(map(rs));
				}
			}
		}

		return list;
	}

	/*
	 * 기존 관리자 JSP가 사용하는 순서 (id, adminId, answer)
	 */
	public int answer(long inquiryId, long adminId, String answer) throws Exception {

		String sql = "UPDATE inquiry " + "SET answer=?, " + "answered_by=?, " + "status='ANSWERED', "
				+ "answered_at=CURRENT_TIMESTAMP " + "WHERE inquiry_id=?";

		try (Connection conn = DBConnection.getConnection();

				PreparedStatement ps = conn.prepareStatement(sql)) {

			ps.setString(1, answer);

			ps.setLong(2, adminId);

			ps.setLong(3, inquiryId);

			return ps.executeUpdate();
		}
	}

	// 다른 코드 호환용 오버로드
	public int answer(long inquiryId, String answer, long adminId) throws Exception {

		return answer(inquiryId, adminId, answer);
	}

	public int delete(long inquiryId, long memberId) throws Exception {

		String sql = "DELETE FROM inquiry " + "WHERE inquiry_id=? " + "AND member_id=?";

		try (Connection conn = DBConnection.getConnection();

				PreparedStatement ps = conn.prepareStatement(sql)) {

			ps.setLong(1, inquiryId);

			ps.setLong(2, memberId);

			return ps.executeUpdate();
		}
	}

	private normalizePageSizeHolder normalize(int page, int pageSize) {

		if (page < 1) {
			page = 1;
		}

		/*
		 * 기존 selectByMemberId()의 전체 조회 호환을 위해 Integer.MAX_VALUE는 허용
		 */
		if (pageSize != 10 && pageSize != 20 && pageSize != 30 && pageSize != Integer.MAX_VALUE) {
			pageSize = 10;
		}

		int offset;

		if (pageSize == Integer.MAX_VALUE) {
			offset = 0;
		} else {
			offset = (page - 1) * pageSize;
		}

		return new normalizePageSizeHolder(pageSize, offset);
	}

	private static class normalizePageSizeHolder {

		int pageSize;
		int offset;

		normalizePageSizeHolder(int pageSize, int offset) {
			this.pageSize = pageSize;
			this.offset = offset;
		}
	}

	private String baseSql() {

		return "SELECT " + "i.*, " + "m.nickname member_nickname, " + "a.nickname admin_nickname " + "FROM inquiry i "
				+ "JOIN member m " + "ON i.member_id=m.member_id " + "LEFT JOIN member a "
				+ "ON i.answered_by=a.member_id";
	}

	private InquiryDTO map(ResultSet rs) throws SQLException {

		InquiryDTO inquiry = new InquiryDTO();

		inquiry.setInquiryId(rs.getLong("inquiry_id"));

		inquiry.setMemberId(rs.getLong("member_id"));

		inquiry.setTitle(rs.getString("title"));

		inquiry.setContent(rs.getString("content"));

		inquiry.setStatus(rs.getString("status"));

		inquiry.setAnswer(rs.getString("answer"));

		long answeredBy = rs.getLong("answered_by");

		inquiry.setAnsweredBy(rs.wasNull() ? null : Long.valueOf(answeredBy));

		inquiry.setCreatedAt(rs.getTimestamp("created_at"));

		inquiry.setAnsweredAt(rs.getTimestamp("answered_at"));

		inquiry.setMemberNickname(rs.getString("member_nickname"));

		inquiry.setAdminNickname(rs.getString("admin_nickname"));

		return inquiry;
	}
}
