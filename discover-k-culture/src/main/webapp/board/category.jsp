<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<%--
[category.jsp] K-컬처 카테고리별 게시글 목록
처리 흐름
1. categoryId 파라미터를 읽어 선택한 카테고리를 확인합니다.
2. DB에서 활성 카테고리 목록을 조회합니다.
3. 존재하지 않는 categoryId면 전체 목록으로 되돌립니다.
4. 선택한 카테고리에 맞는 KCULTURE 게시글을 조회합니다.
5. 카테고리 칩과 게시글 목록을 출력하며 카테고리 이름에 맞는 아이콘을 표시합니다.
--%>

<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.List"%>
<%@ page import="dao.CategoryDAO"%>
<%@ page import="dao.PostDAO"%>
<%@ page import="dto.CategoryDTO"%>
<%@ page import="dto.PostDTO"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%-- Category icons: Twemoji graphics (CC-BY 4.0), Copyright Twitter, Inc. and other contributors. https://github.com/twitter/twemoji --%>

<%
// 한글 요청 파라미터 처리를 위해 UTF-8 인코딩을 지정합니다.
request.setCharacterEncoding("UTF-8");

// 1. URL의 categoryId를 읽어 선택한 카테고리를 결정합니다.
Integer selectedCategoryId = null;
String categoryIdParam = request.getParameter("categoryId");

if (categoryIdParam != null && !categoryIdParam.trim().isEmpty()) {
	try {
		int parsedCategoryId = Integer.parseInt(categoryIdParam.trim());
		if (parsedCategoryId > 0) {
	selectedCategoryId = Integer.valueOf(parsedCategoryId);
		}
	} catch (NumberFormatException ignored) {
		selectedCategoryId = null;
	}
}
 
// 2. 화면에 출력할 카테고리 목록/게시글 목록을 준비합니다.
List<CategoryDTO> categoryList = new ArrayList<CategoryDTO>();
List<PostDTO> postList = new ArrayList<PostDTO>();
String loadError = null;

try {
	// 3. 카테고리 목록을 DB에서 조회합니다.
	CategoryDAO categoryDAO = new CategoryDAO();
	categoryList = categoryDAO.selectAll();

	// 존재하지 않는 categoryId가 들어오면 전체 목록으로 처리합니다.
	if (selectedCategoryId != null) {
		boolean categoryExists = false;

		for (CategoryDTO category : categoryList) {
	if (category.getCategoryId() == selectedCategoryId.intValue()) {
		categoryExists = true;
		break;
	}
		}

		if (!categoryExists) {
	selectedCategoryId = null;
		}
	}

	// 4. 선택된 카테고리에 해당하는 K-컬처 게시글을 최신순으로 조회합니다.
	PostDAO postDAO = new PostDAO();
	postList = postDAO.searchBoard("KCULTURE", selectedCategoryId, "", "latest");

} catch (Exception e) {
	loadError = "게시글을 불러오는 중 오류가 발생했습니다.";
	application.log("category.jsp 목록 조회 오류", e);
}

// 5. JSTL에서 사용할 데이터를 request 영역에 저장합니다.
request.setAttribute("categoryList", categoryList);
request.setAttribute("postList", postList);
request.setAttribute("selectedCategoryId", selectedCategoryId);
request.setAttribute("loadError", loadError);
%>

<!-- css 세팅 -->
<%
// 6. category.jsp 전용 CSS를 header.jsp가 불러오도록 설정합니다.
request.setAttribute("pageCss", "board/category.css");
%>

<% request.setAttribute("boardTranslationLayout", Boolean.TRUE); %>
<%@include file="/include/header.jsp"%>


<div class="container board-translation-layout">
	<h1 class="page-title">Discover K-Culture</h1>

	<%-- ===== 카테고리 필터 버튼 ===== --%>
	<div class="chips">
		<a class="chip" href="${ctx}/board/category.jsp">전체</a>

		<c:forEach var="category" items="${categoryList}">
			<a class="chip"
				href="${ctx}/board/category.jsp?categoryId=${category.categoryId}"><c:out
					value="${category.name}" /></a>
		</c:forEach>
	</div>

	<%-- ===== 게시글 목록 ===== --%>
	<div class="post-list">
		<c:if test="${not empty loadError}">
			<div class="post-item">
				<span class="post-emoji"><img
					src="${ctx}/resources/img/category/warning.png" width="30"
					height="30" alt="오류"></span>
				<div class="post-body">
					<p class="post-title">
						<c:out value="${loadError}" />
					</p>
				</div>
			</div>
		</c:if>

		<c:if test="${empty loadError and empty postList}">
			<div class="post-item">
				<span class="post-emoji"><img
					src="${ctx}/resources/img/category/empty.png" width="30"
					height="30" alt="게시글 없음"></span>
				<div class="post-body">
					<p class="post-title">등록된 게시글이 없습니다.</p>
				</div>
			</div>
		</c:if>

		<%-- 각 게시글의 카테고리명에 따라 다른 아이콘을 선택합니다. --%>
		<c:forEach var="post" items="${postList}">
			<c:set var="categoryNameLower"
				value="${fn:toLowerCase(post.categoryName)}" />

			<div class="post-item">
				<span class="post-emoji"> <c:choose>
						<c:when test="${fn:contains(categoryNameLower, 'food')}">
							<img src="${ctx}/resources/img/category/k-food.png" width="30"
								height="30" alt="K-Food">
						</c:when>
						<c:when test="${fn:contains(categoryNameLower, 'pop')}">
							<img src="${ctx}/resources/img/category/k-pop.png" width="30"
								height="30" alt="K-Pop">
						</c:when>
						<c:when test="${fn:contains(categoryNameLower, 'drama')}">
							<img src="${ctx}/resources/img/category/k-drama.png" width="30"
								height="30" alt="K-Drama">
						</c:when>
						<c:when test="${fn:contains(categoryNameLower, 'beauty')}">
							<img src="${ctx}/resources/img/category/k-beauty.png" width="30"
								height="30" alt="K-Beauty">
						</c:when>
						<c:when test="${fn:contains(categoryNameLower, 'travel')}">
							<img src="${ctx}/resources/img/category/travel.png" width="30"
								height="30" alt="Travel">
						</c:when>
						<c:when test="${fn:contains(categoryNameLower, 'culture')}">
							<img src="${ctx}/resources/img/category/culture.png" width="30"
								height="30" alt="Culture">
						</c:when>
						<c:otherwise>
							<img src="${ctx}/resources/img/category/default.png" width="30"
								height="30" alt="기타">
						</c:otherwise>
					</c:choose>
				</span>

				<div class="post-body">
					<a class="post-title"
						href="${ctx}/board/category-view.jsp?postId=${post.postId}"><c:out
							value="${post.title}" /></a>

					<p class="post-meta">
						<c:out value="${post.memberNickname}" />
						·
						<c:out value="${post.categoryName}" />
						·
						<fmt:formatDate value="${post.createdAt}"
							pattern="yyyy-MM-dd HH:mm" />
					</p>
				</div>
			</div>
		</c:forEach>
	</div>
</div>

<%@ include file="/include/sidebar.jsp"%>
<%@include file="/include/footer.jsp"%>
