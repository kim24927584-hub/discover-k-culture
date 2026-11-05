<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ page import="dao.BookmarkDAO" %>
<%@ page import="dao.PostDAO" %>
<%@ page import="dto.PostDTO" %>
<%!
// JavaScript 비활성화 시 기존 게시글로 되돌아가기 위한 경로입니다.
private String bookmarkViewUrl(PostDTO post) {
    String path;
    if ("KCULTURE".equals(post.getBoardType())) {
        path = "/board/category-view.jsp?postId=" + post.getPostId();
    } else if ("QUESTION".equals(post.getBoardType())) {
        path = "/board/qnaView.jsp?id=" + post.getPostId();
    } else {
        path = "/board/allView.jsp?id=" + post.getPostId();
    }
    return path + "&skipView=1";
}
%>
<%
request.setCharacterEncoding("UTF-8");
boolean ajax = "XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With"));
if (ajax) {
    response.setContentType("application/json; charset=UTF-8");
    response.setHeader("Cache-Control", "no-store");
}
String ctx = request.getContextPath();

if (!"POST".equalsIgnoreCase(request.getMethod())) {
    if (ajax) { response.setStatus(405); out.print("{\"success\":false,\"error\":\"METHOD_NOT_ALLOWED\"}"); }
    else response.sendRedirect(ctx + "/home.jsp");
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
    else response.sendRedirect(ctx + "/board/allList.jsp");
    return;
}

try {
    PostDTO post = new PostDAO().selectById(postId);
    if (post == null) {
        if (ajax) { response.setStatus(404); out.print("{\"success\":false,\"error\":\"NOT_FOUND\"}"); }
        else response.sendRedirect(ctx + "/board/allList.jsp");
        return;
    }

    // 회원/게시글의 관계는 기존 BookmarkDAO로 유지합니다.
    boolean bookmarked = new BookmarkDAO().toggle(memberId.longValue(), postId);

    if (ajax) {
        out.print("{\"success\":true,\"bookmarked\":" + bookmarked + "}");
    } else {
        response.sendRedirect(ctx + bookmarkViewUrl(post));
    }
} catch (Exception e) {
    application.log("북마크 토글 오류", e);
    if (ajax) { response.setStatus(500); out.print("{\"success\":false,\"error\":\"SERVER_ERROR\"}"); }
    else response.sendRedirect(ctx + "/board/allList.jsp");
}
%>
