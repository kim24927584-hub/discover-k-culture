<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>
<%
/*
 * 호환용 엔드포인트입니다.
 * 실제 로그인/자동 로그인/아이디 기억 처리는 LoginServlet(/member/login)에서
 * 한 번만 관리하도록 forward 합니다.
 */
request.getRequestDispatcher("/member/login").forward(request, response);
%>
