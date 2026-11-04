<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="dao.InquiryDAO" %>
<%@ page import="dto.InquiryDTO" %>

<%!
private String inquiryListH(String value) {
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
   1. 로그인 확인
   문의는 로그인 회원 전용입니다. 정지 회원도 문의는 사용할 수 있습니다.
   ========================================================= */
Long memberId = (Long) session.getAttribute("memberId");
if (memberId == null) {
    response.sendRedirect(request.getContextPath() + "/member/login.jsp");
    return;
}

boolean admin = "ADMIN".equals(session.getAttribute("role"));

/* =========================================================
   2. 페이지 번호 / 페이지당 개수
   ========================================================= */
int pageSize = 10;
try {
    int parsed = Integer.parseInt(request.getParameter("pageSize"));
    if (parsed == 10 || parsed == 20 || parsed == 30) pageSize = parsed;
} catch (Exception ignored) {}

int currentPage = 1;
try {
    currentPage = Integer.parseInt(request.getParameter("page"));
} catch (Exception ignored) {}
if (currentPage < 1) currentPage = 1;

/* =========================================================
   3. 관리자: 전체 문의 / 일반 회원: 본인 문의만 조회
   ========================================================= */
InquiryDAO inquiryDAO = new InquiryDAO();
int totalCount = admin
        ? inquiryDAO.countAll()
        : inquiryDAO.countByMemberId(memberId.longValue());

int totalPages = Math.max(1, (int)Math.ceil(totalCount / (double)pageSize));
if (currentPage > totalPages) currentPage = totalPages;

List<InquiryDTO> inquiries = admin
        ? inquiryDAO.selectAllPage(currentPage, pageSize)
        : inquiryDAO.selectByMemberPage(memberId.longValue(), currentPage, pageSize);

int blockSize = 5;
int startPage = ((currentPage - 1) / blockSize) * blockSize + 1;
int endPage = Math.min(startPage + blockSize - 1, totalPages);

request.setAttribute("pageCss", "board/inquiryList.css");
request.setAttribute("pageTitle", "1:1 문의");
request.setAttribute("activeMenu", "INQUIRY");
%>

<%@include file="/include/header.jsp" %>

<main class="container">
    <h1 class="board-title"><%=admin ? "1:1 문의 관리" : "1:1 문의"%></h1>

    <div style="display:flex; justify-content:flex-end; margin-bottom:10px;">
        <a href="<%=request.getContextPath()%>/board/inquiryWrite.jsp" class="btn btn-primary btn-inquiry-write">문의 작성</a>
    </div>

    <table class="board-table">
        <thead>
            <tr>
                <th class="col-num">번호</th>
                <% if (admin) { %><th class="col-author">작성자</th><% } %>
                <th class="col-title">제목</th>
                <th class="col-answer-status">상태</th>
                <th class="col-date">작성일</th>
            </tr>
        </thead>
        <tbody>
        <% if (inquiries == null || inquiries.isEmpty()) { %>
            <tr>
                <td colspan="<%=admin ? 5 : 4%>">등록된 문의가 없습니다.</td>
            </tr>
        <% } else { %>
            <% for (InquiryDTO inquiry : inquiries) { %>
            <tr>
                <td class="col-num"><%=inquiry.getInquiryId()%></td>
                <% if (admin) { %>
                    <td class="col-author"><%=inquiryListH(inquiry.getMemberNickname())%></td>
                <% } %>
                <td class="col-title">
                    <a href="<%=request.getContextPath()%>/board/inquiryView.jsp?id=<%=inquiry.getInquiryId()%>">
                        <%=inquiryListH(inquiry.getTitle())%>
                    </a>
                </td>
                <td class="col-answer-status">
                    <% if ("ANSWERED".equals(inquiry.getStatus())) { %>
                        <span class="board-table-badge answered">답변 완료</span>
                    <% } else { %>
                        <span class="board-table-badge">답변 대기중</span>
                    <% } %>
                </td>
                <td class="col-date">
                    <%=inquiry.getCreatedAt() == null ? "-" : inquiry.getCreatedAt().toString().substring(0, 10)%>
                </td>
            </tr>
            <% } %>
        <% } %>
        </tbody>
    </table>

    <nav class="pagination" aria-label="페이지 이동">
        <a href="<%=currentPage > 1 ? ("?page=" + (currentPage - 1) + "&pageSize=" + pageSize) : "#"%>"
           class="page-move <%=currentPage > 1 ? "" : "is-disabled"%>">← 이전</a>

        <div class="page-numbers">
            <% for (int p = startPage; p <= endPage; p++) { %>
                <a href="?page=<%=p%>&pageSize=<%=pageSize%>"
                   class="page <%=p == currentPage ? "is-active" : ""%>"><%=p%></a>
            <% } %>
        </div>

        <a href="<%=currentPage < totalPages ? ("?page=" + (currentPage + 1) + "&pageSize=" + pageSize) : "#"%>"
           class="page-move <%=currentPage < totalPages ? "" : "is-disabled"%>">다음 →</a>
    </nav>
</main>

<%@include file="/include/sidebar.jsp" %>
<%@include file="/include/footer.jsp" %>
