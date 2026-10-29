<%@ page
    language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib
    prefix="c"
    uri="http://java.sun.com/jsp/jstl/core"%>
<c:set
    var="ctx"
    value="${pageContext.request.contextPath}" />


<!doctype html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta
    name="viewport"
    content="width=device-width, initial-scale=1.0" />
<title>K-culture</title>

<!-- 공통 -->
<link
    rel="stylesheet"
    href="${ctx}/resources/css/style.css" />

<!-- 개별 -->
<c:if test="${not empty pageCss}">
    <link
        rel="stylesheet"
        href="${ctx}/resources/css/${pageCss}" />
</c:if>

</head>
<body>
   <!-- 헤더 -->
    <div class="wrapper">
      <nav>
          <div class="f-cc">
            <div class="logo f-cc">
              <img src="${ctx}/resources/assets/logo-mark.png" alt="" />
              <img src="${ctx}/resources/assets/logo-text.png" alt="" />
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
              <a href="#"
                ><img src="${ctx}/resources/assets/icon-user-profile-3682323.png" alt="" />
                Esther
              </a>
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
              <li class="active-menu">
                <a href="#">Home</a>
              </li>
              <li>
                <a href="#">All Posts</a>
              </li>
              <li>
                <a href="#">Notice</a>
              </li>
              <li>
                <a href="#">Discover K-Culture</a>
              </li>
              <li>
                <a href="#">Free Board</a>
              </li>
              <li>
                <a href="#">Q&A</a>
              </li>
            </ul>
          </div>
          <div class="new-post">
            <a href="#" class="f-cc">
              <img src="${ctx}/resources/assets/icon-plus-sign-3114793.png" alt="" />NEW POST
            </a>
          </div>
        </nav>
        <div class="layout">
      <header class="home-header">

        <div class="search-bar">
          <form>
            <input type="text" name="search" value="" placeholder="Search" />
            <button class="search-btn" type="search">
              <img src="${ctx}/resources/assets/icon-search-6328608.png" alt="" />
            </button>
          </form>
        </div>
      </header>