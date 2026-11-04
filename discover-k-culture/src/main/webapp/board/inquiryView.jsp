<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.InquiryDAO" %>
<%@ page import="dto.InquiryDTO" %>

<%!
private String inquiryViewH(String value) {
    if (value == null) return "";
    return value.replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace("\"", "&quot;")
        .replace("'", "&#39;");
}
%>

<%
request.setCharacterEncoding("UTF-8");

/* =========================================================
   1. 로그인 / 문의 번호 확인
   ========================================================= */
Long memberId = (Long) session.getAttribute("memberId");
if (memberId == null) {
    response.sendRedirect(request.getContextPath() + "/member/login.jsp");
    return;
}

long inquiryId;
try {
    inquiryId = Long.parseLong(request.getParameter("id"));
} catch (Exception e) {
    response.sendRedirect(request.getContextPath() + "/board/inquiryList.jsp");
    return;
}

/* =========================================================
   2. 문의 조회 및 접근 권한 확인
   관리자 또는 문의 작성자 본인만 볼 수 있습니다.
   ========================================================= */
InquiryDTO inquiry = new InquiryDAO().selectById(inquiryId);
boolean admin = "ADMIN".equals(session.getAttribute("role"));

if (inquiry == null || (!admin && inquiry.getMemberId() != memberId.longValue())) {
    response.sendRedirect(request.getContextPath() + "/board/inquiryList.jsp");
    return;
}

request.setAttribute("pageCss", "board/common/viewCommon.css");
request.setAttribute("pageTitle", "1:1 문의 상세보기");
request.setAttribute("activeMenu", "INQUIRY");
%>

<%@include file="/include/header.jsp" %>

<main class="container">
    <h1 class="post-title"><span>[1:1 문의]</span> <%=inquiryViewH(inquiry.getTitle())%></h1>

    <p class="post-meta">
        <% if (admin) { %>
            작성자 <span class="post-writer"><%=inquiryViewH(inquiry.getMemberNickname())%></span> ·
        <% } %>
        <%=inquiry.getCreatedAt() == null ? "-" : inquiry.getCreatedAt().toString().substring(0, 16)%>
        · <%= "ANSWERED".equals(inquiry.getStatus()) ? "답변 완료" : "답변 대기중" %>
    </p>

    <div class="post-body">
        <p class="post-content"><%=inquiryViewH(inquiry.getContent()).replace("\n", "<br>")%></p>
    </div>

    <% if (inquiry.getAnswer() != null && !inquiry.getAnswer().trim().isEmpty()) { %>
        <div class="post-body answer">
            <i class="fa-solid fa-screwdriver-wrench fa-sm"></i>
            <span class="post-meta">
                <%=inquiry.getAdminNickname() == null ? "운영자" : inquiryViewH(inquiry.getAdminNickname())%>의 답변
                · <%=inquiry.getAnsweredAt() == null ? "-" : inquiry.getAnsweredAt().toString().substring(0, 16)%>
            </span>
            <p class="post-content answer"><%=inquiryViewH(inquiry.getAnswer()).replace("\n", "<br>")%></p>
        </div>
    <% } %>

    <%-- 관리자는 같은 화면에서 답변을 등록/수정할 수 있습니다. --%>
    <% if (admin) { %>
        <div class="post-body answer">
            <form action="<%=request.getContextPath()%>/board/process/inquiry/answerProcess.jsp" method="post">
                <input type="hidden" name="inquiryId" value="<%=inquiryId%>">
                <label for="answer"><strong>운영자 답변</strong></label>
                <textarea id="answer" name="answer" maxlength="5000" required
                          style="width:100%; min-height:160px;"><%=inquiryViewH(inquiry.getAnswer())%></textarea>
                <button type="submit" class="btn btn-primary">답변 저장</button>
            </form>
        </div>
    <% } %>

    <div style="display:flex; gap:8px; align-items:center; flex-wrap:wrap;">
        <a href="<%=request.getContextPath()%>/board/inquiryList.jsp" class="btn btn-primary btn-list">
            <span class="btn-arrow">←</span>목록
        </a>

        <%-- 작성자 본인만 자신의 문의를 삭제할 수 있습니다. --%>
        <% if (inquiry.getMemberId() == memberId.longValue()) { %>
            <form action="<%=request.getContextPath()%>/board/process/inquiry/deleteProcess.jsp"
                  method="post" onsubmit="return confirm('이 문의를 삭제하시겠습니까?');">
                <input type="hidden" name="inquiryId" value="<%=inquiryId%>">
                <button type="submit" class="btn btn-list">삭제</button>
            </form>
        <% } %>
    </div>
</main>

<%@include file="/include/sidebar.jsp" %>
<%@include file="/include/footer.jsp" %>
