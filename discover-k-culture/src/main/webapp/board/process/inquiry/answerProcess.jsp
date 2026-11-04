<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.InquiryDAO" %>

<%
request.setCharacterEncoding("UTF-8");

Long adminId = (Long) session.getAttribute("memberId");
if (adminId == null || !"ADMIN".equals(session.getAttribute("role"))) {
    response.sendRedirect(request.getContextPath() + "/home.jsp");
    return;
}

if (!"POST".equalsIgnoreCase(request.getMethod())) {
    response.sendRedirect(request.getContextPath() + "/board/inquiryList.jsp");
    return;
}

long inquiryId;
try {
    inquiryId = Long.parseLong(request.getParameter("inquiryId"));
} catch (Exception e) {
    response.sendRedirect(request.getContextPath() + "/board/inquiryList.jsp");
    return;
}

String answer = request.getParameter("answer");
answer = answer == null ? "" : answer.trim();
if (answer.isEmpty() || answer.length() > 5000) {
    response.sendRedirect(request.getContextPath() + "/board/inquiryView.jsp?id=" + inquiryId + "&error=answer");
    return;
}

try {
    new InquiryDAO().answer(inquiryId, adminId.longValue(), answer);
    response.sendRedirect(request.getContextPath() + "/board/inquiryView.jsp?id=" + inquiryId);
} catch (Exception e) {
    throw new ServletException("문의 답변 저장 중 오류가 발생했습니다.", e);
}
%>
