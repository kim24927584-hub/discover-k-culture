<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="dao.MemberDAO" %>
<%@ page import="dto.MemberDTO" %>

<%!
private String memberListH(String value) {
    if (value == null) return "";
    return value.replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace("\"", "&quot;")
        .replace("'", "&#39;");
}

private String memberProfileSrc(String contextPath, String profileImage) {
    if (profileImage == null || profileImage.trim().isEmpty()) {
        return contextPath + "/resources/img/base.png";
    }
    if (profileImage.startsWith("http://") || profileImage.startsWith("https://")) {
        return profileImage;
    }
    if (profileImage.startsWith("/")) {
        return contextPath + profileImage;
    }
    return contextPath + "/" + profileImage;
}
%>

<%
request.setCharacterEncoding("UTF-8");

/* =========================================================
   1. 관리자 권한 확인
   ========================================================= */
Long adminId = (Long) session.getAttribute("memberId");
if (adminId == null || !"ADMIN".equals(session.getAttribute("role"))) {
    response.sendRedirect(request.getContextPath() + "/home.jsp");
    return;
}

/* =========================================================
   2. 검색 / 페이지 조건
   ========================================================= */
String keyword = request.getParameter("keyword");
keyword = keyword == null ? "" : keyword.trim();
String keywordLower = keyword.toLowerCase();

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
   3. DB 회원 목록 조회 후 검색 조건 적용
   기존 MemberDAO.selectAll()을 재사용하여 CSS/DB 구조 변경 없이 연결합니다.
   ========================================================= */
List<MemberDTO> allMembers = new MemberDAO().selectAll();
List<MemberDTO> filteredMembers = new ArrayList<MemberDTO>();

for (MemberDTO member : allMembers) {
    if (keywordLower.isEmpty()
            || (member.getLoginId() != null && member.getLoginId().toLowerCase().contains(keywordLower))
            || (member.getNickname() != null && member.getNickname().toLowerCase().contains(keywordLower))
            || (member.getEmail() != null && member.getEmail().toLowerCase().contains(keywordLower))) {
        filteredMembers.add(member);
    }
}

int totalCount = filteredMembers.size();
int totalPages = Math.max(1, (int)Math.ceil(totalCount / (double)pageSize));
if (currentPage > totalPages) currentPage = totalPages;

int fromIndex = Math.min((currentPage - 1) * pageSize, totalCount);
int toIndex = Math.min(fromIndex + pageSize, totalCount);
List<MemberDTO> members = filteredMembers.subList(fromIndex, toIndex);

int blockSize = 5;
int startPage = ((currentPage - 1) / blockSize) * blockSize + 1;
int endPage = Math.min(startPage + blockSize - 1, totalPages);
String encodedKeyword = URLEncoder.encode(keyword, StandardCharsets.UTF_8);
String baseQuery = "keyword=" + encodedKeyword + "&pageSize=" + pageSize;

request.setAttribute("pageCss", "member/memberList.css");
request.setAttribute("pageTitle", "회원 관리");
request.setAttribute("activeMenu", "ADMIN");
%>

<%@ include file="/include/header.jsp"%>

