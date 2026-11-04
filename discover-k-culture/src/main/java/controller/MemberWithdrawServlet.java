package controller;

import java.io.IOException;

import dao.MemberDAO;
import dto.MemberDTO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * 마이페이지에서 신청한 본인 회원탈퇴 처리.
 * CSRF 토큰은 공통 CsrfFilter에서 확인합니다.
 */
@WebServlet("/member/withdraw")
public class MemberWithdrawServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || !(session.getAttribute("memberId") instanceof Long)) {
            response.sendRedirect(request.getContextPath() + "/member/login.jsp");
            return;
        }

        Long memberId = (Long) session.getAttribute("memberId");
        String confirmLoginId = request.getParameter("confirmLoginId");

        try {
            MemberDAO memberDAO = new MemberDAO();
            MemberDTO member = memberDAO.selectById(memberId.longValue());

            // 로그인 회원만 본인 계정을 탈퇴할 수 있습니다.
            if (member == null || "ADMIN".equals(member.getRole())
                    || "WITHDRAWN".equals(member.getStatus())) {
                response.sendRedirect(request.getContextPath() + "/member/mypage.jsp?withdrawError=unavailable");
                return;
            }

            // 브라우저 확인창 외에 서버에서도 로그인 ID를 반드시 재확인합니다.
            if (confirmLoginId == null || !member.getLoginId().equals(confirmLoginId.trim())) {
                response.sendRedirect(request.getContextPath() + "/member/mypage.jsp?withdrawError=confirm");
                return;
            }

            if (memberDAO.withdraw(memberId.longValue()) != 1) {
                response.sendRedirect(request.getContextPath() + "/member/mypage.jsp?withdrawError=failed");
                return;
            }

            // 자동로그인 DB 토큰은 MemberDAO.withdraw()에서 함께 제거했습니다.
            // 브라우저의 기존 쿠키 및 세션도 삭제해 재로그인을 방지합니다.
            clearCookie(request, response, "KCULTURE_REMEMBER");
            clearCookie(request, response, "KCULTURE_SAVED_ID");
            session.invalidate();

            response.sendRedirect(request.getContextPath() + "/member/login.jsp?withdrawn=1");

        } catch (Exception e) {
            getServletContext().log("회원탈퇴 처리 실패", e);
            throw new ServletException("회원탈퇴 처리 중 문제가 발생했습니다.", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }

    private void clearCookie(HttpServletRequest request, HttpServletResponse response, String name) {
        Cookie cookie = new Cookie(name, "");
        String contextPath = request.getContextPath();
        cookie.setPath(contextPath == null || contextPath.isEmpty() ? "/" : contextPath);
        cookie.setMaxAge(0);
        cookie.setHttpOnly(true);
        cookie.setSecure(request.isSecure());
        response.addCookie(cookie);
    }
}
