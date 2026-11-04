<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.CommentDAO"%>
<%@ page import="dao.PostDAO"%>
<%@ page import="dao.MemberDAO"%>
<%@ page import="dto.CommentDTO"%>
<%@ page import="dto.PostDTO"%>
<%!
private String viewUrl(PostDTO post) {
    if ("KCULTURE".equals(post.getBoardType())) return "/board/category-view.jsp?postId=" + post.getPostId() + "&skipView=1";
    if ("QUESTION".equals(post.getBoardType())) return "/board/qnaView.jsp?id=" + post.getPostId() + "&skipView=1";
    return "/board/allView.jsp?id=" + post.getPostId() + "&skipView=1";
}
%>
<%
request.setCharacterEncoding("UTF-8");

Long memberId = (Long) session.getAttribute("memberId");
if (memberId == null) { response.sendRedirect(request.getContextPath() + "/member/login.jsp"); return; }
if (new MemberDAO().isSuspended(memberId.longValue())) { response.sendRedirect(request.getContextPath() + "/home.jsp?error=suspended"); return; }

/* 데이터 변경 처리는 POST 요청만 허용합니다. */
if (!"POST".equalsIgnoreCase(request.getMethod())) {
    response.sendRedirect(request.getContextPath() + "/home.jsp");
    return;
}

long postId;
try { postId = Long.parseLong(request.getParameter("postId")); }
catch (Exception e) { response.sendRedirect(request.getContextPath() + "/board/allList.jsp"); return; }

PostDTO post = new PostDAO().selectById(postId);
if (post == null) { response.sendRedirect(request.getContextPath() + "/board/allList.jsp"); return; }

String content = request.getParameter("content");
if (content != null && !content.trim().isEmpty()) {
    CommentDTO comment = new CommentDTO();
    comment.setPostId(postId);
    comment.setMemberId(memberId.longValue());
    comment.setContent(content.trim());
    new CommentDAO().insert(comment);
}
response.sendRedirect(request.getContextPath() + viewUrl(post) + "#comments");
%>
 