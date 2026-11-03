<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />


<!doctype html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>K-culture</title>
<script src="https://code.jquery.com/jquery-4.0.0.js"></script>
<!-- 공통 -->
<link rel="stylesheet" href="${ctx}/resources/css/style.css" />

<!-- 개별 -->
<c:if test="${not empty pageCss}">
	<link rel="stylesheet" href="${ctx}/resources/css/${pageCss}" />
</c:if>

<!-- 아이콘 사용 -->
<script src="https://kit.fontawesome.com/0b6f7fb313.js" crossorigin="anonymous"></script>
</head>
<body>
<!-- 헤더 -->
	<div class="wrapper">
		<nav class="home-nav">
			<div class="f-cc">
				<div class="logo f-cc">
					<img src="${ctx}/resources/assets/logo-mark.png" alt="" /> <img
						src="${ctx}/resources/assets/logo-text.png" alt="" />
				</div>
			</div>
			<!-- 로그인 X -->
			<!-- <div class="auth-menu f-cc">
            <div class="auth-link">
              <a href="#">Login</a>
            </div>
            <span>|</span>
            <div class="auth-link">
              <a href="#">Sign Up</a>
            </div>
          </div> -->
			<!-- 로그인 O -->
			<div class="user-profile">
				<!-- 닉네임 길어질 시 줄바꿈이나 영역을 넘치지 않고
             말줄임 표시되도록 추가 -->
				<div class="login-user">
					<a href="#"><img
						src="${ctx}/resources/assets/icon-user-profile-3682323.png" alt="" />
						Esther </a>
				</div>
				<div class="nationality">
					<img src="${ctx}/resources/assets/language-svgrepo-com.svg" alt="" />
					US
				</div>
			</div>
			<div class="nav-side">
				<ul class="main-menu">
					<li><a href="#">Menu</a></li>
				</ul>
				<ul class="sub-menu">
					<li><a href="${ctx}/index.jsp">Home</a></li>

					<li><a href="${ctx}/board/allList.jsp">All Posts</a></li>

					<li><a href="${ctx}/board/noticeList.jsp">Notice</a></li>

					<li><a href="${ctx}/board/category.jsp"> Discover K-Culture
					</a></li>

					

					<li><a href="${ctx}/board/qnaList.jsp">Q&amp;A</a></li>
					<li><a href="${ctx}/board/inquiryList.jsp">1:1문의</a></li>
				</ul>
			</div>
			<div class="new-post">
				<a href="#" class="f-cc"> <img
					src="${ctx}/resources/assets/icon-plus-sign-3114793.png" alt="" />NEW
					POST
				</a>
			</div>
		</nav>
		<div class="layout">
			<header class="home-header">
                <div class="user-menu">
                    <a href="#" class="home-bookmark">
                    <img src="${ctx}/resources/assets/icons8-star-48.png" alt="">북마크
                    </a>
                    <button class="log-out">Log out</button>
                </div>
				<div class="search-bar">
					<form>
						<input type="text" name="search" value="" placeholder="Search" />
						<button class="search-btn" type="search">
							<img src="${ctx}/resources/assets/icon-search-6328608.png" alt="" />
						</button>
					</form>
				</div>
			</header>
			
<div class="content-wrapper">