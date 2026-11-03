<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<%--
[allList.jsp] 전체 게시글 통합 목록/검색 화면
처리 흐름
1. 검색어, 검색 대상, 게시판 종류, 정렬 방식, 현재 페이지를 파라미터로 받습니다.
2. UnifiedBoardDAO를 이용해 공지/K-컬처/질문/기존 일반글을 한 번에 조회합니다.
3. 검색 결과 개수로 전체 페이지 수를 계산합니다.
4. 게시판 종류/검색/정렬 조건을 유지하면서 목록과 페이지네이션을 출력합니다.
--%>

<%@ page import="java.util.List"%>
<%@ page import="java.net.URLEncoder"%>
<%@ page import="dao.UnifiedBoardDAO"%>
<%@ page import="dto.UnifiedBoardDTO"%>
// 화면에 출력할 문자열의 HTML 특수문자를 치환하여 XSS 위험을 줄입니다.
<%!private String h(String value) {
		if (value == null)
			return "";
		return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;")
				.replace("'", "&#39;");
	}%>
<%
// 한글 검색어 처리를 위해 UTF-8 인코딩을 지정합니다.
request.setCharacterEncoding("UTF-8");

// 1. 검색어를 읽고 앞뒤 공백을 제거합니다.
String keyword = request.getParameter("keyword");
if (keyword == null)
	keyword = "";
keyword = keyword.trim();

// 2. 검색 대상은 전체/제목/내용/작성자 중 하나로 제한합니다.
String searchField = request.getParameter("searchField");
if (!"title".equals(searchField) && !"content".equals(searchField) && !"writer".equals(searchField)) {
	searchField = "all";
}

// 3. 게시판 필터는 공지/K-컬처/질문/기존 일반글만 허용합니다.
String boardFilter = request.getParameter("boardFilter");
if (!"NOTICE".equals(boardFilter) && !"KCULTURE".equals(boardFilter) && !"QUESTION".equals(boardFilter)
		&& !"FREE".equals(boardFilter)) {
	boardFilter = "ALL";
}

// 4. 정렬값을 검증하고 기본값은 최신순으로 설정합니다.
String sortType = request.getParameter("sortType");
if (!"likes".equals(sortType) && !"views".equals(sortType))
	sortType = "latest";

// 5. 현재 페이지를 읽고 최소 1페이지가 되도록 보정합니다.
int pageSize = 10;
int currentPage = 1;
try {
	currentPage = Integer.parseInt(request.getParameter("page"));
} catch (Exception ignored) {
}
if (currentPage < 1)
	currentPage = 1;

// 6. 통합 DAO로 검색 결과 개수와 현재 페이지 목록을 조회합니다.
UnifiedBoardDAO dao = new UnifiedBoardDAO();
int totalCount = dao.countFiltered(keyword, searchField, boardFilter);
int totalPages = Math.max(1, (int) Math.ceil(totalCount / (double) pageSize));
if (currentPage > totalPages)
	currentPage = totalPages;

List<UnifiedBoardDTO> list = dao.selectFiltered(keyword, searchField, boardFilter, sortType, currentPage, pageSize);

// 7. 5페이지 단위의 페이지 블록을 계산합니다.
int blockSize = 5;
int startPage = ((currentPage - 1) / blockSize) * blockSize + 1;
int endPage = Math.min(startPage + blockSize - 1, totalPages);

// 8. 페이지 이동 시 검색/필터/정렬 조건이 유지되도록 쿼리 문자열을 만듭니다.
String queryBase = "keyword=" + URLEncoder.encode(keyword, "UTF-8") + "&searchField=" + searchField + "&boardFilter="
		+ boardFilter + "&sortType=" + sortType;

// 9. header.jsp에서 사용할 페이지 CSS/활성 메뉴/제목을 설정합니다.
request.setAttribute("pageCss", "board/common/listCommon.css");
request.setAttribute("activeMenu", "ALL");
request.setAttribute("pageTitle", "전체 게시글");
%>
<%@include file="/include/header.jsp"%>

