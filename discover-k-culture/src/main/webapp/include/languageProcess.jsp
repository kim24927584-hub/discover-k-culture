
<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"
    import="java.util.Locale" %>

<%
    // 1. 한글 인코딩 설정
    request.setCharacterEncoding("UTF-8");

    // 2. POST 요청만 허용
    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        response.sendError(405, "POST 요청만 허용합니다.");
        return;
    }

    // 3. 선택한 언어 가져오기
    String language = request.getParameter("language");

    // 지원하지 않는 언어는 한국어로 설정
    if (!"ko".equals(language)
            && !"ja".equals(language)
            && !"zh".equals(language)
            && !"en".equals(language)) {
        language = "ko";
    }

    // 4. 세션에 선택한 언어 저장
    session.setAttribute("siteLanguage", language);

    // 5. 언어별 Locale 설정
    if ("ja".equals(language)) {
        session.setAttribute(
            "siteLocale", Locale.JAPAN.toLanguageTag()
        );
    } else if ("zh".equals(language)) {
        session.setAttribute(
            "siteLocale", Locale.CHINA.toLanguageTag()
        );
    } else if ("en".equals(language)) {
        session.setAttribute(
            "siteLocale", Locale.US.toLanguageTag()
        );
    } else {
        session.setAttribute(
            "siteLocale", Locale.KOREA.toLanguageTag()
        );
    }

    // 6. 프로젝트 내부 URL만 리다이렉트 허용
    String contextPath = request.getContextPath();
    String returnUrl = request.getParameter("returnUrl");

    if (returnUrl == null
            || !returnUrl.startsWith(contextPath + "/")
            || returnUrl.startsWith("//")
            || returnUrl.contains("\\")
            || returnUrl.contains("\r")
            || returnUrl.contains("\n")) {

        returnUrl = contextPath + "/index.jsp";
    }

    // 7. 캐시 방지
    response.setHeader("Cache-Control", "no-store");

    // 8. AJAX 요청인 경우 JSON 반환
    if ("XMLHttpRequest".equalsIgnoreCase(
            request.getHeader("X-Requested-With"))) {

        response.setContentType(
            "application/json; charset=UTF-8"
        );

        out.clearBuffer();
        out.print(
            "{\"ok\":true,\"language\":\""
            + language + "\"}"
        );

        return;
    }

    // 9. 일반 POST 요청은 이전 페이지로 이동
    response.sendRedirect(returnUrl);
%>
