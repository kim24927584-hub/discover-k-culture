<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%--
[qnaList.jsp] 질문게시판 목록/검색 화면
처리 흐름
1. 검색어, 검색 대상, 정렬 방식, 현재 페이지를 파라미터로 받습니다.
2. 허용하지 않은 검색/정렬 값은 기본값으로 보정합니다.
3. QUESTION 게시글의 전체 검색 결과 수와 현재 페이지 목록을 조회합니다.
4. 검색 조건을 유지한 채 목록과 페이지네이션을 출력합니다.
--%>

<%@ page import="java.util.List"%>
<%@ page import="java.net.URLEncoder"%>
<%@ page import="dao.PostDAO"%>
<%@ page import="dto.PostDTO"%>
<%!
// 화면에 출력할 문자열의 HTML 특수문자를 치환하여 XSS 위험을 줄입니다.
private String h(String value) {
    if (value == null) return "";
    return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
            .replace("\"", "&quot;").replace("'", "&#39;");
}
%>
<%
// 한글 검색어 처리를 위해 UTF-8 인코딩을 사용합니다.
request.setCharacterEncoding("UTF-8");
// 1. 검색어를 읽고 null이면 빈 문자열로 처리합니다.
String keyword = request.getParameter("keyword");
if (keyword == null) keyword = "";
keyword = keyword.trim();

// 2. 검색 대상은 전체/제목/내용/작성자만 허용합니다.
String searchField = request.getParameter("searchField");
if (!"title".equals(searchField) && !"content".equals(searchField) && !"writer".equals(searchField)) {
    searchField = "all";
}

// 3. 정렬값은 최신순/추천순/조회순만 허용합니다.
String sort = request.getParameter("sort");
if (!"likes".equals(sort) && !"views".equals(sort)) sort = "latest";

// 4. 현재 페이지 번호를 읽고 최소 1페이지가 되도록 보정합니다.
int pageSize = 10;
int currentPage = 1;
try { currentPage = Integer.parseInt(request.getParameter("page")); } catch (Exception ignored) {}
if (currentPage < 1) currentPage = 1;

// 5. 검색 결과 전체 개수와 현재 페이지의 질문 게시글을 조회합니다.
PostDAO postDAO = new PostDAO();
int totalCount = postDAO.countSearchBoard("QUESTION", null, keyword, searchField);
int totalPages = Math.max(1, (int)Math.ceil(totalCount / (double)pageSize));
if (currentPage > totalPages) currentPage = totalPages;
List<PostDTO> posts = postDAO.searchBoardPaged("QUESTION", null, keyword, searchField, sort, currentPage, pageSize);

// 6. 페이지 번호를 5개씩 묶고 검색 조건을 queryBase에 유지합니다.
int blockSize = 5;
int startPage = ((currentPage - 1) / blockSize) * blockSize + 1;
int endPage = Math.min(startPage + blockSize - 1, totalPages);
String queryBase = "keyword=" + URLEncoder.encode(keyword, "UTF-8") + "&searchField=" + searchField + "&sort=" + sort;

// 7. header.jsp에서 사용할 메뉴/CSS/제목 정보를 설정합니다.
request.setAttribute("activeMenu", "QUESTION");
request.setAttribute("pageTitle", "질문게시판");
request.setAttribute("pageCss", "board/common/listCommon.css");
%>
<%@include file="/include/header.jsp"%>

<main class="container">
  <h1 class="board-title">질문게시판</h1>

  <%-- ===== 검색/정렬 영역 ===== --%>
  <form class="board-search" action="<%=request.getContextPath()%>/board/qnaList.jsp" method="get">
    <select name="searchField" class="board-sort" aria-label="검색 대상">
      <option value="all" <%= "all".equals(searchField) ? "selected" : "" %>>전체</option>
      <option value="title" <%= "title".equals(searchField) ? "selected" : "" %>>제목</option>
      <option value="content" <%= "content".equals(searchField) ? "selected" : "" %>>내용</option>
      <option value="writer" <%= "writer".equals(searchField) ? "selected" : "" %>>작성자</option>
    </select>
    <input type="search" class="board-search-input" name="keyword" value="<%=h(keyword)%>" placeholder="검색어를 입력해 주세요">
    <select name="sort" class="board-sort">
      <option value="latest" <%= "latest".equals(sort) ? "selected" : "" %>>최신순</option>
      <option value="likes" <%= "likes".equals(sort) ? "selected" : "" %>>추천순</option>
      <option value="views" <%= "views".equals(sort) ? "selected" : "" %>>조회순</option>
    </select>
    <button type="submit" class="btn btn-primary">검색</button>
  </form>

  <%-- ===== 질문게시판 목록 ===== --%>
  <table class="board-table">
    <thead><tr>
      <th class="col-num">번호</th><th class="col-title">제목</th><th class="col-author">작성자</th>
      <th class="col-date">등록일</th><th class="col-views">조회</th><th class="col-like">추천</th>
    </tr></thead>
    <tbody>
    <% if (posts == null || posts.isEmpty()) { %>
      <tr><td colspan="6">등록된 게시글이 없습니다.</td></tr>
    <% } else { for (PostDTO post : posts) { %>
      <tr>
        <td class="col-num"><%=post.getPostId()%></td>
        <td class="col-title"><a href="<%=request.getContextPath()%>/board/qnaView.jsp?id=<%=post.getPostId()%>"><%=h(post.getTitle())%></a></td>
        <td class="col-author"><%=h(post.getMemberNickname())%></td>
        <td class="col-date"><%=post.getCreatedAt() == null ? "-" : post.getCreatedAt().toString().substring(0,10)%></td>
        <td class="col-views"><%=post.getViewCount()%></td>
        <td class="col-like"><%=post.getLikeCount()%></td>
      </tr>
    <% } } %>
    </tbody>
  </table>

  <%-- ===== 검색 조건을 유지하는 페이지네이션 ===== --%>
  <nav class="pagination" aria-label="페이지 이동">
    <a href="<%=currentPage > 1 ? ("?" + queryBase + "&page=" + (currentPage - 1)) : "#"%>" class="page-move <%=currentPage > 1 ? "" : "is-disabled"%>">← 이전</a>
    <div class="page-numbers">
      <% for (int p = startPage; p <= endPage; p++) { %>
        <a href="?<%=queryBase%>&page=<%=p%>" class="page <%=p == currentPage ? "is-active" : ""%>"><%=p%></a>
      <% } %>
    </div>
    <a href="<%=currentPage < totalPages ? ("?" + queryBase + "&page=" + (currentPage + 1)) : "#"%>" class="page-move <%=currentPage < totalPages ? "" : "is-disabled"%>">다음 →</a>
  </nav>
</main>

<%@include file="/include/sidebar.jsp"%>
<%@include file="/include/footer.jsp"%>