<main class="container">
	<h1 class="board-title">전체게시글</h1>

	<%-- ===== 검색 대상 + 게시판 필터 + 검색어 + 정렬 ===== --%>
	<form class="board-search"
		action="<%=request.getContextPath()%>/board/allList.jsp" method="get">
		<select name="searchField" class="board-sort" aria-label="검색 대상">
			<option value="all"
				<%="all".equals(searchField) ? "selected" : ""%>>전체</option>
			<option value="title"
				<%="title".equals(searchField) ? "selected" : ""%>>제목</option>
			<option value="content"
				<%="content".equals(searchField) ? "selected" : ""%>>내용</option>
			<option value="writer"
				<%="writer".equals(searchField) ? "selected" : ""%>>작성자</option>
		</select> <select name="boardFilter" class="board-sort" aria-label="게시판 필터">
			<option value="ALL"
				<%="ALL".equals(boardFilter) ? "selected" : ""%>>전체 게시판</option>
			<option value="NOTICE"
				<%="NOTICE".equals(boardFilter) ? "selected" : ""%>>공지사항</option>
			<option value="KCULTURE"
				<%="KCULTURE".equals(boardFilter) ? "selected" : ""%>>K-컬처</option>
			<option value="QUESTION"
				<%="QUESTION".equals(boardFilter) ? "selected" : ""%>>질문게시판</option>
			<option value="FREE"
				<%="FREE".equals(boardFilter) ? "selected" : ""%>>기존 일반글</option>
		</select> <input type="search" class="board-search-input"
			placeholder="검색어를 입력해 주세요" name="keyword" value="<%=h(keyword)%>">

		<select name="sortType" class="board-sort" aria-label="정렬">
			<option value="latest"
				<%="latest".equals(sortType) ? "selected" : ""%>>최신순</option>
			<option value="likes"
				<%="likes".equals(sortType) ? "selected" : ""%>>추천순</option>
			<option value="views"
				<%="views".equals(sortType) ? "selected" : ""%>>조회순</option>
		</select>
		<button type="submit" class="btn btn-primary">검색</button>
	</form>

	<%-- ===== 공지/게시글 통합 목록 ===== --%>
	<table class="board-table">
		<thead>
			<tr>
				<th class="col-num">번호</th>
				<th class="col-board">게시판</th>
				<th class="col-title">제목</th>
				<th class="col-author">작성자</th>
				<th class="col-views">조회</th>
				<th class="col-like">추천</th>
				<th class="col-dislike">비추천</th>
				<th class="col-date">작성일</th>
			</tr>
		</thead>
		<tbody>
			<%
			if (list == null || list.isEmpty()) {
			%>
			<tr>
				<td colspan="8">검색 결과가 없습니다.</td>
			</tr>
			<%
			} else {
			for (UnifiedBoardDTO item : list) {
			%>
			<tr>
				<td class="col-num"><%=item.getId()%></td>
				<td class="col-board"><span class="board-table-badge"><%=h(item.getBoardName())%></span></td>
				<td class="col-title"><a
					href="<%=request.getContextPath() + item.getViewUrl()%>"><%=h(item.getTitle())%></a>
				</td>
				<td class="col-author"><%=h(item.getWriterNickname())%></td>
				<td class="col-views"><%=item.getViewCount()%></td>
				<td class="col-like"><%=item.getLikeCount()%></td>
				<td class="col-dislike"><%=item.getDislikeCount()%></td>
				<td class="col-date"><%=item.getCreatedAt() == null ? "-" : item.getCreatedAt().toString().substring(0, 10)%></td>
			</tr>
			<%
			}
			}
			%>
		</tbody>
	</table>

	<%-- ===== 검색 조건을 유지하는 페이지네이션 ===== --%>
	<nav class="pagination" aria-label="페이지 이동">
		<a
			href="<%=currentPage > 1 ? ("?" + queryBase + "&page=" + (currentPage - 1)) : "#"%>"
			class="page-move <%=currentPage > 1 ? "" : "is-disabled"%>">← 이전</a>
		<div class="page-numbers">
			<%
			for (int p = startPage; p <= endPage; p++) {
			%>
			<a href="?<%=queryBase%>&page=<%=p%>"
				class="page <%=p == currentPage ? "is-active" : ""%>"><%=p%></a>
			<%
			}
			%>
		</div>
		<a
			href="<%=currentPage < totalPages ? ("?" + queryBase + "&page=" + (currentPage + 1)) : "#"%>"
			class="page-move <%=currentPage < totalPages ? "" : "is-disabled"%>">다음
			→</a>
	</nav>
</main>

<%@include file="/include/sidebar.jsp"%>
<%@include file="/include/footer.jsp"%>
