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

<link
    rel="stylesheet"
    href="css/style.css" />
<link
    rel="stylesheet"
    href="css/home.css" />
</head>
<body>
    <!-- 헤더 -->
    <div class="wrapper">
        <header>
            <!-- <div class="h-profile">
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
                            src="assets/logo-mark.png"
                            alt="" /> <img
                            src="assets/logo-text.png"
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
                        src="assets/icon-plus-sign-3114793.png"
                        alt="" />NEW POST
                    </a>
                </div>
            </nav>
        </header>

        <!-- 메인 -->
        <div class="layout">
            <div class="search-bar">
                <form>
                    <input
                        type="text"
                        name="search"
                        value=""
                        placeholder="Search" />
                    <button
                        class="btn search-btn"
                        type="search">
                        <img
                            src="assets/icon-search-6328608.png"
                            alt="" />
                    </button>
                </form>
            </div>
            <div class="content-wrapper">
                <main>
                    <section class="s1">
                        <table class="board-notice">
                            <caption>
                                <div class="notice-caption">
                                    <strong>Notice</strong> <a href="#"> <img
                                        src="assets/icon-arrow-right-6423875.png"
                                        alt="" />
                                    </a>
                                </div>
                            </caption>
                            <tr>
                                <td class="notice-symbol must-read">MUST-READ</td>
                                <td class="title"><a href="#">Community Guidelines</a></td>
                                <td class="hits">3</td>
                            </tr>

                            <tr>
                                <td class="notice-symbol notice">NOTICE</td>
                                <td class="title"><a href="#">Welcome to K-culture !</a></td>
                                <td class="hits">11</td>
                            </tr>

                            <tr>
                                <td class="notice-symbol must-read">MUST-READ</td>
                                <td class="title"><a href="#">Community Guidelines</a></td>
                                <td class="hits">3</td>
                            </tr>
                        </table>
                    </section>
                </main>

                <div class="sidebar">
                    <!-- 화면이 작아지면 맨 아래로 내려가도록 -->
                    <div class="sidebar-s1">
                        <ul class="s1-tabs">
                            <li class="tab-btn">All Posts</li>
                            <li class="tab-btn">K-Culture</li>
                            <li class="tab-btn">Free Board</li>
                        </ul>

                        <ul class="tab-content">
                            <div class="s1-content">
                                <tr></tr>
                            </div>
                        </ul>
                    </div>
                </div>
            </div>
            <!-- 푸터 -->
            <footer>
                <div class="f-section">
                    <div class="f-logo">
                        <img
                            src="assets/logo.png"
                            alt="" />
                    </div>
                    <div class="copy">
                        <p class="copyright">&copy; 2026, All Rights Reserved</p>
                        <p class="copydesc">
                            <span>김민성</span><span>이우민</span><span>양영준</span><span>송연희</span>
                        </p>
                        <p class="copyinfo">
                            <span>이용약관</span> <span>개인정보처리방침</span> <span>개인 정보 설정</span> <span>위치정보이용약관</span>
                        </p>
                    </div>
                </div>
            </footer>
        </div>
    </div>
</body>
</html>
