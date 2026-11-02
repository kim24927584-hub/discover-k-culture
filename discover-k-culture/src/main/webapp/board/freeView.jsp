<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<% request.setAttribute("pageCss", "board/freeView.css"); %>

<%@include file="/include/header.jsp" %>
  <main class="container">
    <h1 class="post-title"><span>[k-food]</span> 코르티스 신곡 나왔다</h1>
    <span class="post-meta">작성자 <span class="post-meta writer">unknowun</span> · 조회 3 · 2028-10-10 14:20</span>
    
    <div class="post-body">
	    <video src="../resources/video/redred.mp4" controls poster="../resources/img/intro-thumb.png" width="640">
	  	이 브라우저는 video 태그를 지원하지 않습니다.
		</video>
	    <p class="post-content">진짜 좋은데?</p>
	    <div class="like-box">
		    <div class="post-like active">
			  <i class="fa-regular fa-thumbs-up fa-lg "></i>			  	     
		      <span class="like-count">1</span>
		    </div>
		    <div class="post-like">
		      <i class="fa-regular fa-thumbs-down fa-lg"></i>
		      <span class="like-count">1</span>
		    </div>
	    </div>
    </div>
    <a href="category.html" class="btn"><span class="btn-arrow">←</span>목록</a>
    <h3 class="comments-title">Comments <span class="comment-count">(1)</span></h3>
    <div class="comments">
      <div class="comment">
        <div class="comment-body">
          <span class="comment-name">unknown</span>
          <span class="comment-meta">2028-10-10 14:20</span>
          <p class="comment-text">아 정말요?</p>
        </div>
        <div class="comment-like">
          <span class="thumb-up">👍</span>
          <span class="like-count">1</span>
        </div>
        
      </div>
      <div class="comment">
        <div class="comment-body">
          <span class="comment-name">unknown</span>
          <span class="comment-meta">2028-10-10 14:20</span>
          <p class="comment-text">아 정말요?</p>
        </div>
        <div class="comment-like active">
          <span class="thumb-up">👍</span>
          <span class="like-count">1</span>
        </div>
        
      </div>

	 </div>
  </main>

<%@include file="/include/sidebar.jsp" %>
<%@include file="/include/footer.jsp" %>