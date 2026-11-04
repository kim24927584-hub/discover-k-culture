<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.Locale" %>
<%
/*
 * 공통 헤더의 언어 변경 요청 처리.
 * CSRF 필터가 POST 요청의 _csrf 값을 검사합니다.
 * 로그인 여부와 관계없이 세션에 선택한 표시 언어를 저장합니다.
 */
request.setCharacterEncoding("UTF-8");

if (!"POST".equalsIgnoreCase(request.getMethod())) {
    response.sendError(405, "POST 요청만 허용합니다.");
    return;
}

String language = request.getParameter("language");
if (!"ko".equals(language) && !"ja".equals(language)
        && !"zh".equals(language) && !"en".equals(language)) {
    language = "ko";
}

session.setAttribute("siteLanguage", language);
if ("ja".equals(language)) {
    session.setAttribute("siteLocale", Locale.JAPAN.toLanguageTag());
} else if ("zh".equals(language)) {
    session.setAttribute("siteLocale", Locale.CHINA.toLanguageTag());
} else if ("en".equals(language)) {
    session.setAttribute("siteLocale", Locale.US.toLanguageTag());
} else {
    session.setAttribute("siteLocale", Locale.KOREA.toLanguageTag());
}

/*
 * 다른 사이트로 이동되는 열린 리다이렉트를 방지하고,
 * 현재 프로젝트 내부 URL로만 되돌아갑니다.
 */
String contextPath = request.getContextPath();
String returnUrl = request.getParameter("returnUrl");
if (returnUrl == null || !returnUrl.startsWith(contextPath + "/")
        || returnUrl.startsWith("//") || returnUrl.contains("\\")
        || returnUrl.contains("\r") || returnUrl.contains("\n")) {
    returnUrl = contextPath + "/index.jsp";
}

response.setHeader("Cache-Control", "no-store");

/*
 * 좌측 언어 선택창의 비동기 변경 요청은 JSON만 반환합니다.
 * 일반 POST(자바스크립트 비활성화 등)는 기존처럼 리다이렉트합니다.
 */
if ("XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With"))) {
    response.setContentType("application/json; charset=UTF-8");
    response.getWriter().write("{\"ok\":true,\"language\":\"" + language + "\"}");
    return;
}
response.sendRedirect(returnUrl);
%>
