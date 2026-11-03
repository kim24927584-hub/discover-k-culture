package controller;

import dao.NoticeDAO;
import dao.NoticeMediaDAO;
import dto.NoticeDTO;
import dto.NoticeImageDTO;
import dto.NoticeVideoDTO;

import java.io.File;
import java.io.IOException;
import java.util.Collection;
import java.util.Locale;
import java.util.UUID;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

@WebServlet("/admin/notice/save")
@MultipartConfig(fileSizeThreshold = 1024 * 1024, maxFileSize = 100 * 1024 * 1024, maxRequestSize = 300 * 1024 * 1024)
public class NoticeSaveServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		request.setCharacterEncoding("UTF-8");

		HttpSession session = request.getSession(false);

		if (session == null || session.getAttribute("memberId") == null) {
			response.sendRedirect(request.getContextPath() + "/member/login.jsp");
			return;
		}

		if (!"ADMIN".equals(session.getAttribute("role"))) {
			response.sendRedirect(request.getContextPath() + "/home.jsp");
			return;
		}

		try {
			long memberId = ((Long) session.getAttribute("memberId")).longValue();
			String idText = request.getParameter("id");
			String title = request.getParameter("title");
			String content = request.getParameter("content");

			if (title == null || title.trim().isEmpty() || content == null || content.trim().isEmpty()) {
				response.sendRedirect(request.getContextPath() + "/board/noticeList.jsp?error=empty");
				return;
			}

			NoticeDAO noticeDAO = new NoticeDAO();
			NoticeDTO notice = new NoticeDTO();
			notice.setMemberId(memberId);
			notice.setTitle(title.trim());
			notice.setContent(content.trim());

			long noticeId;
			boolean editing = idText != null && !idText.trim().isEmpty();

			if (!editing) {
				noticeId = noticeDAO.insertAndGetId(notice);

				if (noticeId <= 0) {
					throw new ServletException("공지 등록에 실패했습니다.");
				}
			} else {
				noticeId = Long.parseLong(idText.trim());

				// 존재하지 않는 공지 ID로 수정 요청하는 것을 방지합니다.
				NoticeDTO oldNotice = noticeDAO.selectById(noticeId);
				if (oldNotice == null) {
					response.sendRedirect(request.getContextPath() + "/board/noticeList.jsp");
					return;
				}

				notice.setNoticeId(noticeId);
				noticeDAO.update(notice);
			}

			NoticeMediaDAO mediaDAO = new NoticeMediaDAO();

			if (editing) {
				deleteSelectedImages(request, noticeId, mediaDAO);
				deleteSelectedVideos(request, noticeId, mediaDAO);
			}

			saveImages(request, noticeId, mediaDAO);
			saveVideos(request, noticeId, mediaDAO);

			response.sendRedirect(request.getContextPath() + "/board/noticeView.jsp?id=" + noticeId);

		} catch (NumberFormatException e) {
			response.sendRedirect(request.getContextPath() + "/board/noticeList.jsp");
		} catch (Exception e) {
			throw new ServletException("공지사항 저장 중 오류가 발생했습니다.", e);
		}
	}

	private void deleteSelectedImages(HttpServletRequest request, long noticeId, NoticeMediaDAO mediaDAO)
			throws Exception {

		String[] ids = request.getParameterValues("deleteImageIds");
		if (ids == null) {
			return;
		}

		for (String idText : ids) {
			long imageId = Long.parseLong(idText);
			NoticeImageDTO image = mediaDAO.selectImageById(imageId);

			// 현재 수정 중인 공지의 이미지인지 확인 후 삭제합니다.
			if (image == null || image.getNoticeId() != noticeId) {
				continue;
			}

			int deleted = mediaDAO.deleteImage(imageId, noticeId);
			if (deleted == 1) {
				deletePhysicalFile(image.getImagePath());
			}
		}
	}

	private void deleteSelectedVideos(HttpServletRequest request, long noticeId, NoticeMediaDAO mediaDAO)
			throws Exception {

		String[] ids = request.getParameterValues("deleteVideoIds");
		if (ids == null) {
			return;
		}

		for (String idText : ids) {
			long videoId = Long.parseLong(idText);
			NoticeVideoDTO video = mediaDAO.selectVideoById(videoId);

			if (video == null || video.getNoticeId() != noticeId) {
				continue;
			}

			int deleted = mediaDAO.deleteVideo(videoId, noticeId);
			if (deleted == 1) {
				deletePhysicalFile(video.getVideoPath());
			}
		}
	}

	private void deletePhysicalFile(String webPath) {
		if (webPath == null || webPath.trim().isEmpty()) {
			return;
		}

		String realPath = getServletContext().getRealPath(webPath);
		if (realPath == null) {
			return;
		}

		File file = new File(realPath);
		if (file.exists()) {
			file.delete();
		}
	}

	private void saveImages(HttpServletRequest request, long noticeId, NoticeMediaDAO mediaDAO) throws Exception {

		Collection<Part> parts = request.getParts();
		int order = mediaDAO.getMaxImageOrder(noticeId) + 1;

		for (Part part : parts) {
			if (!"images".equals(part.getName()) || part.getSize() <= 0) {
				continue;
			}

			String contentType = part.getContentType();
			if (contentType == null || !contentType.toLowerCase(Locale.ROOT).startsWith("image/")) {
				continue;
			}

			String originalName = part.getSubmittedFileName();
			String extension = extension(originalName);

			if (!".jpg".equals(extension) && !".jpeg".equals(extension) && !".png".equals(extension)
					&& !".gif".equals(extension) && !".webp".equals(extension)) {
				continue;
			}

			String savedName = UUID.randomUUID().toString() + extension;
			String webDir = "/uploads/notice/image";
			String realDir = getServletContext().getRealPath(webDir);

			if (realDir == null) {
				throw new IOException("공지 이미지 업로드 경로를 찾을 수 없습니다.");
			}

			File dir = new File(realDir);
			if (!dir.exists() && !dir.mkdirs()) {
				throw new IOException("공지 이미지 업로드 폴더를 만들 수 없습니다.");
			}

			part.write(new File(dir, savedName).getAbsolutePath());

			NoticeImageDTO image = new NoticeImageDTO();
			image.setNoticeId(noticeId);
			image.setImageName(originalName);
			image.setImagePath(webDir + "/" + savedName);
			image.setImageOrder(order++);
			mediaDAO.insertImage(image);
		}
	}

	private void saveVideos(HttpServletRequest request, long noticeId, NoticeMediaDAO mediaDAO) throws Exception {

		Collection<Part> parts = request.getParts();
		int order = mediaDAO.getMaxVideoOrder(noticeId) + 1;

		for (Part part : parts) {
			if (!"videos".equals(part.getName()) || part.getSize() <= 0) {
				continue;
			}

			String contentType = part.getContentType();
			if (contentType == null || !contentType.toLowerCase(Locale.ROOT).startsWith("video/")) {
				continue;
			}

			String originalName = part.getSubmittedFileName();
			String extension = extension(originalName);

			if (!".mp4".equals(extension) && !".webm".equals(extension) && !".ogg".equals(extension)
					&& !".mov".equals(extension)) {
				continue;
			}

			String savedName = UUID.randomUUID().toString() + extension;
			String webDir = "/uploads/notice/video";
			String realDir = getServletContext().getRealPath(webDir);

			if (realDir == null) {
				throw new IOException("공지 영상 업로드 경로를 찾을 수 없습니다.");
			}

			File dir = new File(realDir);
			if (!dir.exists() && !dir.mkdirs()) {
				throw new IOException("공지 영상 업로드 폴더를 만들 수 없습니다.");
			}

			part.write(new File(dir, savedName).getAbsolutePath());

			NoticeVideoDTO video = new NoticeVideoDTO();
			video.setNoticeId(noticeId);
			video.setVideoName(originalName);
			video.setVideoPath(webDir + "/" + savedName);
			video.setVideoOrder(order++);
			mediaDAO.insertVideo(video);
		}
	}

	private String extension(String fileName) {
		if (fileName == null) {
			return "";
		}

		int dot = fileName.lastIndexOf('.');
		if (dot < 0 || dot == fileName.length() - 1) {
			return "";
		}

		return fileName.substring(dot).toLowerCase(Locale.ROOT);
	}
}
