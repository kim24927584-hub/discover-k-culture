
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<link rel="stylesheet" href="../resources/css/common.css">
<link rel="stylesheet" href="../resources/css/mypage.css">
</head>
<body>
<main class="container">
<h1>마이페이지</h1>
<!-- 프로필 -->
<section class="mypage-profile">
	<img class="mypage-avatar" src="../resources/img/profile.jpg">
	<div class="mypage-info">
		<h2 class="mypage-name">LOSA</h2>
		<ul class="mypage-meta">
			<li>아이디: test</li>
			<li>이메일: test@naver.com</li>
			<li>국적: USA</li>
			<li>언어: 영여</li>
			<li>상태: 활동</li>
		
		</ul>
		<a href="profileFix.jsp" class="btn btn-primary">정보수정</a>
		
		<hr>
		
		<h2>프로필 사진 변경</h2>
		<form class="mypage-upload" action="avatarUpdateProcess.jsp" method="post" enctype="multipart/form-data">
          
          <input type="file" name="imageFile" class="form-input" accept="image/*" required>
          <p class="form-hint">jpg, png 등 · 최대 5MB · 파일을 선택하면 저장 전에도 위 프로필 사진에서 바로 미리 볼 수 있습니다.</p>
          <button type="submit" class="btn btn-primary">프로필 사진 저장</button>  
        </form>
	</div>
</section>
	<!-- 탭버튼 -->
	<div class="tabs">
		<button class="tab-btn is-active" data-tab="my-posts">
			<span>내 게시글</span>
			<strong class="tab-count">5</strong>
		</button>
		<button class="tab-btn" data-tab="bookmarks">
			<span>북마크</span>
			<strong class="tab-count">5</strong>
			
		</button>
		<button class="tab-btn" data-tab="likes">
			<span>내가 추천한 게시글</span>
			<strong class="tab-count">5</strong>
		</button>
	</div>
	<!-- 탭 패널 -->
	<section class="tab-panel" id="my-posts">
		<ul class="board-list">
			<li class="board-item">
				<span class="board-category">K-컬쳐</span>
				<div class="board-body">
					<a class="board-title" href="#">한국에서 꼭 먹어봐야 할 음식 5가지</a>
					<p class="board-meta">2026.01.01 조회 118 추천12 댓글0</p>
				</div>
			</li>
			<li class="board-item">
				<span class="board-category">K-컬쳐</span>
				<div class="board-body">
					<a class="board-title" href="#">한국에서 꼭 먹어봐야 할 음식 5가지</a>
					<p class="board-meta">2026.01.01 조회 118 추천12 댓글0</p>
				</div>
			</li>
		</ul>
			
			  <nav class="pagination" aria-label="페이지 이동">
			    <a href="" class="page-move is-disabled">← 이전</a>
			    <div class="page-numbers">
			      <a href="#" class="page is-active">1</a>
			      <a href="#" class="page">2</a>
			      <a href="#" class="page">3</a>
			    </div>
			    <a href="#" class="page-move">다음 →</a>
			
			  </nav>
		
	</section>
	
	  <section class="tab-panel" id="bookmarks" hidden>
	    <ul class="board-list">
	      <li class="board-item">...북마크한 글...</li>
	    </ul>
	  </section>
	
	  <section class="tab-panel" id="likes" hidden>
	    <ul class="board-list">
	      <li class="board-item">...추천한 글...</li>
	    </ul>
	  </section>
</main>
<script>
/* 탭메뉴 */
var tabs = document.querySelectorAll('.tab-btn');
var panels = document.querySelectorAll('.tab-panel');

tabs.forEach(function (tab) {
  tab.addEventListener('click', function () {
    tabs.forEach(function (t) { t.classList.remove('is-active'); });
    panels.forEach(function (p) { p.hidden = true; });

    tab.classList.add('is-active');
    document.getElementById(tab.dataset.tab).hidden = false;
  });
});

/* 파일 변경시 프로필 사진 미리보기 */
var fileInput = document.querySelector('.mypage-upload input[type="file"]');
var avatar = document.querySelector('.mypage-avatar');

fileInput.addEventListener('change', function () {
  var file = fileInput.files[0];
  if (file) avatar.src = URL.createObjectURL(file);
});
</script>
</body>
</html>