package controller;

import dao.NoticeDAO;
import dao.NoticeMediaDAO;
import dto.NoticeDTO;
import dto.NoticeImageDTO;
import dto.NoticeVideoDTO;

import java.io.File;
import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/admin/notice/delete")
public class NoticeDeleteServlet extends HttpServlet {

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
            long noticeId = Long.parseLong(request.getParameter("id"));

            NoticeDAO noticeDAO = new NoticeDAO();
            NoticeDTO notice = noticeDAO.selectById(noticeId);

            if (notice == null) {
                response.sendRedirect(request.getContextPath() + "/board/noticeList.jsp");
                return;
            }

            NoticeMediaDAO mediaDAO = new NoticeMediaDAO();
            List<NoticeImageDTO> images = mediaDAO.selectImages(noticeId);
            List<NoticeVideoDTO> videos = mediaDAO.selectVideos(noticeId);

            if (images != null) {
                for (NoticeImageDTO image : images) {
                    if (mediaDAO.deleteImage(image.getImageId(), noticeId) == 1) {
                        deletePhysicalFile(image.getImagePath());
                    }
                }
            }

            if (videos != null) {
                for (NoticeVideoDTO video : videos) {
                    if (mediaDAO.deleteVideo(video.getVideoId(), noticeId) == 1) {
                        deletePhysicalFile(video.getVideoPath());
                    }
                }
            }

            noticeDAO.delete(noticeId);
            response.sendRedirect(request.getContextPath() + "/board/noticeList.jsp");

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/board/noticeList.jsp");
        } catch (Exception e) {
            throw new ServletException("공지사항 삭제 중 오류가 발생했습니다.", e);
        }
    }

    private void deletePhysicalFile(String webPath) {
        if (webPath == null || webPath.trim().isEmpty()) return;

        String realPath = getServletContext().getRealPath(webPath);
        if (realPath == null) return;

        File file = new File(realPath);
        if (file.exists()) file.delete();
    }
}
