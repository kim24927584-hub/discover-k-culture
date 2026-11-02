<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<% request.setAttribute("pageCss", "board/common/listCommon.css"); %>

<%@include file="/include/header.jsp" %>
  
<main class="container">
  <h1 class="board-title">공지사항</h1>


	
  <table class="board-table">
    <thead>
      <tr>
        <th class="col-num">번호</th>
        <th class="col-title">제목</th>
        <th class="col-author">작성자</th>
        <th class="col-views">조회</th>
        <th class="col-date">작성일</th>
        
        
      </tr>
    </thead>
    <tbody>
      <tr>
        <td class="col-num">3</td>
        <td class="col-title"><a href="noticeView.jsp">1.2패치사항</a></td>
        <td class="col-author">관리자</td>
        <td class="col-views">120</td>
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

