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

try {
    InquiryDAO dao = new InquiryDAO();
    InquiryDTO inquiry = dao.selectById(inquiryId);

    if (inquiry != null && inquiry.getMemberId() == memberId.longValue()) {
        dao.delete(inquiryId, memberId.longValue());
    }

    response.sendRedirect(request.getContextPath() + "/board/inquiryList.jsp");
} catch (Exception e) {
    throw new ServletException("문의 삭제 중 오류가 발생했습니다.", e);
}
%>
