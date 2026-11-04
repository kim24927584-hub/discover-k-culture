<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.net.URLDecoder" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="jakarta.servlet.http.Cookie" %>

<%!
private String loginH(String value) {
    if (value == null) return "";
    return value.replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace("\"", "&quot;")
        .replace("'", "&#39;");
}
%>

<%
/* =========================================================
   로그인 화면
   - LoginServlet(/member/login)과 입력 name을 맞춥니다.
   - 아이디 기억 쿠키가 있으면 로그인 ID만 자동으로 채웁니다.
   ========================================================= */
request.setAttribute("pageCss", "member/login.css");
request.setAttribute("pageTitle", "로그인");

String savedLoginId = "";
Cookie[] loginCookies = request.getCookies();
if (loginCookies != null) {
    for (Cookie cookie : loginCookies) {
        if ("KCULTURE_SAVED_ID".equals(cookie.getName())) {
            try {
                savedLoginId = URLDecoder.decode(cookie.getValue(), StandardCharsets.UTF_8);
            } catch (Exception ignored) {
                savedLoginId = "";
            }
            break;
        }
    }
}

String loginError = request.getParameter("error");
String socialError = request.getParameter("socialError");
%>

<%@include file="/include/header.jsp" %>

<div class="login-page">
    <div class="login-box">
        <h2>로그인</h2>

        <%-- 회원가입 완료 안내 --%>
        <% if ("1".equals(request.getParameter("joined"))) { %>
            <p class="social-desc">회원가입이 완료되었습니다. 로그인해 주세요.</p>
        <% } %>

        <%-- 로그인 실패 안내 --%>
        <% if (loginError != null) { %>
            <p class="social-desc">
                <% if ("empty".equals(loginError)) { %>
                    아이디와 비밀번호를 모두 입력해 주세요.
                <% } else { %>
                    아이디 또는 비밀번호를 확인해 주세요.
                <% } %>
            </p>
        <% } %>

        <%-- 소셜 로그인 오류 안내 --%>
        <% if (socialError != null) { %>
            <p class="social-desc">
                소셜 로그인을 완료하지 못했습니다. 설정 또는 로그인 상태를 확인해 주세요.
            </p>
        <% } %>

        <form action="<%=request.getContextPath()%>/member/login" class="login-form" method="post">
            <div class="form-group">
                <input
                    type="text"
                    name="id"
                    class="form-input"
                    placeholder="아이디"
                    value="<%=loginH(savedLoginId)%>"
                    required
                    autofocus />
            </div>

            <div class="form-group">
                <input
                    type="password"
                    name="password"
                    class="form-input"
                    placeholder="비밀번호"
                    required />
            </div>

            <div class="login-option">
                <label>
                    <input
                        type="checkbox"
                        name="rememberId"
                        class="remember-me"
                        value="true"
                        <%=savedLoginId.isEmpty() ? "" : "checked"%> />
                    아이디 기억
                </label>

                <label>
                    <input
                        type="checkbox"
                        name="autoLogin"
                        class="auto-login"
                        value="true" />
                    자동 로그인
                </label>
            </div>

            <button type="submit" class="btn btn-primary">로그인</button>
        </form>

        <div class="social-login">
            <div class="social-divider">소셜 로그인</div>

            <div class="social-btn">
                <a href="<%=request.getContextPath()%>/oauth/google/login" class="google-btn">
                    <img src="${ctx}/resources/img/google.png" alt="Google로 로그인" />Google로 로그인
                </a>

                <a href="<%=request.getContextPath()%>/oauth/kakao/login" class="kakao-btn">
                    <img src="${ctx}/resources/img/kakao_login_kr_medium.png" alt="카카오로 로그인" />
                </a>

                <a href="<%=request.getContextPath()%>/oauth/naver/login" class="naver-btn">
                    <img src="${ctx}/resources/img/NAVER_login_Light_KR_green_narrow_H48.png" alt="네이버로 로그인" />
                </a>
            </div>

            <div class="social-desc">
                최초 로그인 시 소셜 계정 정보로 회원 계정이 자동 생성되거나 기존 계정에 연결됩니다.
            </div>
        </div>

        <div class="login-footer">
            <div class="login-links">
                <%-- 현재 프로젝트에 별도 계정복구 기능이 없어 동작하지 않는 # 링크는 제거합니다. --%>
                <a href="<%=request.getContextPath()%>/member/join.jsp">회원가입</a>
            </div>
        </div>
    </div>
</div>

<%@include file="/include/sidebar.jsp" %>
<%@include file="/include/footer.jsp" %>
