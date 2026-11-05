<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ page import="dao.BookmarkListDAO" %>
<%
request.setCharacterEncoding("UTF-8");
boolean ajax = "XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With"));
String ctx = request.getContextPath();
String fallback = ctx + "/member/mypage.jsp?tab=bookmark#bookmarkSection";
if (ajax) {
    response.setContentType("application/json; charset=UTF-8");
    response.setHeader("Cache-Control", "no-store");
}
if (!"POST".equalsIgnoreCase(request.getMethod())) {
    if (ajax) { response.setStatus(405); out.print("{\"success\":false,\"error\":\"METHOD_NOT_ALLOWED\"}"); }
    else response.sendRedirect(fallback);
    return;
}
Long memberId = (Long) session.getAttribute("memberId");
if (memberId == null) {
    if (ajax) { response.setStatus(401); out.print("{\"success\":false,\"error\":\"LOGIN_REQUIRED\"}"); }
    else response.sendRedirect(ctx + "/member/login.jsp");
    return;
}
long postId;
try {
    postId = Long.parseLong(request.getParameter("postId"));
    if (postId <= 0) throw new NumberFormatException();
} catch (Exception e) {
    if (ajax) { response.setStatus(400); out.print("{\"success\":false,\"error\":\"INVALID_ID\"}"); }
    else response.sendRedirect(fallback);
    return;
}
try {
    // 로그인한 회원의 북마크만 삭제합니다. 이미 해제된 경우에도 정상 응답합니다.
    new BookmarkListDAO().delete(memberId.longValue(), postId);
    if (ajax) {
        out.print("{\"success\":true,\"bookmarked\":false}");
    } else {
        response.sendRedirect(fallback);
    }
} catch (Exception e) {
    application.log("마이페이지 북마크 해제 오류", e);
    if (ajax) { response.setStatus(500); out.print("{\"success\":false,\"error\":\"SERVER_ERROR\"}"); }
    else response.sendRedirect(fallback);
}
%>
