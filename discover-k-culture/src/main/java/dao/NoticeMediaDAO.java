package dao;

import dto.NoticeImageDTO;
import dto.NoticeVideoDTO;
import util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import java.util.ArrayList;
import java.util.List;

public class NoticeMediaDAO {

	public int insertImage(NoticeImageDTO image) throws Exception {
		String sql = "INSERT INTO notice_image(" + "notice_id,image_name,image_path,image_order" + ") VALUES(?,?,?,?)";

		try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setLong(1, image.getNoticeId());
			ps.setString(2, image.getImageName());
			ps.setString(3, image.getImagePath());
			ps.setInt(4, image.getImageOrder());
			return ps.executeUpdate();
		}
	}

	public int insertVideo(NoticeVideoDTO video) throws Exception {
		String sql = "INSERT INTO notice_video(" + "notice_id,video_name,video_path,video_order" + ") VALUES(?,?,?,?)";

		try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setLong(1, video.getNoticeId());
			ps.setString(2, video.getVideoName());
			ps.setString(3, video.getVideoPath());
			ps.setInt(4, video.getVideoOrder());
			return ps.executeUpdate();
		}
	}

	public NoticeImageDTO selectImageById(long imageId) throws Exception {
		String sql = "SELECT * FROM notice_image WHERE image_id=?";

		try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setLong(1, imageId);

			try (ResultSet rs = ps.executeQuery()) {
				if (!rs.next()) {
					return null;
				}

				NoticeImageDTO image = new NoticeImageDTO();
				image.setImageId(rs.getLong("image_id"));
				image.setNoticeId(rs.getLong("notice_id"));
				image.setImageName(rs.getString("image_name"));
				image.setImagePath(rs.getString("image_path"));
				image.setImageOrder(rs.getInt("image_order"));
				image.setCreatedAt(rs.getTimestamp("created_at"));
				return image;
			}
		}
	}

	public NoticeVideoDTO selectVideoById(long videoId) throws Exception {
		String sql = "SELECT * FROM notice_video WHERE video_id=?";

		try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setLong(1, videoId);

			try (ResultSet rs = ps.executeQuery()) {
				if (!rs.next()) {
					return null;
				}

				NoticeVideoDTO video = new NoticeVideoDTO();
				video.setVideoId(rs.getLong("video_id"));
				video.setNoticeId(rs.getLong("notice_id"));
				video.setVideoName(rs.getString("video_name"));
				video.setVideoPath(rs.getString("video_path"));
				video.setVideoOrder(rs.getInt("video_order"));
				video.setCreatedAt(rs.getTimestamp("created_at"));
				return video;
			}
		}
	}

	public int deleteImage(long imageId, long noticeId) throws Exception {
		String sql = "DELETE FROM notice_image WHERE image_id=? AND notice_id=?";

		try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setLong(1, imageId);
			ps.setLong(2, noticeId);
			return ps.executeUpdate();
		}
	}

	public int deleteVideo(long videoId, long noticeId) throws Exception {
		String sql = "DELETE FROM notice_video WHERE video_id=? AND notice_id=?";

		try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setLong(1, videoId);
			ps.setLong(2, noticeId);
			return ps.executeUpdate();
		}
	}

	public int getMaxImageOrder(long noticeId) throws Exception {
		String sql = "SELECT COALESCE(MAX(image_order),0) FROM notice_image WHERE notice_id=?";

		try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setLong(1, noticeId);
			try (ResultSet rs = ps.executeQuery()) {
				return rs.next() ? rs.getInt(1) : 0;
			}
		}
	}

	public int getMaxVideoOrder(long noticeId) throws Exception {
		String sql = "SELECT COALESCE(MAX(video_order),0) FROM notice_video WHERE notice_id=?";

		try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setLong(1, noticeId);
			try (ResultSet rs = ps.executeQuery()) {
				return rs.next() ? rs.getInt(1) : 0;
			}
		}
	}

	public List<NoticeImageDTO> selectImages(long noticeId) throws Exception {
		List<NoticeImageDTO> list = new ArrayList<NoticeImageDTO>();

		String sql = "SELECT * " + "FROM notice_image " + "WHERE notice_id=? " + "ORDER BY image_order,image_id";

		try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setLong(1, noticeId);

			try (ResultSet rs = ps.executeQuery()) {
				while (rs.next()) {
					NoticeImageDTO image = new NoticeImageDTO();
					image.setImageId(rs.getLong("image_id"));
					image.setNoticeId(rs.getLong("notice_id"));
					image.setImageName(rs.getString("image_name"));
					image.setImagePath(rs.getString("image_path"));
					image.setImageOrder(rs.getInt("image_order"));
					image.setCreatedAt(rs.getTimestamp("created_at"));
					list.add(image);
				}
			}
		}

		return list;
	}

	public List<NoticeVideoDTO> selectVideos(long noticeId) throws Exception {
		List<NoticeVideoDTO> list = new ArrayList<NoticeVideoDTO>();

		String sql = "SELECT * " + "FROM notice_video " + "WHERE notice_id=? " + "ORDER BY video_order,video_id";

		try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setLong(1, noticeId);

			try (ResultSet rs = ps.executeQuery()) {
				while (rs.next()) {
					NoticeVideoDTO video = new NoticeVideoDTO();
					video.setVideoId(rs.getLong("video_id"));
					video.setNoticeId(rs.getLong("notice_id"));
					video.setVideoName(rs.getString("video_name"));
					video.setVideoPath(rs.getString("video_path"));
					video.setVideoOrder(rs.getInt("video_order"));
					video.setCreatedAt(rs.getTimestamp("created_at"));
					list.add(video);
				}
			}
		}

		return list;
	}
}
