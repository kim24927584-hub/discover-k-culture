package controller.oauth;

import dto.MemberDTO;
import dto.SocialUserInfo;
import service.SocialMemberService;
import service.SocialOAuthService;
import util.OAuthSessionUtil;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(urlPatterns = {
    "/oauth/google/callback",
    "/oauth/kakao/callback",
    "/oauth/naver/callback"
})
public class SocialCallbackServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String provider = provider(request.getServletPath());
        String providerParam = provider.toLowerCase();

        if (session == null) {
            response.sendRedirect(
                request.getContextPath()
                + "/member/login.jsp?socialError=session&provider=" + providerParam
            );
            return;
        }

        String expectedProvider = (String) session.getAttribute("oauthProvider");
        String expectedState = (String) session.getAttribute("oauthState");

        String state = request.getParameter("state");
        String code = request.getParameter("code");
        String error = request.getParameter("error");

        session.removeAttribute("oauthProvider");
        session.removeAttribute("oauthState");

        if (error != null
                || code == null
                || expectedState == null
                || !expectedState.equals(state)
                || !provider.equals(expectedProvider)) {

            getServletContext().log(
                "[OAuth] callback validation failed: provider=" + provider
                + ", providerMatched=" + provider.equals(expectedProvider)
                + ", stateMatched=" + (expectedState != null && expectedState.equals(state))
                + ", codePresent=" + (code != null && !code.isBlank())
                + ", providerError=" + (error != null)
            );

            response.sendRedirect(
                request.getContextPath()
                + "/member/login.jsp?socialError=cancel&provider=" + providerParam
            );
            return;
        }

        try {
            String redirectUri = callbackUrl(request, provider);

            getServletContext().log(
                "[OAuth] " + provider + " callback, redirectUri=" + redirectUri
            );

            SocialUserInfo socialUser = new SocialOAuthService()
                    .fetchUser(provider, code, redirectUri, state);

            MemberDTO member = new SocialMemberService().loginOrCreate(socialUser);

            OAuthSessionUtil.saveMember(session, member);

            if ("SUSPENDED".equals(member.getStatus())) {
                response.sendRedirect(request.getContextPath() + "/home.jsp?loginSuspended=1");
                return;
            }

            response.sendRedirect(request.getContextPath() + "/home.jsp");

        } catch (Exception e) {
            getServletContext().log(provider + " 소셜 로그인 실패", e);

            response.sendRedirect(
                request.getContextPath()
                + "/member/login.jsp?socialError=failed&provider=" + providerParam
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
           .append(provider.toLowerCase())
           .append("/callback");

        return url.toString();
    }
}
