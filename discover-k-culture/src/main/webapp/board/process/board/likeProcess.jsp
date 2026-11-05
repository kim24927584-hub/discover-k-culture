<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ page import="dao.PostLikeDAO" %>
<%@ page import="dao.PostDislikeDAO" %>
<%@ page import="dao.PostDAO" %>
<%@ page import="dao.MemberDAO" %>
<%@ page import="dto.PostDTO" %>
<%!
private String viewUrl(PostDTO post) {
    String base;
    if ("KCULTURE".equals(post.getBoardType())) base = "/board/category-view.jsp?postId=" + post.getPostId() + "&skipView=1";
    else if ("QUESTION".equals(post.getBoardType())) base = "/board/qnaView.jsp?id=" + post.getPostId() + "&skipView=1";
    else base = "/board/allView.jsp?id=" + post.getPostId() + "&skipView=1";
    return base;
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
    if (new MemberDAO().isSuspended(memberId.longValue())) {
        if (ajax) { response.setStatus(403); out.print("{\"success\":false,\"error\":\"SUSPENDED\"}"); }
        else response.sendRedirect(ctx + viewUrl(post));
        return;
    }
    new PostLikeDAO().toggle(memberId.longValue(), postId);

    if (ajax) {
        // DAO 트랜잭션 커밋 후 실제 카운트와 선택 상태를 재조회합니다.
        PostDTO current = new PostDAO().selectById(postId);
        boolean liked = new PostLikeDAO().exists(memberId.longValue(), postId);
        boolean disliked = new PostDislikeDAO().exists(memberId.longValue(), postId);
        out.print("{\"success\":true,\"liked\":" + liked
            + ",\"disliked\":" + disliked
            + ",\"likeCount\":" + current.getLikeCount()
            + ",\"dislikeCount\":" + current.getDislikeCount() + "}");
    } else {
        response.sendRedirect(ctx + viewUrl(post));
    }
} catch (Exception e) {
    application.log("board like 반응 처리 오류", e);
    if (ajax) { response.setStatus(500); out.print("{\"success\":false,\"error\":\"SERVER_ERROR\"}"); }
    else response.sendRedirect(ctx + "/board/allList.jsp");
}
%>
