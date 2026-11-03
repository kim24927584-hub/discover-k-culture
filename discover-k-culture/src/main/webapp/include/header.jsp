<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<%--
====================================================================
 header.jsp

 [목적]
 사용자가 제공한 기존 헤더 디자인과 위치를 그대로 유지하면서
 하드코딩된 사용자 정보와 빈 링크(#)를 실제 기능에 연결합니다.

 [중요]
 - header.css의 클래스명/구조를 그대로 사용합니다.
 - 북마크 → 로그아웃 → 검색창 순서를 유지합니다.
 - CSS 파일 자체는 수정하지 않습니다.
====================================================================
--%>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<%
/* =========================================================
   1. 로그인 정보 확인
   ---------------------------------------------------------
   로그인 처리 시 session에 저장된 값을 가져옵니다.
   ========================================================= */
Object headerMemberId =
    session.getAttribute("memberId");

String headerNickname =
    (String) session.getAttribute("nickname");

String headerProfileImage =
    (String) session.getAttribute("profileImage");

String headerRole =
    (String) session.getAttribute("role");

boolean headerLoggedIn =
    headerMemberId != null;

boolean headerAdmin =
    "ADMIN".equals(headerRole);


/* =========================================================
   2. 현재 페이지 메뉴 확인
   ---------------------------------------------------------
   각 페이지에서 activeMenu를 직접 지정하면 그 값을 사용합니다.

   예)
   request.setAttribute("activeMenu", "KCULTURE");

   지정하지 않은 경우에는 현재 URL로 자동 판단합니다.
   ========================================================= */
String headerActiveMenu =
    (String) request.getAttribute("activeMenu");

String headerRequestUri =
    request.getRequestURI();

if (
    headerActiveMenu == null
    || headerActiveMenu.trim().isEmpty()
) {

    if (
        headerRequestUri.endsWith("/index.jsp")
        || headerRequestUri.endsWith("/home.jsp")
    ) {

        headerActiveMenu = "HOME";

    } else if (
        headerRequestUri.contains("/notice")
    ) {

        headerActiveMenu = "NOTICE";

    } else if (
        headerRequestUri.contains("/category")
    ) {

        headerActiveMenu = "KCULTURE";

    } else if (
        headerRequestUri.contains("/qna")
    ) {

        headerActiveMenu = "QUESTION";

    } else if (
        headerRequestUri.contains("/inquiry")
    ) {

        headerActiveMenu = "INQUIRY";

    } else if (
        headerRequestUri.contains("/bookmark")
    ) {

        headerActiveMenu = "BOOKMARK";

    } else if (
        headerRequestUri.contains("/all")
        || headerRequestUri.contains("/free")
    ) {

        headerActiveMenu = "ALL";

    } else if (
        headerRequestUri.contains("/admin/")
    ) {

        headerActiveMenu = "ADMIN";

    } else {

        headerActiveMenu = "";
    }
}


/* =========================================================
   3. 프로필 이미지 주소 설정
   ---------------------------------------------------------
   회원 프로필 이미지가 없으면 기존 기본 이미지를 사용합니다.
   ========================================================= */
String headerProfileSrc =
    request.getContextPath()
    + "/resources/assets/icon-user-profile-3682323.png";

if (
    headerProfileImage != null
    && !headerProfileImage.trim().isEmpty()
) {

    if (
        headerProfileImage.startsWith("http://")
        || headerProfileImage.startsWith("https://")
    ) {

        headerProfileSrc =
            headerProfileImage;

    } else if (
        headerProfileImage.startsWith("/")
    ) {

        headerProfileSrc =
            request.getContextPath()
            + headerProfileImage;

    } else {

        headerProfileSrc =
            request.getContextPath()
            + "/"
            + headerProfileImage;
    }
}


/* =========================================================
   4. 새 글 작성 버튼의 게시판 결정
   ---------------------------------------------------------
   화면에서 보고 있는 게시판 종류에 따라 글쓰기 boardType을
   자동으로 결정합니다.
   ========================================================= */
String headerWriteBoardType = "FREE";

if ("KCULTURE".equals(headerActiveMenu)) {

    headerWriteBoardType = "KCULTURE";

} else if ("QUESTION".equals(headerActiveMenu)) {

    headerWriteBoardType = "QUESTION";
}


/* JSP EL에서 사용할 값 저장 */
request.setAttribute(
    "headerActiveMenu",
    headerActiveMenu
);

request.setAttribute(
    "headerProfileSrc",
    headerProfileSrc
);

request.setAttribute(
    "headerWriteBoardType",
    headerWriteBoardType
);
%>


<!doctype html>
<html lang="ko">

<head>

<meta charset="UTF-8" />

<meta
    name="viewport"
    content="width=device-width, initial-scale=1.0" />

<title>
    <c:choose>
        <c:when test="${not empty pageTitle}">
            <c:out value="${pageTitle}" /> | K-culture
        </c:when>
        <c:otherwise>
            K-culture
        </c:otherwise>
    </c:choose>
</title>


<%-- 기존 프로젝트에서 사용하던 jQuery 유지 --%>
<script src="https://code.jquery.com/jquery-4.0.0.js"></script>


<%-- ========================================================
     공통 CSS
     ======================================================== --%>
<link
    rel="stylesheet"
    href="${ctx}/resources/css/style.css" />


<%-- ========================================================
     헤더 CSS
     --------------------------------------------------------
     사용자가 제공한 header.css를 그대로 불러옵니다.
     CSS 내용은 수정하지 않았습니다.
     ======================================================== --%>
<link
    rel="stylesheet"
    href="${ctx}/resources/css/header.css" />


<%-- 페이지별 CSS --%>
<c:if test="${not empty pageCss}">

    <link
        rel="stylesheet"
        href="${ctx}/resources/css/${pageCss}" />

</c:if>


<%-- 기존 아이콘 사용 유지 --%>
<script
    src="https://kit.fontawesome.com/0b6f7fb313.js"
    crossorigin="anonymous">
</script>

</head>


<body>


<%-- ========================================================
     전체 헤더 시작
     ======================================================== --%>
<div class="wrapper">


    <%-- ====================================================
         좌측 메뉴
         ==================================================== --%>
    <nav class="home-nav">


        <%-- 로고 --%>
        <div class="f-cc">

            <div class="logo f-cc">

                <a href="${ctx}/index.jsp">

                    <img
                        src="${ctx}/resources/assets/logo-mark.png"
                        alt="" />

                    <img
                        src="${ctx}/resources/assets/logo-text.png"
                        alt="K-culture" />

                </a>

            </div>

        </div>


        <%-- =================================================
             비로그인 상태
             ================================================= --%>
        <c:if test="${empty sessionScope.memberId}">

            <div class="auth-menu f-cc">

                <div class="auth-link">

                    <a href="${ctx}/member/login.jsp">
                        로그인
                    </a>

                </div>

                <span>|</span>

                <div class="auth-link">

                    <a href="${ctx}/member/join.jsp">
                        회원가입
                    </a>

                </div>

            </div>

        </c:if>


        <%-- =================================================
             로그인 상태의 사용자 정보
             -------------------------------------------------
             기존 Esther 같은 하드코딩 값을 실제 세션 정보로 교체
             ================================================= --%>
        <c:if test="${not empty sessionScope.memberId}">

            <div class="user-profile">


                <%-- 프로필 / 닉네임 --%>
                <div class="login-user">

                    <a href="${ctx}/member/mypage.jsp">

                        <img
                            src="${headerProfileSrc}"
                            alt="프로필 이미지" />

                        <c:choose>

                            <c:when test="${not empty sessionScope.nickname}">
                                <c:out value="${sessionScope.nickname}" />
                            </c:when>

                            <c:otherwise>
                                마이페이지
                            </c:otherwise>

                        </c:choose>

                    </a>

                </div>


                <%-- 기존 US 고정값 대신 한국어 표시 --%>
                <div class="nationality">

                    <img
                        src="${ctx}/resources/assets/language-svgrepo-com.svg"
                        alt="언어" />

                    KO

                </div>

            </div>

        </c:if>


        <%-- =================================================
             좌측 메뉴
             ================================================= --%>
        <div class="nav-side">

            <ul class="main-menu">

                <li>
                    <a href="${ctx}/index.jsp">
                        메뉴
                    </a>
                </li>

            </ul>


            <ul class="sub-menu">


                <li class="${headerActiveMenu eq 'HOME' ? 'active-menu' : ''}">

                    <a href="${ctx}/index.jsp">
                        홈
                    </a>

                </li>


                <li class="${headerActiveMenu eq 'ALL' ? 'active-menu' : ''}">

                    <a href="${ctx}/board/allList.jsp">
                        전체 게시글
                    </a>

                </li>


                <li class="${headerActiveMenu eq 'NOTICE' ? 'active-menu' : ''}">

                    <a href="${ctx}/board/noticeList.jsp">
                        공지사항
                    </a>

                </li>


                <li class="${headerActiveMenu eq 'KCULTURE' ? 'active-menu' : ''}">

                    <a href="${ctx}/board/category.jsp">
                        K-컬처 탐색
                    </a>

                </li>


                <li class="${headerActiveMenu eq 'QUESTION' ? 'active-menu' : ''}">

                    <a href="${ctx}/board/qnaList.jsp">
                        질문게시판
                    </a>

                </li>


                <li class="${headerActiveMenu eq 'INQUIRY' ? 'active-menu' : ''}">

                    <a href="${ctx}/board/inquiryList.jsp">
                        1:1 문의
                    </a>

                </li>


                <%-- 관리자에게만 관리자 메뉴 출력 --%>
                <c:if test="${sessionScope.role eq 'ADMIN'}">

                    <li class="${headerActiveMenu eq 'ADMIN' ? 'active-menu' : ''}">

                        <a href="${ctx}/admin/memberList.jsp">
                            관리자
                        </a>

                    </li>

                </c:if>

            </ul>

        </div>


        <%-- =================================================
             새 글 작성
             -------------------------------------------------
             로그인 사용자만 실제 글쓰기 화면으로 이동합니다.
             비로그인 사용자는 로그인 화면으로 이동합니다.
             ================================================= --%>
        <div class="new-post">

            <c:choose>

                <c:when test="${not empty sessionScope.memberId}">

                    <a
                        href="${ctx}/post/write.jsp?boardType=${headerWriteBoardType}"
                        class="f-cc">

                        <img
                            src="${ctx}/resources/assets/icon-plus-sign-3114793.png"
                            alt="" />

                        새 글 작성

                    </a>

                </c:when>


                <c:otherwise>

                    <a
                        href="${ctx}/member/login.jsp"
                        class="f-cc">

                        <img
                            src="${ctx}/resources/assets/icon-plus-sign-3114793.png"
                            alt="" />

                        새 글 작성

                    </a>

                </c:otherwise>

            </c:choose>

        </div>

    </nav>


    <%-- ====================================================
         우측 레이아웃
         ==================================================== --%>
    <div class="layout">


        <%-- =================================================
             상단 메뉴

             ★ 사용자가 제공한 화면의 순서 그대로 유지
             [북마크] [로그아웃] [검색창]

             .home-header는 justify-content:flex-end이므로
             이 세 요소가 화면 오른쪽에 배치됩니다.
             ================================================= --%>
        <header class="home-header">


            <%-- 로그인했을 때만 북마크/로그아웃 표시 --%>
            <c:if test="${not empty sessionScope.memberId}">

                <div class="user-menu">


                    <%-- =====================================
                         북마크 버튼
                         -------------------------------------------------
                         클릭하면 현재 로그인 사용자의
                         북마크 목록 페이지로 이동합니다.
                         ===================================== --%>
                    <a
                        href="${ctx}/member/bookmarkList.jsp"
                        class="home-bookmark">

                        <img
                            src="${ctx}/resources/assets/icons8-star-48.png"
                            alt="" />

                        북마크

                    </a>


                    <%-- =====================================
                         로그아웃 버튼
                         -------------------------------------------------
                         기존 button + 빈 기능을 제거하고
                         실제 logout.jsp 링크로 연결합니다.

                         class="log-out"은 그대로 유지하므로
                         기존 CSS 위치/디자인을 그대로 사용합니다.
                         ===================================== --%>
                    <a
                        href="${ctx}/member/logout.jsp"
                        class="log-out">

                        로그아웃

                    </a>

                </div>

            </c:if>


            <%-- =================================================
                 검색창
                 -------------------------------------------------
                 기존 위치와 구조를 그대로 유지합니다.
                 전체 게시글의 keyword 검색으로 연결합니다.
                 ================================================= --%>
            <div class="search-bar">

                <form
                    action="${ctx}/board/allList.jsp"
                    method="get">

                    <input
                        type="text"
                        name="keyword"
                        value="<c:out value='${param.keyword}' />"
                        placeholder="검색" />

                    <button
                        class="search-btn"
                        type="submit"
                        aria-label="검색">

                        <img
                            src="${ctx}/resources/assets/icon-search-6328608.png"
                            alt="" />

                    </button>

                </form>

            </div>

        </header>


        <%-- 각 페이지의 내용이 시작되는 영역 --%>
        <div class="content-wrapper">
