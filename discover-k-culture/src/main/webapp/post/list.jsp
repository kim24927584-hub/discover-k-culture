<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
/* 이전 post/list.jsp 주소를 현재 게시판별 목록으로 연결합니다. */
String boardType = request.getParameter("boardType");
if ("KCULTURE".equals(boardType)) {
    response.sendRedirect(request.getContextPath() + "/board/category.jsp");
} else if ("QUESTION".equals(boardType)) {
    response.sendRedirect(request.getContextPath() + "/board/qnaList.jsp");
} else {
    response.sendRedirect(request.getContextPath() + "/board/allList.jsp");
}
%>
