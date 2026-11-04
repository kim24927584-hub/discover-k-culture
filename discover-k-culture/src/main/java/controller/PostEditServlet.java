package controller;

import java.io.File;
import java.io.IOException;
import java.util.UUID;

import dao.MemberDAO;
import dao.PostDAO;
import dao.PostImageDAO;
import dao.PostVideoDAO;
import dto.MemberDTO;
import dto.PostDTO;
import dto.PostImageDTO;
import dto.PostVideoDTO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

@WebServlet(urlPatterns = { "/board/process/board/edit", "/post/edit" })
@MultipartConfig(fileSizeThreshold = 1048576, maxFileSize = 52428800, maxRequestSize = 209715200)
public class PostEditServlet extends HttpServlet {

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

		try {
			long memberId = ((Long) session.getAttribute("memberId")).longValue();

			// 정지 기간 만료 여부까지 DB에서 다시 확인한 최신 회원 상태를 사용합니다.
			MemberDTO currentMember = new MemberDAO().selectById(memberId);

			if (currentMember == null) {
				response.sendRedirect(request.getContextPath() + "/member/logout");
				return;
			}

			// 정지 회원은 새 글뿐 아니라 기존 게시글도 수정할 수 없습니다.
			if ("SUSPENDED".equals(currentMember.getStatus())) {
				response.sendRedirect(request.getContextPath() + "/member/mypage.jsp?restricted=post");
				return;
			}

			String postIdText = request.getParameter("postId");
			if (postIdText == null || postIdText.trim().isEmpty()) {
				response.sendRedirect(request.getContextPath() + "/home.jsp");
				return;
			}

			long postId = Long.parseLong(postIdText);

			PostDAO postDAO = new PostDAO();
			PostDTO oldPost = postDAO.selectById(postId);

			if (oldPost == null || oldPost.getMemberId() != memberId) {
				response.sendRedirect(request.getContextPath() + "/home.jsp");
				return;
			}

			String title = request.getParameter("title");
			String content = request.getParameter("content");

			if (title == null || title.trim().isEmpty() || title.trim().length() > 200 || content == null || content.trim().isEmpty()) {
				response.sendRedirect(request.getContextPath() + "/board/process/board/edit.jsp?id=" + postId + "&error=empty");
				return;
			}

			PostDTO post = new PostDTO();
			post.setPostId(postId);
			post.setMemberId(memberId);
			post.setBoardType(oldPost.getBoardType());

			if ("KCULTURE".equals(oldPost.getBoardType())) {
				String categoryIdText = request.getParameter("categoryId");
				if (categoryIdText == null || categoryIdText.trim().isEmpty()) {
					response.sendRedirect(request.getContextPath() + "/board/process/board/edit.jsp?id=" + postId + "&error=category");
					return;
				}
				post.setCategoryId(Integer.parseInt(categoryIdText));
			} else {
				post.setCategoryId(0);
			}

			post.setTitle(title.trim());
			post.setContent(content);

			postDAO.update(post);

			deleteImages(request, postId);
			deleteVideos(request, postId);
			saveFiles(request, postId, "images", true);
			saveFiles(request, postId, "videos", false);

			String detailPath;

			if ("FREE".equals(oldPost.getBoardType())) {
				detailPath = "/board/allView.jsp?id=" + postId;
			} else if ("QUESTION".equals(oldPost.getBoardType())) {
				detailPath = "/board/qnaView.jsp?id=" + postId;
			} else {
				detailPath = "/board/category-view.jsp?postId=" + postId;
			}

			response.sendRedirect(request.getContextPath() + detailPath);

		} catch (NumberFormatException e) {
			response.sendRedirect(request.getContextPath() + "/home.jsp");
		} catch (Exception e) {
			throw new ServletException("게시글 수정 중 오류가 발생했습니다.", e);
		}
	}

	private void deleteImages(HttpServletRequest request, long postId) throws Exception {
		String[] ids = request.getParameterValues("deleteImageIds");
		if (ids == null) {
			return;
		}

		PostImageDAO dao = new PostImageDAO();

		for (String idText : ids) {
			long imageId = Long.parseLong(idText);
			PostImageDTO image = dao.selectById(imageId);

			// 다른 게시글의 첨부 ID를 임의로 보내도 삭제되지 않도록 게시글 소유를 확인합니다.
			if (image != null && image.getPostId() == postId) {
				deletePhysicalFile(image.getImagePath());
				dao.delete(image.getImageId());
			}
		}
	}

	private void deleteVideos(HttpServletRequest request, long postId) throws Exception {
		String[] ids = request.getParameterValues("deleteVideoIds");
		if (ids == null) {
			return;
		}

		PostVideoDAO dao = new PostVideoDAO();

		for (String idText : ids) {
			long videoId = Long.parseLong(idText);
			PostVideoDTO video = dao.selectById(videoId);

			if (video != null && video.getPostId() == postId) {
				deletePhysicalFile(video.getVideoPath());

				if (video.getThumbnailPath() != null && !video.getThumbnailPath().trim().isEmpty()) {
					deletePhysicalFile(video.getThumbnailPath());
				}

				dao.delete(video.getVideoId());
			}
		}
	}

	private void deletePhysicalFile(String webPath) {
		if (webPath == null || webPath.trim().isEmpty()) {
			return;
		}

		String realPath = getServletContext().getRealPath(webPath);
		if (realPath != null) {
			File file = new File(realPath);
			if (file.exists()) {
				file.delete();
			}
		}
	}

	private void saveFiles(HttpServletRequest request, long postId, String fieldName, boolean image) throws Exception {

		String relativeDir = image ? "/uploads/post/image" : "/uploads/post/video";
		String realPath = getServletContext().getRealPath(relativeDir);

		if (realPath == null) {
			throw new Exception("업로드 경로를 찾을 수 없습니다: " + relativeDir);
		}

		File dir = new File(realPath);
		if (!dir.exists() && !dir.mkdirs()) {
			throw new Exception("업로드 폴더 생성 실패: " + realPath);
		}

		int order = image ? new PostImageDAO().getMaxOrder(postId) + 1 : new PostVideoDAO().getMaxOrder(postId) + 1;

		for (Part part : request.getParts()) {
			if (!fieldName.equals(part.getName()) || part.getSize() <= 0) {
				continue;
			}

			String originalName = part.getSubmittedFileName();
			String contentType = part.getContentType();

			if (originalName == null || originalName.trim().isEmpty() || contentType == null) {
				continue;
			}

			if (image && !contentType.startsWith("image/")) {
				continue;
			}

			if (!image && !contentType.startsWith("video/")) {
				continue;
			}

			int dot = originalName.lastIndexOf('.');
			String extension = dot >= 0 ? originalName.substring(dot).toLowerCase() : "";

			// MIME 값과 함께 실제 확장자도 허용 목록으로 검사합니다.
			if (image) {
				if (!(".jpg".equals(extension) || ".jpeg".equals(extension)
						|| ".png".equals(extension) || ".gif".equals(extension)
						|| ".webp".equals(extension))) {
					continue;
				}
			} else {
				if (!(".mp4".equals(extension) || ".webm".equals(extension)
						|| ".ogg".equals(extension) || ".mov".equals(extension))) {
					continue;
				}
			}

			String savedName = UUID.randomUUID().toString() + extension;

			part.write(new File(dir, savedName).getAbsolutePath());

			if (image) {
				PostImageDTO dto = new PostImageDTO();
				dto.setPostId(postId);
				dto.setImageName(originalName);
				dto.setImagePath(relativeDir + "/" + savedName);
				dto.setImageOrder(order++);
				new PostImageDAO().insert(dto);
			} else {
				PostVideoDTO dto = new PostVideoDTO();
				dto.setPostId(postId);
				dto.setVideoName(originalName);
				dto.setVideoPath(relativeDir + "/" + savedName);
				dto.setThumbnailPath(null);
				dto.setVideoOrder(order++);
				new PostVideoDAO().insert(dto);
			}
		}
	}
}
