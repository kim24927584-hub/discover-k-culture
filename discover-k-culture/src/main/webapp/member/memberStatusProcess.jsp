<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.Date" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="dao.MemberDAO" %>
<%
request.setCharacterEncoding("UTF-8");

Long adminId = (Long) session.getAttribute("memberId");
if (adminId == null || !"ADMIN".equals(session.getAttribute("role"))) {
    response.sendRedirect(request.getContextPath() + "/home.jsp");
    return;
}

String keyword = request.getParameter("keyword");
if (keyword == null) keyword = "";
String pageParam = request.getParameter("page");
String pageSizeParam = request.getParameter("pageSize");
if (pageParam == null || !pageParam.matches("\\d+")) pageParam = "1";
if (pageSizeParam == null || !("10".equals(pageSizeParam) || "20".equals(pageSizeParam) || "30".equals(pageSizeParam))) pageSizeParam = "10";

String redirectUrl = request.getContextPath() + "/member/memberList.jsp?page=" + pageParam
        + "&pageSize=" + pageSizeParam + "&keyword=" + URLEncoder.encode(keyword, "UTF-8");

try {
    long memberId = Long.parseLong(request.getParameter("memberId"));
    String status = request.getParameter("status");
    MemberDAO dao = new MemberDAO();

    if ("ACTIVE".equals(status)) {
        dao.updateStatus(memberId, "ACTIVE", null, null);
    } else if ("SUSPENDED".equals(status)) {
        String untilRaw = request.getParameter("suspendedUntil");
        String reason = request.getParameter("suspensionReason");

        if (untilRaw == null || untilRaw.trim().isEmpty() || reason == null || reason.trim().isEmpty()) {
            response.sendRedirect(redirectUrl + "&error=suspendRequired");
            return;
        }

        Date suspendedUntil = Date.valueOf(untilRaw);
        int updated = dao.updateStatus(memberId, "SUSPENDED", suspendedUntil, reason.trim());
        if (updated == 0) {
            response.sendRedirect(redirectUrl + "&error=invalidSuspend");
            return;
        }
    }
} catch (Exception e) {
    application.log("회원 상태 변경 실패", e);
    response.sendRedirect(redirectUrl + "&error=status");
    return;
}

response.sendRedirect(redirectUrl + "&updated=1");
%>
