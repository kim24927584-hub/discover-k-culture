package controller;

import java.io.IOException;

import dao.RememberLoginDAO;
import util.RememberLoginUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * 로그아웃 처리.
 *
 * 세션만 삭제하면 AutoLoginFilter가 남아 있는 자동로그인 쿠키로 다시 로그인시킬 수 있으므로
 * 자동 로그인 DB 토큰과 KCULTURE_REMEMBER 쿠키도 함께 제거합니다.
 */
@WebServlet("/member/logout")
public class LogoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String AUTO_LOGIN_COOKIE = "KCULTURE_REMEMBER";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        logout(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        logout(request, response);
    }

    private void logout(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        /* 브라우저의 자동 로그인 원본 토큰을 찾아 DB의 해시 토큰도 제거합니다. */
        String rawToken = findCookie(request, AUTO_LOGIN_COOKIE);
        if (rawToken != null && !rawToken.isBlank()) {
            try {
                new RememberLoginDAO().deleteToken(RememberLoginUtil.sha256(rawToken));
            } catch (Exception e) {
                getServletContext().log("로그아웃 자동 로그인 토큰 삭제 실패", e);
            }
        }

        clearAutoLoginCookie(request, response);

        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }

        response.sendRedirect(request.getContextPath() + "/home.jsp");
    }

    private String findCookie(HttpServletRequest request, String name) {
        Cookie[] cookies = request.getCookies();
        if (cookies == null) return null;

        for (Cookie cookie : cookies) {
            if (name.equals(cookie.getName())) {
                return cookie.getValue();
            }
        }
        return null;
    }

    private void clearAutoLoginCookie(HttpServletRequest request, HttpServletResponse response) {
        Cookie cookie = new Cookie(AUTO_LOGIN_COOKIE, "");
        String path = request.getContextPath();
        cookie.setPath(path == null || path.isEmpty() ? "/" : path);
        cookie.setMaxAge(0);
        cookie.setHttpOnly(true);
        cookie.setSecure(request.isSecure());
        response.addCookie(cookie);
    }
}
