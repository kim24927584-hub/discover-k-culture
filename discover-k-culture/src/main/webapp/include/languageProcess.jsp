<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.Locale"%>
<%
request.setCharacterEncoding("UTF-8");

String language = request.getParameter("language");

if (!"ko".equals(language)
        && !"ja".equals(language)
        && !"zh".equals(language)
        && !"en".equals(language)) {
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

String returnUrl = request.getParameter("returnUrl");
String contextPath = request.getContextPath();

if (returnUrl == null
        || returnUrl.trim().isEmpty()
        || !returnUrl.startsWith(contextPath)) {
    returnUrl = contextPath + "/home.jsp";
}

response.sendRedirect(returnUrl);
%>
