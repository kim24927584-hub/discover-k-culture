package controller.oauth;

import service.SocialOAuthService;
import util.OAuthConfig;

import java.io.IOException;
import java.security.SecureRandom;
import java.util.Base64;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(
    urlPatterns = {
        "/oauth/google/login",
        "/oauth/kakao/login",
        "/oauth/naver/login"
    }
)
public class SocialLoginServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(
        HttpServletRequest request,
        HttpServletResponse response
    ) throws ServletException, IOException {

        String provider = null;

        try {
            provider = provider(request.getServletPath());

            String clientId = OAuthConfig.required(provider + "_CLIENT_ID");

            String state = createState();
            HttpSession session = request.getSession(true);

            session.setAttribute("oauthState", state);
            session.setAttribute("oauthProvider", provider);

            String redirectUri = callbackUrl(request, provider);

            getServletContext().log(
                "[OAuth] " + provider + " login start, redirectUri=" + redirectUri
            );

            String url = new SocialOAuthService().authorizationUrl(
                provider,
                clientId,
                redirectUri,
                state
            );

            response.sendRedirect(url);

        } catch (IllegalStateException e) {
            getServletContext().log("소셜 로그인 설정 오류: " + provider, e);

            String p = provider == null ? "" : provider.toLowerCase();
            response.sendRedirect(
                request.getContextPath()
                + "/member/login.jsp?socialError=config&provider=" + p
            );

        } catch (Exception e) {
            getServletContext().log("소셜 로그인 시작 실패: " + provider, e);

            String p = provider == null ? "" : provider.toLowerCase();
            response.sendRedirect(
                request.getContextPath()
                + "/member/login.jsp?socialError=failed&provider=" + p
            );
        }
    }

    private String provider(String servletPath) {
        if (servletPath.contains("/google/")) {
            return "GOOGLE";
        }
        if (servletPath.contains("/kakao/")) {
            return "KAKAO";
        }
        if (servletPath.contains("/naver/")) {
            return "NAVER";
        }
        throw new IllegalArgumentException("지원하지 않는 OAuth 경로입니다.");
    }

    private String callbackUrl(HttpServletRequest request, String provider) {
        String providerPath = provider.toLowerCase();

        StringBuilder url = new StringBuilder();
        url.append(request.getScheme())
           .append("://")
           .append(request.getServerName());

        int port = request.getServerPort();
        boolean defaultPort = ("http".equalsIgnoreCase(request.getScheme()) && port == 80)
                || ("https".equalsIgnoreCase(request.getScheme()) && port == 443);

        if (!defaultPort) {
            url.append(':').append(port);
        }

        url.append(request.getContextPath())
           .append("/oauth/")
           .append(providerPath)
           .append("/callback");

        return url.toString();
    }

    private String createState() {
        byte[] bytes = new byte[24];
        new SecureRandom().nextBytes(bytes);

        return Base64.getUrlEncoder()
            .withoutPadding()
            .encodeToString(bytes);
    }
}
