<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.CommentDAO"%>
<%@ page import="dao.PostDAO"%>
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

CommentDAO commentDAO = new CommentDAO();
CommentDTO comment = commentDAO.selectById(commentId);
if (comment == null) { response.sendRedirect(request.getContextPath() + "/board/allList.jsp"); return; }

PostDTO post = new PostDAO().selectById(comment.getPostId());
if (post == null) { response.sendRedirect(request.getContextPath() + "/board/allList.jsp"); return; }

boolean admin = "ADMIN".equals(session.getAttribute("role"));
commentDAO.delete(commentId, memberId.longValue(), admin);

response.sendRedirect(request.getContextPath() + viewUrl(post) + "#comments");
%>
