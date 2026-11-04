<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
/* 예전 categoryView.jsp 주소로 들어오는 요청을 실제 상세보기 페이지로 연결합니다. */
String postId = request.getParameter("postId");
if (postId == null || postId.trim().isEmpty()) {
    postId = request.getParameter("id");
}
if (postId == null || postId.trim().isEmpty()) {
    response.sendRedirect(request.getContextPath() + "/board/category.jsp");
} else {
    response.sendRedirect(request.getContextPath() + "/board/category-view.jsp?postId=" + java.net.URLEncoder.encode(postId, "UTF-8"));
}
%>
