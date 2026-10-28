<%@ page
    language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<% request.setAttribute("pageCss", "header.css"); %>

<%-- <%@ taglib prefix="c" uri="jakarta.tags.core" %> --%>

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

<!-- 
<link
    rel="stylesheet"
    href="css/style.css" />
<link
    rel="stylesheet"
    href="css/home.css" />
 -->


<%-- 모든 페이지 공통 --%>
<link
    rel="stylesheet"
    href="${ctx}/resources/css/reset.css" />
<link
    rel="stylesheet"
    href="${ctx}/resources/css/common.css" />


<%-- 페이지별 CSS (값이 있을 때만) --%>
<c:if test="${not empty pageCss}">
    <link
        rel="stylesheet"
        href="${ctx}/resources/css/${pageCss}" />
</c:if>


</head>
<body>
    <!-- 헤더 -->
    <div class="wrapper">
        <header>
            <!-- 수정 필요
             <div class="h-profile">
            <a href="#"
              ><img src="assets/icon-user-profile-3682323.png" alt="" />
              Esther
            </a>
            <div class="nationality">
              <img src="assets/icon-global-2531125.png" alt="" />
              US
            </div>
          </div> -->
            <nav>
                <div class="f-cc">
                    <div class="logo f-cc">
                        <img
                            src="${ctx}/resources/assets/logo-mark.png"
                            alt="" /> <img
                            src="${ctx}/resources/assets/logo-text.png"
                            alt="" />
                    </div>
                </div>
                <div class="auth-menu">
                    <div class="auth-link">
                        <a href="#">Login</a>
                    </div>
                    <span>|</span>
                    <div class="auth-link">
                        <a href="#">Sign Up</a>
                    </div>
                </div>
                <div class="nav-side">
                    <!-- 로그인 X -->

                    <ul class="main-menu">
                        <li><a href="#">Menu</a></li>
                    </ul>
                    <ul class="sub-menu">
                        <li class="active-menu"><a href="#">Home</a></li>
                        <li><a href="#">All Posts</a></li>
                        <li><a href="#">Notice</a></li>
                        <li><a href="#">Discover K-Culture</a></li>
                        <li><a href="#">Free Board</a></li>
                        <li><a href="#">Q&A</a></li>
                    </ul>
                </div>
                <div class="new-post">
                    <a
                        href="#"
                        class="f-cc"> <img
                        src="${ctx}/resources/assets/icon-plus-sign-3114793.png"
                        alt="" />NEW POST
                    </a>
                </div>
            </nav>
        </header>