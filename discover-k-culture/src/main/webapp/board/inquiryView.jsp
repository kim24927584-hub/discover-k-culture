<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<% request.setAttribute("pageCss", "board/common/viewCommon.css"); %>

<%@include file="/include/header.jsp" %>
  <main class="container">
    <h1 class="post-title"><span>[1:1문의]</span> 정지 사유가 뭔가요?</h1>
    <p class="post-meta">2028-10-10 14:20</p>
    
    <div class="post-body">
	    
	    <p class="post-content">안녕하세요.

		오늘 로그인하려고 했더니 계정이 7일간 정지되었다는 메시지가 떴습니다. 사전에 경고를 받은 적이 없어서 무엇이 문제였는지 잘 모르겠습니다.
		
		저는 주로 자유게시판에 한국 음식이나 서울 카페에 관한 글을 올리고 있습니다. 지난주에 맛집 후기를 정리한 개인 블로그 링크를 몇 번 공유했는데, 혹시 그게 이유일까요?
		
		제가 규칙을 어긴 거라면 죄송합니다. 앞으로 주의할 수 있도록 어떤 게시글이 문제였는지 알려주시면 좋겠습니다. 정지 기간을 줄여 주실 수 있는 방법이 있을까요?
		
		감사합니다.</p>
	   
    </div>
    <div class="post-body answer">
	    <i class="fa-solid fa-screwdriver-wrench fa-sm"></i>
	    <span class="post-meta">운영자의 답변 · 2026-11-03</span> 
	    <p class="post-content answer">
			안녕하세요, travel_mina 님.
			
			문의 주셔서 감사드리며, 불편을 드려 죄송합니다.
			
			회원님의 계정을 확인한 결과, 10월 27일부터 29일 사이에 외부 블로그 링크가 포함된 게시글 5건이 짧은 기간에 자유게시판에 작성되었습니다. 이 활동이 **커뮤니티 운영정책 제4조(광고 및 스팸)**에 해당하는 홍보성 활동으로 감지되어 계정이 자동으로 7일 정지되었습니다.
			
			의도하신 것이 아니라는 점은 충분히 이해합니다. 게시글에 실제 후기 내용이 포함되어 있었던 점을 고려해 정지 기간을 3일로 단축해 드렸습니다. 2026년 11월 5일부터 계정을 다시 이용하실 수 있습니다.
			
			앞으로는 아래 내용을 참고해 주세요.
			
			외부 링크만 올리기보다 본문에 주요 내용을 함께 작성해 주세요.
			짧은 시간 안에 링크가 포함된 글을 여러 개 올리는 것은 피해 주세요.
			
			앞으로도 한국에서의 경험을 즐겁게 나눠 주시길 바랍니다.
			
			감사합니다.
			Discover K-Culture 운영팀
		</p>
	   
    </div>
    <a href="inquiryList.jsp" class="btn btn-primary btn-list"><span class="btn-arrow">←</span>목록</a>
    
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