package filter;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * 일반 HTML 폼의 상태 변경 요청을 보호하는 CSRF 필터입니다.
 *
 * GET 화면을 열 때 세션에 토큰을 만들고 header.jsp가 모든 POST 폼에
 * _csrf hidden 값을 자동 추가합니다. /api/*는 기존 fetch 요청 호환을 위해 제외합니다.
 */
@WebFilter("/*")
public class CsrfFilter implements Filter {

    public static final String SESSION_KEY = "CSRF_TOKEN";
    public static final String REQUEST_KEY = "csrfToken";
    public static final String PARAMETER_NAME = "_csrf";

    private final SecureRandom random = new SecureRandom();

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        String servletPath = req.getServletPath();
        if (isStaticResource(servletPath)) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = req.getSession(true);
        String token = (String) session.getAttribute(SESSION_KEY);

        if (token == null || token.isBlank()) {
            byte[] bytes = new byte[32];
            random.nextBytes(bytes);
            token = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
            session.setAttribute(SESSION_KEY, token);
        }

        req.setAttribute(REQUEST_KEY, token);

        String method = req.getMethod();

        if (isStateChanging(method) && !isExcluded(servletPath)) {
            String submitted = req.getParameter(PARAMETER_NAME);

            if (!safeEquals(token, submitted)) {
                res.sendError(HttpServletResponse.SC_FORBIDDEN, "잘못된 요청입니다. 페이지를 새로고침한 뒤 다시 시도해 주세요.");
                return;
            }
        }

        chain.doFilter(request, response);
    }

    private boolean isStateChanging(String method) {
        return "POST".equalsIgnoreCase(method)
                || "PUT".equalsIgnoreCase(method)
                || "PATCH".equalsIgnoreCase(method)
                || "DELETE".equalsIgnoreCase(method);
    }

    private boolean isExcluded(String servletPath) {
        if (servletPath == null) return false;

        /*
         * multipart/form-data 요청은 파일 파싱 시점이 Servlet 설정에 영향을 받기 때문에
         * 공통 필터에서 파라미터를 먼저 읽지 않습니다. 해당 기능들은 로그인/권한/POST 검증과
         * 서버 측 파일 검증을 각각의 Servlet에서 수행합니다.
         */
        return servletPath.startsWith("/api/")
                || "/post/write".equals(servletPath)
                || "/board/process/board/write".equals(servletPath)
                || "/post/edit".equals(servletPath)
                || "/board/process/board/edit".equals(servletPath)
                || "/admin/notice/save".equals(servletPath)
                || "/member/profile-image".equals(servletPath);
    }

    private boolean isStaticResource(String servletPath) {
        if (servletPath == null) return false;
        return servletPath.startsWith("/resources/")
                || servletPath.startsWith("/uploads/")
                || "/favicon.ico".equals(servletPath);
    }

    private boolean safeEquals(String expected, String actual) {
        if (expected == null || actual == null) return false;
        return MessageDigest.isEqual(
                expected.getBytes(StandardCharsets.UTF_8),
                actual.getBytes(StandardCharsets.UTF_8));
    }
}
