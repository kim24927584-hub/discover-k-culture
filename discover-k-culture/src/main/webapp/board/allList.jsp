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
<%!
/* 번역 엔진은 select/option/input을 제외하므로 검색 UI 문구는 서버에서 다국어로 출력합니다. */
private String boardUiLabel(String lang, String ko, String en, String ja, String zh) {
    if ("en".equals(lang)) return en;
    if ("ja".equals(lang)) return ja;
    if ("zh".equals(lang)) return zh;
    return ko;
}
private String h(String value) {
		if (value == null)
			return "";
		return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;")
				.replace("'", "&#39;");
	}%>
<%
// 세션의 표시 언어와 일치하는 검색창/표 머리글을 서버에서 렌더링합니다.
String boardUiLanguage = (String) session.getAttribute("siteLanguage");
if (!"en".equals(boardUiLanguage) && !"ja".equals(boardUiLanguage)
        && !"zh".equals(boardUiLanguage)) boardUiLanguage = "ko";

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
<% request.setAttribute("boardTranslationLayout", Boolean.TRUE); %>
<%@include file="/include/header.jsp"%>

<main class="container board-translation-layout board-all-list">
	<h1 class="board-title">전체게시글</h1>

	<%-- ===== 검색 대상 + 게시판 필터 + 검색어 + 정렬 ===== --%>
	<form class="board-search" action="<%=request.getContextPath()%>/board/allList.jsp" method="get">
		<select name="searchField" class="board-sort" aria-label="<%=boardUiLabel(boardUiLanguage, "검색 대상", "Search field", "検索対象", "搜索范围")%>" data-deepl-ignore>
			<option value="all" <%="all".equals(searchField) ? "selected" : ""%>><%=boardUiLabel(boardUiLanguage, "전체", "All", "すべて", "全部")%></option>
			<option value="title" <%="title".equals(searchField) ? "selected" : ""%>><%=boardUiLabel(boardUiLanguage, "제목", "Title", "タイトル", "标题")%></option>
			<option value="content" <%="content".equals(searchField) ? "selected" : ""%>><%=boardUiLabel(boardUiLanguage, "내용", "Content", "内容", "内容")%></option>
			<option value="writer" <%="writer".equals(searchField) ? "selected" : ""%>><%=boardUiLabel(boardUiLanguage, "작성자", "Author", "投稿者", "作者")%></option>
		</select>
		<select name="boardFilter" class="board-sort" aria-label="<%=boardUiLabel(boardUiLanguage, "게시판 필터", "Board filter", "掲示板フィルター", "版块筛选")%>" data-deepl-ignore>
			<option value="ALL" <%="ALL".equals(boardFilter) ? "selected" : ""%>><%=boardUiLabel(boardUiLanguage, "전체 게시판", "All Boards", "すべての掲示板", "所有版块")%></option>
			<option value="NOTICE" <%="NOTICE".equals(boardFilter) ? "selected" : ""%>><%=boardUiLabel(boardUiLanguage, "공지사항", "Notices", "お知らせ", "公告")%></option>
			<option value="KCULTURE" <%="KCULTURE".equals(boardFilter) ? "selected" : ""%>><%=boardUiLabel(boardUiLanguage, "K-컬처", "K-Culture", "K-カルチャー", "K-Culture")%></option>
			<option value="QUESTION" <%="QUESTION".equals(boardFilter) ? "selected" : ""%>><%=boardUiLabel(boardUiLanguage, "질문게시판", "Questions", "質問掲示板", "问答")%></option>
			<option value="FREE" <%="FREE".equals(boardFilter) ? "selected" : ""%>><%=boardUiLabel(boardUiLanguage, "기존 일반글", "General", "自由掲示板", "自由讨论")%></option>
		</select>
		<input type="search" class="board-search-input" name="keyword"
			placeholder="<%=boardUiLabel(boardUiLanguage, "검색어를 입력해 주세요", "Search posts...", "キーワードを入力", "请输入关键词")%>" value="<%=h(keyword)%>" data-deepl-ignore>
		<select name="sortType" class="board-sort" aria-label="<%=boardUiLabel(boardUiLanguage, "정렬", "Sort", "並び替え", "排序")%>" data-deepl-ignore>
			<option value="latest" <%="latest".equals(sortType) ? "selected" : ""%>><%=boardUiLabel(boardUiLanguage, "최신순", "Newest", "新着順", "最新")%></option>
			<option value="likes" <%="likes".equals(sortType) ? "selected" : ""%>><%=boardUiLabel(boardUiLanguage, "추천순", "Most Liked", "いいね順", "点赞数")%></option>
			<option value="views" <%="views".equals(sortType) ? "selected" : ""%>><%=boardUiLabel(boardUiLanguage, "조회순", "Most Viewed", "閲覧順", "浏览数")%></option>
		</select>
		<button type="submit" class="btn btn-primary" data-deepl-ignore><%=boardUiLabel(boardUiLanguage, "검색", "Search", "検索", "搜索")%></button>
	</form>

	<%-- ===== 공지/게시글 통합 목록 ===== --%>
	<div class="board-table-scroll" role="region" aria-label="게시글 목록 (가로 스크롤 가능)" tabindex="0">
    <table class="board-table">
        <colgroup>
            <col class="col-num">
            <col class="col-board">
            <col class="col-title">
            <col class="col-author">
            <col class="col-views">
            <col class="col-like">
            <col class="col-dislike">
            <col class="col-date">
        </colgroup>
        <thead>
            <tr>
                <th class="col-num" data-deepl-ignore><%=boardUiLabel(boardUiLanguage, "번호", "No.", "番号", "编号")%></th>
                <th class="col-board" data-deepl-ignore><%=boardUiLabel(boardUiLanguage, "게시판", "Board", "掲示板", "版块")%></th>
                <th class="col-title" data-deepl-ignore><%=boardUiLabel(boardUiLanguage, "제목", "Title", "タイトル", "标题")%></th>
                <th class="col-author" data-deepl-ignore><%=boardUiLabel(boardUiLanguage, "작성자", "Author", "投稿者", "作者")%></th>
                <th class="col-views" data-deepl-ignore><%=boardUiLabel(boardUiLanguage, "조회", "Views", "閲覧数", "浏览")%></th>
                <th class="col-like" data-deepl-ignore><%=boardUiLabel(boardUiLanguage, "추천", "Likes", "いいね", "点赞")%></th>
                <th class="col-dislike" data-deepl-ignore><%=boardUiLabel(boardUiLanguage, "비추천", "Dislikes", "低評価", "点踩")%></th>
                <th class="col-date" data-deepl-ignore><%=boardUiLabel(boardUiLanguage, "작성일", "Date", "投稿日", "日期")%></th>
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
</div>

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
