<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<% request.setAttribute("pageCss", "board/common/viewCommon.css"); %>

<%@include file="/include/header.jsp" %>
  <main class="container">
    <h1 class="post-title"><span>[k-food]</span> 엽떡 처음 먹어보는데</h1>
    <p class="post-meta">작성자 <span class="post-writer">unknowun</span> · 조회 3 · 2028-10-10 14:20</p>
    
    <div class="post-body">
    
    	<!-- 비디오가 있는 경우 -->
	    <%-- <video src="${ctx}/resources/video/redred.mp4" controls poster="../resources/img/intro-thumb.png">
	  	이 브라우저는 video 태그를 지원하지 않습니다.
		</video> --%>
		
		<!-- 이미지가 있는 경우 -->
		<img src="${ctx }/resources/img/food1.png">
		
	    <p class="post-content">너무 매워요 ㅠ</p>
	    <div class="post-actions">
		    <div class="like-box">
			    <button type="button" class="action-btn post-reaction post-like active">
				  <i class="fa-regular fa-thumbs-up fa-lg "></i>			  	     
			      <span class="like-count">1</span>
			    </button>
			    <button type="button" class="action-btn post-reaction post-dislike">
			      <i class="fa-regular fa-thumbs-down fa-lg"></i>
			      <span class="like-count">1</span>
			    </button>
		    </div>
		   	<button type="button" class="action-btn post-bookmark">
			      <i class="fa-regular fa-star icon-off"></i>
			      
			      <i class="fa-solid fa-star icon-on" style="color: rgb(255, 212, 59);"></i>
			      <span class="bookmark-text">북마크</span>
			</button>
			
		</div>
    </div>
    <a href="category.jsp" class="btn btn-primary btn-list"><span class="btn-arrow">←</span>목록</a>
    <h2 class="comments-title">Comments <span class="comment-count">(1)</span></h2>
    
   	<form class="comment-write" method="post" action="commentProcess.jsp">
   		<input type="text" name="commentContent" class="comment-write-input"
   		placeholder="댓글을 입력하세요" aria-label="댓글입력">
   		<button type="submit" class="btn comment-button">댓글 작성</button>
   	</form>
    
    <div class="comments">
      <div class="comment">
        <div class="comment-body">
          <span class="comment-name">unknown</span>
          <span class="comment-meta">2028-10-10 14:20</span>
          <p class="comment-text">아 정말요?</p>
        </div>
        <button  type="button" class="comment-like">
          <span class="thumb-up">
          	<i class="fa-regular fa-thumbs-up fa-lg"></i>
          </span>
          <span class="like-count">100</span>
        </button>
        
      </div>
      <div class="comment">
        <div class="comment-body">
          <span class="comment-name">unknown</span>
          <span class="comment-meta">2028-10-10 14:20</span>
          <p class="comment-text">아 정말요?</p>
        </div>
        <div class="comment-like active">
          <span class="thumb-up">
          	<i class="fa-regular fa-thumbs-up fa-lg"></i>
          </span>
          <span class="like-count">1</span>
        </div>
        
      </div>

	 </div>
  </main>
<script type="text/javascript">
	/* 북마크 버튼 토글 */
	const bookmarkBtn = document.querySelector(".post-bookmark");
	bookmarkBtn.addEventListener("click", function(){
		bookmarkBtn.classList.toggle("active");
	})
	
	/* 게시글 좋아요 버튼 토글 */
	const postLikeBtns = document.querySelectorAll(".post-reaction");
	postLikeBtns.forEach(function(btn){
		btn.addEventListener("click", function(){
			const isActive = btn.classList.contains("active");
			postLikeBtns.forEach(function(each_btn){
				each_btn.classList.remove("active");
			});
			if(!isActive){
				btn.classList.add("active");
			}
			
		})
	})
	
	/* 댓글 좋아요 토글 */
	const commentLikeBtns = document.querySelectorAll(".comment-like");
	commentLikeBtns.forEach(function(btn){
		btn.addEventListener("click", function(){
			const isActive = btn.classList.contains("active");
			btn.classList.remove("active");
			if(!isActive){
				btn.classList.add("active");
			}
			
		})
	})
</script>
<%@include file="/include/sidebar.jsp" %>
<%@include file="/include/footer.jsp" %>