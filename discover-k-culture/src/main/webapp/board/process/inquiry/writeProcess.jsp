<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.InquiryDAO" %>
<%@ page import="dto.InquiryDTO" %>

<%
request.setCharacterEncoding("UTF-8");

Long memberId = (Long) session.getAttribute("memberId");
if (memberId == null) {
    response.sendRedirect(request.getContextPath() + "/member/login.jsp");
    return;
}

if (!"POST".equalsIgnoreCase(request.getMethod())) {
    response.sendRedirect(request.getContextPath() + "/board/inquiryWrite.jsp");
    return;
}

String title = request.getParameter("title");
String content = request.getParameter("content");
title = title == null ? "" : title.trim();
content = content == null ? "" : content.trim();

if (title.isEmpty() || title.length() > 200 || content.isEmpty() || content.length() > 5000) {
    response.sendRedirect(request.getContextPath() + "/board/inquiryWrite.jsp?error=invalid");
    return;
}

InquiryDTO inquiry = new InquiryDTO();
inquiry.setMemberId(memberId.longValue());
inquiry.setTitle(title);
inquiry.setContent(content);

try {
    if (new InquiryDAO().insert(inquiry) != 1) {
        throw new Exception("문의 등록 결과가 1건이 아닙니다.");
    }
    response.sendRedirect(request.getContextPath() + "/board/inquiryList.jsp");
} catch (Exception e) {
    throw new ServletException("문의 등록 중 오류가 발생했습니다.", e);
}
%>