<main class="member-admin">
    <div class="member-admin-heading">
        <div>
            <h1>회원 관리</h1>
            <p>회원 상태와 정지 정보를 실제 회원 데이터 기준으로 관리합니다.</p>
        </div>

        <div class="member-admin-links">
            <a href="<%=request.getContextPath()%>/board/noticeList.jsp">공지 관리</a>
            <a href="<%=request.getContextPath()%>/board/inquiryList.jsp">문의 관리</a>
        </div>
    </div>

    <%-- 처리 결과 안내 --%>
    <% if ("1".equals(request.getParameter("updated"))) { %>
        <p>회원 상태가 변경되었습니다.</p>
    <% } else if ("1".equals(request.getParameter("deleted"))) { %>
        <p>회원이 삭제되었습니다.</p>
    <% } else if (request.getParameter("error") != null) { %>
        <p>요청을 처리하지 못했습니다. 입력값과 대상 회원 상태를 확인해 주세요.</p>
    <% } %>

    <div class="member-toolbar">
        <form class="member-search" action="<%=request.getContextPath()%>/member/memberList.jsp" method="get">
            <input type="text" name="keyword" value="<%=memberListH(keyword)%>"
                   aria-label="회원 검색" placeholder="로그인 ID, 닉네임, 이메일 검색">
            <input type="hidden" name="pageSize" value="<%=pageSize%>">
            <button type="submit" class="member-btn member-btn-primary">검색</button>
            <a href="<%=request.getContextPath()%>/member/memberList.jsp" class="member-btn member-btn-reset">초기화</a>
        </form>

        <div class="member-count">
            <span><%=keyword.isEmpty() ? "전체 회원" : "검색 결과"%></span>
            <strong><%=totalCount%>명</strong>
        </div>

        <form class="member-page-size" action="<%=request.getContextPath()%>/member/memberList.jsp" method="get">
            <input type="hidden" name="keyword" value="<%=memberListH(keyword)%>">
            <label for="memberPageSize">페이지당</label>
            <select id="memberPageSize" name="pageSize" onchange="this.form.submit()">
                <option value="10" <%=pageSize == 10 ? "selected" : ""%>>10명</option>
                <option value="20" <%=pageSize == 20 ? "selected" : ""%>>20명</option>
                <option value="30" <%=pageSize == 30 ? "selected" : ""%>>30명</option>
            </select>
        </form>
    </div>

    <div class="member-table-container">
        <table class="member-table">
            <thead>
                <tr>
                    <th scope="col">ID</th>
                    <th scope="col">프로필</th>
                    <th scope="col">회원</th>
                    <th scope="col">국가</th>
                    <th scope="col">권한</th>
                    <th scope="col">상태</th>
                    <th scope="col">정지 정보</th>
                    <th scope="col">관리</th>
                </tr>
            </thead>
            <tbody>
            <% if (members.isEmpty()) { %>
                <tr><td colspan="8">조건에 맞는 회원이 없습니다.</td></tr>
            <% } else { %>
                <% for (MemberDTO member : members) {
                    boolean isMemberAdmin = "ADMIN".equals(member.getRole());
                    boolean withdrawn = "WITHDRAWN".equals(member.getStatus());
                    boolean suspended = "SUSPENDED".equals(member.getStatus());
                %>
                <tr>
                    <td class="member-number">#<%=member.getMemberId()%></td>
                    <td>
                        <span class="member-avatar">
                            <img src="<%=memberProfileSrc(request.getContextPath(), member.getProfileImage())%>" alt="프로필">
                        </span>
                    </td>
                    <td class="member-name-cell">
                        <span class="member-login"><%=memberListH(member.getLoginId())%></span>
                        <span class="member-nickname"><%=memberListH(member.getNickname())%></span>
                    </td>
                    <td><%=member.getNationality() == null || member.getNationality().trim().isEmpty() ? "-" : memberListH(member.getNationality())%></td>
                    <td>
                        <span class="member-badge <%=isMemberAdmin ? "member-role-admin" : "member-role-user"%>">
                            <%=memberListH(member.getRole())%>
                        </span>
                    </td>
                    <td>
                        <span class="member-badge <%=suspended ? "member-status-suspended" : "member-status-active"%>">
                            <%=withdrawn ? "탈퇴" : suspended ? "정지" : "활동"%>
                        </span>
                    </td>
                    <td>
                        <div class="member-suspension">
                            <span class="member-date"><%=member.getSuspendedUntil() == null ? "-" : member.getSuspendedUntil()%></span>
                            <span class="member-reason" title="<%=memberListH(member.getSuspensionReason())%>">
                                <%=member.getSuspensionReason() == null || member.getSuspensionReason().trim().isEmpty()
                                    ? "정지 사유 없음" : memberListH(member.getSuspensionReason())%>
                            </span>
                        </div>
                    </td>
                    <td>
                    <% if (isMemberAdmin) { %>
                        <span class="member-protected">관리자 계정 보호</span>
                    <% } else if (withdrawn) { %>
                        <span class="member-protected">탈퇴 처리된 회원</span>
                    <% } else { %>
                        <div class="member-actions">
                            <%-- 상태 변경 폼 --%>
                            <form action="<%=request.getContextPath()%>/member/memberStatusProcess.jsp"
                                  method="post" class="member-actions member-status-form">
                                <input type="hidden" name="memberId" value="<%=member.getMemberId()%>">
                                <input type="hidden" name="keyword" value="<%=memberListH(keyword)%>">
                                <input type="hidden" name="page" value="<%=currentPage%>">
                                <input type="hidden" name="pageSize" value="<%=pageSize%>">

                                <select name="status" aria-label="<%=memberListH(member.getNickname())%> 상태">
                                    <option value="ACTIVE" <%=suspended ? "" : "selected"%>>활동</option>
                                    <option value="SUSPENDED" <%=suspended ? "selected" : ""%>>정지</option>
                                </select>

                                <input type="date" name="suspendedUntil" aria-label="정지 종료일"
                                       value="<%=member.getSuspendedUntil() == null ? "" : member.getSuspendedUntil()%>">
                                <input type="text" name="suspensionReason" class="member-reason-input"
                                       maxlength="300" aria-label="정지 사유" placeholder="정지 사유 입력"
                                       value="<%=memberListH(member.getSuspensionReason())%>">

                                <button type="submit" class="member-btn member-btn-primary">변경</button>
                            </form>

                            <%-- 회원 삭제 폼 --%>
                            <form action="<%=request.getContextPath()%>/member/memberDeleteProcess.jsp"
                                  method="post" onsubmit="return confirm('이 회원과 관련 데이터를 삭제하시겠습니까?');">
                                <input type="hidden" name="memberId" value="<%=member.getMemberId()%>">
                                <input type="hidden" name="keyword" value="<%=memberListH(keyword)%>">
                                <input type="hidden" name="page" value="<%=currentPage%>">
                                <input type="hidden" name="pageSize" value="<%=pageSize%>">
                                <button type="submit" class="member-btn member-btn-delete">회원 삭제</button>
                            </form>
                        </div>
                    <% } %>
                    </td>
                </tr>
                <% } %>
            <% } %>
            </tbody>
        </table>
    </div>

    <nav class="member-pagination" aria-label="회원 목록 페이지 이동">
        <% if (currentPage > 1) { %>
            <span><a href="?<%=baseQuery%>&page=<%=currentPage - 1%>">← 이전</a></span>
        <% } else { %>
            <span class="is-disabled">← 이전</span>
        <% } %>

        <% for (int p = startPage; p <= endPage; p++) { %>
            <% if (p == currentPage) { %>
                <span class="is-current"><%=p%></span>
            <% } else { %>
                <span><a href="?<%=baseQuery%>&page=<%=p%>"><%=p%></a></span>
            <% } %>
        <% } %>

        <% if (currentPage < totalPages) { %>
            <span><a href="?<%=baseQuery%>&page=<%=currentPage + 1%>">다음 →</a></span>
        <% } else { %>
            <span class="is-disabled">다음 →</span>
        <% } %>
    </nav>
    <p class="member-page-summary"><%=currentPage%> / <%=totalPages%> 페이지</p>
</main>

<script>
(function () {
    /* 정지 선택 시에만 정지 종료일/사유를 필수 입력으로 처리합니다. */
    document.querySelectorAll('.member-status-form').forEach(function (form) {
        var select = form.querySelector('select[name="status"]');
        var date = form.querySelector('input[name="suspendedUntil"]');
        var reason = form.querySelector('input[name="suspensionReason"]');

        function sync() {
            var suspended = select.value === 'SUSPENDED';
            date.required = suspended;
            reason.required = suspended;
            if (!suspended) {
                date.value = '';
                reason.value = '';
            }
        }

        select.addEventListener('change', sync);
        sync();
    });
})();
</script>

<%@ include file="/include/sidebar.jsp"%>
<%@ include file="/include/footer.jsp"%>
