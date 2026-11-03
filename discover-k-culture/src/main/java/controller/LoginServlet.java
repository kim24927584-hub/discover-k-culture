package controller;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;

import dao.MemberDAO;
import dao.RememberLoginDAO;
import dto.MemberDTO;
import util.OAuthSessionUtil;
import util.RememberLoginUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/member/login")
public class LoginServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String AUTO_LOGIN_COOKIE = "KCULTURE_REMEMBER";
    private static final String REMEMBER_ID_COOKIE = "KCULTURE_SAVED_ID";
    private static final int COOKIE_MAX_AGE = 60 * 60 * 24 * 30; // 30일

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // 현재 login.jsp는 name="id"를 사용하고,
        // 예전 화면/프로세스에서는 loginId를 사용할 수 있어 둘 다 지원합니다.
        String loginId = trimToNull(request.getParameter("id"));
        if (loginId == null) {
            loginId = trimToNull(request.getParameter("loginId"));
        }

        String password = request.getParameter("password");
        boolean autoLogin = isChecked(request.getParameter("autoLogin"));
        boolean rememberId = isChecked(request.getParameter("rememberId"));

        if (loginId == null || password == null || password.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/member/login.jsp?error=empty");
            return;
        }

        try {
            MemberDTO member = new MemberDAO().authenticate(loginId, password);

            if (member == null) {
                response.sendRedirect(request.getContextPath() + "/member/login.jsp?error=1");
                return;
            }

            // 로그인 전 기존 세션을 교체하여 세션 고정 공격을 줄입니다.
            HttpSession oldSession = request.getSession(false);
            if (oldSession != null) {
                oldSession.invalidate();
            }

            HttpSession session = request.getSession(true);
            OAuthSessionUtil.saveMember(session, member);

            String cookiePath = cookiePath(request);

            // 아이디 기억: 비밀번호/세션은 저장하지 않고 로그인 ID만 30일 보관합니다.
            saveRememberIdCookie(response, request, cookiePath, member.getLoginId(), rememberId);

            // 자동 로그인: 브라우저에는 원본 토큰, DB에는 SHA-256 해시만 저장합니다.
            // 체크를 해제하고 로그인하면 기존 자동 로그인 토큰도 함께 해제합니다.
            replaceAutoLoginToken(request, response, cookiePath, member.getMemberId(), autoLogin);

            // 정지 회원도 문의 기능을 사용할 수 있도록 로그인 자체는 허용합니다.
            if ("SUSPENDED".equals(member.getStatus())) {
                response.sendRedirect(request.getContextPath() + "/home.jsp?loginSuspended=1");
                return;
            }

            response.sendRedirect(request.getContextPath() + "/home.jsp");

        } catch (Exception e) {
            throw new ServletException("로그인 처리 중 오류가 발생했습니다.", e);
        }
    }

    private void saveRememberIdCookie(HttpServletResponse response,
                                      HttpServletRequest request,
                                      String cookiePath,
                                      String loginId,
                                      boolean rememberId) {

        String value = rememberId
                ? URLEncoder.encode(loginId, StandardCharsets.UTF_8)
                : "";

        Cookie cookie = new Cookie(REMEMBER_ID_COOKIE, value);
        cookie.setPath(cookiePath);
        cookie.setMaxAge(rememberId ? COOKIE_MAX_AGE : 0);
        cookie.setHttpOnly(true);
        cookie.setSecure(request.isSecure());
        response.addCookie(cookie);
    }

    private void replaceAutoLoginToken(HttpServletRequest request,
                                       HttpServletResponse response,
                                       String cookiePath,
                                       long memberId,
                                       boolean autoLogin) throws Exception {

        RememberLoginDAO rememberLoginDAO = new RememberLoginDAO();

        // 이미 브라우저에 자동 로그인 쿠키가 있다면 기존 DB 토큰부터 제거합니다.
        String oldRawToken = findCookie(request, AUTO_LOGIN_COOKIE);
        if (oldRawToken != null && !oldRawToken.isBlank()) {
            try {
                rememberLoginDAO.deleteToken(RememberLoginUtil.sha256(oldRawToken));
            } catch (Exception ignored) {
                // 새 로그인 자체가 실패하지 않도록 기존 토큰 정리 실패는 무시합니다.
            }
        }

        if (!autoLogin) {
            clearAutoLoginCookie(response, request, cookiePath);
            return;
        }

        String rawToken = RememberLoginUtil.createToken();
        String tokenHash = RememberLoginUtil.sha256(rawToken);

        rememberLoginDAO.saveToken(
                memberId,
                tokenHash,
                LocalDateTime.now().plusDays(30)
        );

        Cookie cookie = new Cookie(AUTO_LOGIN_COOKIE, rawToken);
        cookie.setPath(cookiePath);
        cookie.setMaxAge(COOKIE_MAX_AGE);
        cookie.setHttpOnly(true);
        cookie.setSecure(request.isSecure());
        response.addCookie(cookie);
    }

    private void clearAutoLoginCookie(HttpServletResponse response,
                                      HttpServletRequest request,
                                      String cookiePath) {
        Cookie cookie = new Cookie(AUTO_LOGIN_COOKIE, "");
        cookie.setPath(cookiePath);
        cookie.setMaxAge(0);
        cookie.setHttpOnly(true);
        cookie.setSecure(request.isSecure());
        response.addCookie(cookie);
    }

    private String findCookie(HttpServletRequest request, String name) {
        Cookie[] cookies = request.getCookies();
        if (cookies == null) {
            return null;
        }
        for (Cookie cookie : cookies) {
            if (name.equals(cookie.getName())) {
                return cookie.getValue();
            }
        }
        return null;
    }

    private String cookiePath(HttpServletRequest request) {
        String path = request.getContextPath();
        return path == null || path.isEmpty() ? "/" : path;
    }

    private boolean isChecked(String value) {
        return "Y".equalsIgnoreCase(value)
                || "true".equalsIgnoreCase(value)
                || "on".equalsIgnoreCase(value);
    }

    private String trimToNull(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
