package controller;

import java.io.File;
import java.io.IOException;
import java.util.Locale;
import java.util.UUID;

import dao.MemberDAO;
import dto.MemberDTO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

@WebServlet("/member/profile-image")
@MultipartConfig(fileSizeThreshold = 1024 * 1024, maxFileSize = 5 * 1024 * 1024, maxRequestSize = 6 * 1024 * 1024)
public class ProfileImageUploadServlet extends HttpServlet {

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

		Long memberId = (Long) session.getAttribute("memberId");

		try {

			Part part = request.getPart("profileImage");

			if (part == null || part.getSize() <= 0) {

				response.sendRedirect(request.getContextPath() + "/member/mypage.jsp" + "?profileError=empty");

				return;
			}

			String originalName = part.getSubmittedFileName();

			String contentType = part.getContentType();

			if (originalName == null || originalName.trim().isEmpty() || contentType == null
					|| !contentType.toLowerCase(Locale.ROOT).startsWith("image/")) {

				response.sendRedirect(request.getContextPath() + "/member/mypage.jsp" + "?profileError=type");

				return;
			}

			String extension = getExtension(originalName);

			if (!".jpg".equals(extension) && !".jpeg".equals(extension) && !".png".equals(extension)
					&& !".gif".equals(extension) && !".webp".equals(extension)) {

				response.sendRedirect(request.getContextPath() + "/member/mypage.jsp" + "?profileError=type");

				return;
			}

			String relativeDir = "/uploads/profile";

			String realPath = getServletContext().getRealPath(relativeDir);

			if (realPath == null) {

				throw new ServletException("프로필 이미지 업로드 경로를 찾을 수 없습니다.");
			}

			File dir = new File(realPath);

			if (!dir.exists() && !dir.mkdirs()) {

				throw new ServletException("프로필 이미지 폴더를 생성할 수 없습니다.");
			}

			String savedName = UUID.randomUUID().toString() + extension;

			File savedFile = new File(dir, savedName);

			/*
			 * 먼저 새 파일 저장
			 */
			part.write(savedFile.getAbsolutePath());

			String newWebPath = relativeDir + "/" + savedName;

			MemberDAO dao = new MemberDAO();

			MemberDTO member = dao.selectById(memberId.longValue());

			String oldWebPath = member == null ? null : member.getProfileImage();

			int updated = dao.updateProfileImage(memberId.longValue(), newWebPath);

			if (updated != 1) {

				savedFile.delete();

				throw new ServletException("프로필 이미지 DB 저장에 실패했습니다.");
			}

			/*
			 * 다른 화면에서도 바로 보이도록 세션 값 갱신
			 */
			session.setAttribute("profileImage", newWebPath);

			/*
			 * 기존 프로필 사진이 프로젝트 uploads/profile 안의 파일이면 삭제
			 */
			deleteOldProfileImage(oldWebPath, newWebPath);

			response.sendRedirect(request.getContextPath() + "/member/mypage.jsp" + "?profileUpdated=1");

		} catch (IllegalStateException e) {

			/*
			 * 파일 크기 제한 초과
			 */
			response.sendRedirect(request.getContextPath() + "/member/mypage.jsp" + "?profileError=size");

		} catch (Exception e) {

			throw new ServletException("프로필 이미지 변경 중 오류가 발생했습니다.", e);
		}
	}

	private String getExtension(String fileName) {

		int dot = fileName.lastIndexOf('.');

		if (dot < 0 || dot == fileName.length() - 1) {

			return "";
		}

		return fileName.substring(dot).toLowerCase(Locale.ROOT);
	}

	private void deleteOldProfileImage(String oldWebPath, String newWebPath) {

		if (oldWebPath == null || oldWebPath.trim().isEmpty() || oldWebPath.equals(newWebPath)
				|| !oldWebPath.startsWith("/uploads/profile/")) {
			return;
		}

		String oldRealPath = getServletContext().getRealPath(oldWebPath);

		if (oldRealPath == null) {
			return;
		}

		File oldFile = new File(oldRealPath);

		if (oldFile.exists() && oldFile.isFile()) {

			oldFile.delete();
		}
	}
}
