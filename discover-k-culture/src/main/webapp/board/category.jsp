<%@ page
    language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!-- css 세팅 -->
<% request.setAttribute("pageCss", "category.css"); %>

<%@include file="/include/header.jsp" %>


  <div class="container">
    <h1 class="page-title">Discover K-Culture</h1>
    <div class="chips">
      <div class="chip">K-food</div>
      <div class="chip">K-pop</div>
      <div class="chip">K-pop</div>
      <div class="chip">K-pop</div>

    </div>
    <div class="post-list">
      <div class="post-item">
        <span class="post-emoji">🍜</span>
        <div class="post-body">
          <a class="post-title" href="category-view.jsp">엽기떡볶이</a>
          <p class="post-meta">이름 · 카테고리 이름 · 2028-10-10 14:20</p>
        </div>
      </div>
      <div class="post-item">
        <span class="post-emoji">🍜</span>
        <div class="post-body">
          <a class="post-title">엽기떡볶이</a>
          <p class="post-meta">이름 · 카테고리 이름 · 2028-10-10 14:20</p>
        </div>
      </div>
      <div class="post-item">
        <span class="post-emoji">🍜</span>
        <div class="post-body">
          <a class="post-title">엽기떡볶이</a>
          <p class="post-meta">이름 · 카테고리 이름 · 2028-10-10 14:20</p>
        </div>
      </div>
    </div>  
  </div>
<%@ include file="/include/sidebar.jsp"%>
<%@include file="/include/footer.jsp"%>