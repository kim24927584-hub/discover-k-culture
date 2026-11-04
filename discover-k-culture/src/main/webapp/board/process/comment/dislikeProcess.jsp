<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.CommentDislikeDAO"%>
<%@ page import="dao.CommentDAO"%>
<%@ page import="dao.PostDAO"%>
<%@ page import="dao.MemberDAO"%>
<%@ page import="dto.CommentDTO"%>
<%@ page import="dto.PostDTO"%>
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
Long memberId = (Long) session.getAttribute("memberId");
if (memberId == null) { response.sendRedirect(request.getContextPath() + "/member/login.jsp"); return; }

/* 데이터 변경 처리는 POST 요청만 허용합니다. */
if (!"POST".equalsIgnoreCase(request.getMethod())) {
    response.sendRedirect(request.getContextPath() + "/home.jsp");
    return;
}

long commentId;
try { commentId = Long.parseLong(request.getParameter("commentId")); }
catch (Exception e) { response.sendRedirect(request.getContextPath() + "/board/allList.jsp"); return; }

CommentDTO comment = new CommentDAO().selectById(commentId);
if (comment == null) { response.sendRedirect(request.getContextPath() + "/board/allList.jsp"); return; }

PostDTO post = new PostDAO().selectById(comment.getPostId());
if (post == null) { response.sendRedirect(request.getContextPath() + "/board/allList.jsp"); return; }

if (!new MemberDAO().isSuspended(memberId.longValue())) {
    new CommentDislikeDAO().toggle(memberId.longValue(), commentId);
}
response.sendRedirect(request.getContextPath() + viewUrl(post, commentId));
%>
  