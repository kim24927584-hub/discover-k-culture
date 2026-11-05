<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ page import="dao.CommentLikeDAO" %>
<%@ page import="dao.CommentDislikeDAO" %>
<%@ page import="dao.PostDAO" %>
<%@ page import="dao.MemberDAO" %>
<%@ page import="dto.PostDTO" %>
<%@ page import="dao.CommentDAO" %>
<%@ page import="dto.CommentDTO" %>
<%!
private String viewUrl(PostDTO post, long commentId) {
    String base;
    if ("KCULTURE".equals(post.getBoardType())) base = "/board/category-view.jsp?postId=" + post.getPostId() + "&skipView=1";
    else if ("QUESTION".equals(post.getBoardType())) base = "/board/qnaView.jsp?id=" + post.getPostId() + "&skipView=1";
    else base = "/board/allView.jsp?id=" + post.getPostId() + "&skipView=1";
    return base + "#comment-" + commentId;
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
long commentId;
try {
    commentId = Long.parseLong(request.getParameter("commentId"));
    if (commentId <= 0) throw new NumberFormatException();
} catch (Exception e) {
    if (ajax) { response.setStatus(400); out.print("{\"success\":false,\"error\":\"INVALID_ID\"}"); }
    else response.sendRedirect(ctx + "/board/allList.jsp");
    return;
}
try {
    CommentDTO comment = new CommentDAO().selectById(commentId);
    PostDTO post = comment == null ? null : new PostDAO().selectById(comment.getPostId());
    if (post == null) {
        if (ajax) { response.setStatus(404); out.print("{\"success\":false,\"error\":\"NOT_FOUND\"}"); }
        else response.sendRedirect(ctx + "/board/allList.jsp");
        return;
    }
    if (new MemberDAO().isSuspended(memberId.longValue())) {
        if (ajax) { response.setStatus(403); out.print("{\"success\":false,\"error\":\"SUSPENDED\"}"); }
        else response.sendRedirect(ctx + viewUrl(post, commentId));
        return;
    }
    new CommentLikeDAO().toggle(memberId.longValue(), commentId);

    if (ajax) {
        // DAO 트랜잭션 커밋 후 실제 카운트와 선택 상태를 재조회합니다.
        CommentDTO current = new CommentDAO().selectById(commentId);
        boolean liked = new CommentLikeDAO().exists(memberId.longValue(), commentId);
        boolean disliked = new CommentDislikeDAO().exists(memberId.longValue(), commentId);
        out.print("{\"success\":true,\"liked\":" + liked
            + ",\"disliked\":" + disliked
            + ",\"likeCount\":" + current.getLikeCount()
            + ",\"dislikeCount\":" + current.getDislikeCount() + "}");
    } else {
        response.sendRedirect(ctx + viewUrl(post, commentId));
    }
} catch (Exception e) {
    application.log("comment like 반응 처리 오류", e);
    if (ajax) { response.setStatus(500); out.print("{\"success\":false,\"error\":\"SERVER_ERROR\"}"); }
    else response.sendRedirect(ctx + "/board/allList.jsp");
}
%>
