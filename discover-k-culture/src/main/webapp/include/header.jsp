<%@ page
    language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<!doctype html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta
    name="viewport"
    content="width=device-width, initial-scale=1.0" />
<title>K-culture</title>

</head>
<body>
    <!-- 헤더 -->
    <div class="wrapper">
        <header>
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
                            src="${ctx}/resources/assets/icon-user-profile-3682323.png"
                            alt="" /> Esther </a>
                    </div>
                    <div class="nationality">
                        <img
                            src="${ctx}/resources/assets/language-svgrepo-com.svg"
                            alt="" /> US
                    </div>
                </div>
                <div class="nav-side">
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