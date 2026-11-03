package controller;

import java.io.File;
import java.io.IOException;
import java.util.UUID;

import dao.PostDAO;
import dao.MemberDAO;
import dto.MemberDTO;
import dao.PostImageDAO;
import dao.PostVideoDAO;
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

@WebServlet(urlPatterns = { "/board/process/board/write", "/post/write" })
@MultipartConfig(fileSizeThreshold = 1048576, maxFileSize = 52428800, maxRequestSize = 209715200)
public class PostWriteServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	private boolean isValidBoardType(String boardType) {
		return "KCULTURE".equals(boardType) || "QUESTION".equals(boardType);
	}

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
			String boardType = request.getParameter("boardType");

			/*
			 * 관리자 공지 작성은 공지 전용 저장 Servlet으로 넘깁니다.
			 * JavaScript가 꺼져 있어도 서버에서 한 번 더 안전하게 처리합니다.
			 */
			if ("NOTICE".equals(boardType) && "ADMIN".equals(session.getAttribute("role"))) {
				request.getRequestDispatcher("/admin/notice/save").forward(request, response);
				return;
			}

			if (!isValidBoardType(boardType)) {
				boardType = "KCULTURE";
			}

			Long memberId = (Long) session.getAttribute("memberId");

			MemberDTO currentMember = new MemberDAO().selectById(memberId.longValue());

			if (currentMember != null && "SUSPENDED".equals(currentMember.getStatus())) {

				response.sendRedirect(request.getContextPath() + "/member/mypage.jsp?restricted=post");

				return;
			}

			String title = request.getParameter("title");
			String content = request.getParameter("content");

			if (title == null || title.trim().isEmpty() || content == null || content.trim().isEmpty()) {
				response.sendRedirect(request.getContextPath() + "/board/write.jsp?boardType=" + boardType);
				return;
			}

			PostDTO post = new PostDTO();
			post.setMemberId(((Long) session.getAttribute("memberId")).longValue());
			post.setBoardType(boardType);

			if ("KCULTURE".equals(boardType)) {
				String categoryId = request.getParameter("categoryId");
				if (categoryId == null || categoryId.trim().isEmpty()) {
					response.sendRedirect(request.getContextPath() + "/board/write.jsp?boardType=KCULTURE");
					return;
				}
				post.setCategoryId(Integer.parseInt(categoryId));
			} else {
				post.setCategoryId(0);
			}

			post.setTitle(title.trim());
			post.setContent(content);

			long postId = new PostDAO().insertAndGetId(post);
			if (postId <= 0) {
				throw new Exception("게시글 등록 실패");
			}

			saveFiles(request, postId, "images", true);
			saveFiles(request, postId, "videos", false);

			String detailPath;

			if ("QUESTION".equals(boardType)) {
				detailPath = "/board/qnaView.jsp?id=" + postId;
			} else {
				detailPath = "/board/category-view.jsp?postId=" + postId;
			}

			response.sendRedirect(request.getContextPath() + detailPath);

		} catch (Exception e) {
			throw new ServletException("게시글 등록 중 오류가 발생했습니다.", e);
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
			if (!fieldName.equals(part.getName()) || part.getSize() <= 0)
				continue;

			String originalName = part.getSubmittedFileName();
			String contentType = part.getContentType();
			if (originalName == null || originalName.trim().isEmpty() || contentType == null)
				continue;

			if (image && !contentType.startsWith("image/"))
				continue;
			if (!image && !contentType.startsWith("video/"))
				continue;

			int dot = originalName.lastIndexOf('.');
			String extension = dot >= 0 ? originalName.substring(dot).toLowerCase() : "";
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
