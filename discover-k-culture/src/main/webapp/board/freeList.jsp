<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<% request.setAttribute("pageCss", "board/freeList.css"); %>

<%@include file="/include/header.jsp" %>
  
<main class="container">
  <h1 class="board-title">자유게시판</h1>

<form class="board-search" action="freeList.jsp" method="get">
	<input type="search" class="board-search-input" placeholder="제목, 내용, 작성자 검색" name="keyword">
	<select name="sortType" class="board-sort">
		<option value="latest" selected>최신순</option>
		<option value="likes">추천순</option>
		<option value="views">조회순</option>
	</select>
	<button type="submit" class="btn btn-primary">검색</button>
</form>
	
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
      <tr>
        <td class="col-num">3</td>
        <td class="col-board">
        	<span class="board-badge">공지</span>
        </td>
        <td class="col-title"><a href="freeView.jsp">엽기떡볶이 후기sssssssssssssssssssssssssssssssssss</a></td>
        <td class="col-author">민지</td>
        <td class="col-views">120</td>
        <td class="col-like">1</td>
        <td class="col-dislike">2</td>
        <td class="col-date">2026-10-24</td>  
      </tr>
      <tr>
        <td class="col-num">3</td>
        <td class="col-board">
        	<span class="board-badge">공지</span>
        </td>
        <td class="col-title"><a href="freeView.jsp">엽기떡볶이 후기</a></td>
        <td class="col-author">민지</td>
        <td class="col-views">120</td>
        <td class="col-like">1</td>
        <td class="col-dislike">2</td>
        <td class="col-date">2026-10-24</td>  
      </tr>
      
      
      
    </tbody>
  </table>

  <nav class="pagination" aria-label="페이지 이동">
    <a href="" class="page-move is-disabled">← 이전</a>
    <div class="page-numbers">
      <a href="#" class="page is-active">1</a>
      <a href="#" class="page">2</a>
      <a href="#" class="page">3</a>
    </div>
    <a href="#" class="page-move">다음 →</a>

  </nav>
</main>

<%@include file="/include/sidebar.jsp" %>
<%@include file="/include/footer.jsp" %>

