<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="java.util.List" %>

<%@ page import="dao.MemberDAO" %>
<%@ page import="dao.PostDAO" %>
<%@ page import="dao.BookmarkListDAO" %>
<%@ page import="dao.PostLikeDAO" %>

<%@ page import="dto.MemberDTO" %>
<%@ page import="dto.PostDTO" %>
<%@ page import="dto.BookmarkPostDTO" %>


<%!
/* =========================================================
   HTML 출력 안전 처리
   ---------------------------------------------------------
   사용자 입력값이 HTML 태그로 실행되는 것을 막기 위한
   기본 이스케이프 함수입니다.
   ========================================================= */
private String h(String value) {

    if (value == null) {
        return "";
    }

    return value
        .replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace("\"", "&quot;")
        .replace("'", "&#39;");
}


/* =========================================================
   게시판 종류를 한글 이름으로 변경
   ========================================================= */
private String boardName(
    String boardType,
    String categoryName
) {

    if ("KCULTURE".equals(boardType)) {

        if (
            categoryName != null
            && !categoryName.trim().isEmpty()
        ) {

            return "K-컬처 · "
                + categoryName;
        }

        return "K-컬처";
    }

    if ("QUESTION".equals(boardType)) {
        return "질문게시판";
    }

    return "자유게시판";
}


/* =========================================================
   PostDTO 상세보기 주소
   ========================================================= */
private String postDetailUrl(
    String contextPath,
    PostDTO post
) {

    if (
        "KCULTURE".equals(
            post.getBoardType()
        )
    ) {

        return contextPath
            + "/board/category-view.jsp?postId="
            + post.getPostId();
    }

    if (
        "QUESTION".equals(
            post.getBoardType()
        )
    ) {

        return contextPath
            + "/board/qnaView.jsp?id="
            + post.getPostId();
    }

    return contextPath
        + "/board/allView.jsp?id="
        + post.getPostId();
}


/* =========================================================
   BookmarkPostDTO 상세보기 주소
   ========================================================= */
private String bookmarkDetailUrl(
    String contextPath,
    BookmarkPostDTO post
) {

    if (
        "KCULTURE".equals(
            post.getBoardType()
        )
    ) {

        return contextPath
            + "/board/category-view.jsp?postId="
            + post.getPostId();
    }

    if (
        "QUESTION".equals(
            post.getBoardType()
        )
    ) {

        return contextPath
            + "/board/qnaView.jsp?id="
            + post.getPostId();
    }

    return contextPath
        + "/board/allView.jsp?id="
        + post.getPostId();
}
%>


<%
request.setCharacterEncoding(
    "UTF-8"
);


/* =========================================================
   1. 로그인 확인
   ---------------------------------------------------------
   마이페이지는 로그인 회원 전용 화면입니다.
   ========================================================= */
Long memberId =
    (Long) session.getAttribute(
        "memberId"
    );

if (memberId == null) {

    response.sendRedirect(
        request.getContextPath()
        + "/member/login.jsp"
    );

    return;
}


/* =========================================================
   2. 최신 회원 정보 조회
   ---------------------------------------------------------
   세션 정보만 사용하지 않고 DB의 최신 회원 정보를 조회합니다.
   ========================================================= */
MemberDAO memberDAO =
    new MemberDAO();

MemberDTO member =
    memberDAO.selectById(
        memberId.longValue()
    );

if (member == null || "WITHDRAWN".equals(member.getStatus())) {

    // 탈퇴 처리된 회원은 이전 세션이 남아 있어도 마이페이지에 접근할 수 없습니다.
    session.invalidate();
    response.sendRedirect(
        request.getContextPath()
        + "/member/logout"
    );

    return;
}


/* =========================================================
   3. 프로필 이미지 주소 결정
   ---------------------------------------------------------
   가입 후 프로필 사진을 등록하지 않은 회원은
   /resources/img/base.png를 기본 프로필 이미지로 사용합니다.
   DB의 profile_image 값은 비워 두고 화면 출력에서만 기본값을 적용합니다.
   ========================================================= */
String defaultProfileSrc =
    request.getContextPath()
    + "/resources/img/base.png";

String profileSrc = defaultProfileSrc;

if (
    member.getProfileImage() != null
    && !member.getProfileImage()
        .trim()
        .isEmpty()
) {

    String profileImage =
        member.getProfileImage();

    if (
        profileImage.startsWith("http://")
        || profileImage.startsWith("https://")
    ) {

        profileSrc =
            profileImage;

    } else if (
        profileImage.startsWith("/")
    ) {

        profileSrc =
            request.getContextPath()
            + profileImage;

    } else {

        profileSrc =
            request.getContextPath()
            + "/"
            + profileImage;
    }
}


/* =========================================================
   4. 내가 작성한 게시글 조회
   ---------------------------------------------------------
   기존 PostDAO.selectByMemberId() 기능을 그대로 사용합니다.
   ========================================================= */
PostDAO postDAO =
    new PostDAO();

List<PostDTO> myPosts =
    postDAO.selectByMemberId(
        memberId.longValue()
    );


/* =========================================================
   5. 내가 북마크한 게시글 조회
   ---------------------------------------------------------
   별도의 bookmarkList.jsp를 사용하지 않고
   마이페이지가 직접 북마크 목록을 조회합니다.
   ========================================================= */
BookmarkListDAO bookmarkDAO =
    new BookmarkListDAO();

List<BookmarkPostDTO> myBookmarks =
    bookmarkDAO.selectByMemberId(
        memberId.longValue()
    );


/* =========================================================
   6. 내가 추천한 게시글 조회
   ---------------------------------------------------------
   기존 PostLikeDAO.selectPostsByMemberId()를 재사용합니다.
   post_like 테이블에서 현재 로그인 회원의 추천 기록만 조회하고,
   추천을 가장 최근에 누른 게시글부터 표시합니다.
   ========================================================= */
PostLikeDAO myPostLikeDAO = new PostLikeDAO();

List<PostDTO> myLikedPosts =
    myPostLikeDAO.selectPostsByMemberId(
        memberId.longValue()
    );


/* =========================================================
   7. 처음 표시할 탭
   ---------------------------------------------------------
   상단 헤더의 북마크 버튼에서

   mypage.jsp?tab=bookmark#bookmarkSection

   으로 들어오면 북마크 탭을 바로 표시합니다.
   ========================================================= */
String selectedTab =
    request.getParameter("tab");

boolean showBookmarkTab =
    "bookmark".equals(selectedTab);

boolean showLikeTab =
    "likes".equals(selectedTab);


/* =========================================================
   8. 공통 헤더 설정
   ---------------------------------------------------------
   기존 mypage.css를 그대로 사용합니다.
   CSS 파일은 변경하지 않습니다.
   ========================================================= */
request.setAttribute(
    "pageTitle",
    "마이페이지"
);

request.setAttribute(
    "pageCss",
    "member/mypage.css"
);
%>


<%@ include file="/include/header.jsp" %>


<main class="container">


    <%-- =====================================================
         마이페이지 제목
         ===================================================== --%>
    <h1>
        마이페이지
    </h1>


    <%-- =====================================================
         프로필 영역
         -----------------------------------------------------
         기존 mypage.css의
         .mypage-profile / .mypage-avatar / .mypage-info /
         .mypage-meta 클래스를 그대로 사용합니다.
         ===================================================== --%>
    <section class="mypage-profile">


        <img
            src="<%=h(profileSrc)%>"
            alt="프로필 이미지"
            class="mypage-avatar"
            id="profileAvatar"
            data-default-src="<%=h(defaultProfileSrc)%>"
            onerror="this.onerror=null;this.src='<%=h(defaultProfileSrc)%>';">


        <div class="mypage-info">

            <h2 data-deepl-ignore>
                <%=h(member.getNickname())%>님
            </h2>


            <ul class="mypage-meta">

                <li>
                    아이디 :
                    <span data-deepl-ignore><%=h(member.getLoginId())%></span>
                </li>

                <li>
                    이메일 :
                    <span data-deepl-ignore><%=h(member.getEmail())%></span>
                </li>

                <li>
                    국적 :
                    <span data-deepl-ignore><%=member.getNationality() == null
                        || member.getNationality()
                            .trim()
                            .isEmpty()
                        ? "-"
                        : h(member.getNationality())%></span>
                </li>

                <li>
                    회원 상태 :
                    <span data-deepl-ignore><%=h(member.getStatus())%></span>
                </li>

            </ul>

            <%-- =============================================
                 회원 정보 수정
                 기존 updateProcess.jsp를 실제 화면과 연결합니다.
                 ============================================= --%>
            <button type="button" class="btn btn-edit" id="profileEditButton">정보 수정</button>

            <div class="profile-edit-wrap" id="profileEditWrap">
                <form action="<%=request.getContextPath()%>/member/updateProcess.jsp"
                      method="post" class="profile-edit-form">
                    <div class="form-field">
                        <div>
                            <label>닉네임
                                <input name="nickname" value="<%=h(member.getNickname())%>" maxlength="50" required>
                            </label>
                        </div>
                        <div>
                            <label>아이디
                                <input value="<%=h(member.getLoginId())%>" readonly>
                            </label>
                        </div>
                        <div>
                            <label>이메일
                                <input type="email" name="email" value="<%=h(member.getEmail())%>" maxlength="100" required>
                            </label>
                        </div>
                        <div>
                            <label>국적
                                <input name="nationality" value="<%=h(member.getNationality())%>" maxlength="50">
                            </label>
                        </div>
                        <div>
                            <label>언어
                                <select name="languageId" class="fix-language" data-language-preview="true" required>
                                    <option value="1" <%=member.getLanguageId() == 1 ? "selected" : ""%>>한국어</option>
                                    <option value="2" <%=member.getLanguageId() == 2 ? "selected" : ""%>>日本語</option>
                                    <option value="3" <%=member.getLanguageId() == 3 ? "selected" : ""%>>中文</option>
                                    <option value="4" <%=member.getLanguageId() == 4 ? "selected" : ""%>>English</option>
                                </select>
                                <span class="form-hint" data-deepl-ignore>선택 즉시 화면을 미리 번역합니다. 저장을 눌러야 기본 언어가 변경됩니다.</span>
                                <span id="languagePreviewError" class="form-hint" data-deepl-ignore role="alert" style="display:none; color:#b42318;"></span>
                            </label>
                        </div>
                    </div>
                    <div class="fix-buttons">
                        <button type="submit" class="btn btn-primary">저장</button>
                        <button type="button" class="btn cancel" id="profileEditCancel">취소</button>
                    </div>
                </form>
            </div>

            <% if ("1".equals(request.getParameter("updated"))) { %>
                <p class="form-hint">회원 정보가 수정되었습니다.</p>
            <% } %>
            <% if (request.getParameter("updateError") != null) { %>
                <p class="form-hint">회원 정보를 수정하지 못했습니다. 닉네임/이메일 중복 또는 입력값을 확인해 주세요.</p>
            <% } %>


            <%-- =============================================
                 프로필 이미지 변경

                 기존 ProfileImageUploadServlet의
                 /member/profile-image 주소를 그대로 사용합니다.
                 ============================================= --%>
            <form
                id="profileImageForm"
                action="<%=request.getContextPath()%>/member/profile-image"
                method="post"
                enctype="multipart/form-data">

                <input
                    type="file"
                    id="profileImageInput"
                    name="profileImage"
                    accept="image/jpeg,image/png,image/gif,image/webp"
                    aria-describedby="profilePreviewMessage"
                    required>

                <%-- 실제 저장 전에는 DB를 수정하지 않고 화면에만 표시합니다. --%>
                <p id="profilePreviewMessage" class="form-hint" aria-live="polite">
                    파일을 선택하면 위 프로필 사진에서 미리볼 수 있습니다.
                </p>
                <button type="button" class="btn" id="profilePreviewCancel" hidden>
                    선택 취소
                </button>

                <button
                    type="submit"
                    class="btn">
                    프로필 이미지 변경
                </button>

            </form>

            <p class="form-hint">
                JPG, JPEG, PNG, GIF, WEBP 이미지를 사용할 수 있습니다.
            </p>


            <%-- 프로필 변경 결과 메시지 --%>
            <% if ("1".equals(request.getParameter("profileUpdated"))) { %>

                <p class="form-hint">
                    프로필 이미지가 변경되었습니다.
                </p>

            <% } %>


            <%
            String profileError =
                request.getParameter(
                    "profileError"
                );

            if (profileError != null) {
            %>

                <p class="form-hint">

                    <%
                    if ("empty".equals(profileError)) {
                    %>

                        이미지를 선택해 주세요.

                    <%
                    } else if ("size".equals(profileError)) {
                    %>

                        이미지 크기가 너무 큽니다.

                    <%
                    } else {
                    %>

                        사용할 수 없는 이미지 형식입니다.

                    <%
                    }
                    %>

                </p>

            <% } %>

        </div>

    </section>

    <%-- =====================================================
         회원탈퇴 (일반 회원만 표시)
         -----------------------------------------------------
         실수로 탈퇴하지 않도록 본인 로그인 아이디를 다시 입력하고,
         한 번 더 확인한 후 POST로 /member/withdraw에 요청합니다.
         기존 버튼 CSS를 사용하고 별도의 CSS 변경은 하지 않습니다.
         ===================================================== --%>
    <% if (!"ADMIN".equals(member.getRole())) { %>
    <section aria-labelledby="withdrawTitle" style="margin:28px 0 16px;">
        <h2 id="withdrawTitle">계정 관리</h2>
        <p class="form-hint">
            회원탈퇴 시 계정이 비활성화되며, 다시 로그인할 수 없습니다.
            기존 게시글과 댓글은 보존됩니다.
        </p>

        <button type="button" class="btn" id="withdrawOpenButton"
                aria-expanded="<%=request.getParameter("withdrawError") != null%>" aria-controls="withdrawPanel">
            회원탈퇴
        </button>

        <div id="withdrawPanel" <%=request.getParameter("withdrawError") == null ? "hidden" : ""%>>
            <p class="form-hint">
                탈퇴를 진행하려면 아래 입력칸에 자신의 로그인 아이디를 정확히 입력하세요.
            </p>
            <% if (request.getParameter("withdrawError") != null) { %>
                <p role="alert">회원탈퇴를 처리하지 못했습니다. 아이디와 로그인 상태를 확인해 주세요.</p>
            <% } %>
            <form method="post"
                  action="<%=request.getContextPath()%>/member/withdraw"
                  id="withdrawForm">
                <label for="withdrawLoginId">로그인 아이디 확인</label>
                <input type="text" id="withdrawLoginId" name="confirmLoginId"
                       maxlength="50" required autocomplete="off"
                       placeholder="<%=h(member.getLoginId())%>"
                       style="display:block;max-width:320px;width:100%;padding:10px;margin:8px 0;">
                <button type="submit" class="btn" style="color:#b42318;">
                    탈퇴 확정
                </button>
                <button type="button" class="btn" id="withdrawCancelButton">취소</button>
            </form>
        </div>
    </section>
    <% } %>


    <%-- =====================================================
         내 활동 탭
         -----------------------------------------------------
         기존 CSS의 .tabs / .tab-btn 클래스를 그대로 사용합니다.

         1. 내 게시글
         2. 내 북마크
         3. 내가 추천한 게시글
         ===================================================== --%>
    <div class="tabs">

        <button
            type="button"
            id="myPostTabButton"
            class="tab-btn <%=(!showBookmarkTab && !showLikeTab) ? "is-active" : ""%>"
            aria-controls="myPostSection"
            aria-selected="<%=!showBookmarkTab && !showLikeTab%>">

            내 게시글
            (<%=myPosts == null ? 0 : myPosts.size()%>)

        </button>


        <button
            type="button"
            id="bookmarkTabButton"
            class="tab-btn <%=showBookmarkTab ? "is-active" : ""%>"
            aria-controls="bookmarkSection"
            aria-selected="<%=showBookmarkTab%>">

            ★ 내 북마크
            (<span data-bookmark-count><%=myBookmarks == null ? 0 : myBookmarks.size()%></span>)

        </button>

        <%-- 기존 추천 기능과 연결: 내 추천 게시글 수와 목록을 표시합니다. --%>
        <button
            type="button"
            id="likeTabButton"
            class="tab-btn <%=showLikeTab ? "is-active" : ""%>"
            aria-controls="likesSection"
            aria-selected="<%=showLikeTab%>">

            내가 추천한 게시글
            (<%=myLikedPosts.size()%>)

        </button>

    </div>


    <%-- =====================================================
         내 게시글 영역
         ===================================================== --%>
    <section
        id="myPostSection"
        <%=showBookmarkTab || showLikeTab ? "hidden" : ""%>>

        <h2>
            내가 작성한 게시글
        </h2>


        <div class="board-list">

            <%
            if (
                myPosts == null
                || myPosts.isEmpty()
            ) {
            %>

                <div class="board-item">

                    <div class="board-body">

                        <span class="board-title">
                            작성한 게시글이 없습니다.
                        </span>

                    </div>

                </div>

            <%
            } else {

                for (
                    PostDTO post
                    : myPosts
                ) {
            %>

                <div class="board-item">


                    <span class="board-category">

                        <%=h(
                            boardName(
                                post.getBoardType(),
                                post.getCategoryName()
                            )
                        )%>

                    </span>


                    <div class="board-body">

                        <a
                            class="board-title"
                            href="<%=postDetailUrl(request.getContextPath(), post)%>">

                            <%=h(post.getTitle())%>

                        </a>


                        <div class="board-meta">

                            조회
                            <%=post.getViewCount()%>

                            · 추천
                            <%=post.getLikeCount()%>

                            ·

                            <%=post.getCreatedAt() == null
                                ? "-"
                                : post.getCreatedAt()
                                    .toString()
                                    .substring(0, 10)%>

                        </div>

                    </div>

                </div>

            <%
                }
            }
            %>

        </div>

    </section>


    <%-- =====================================================
         내 북마크 영역
         -----------------------------------------------------
         예전의 bookmarkList.jsp 기능을 이 영역으로 이동했습니다.
         ===================================================== --%>
    <section
        id="bookmarkSection"
        <%=showBookmarkTab ? "" : "hidden"%>>

        <h2>
            내가 북마크한 게시글
        </h2>


        <div class="board-list" data-bookmark-list>

            <%
            if (
                myBookmarks == null
                || myBookmarks.isEmpty()
            ) {
            %>

                <div class="board-item" data-bookmark-empty>

                    <div class="board-body">

                        <span class="board-title">
                            북마크한 게시글이 없습니다.
                        </span>

                    </div>

                </div>

            <%
            } else {

                for (
                    BookmarkPostDTO post
                    : myBookmarks
                ) {
            %>

                <div class="board-item" data-bookmark-item>


                    <span class="board-category">

                        <%=h(
                            boardName(
                                post.getBoardType(),
                                post.getCategoryName()
                            )
                        )%>

                    </span>


                    <div class="board-body">

                        <%-- 제목 클릭 → 원래 게시글 상세보기 --%>
                        <a
                            class="board-title"
                            href="<%=bookmarkDetailUrl(request.getContextPath(), post)%>">

                            <%=h(post.getTitle())%>

                        </a>


                        <div class="board-meta">

                            작성자
                            <span data-deepl-ignore><%=h(post.getMemberNickname())%></span>

                            · 조회
                            <%=post.getViewCount()%>

                            · 추천
                            <%=post.getLikeCount()%>

                            · 북마크
                            <%=post.getBookmarkedAt() == null
                                ? "-"
                                : post.getBookmarkedAt()
                                    .toString()
                                    .substring(0, 10)%>

                        </div>


                        <%-- =================================
                             북마크 해제
                             ---------------------------------
                             해제 후에도 마이페이지 북마크 탭으로
                             돌아오도록 처리합니다.
                             ================================= --%>
                        <form
                            action="<%=request.getContextPath()%>/member/bookmarkRemoveProcess.jsp"
                            method="post" data-ajax-bookmark="remove"
                            data-login-url="<%=request.getContextPath()%>/member/login.jsp">

                            <input
                                type="hidden"
                                name="postId"
                                value="<%=post.getPostId()%>">

                            <button
                                type="submit"
                                class="btn"
                                onclick="return confirm('이 게시글의 북마크를 해제하시겠습니까?');">

                                ★ 북마크 해제

                            </button>

                        </form>

                    </div>

                </div>

            <%
                }
            }
            %>

        </div>

    </section>


    <%-- =====================================================
         내가 추천한 게시글
         -----------------------------------------------------
         PostLikeDAO에서 로그인 회원의 post_like 기록을 조회합니다.
         추천한 게시글의 제목을 클릭하면 원래 상세화면으로 이동하며,
         추천을 취소한 글은 다음 조회에서 자동으로 제외됩니다.

         별도 CSS 추가 없이 기존 board-list 스타일을 재사용합니다.
         ===================================================== --%>
    <section
        id="likesSection"
        <%=showLikeTab ? "" : "hidden"%>>

        <h2>내가 추천한 게시글</h2>

        <div class="board-list">

            <% if (myLikedPosts.isEmpty()) { %>

                <div class="board-item">
                    <div class="board-body">
                        <span class="board-title">아직 추천한 게시글이 없습니다.</span>
                    </div>
                </div>

            <% } else { %>

                <% for (PostDTO likedPost : myLikedPosts) { %>

                    <div class="board-item">

                        <%-- 해당 게시글의 게시판/카테고리 정보를 표시 --%>
                        <span class="board-category">
                            <%=h(boardName(likedPost.getBoardType(), likedPost.getCategoryName()))%>
                        </span>

                        <div class="board-body">

                            <%-- 원래 게시글 상세보기로 이동 --%>
                            <a
                                class="board-title"
                                href="<%=postDetailUrl(request.getContextPath(), likedPost)%>">
                                <%=h(likedPost.getTitle())%>
                            </a>

                            <div class="board-meta">
                                작성자 <span data-deepl-ignore><%=h(likedPost.getMemberNickname())%></span>
                                · 조회 <%=likedPost.getViewCount()%>
                                · 추천 <%=likedPost.getLikeCount()%>
                                · 댓글 <%=likedPost.getCommentCount()%>
                                · 작성일
                                <%=likedPost.getCreatedAt() == null
                                    ? "-"
                                    : likedPost.getCreatedAt().toString().substring(0, 10)%>
                            </div>

                        </div>
                    </div>

                <% } %>

            <% } %>

        </div>

    </section>

</main>


<%@ include file="/include/sidebar.jsp" %>


<%-- ========================================================
     마이페이지 세 가지 탭 전환
     --------------------------------------------------------
     hidden 속성으로 내용 표시 여부를 변경하므로 기존 CSS는 그대로입니다.
     URL의 tab=bookmark / tab=likes 값으로 바로 진입할 수 있습니다.
     ======================================================== --%>
<script>
(function () {
    const sections = {
        posts: document.getElementById("myPostSection"),
        bookmark: document.getElementById("bookmarkSection"),
        likes: document.getElementById("likesSection")
    };

    const buttons = {
        posts: document.getElementById("myPostTabButton"),
        bookmark: document.getElementById("bookmarkTabButton"),
        likes: document.getElementById("likeTabButton")
    };

    /* 하나의 탭만 활성화하고 나머지 패널은 숨깁니다. */
    function showTab(tabName, scrollToSection) {
        if (!sections[tabName]) tabName = "posts";

        Object.keys(sections).forEach(function (name) {
            const active = (name === tabName);
            sections[name].hidden = !active;
            buttons[name].classList.toggle("is-active", active);
            buttons[name].setAttribute("aria-selected", String(active));
        });

        if (scrollToSection) {
            sections[tabName].scrollIntoView({ behavior: "smooth", block: "start" });
        }
    }

    /* 탭 클릭 시 해당 목록 표시 */
    Object.keys(buttons).forEach(function (name) {
        buttons[name].addEventListener("click", function () {
            showTab(name, name !== "posts");
        });
    });

    /* 헤더의 북마크 링크 및 직접 탭 URL 접근 지원 */
    const params = new URLSearchParams(window.location.search);
    const tabParam = params.get("tab");
    if (tabParam === "bookmark" || window.location.hash === "#bookmarkSection") {
        showTab("bookmark", false);
    } else if (tabParam === "likes" || window.location.hash === "#likesSection") {
        showTab("likes", false);
    } else {
        showTab("posts", false);
    }

    /* 기존 프로필 정보 수정 폼 열기/닫기는 그대로 유지 */
    const profileEditButton = document.getElementById("profileEditButton");
    const profileEditWrap = document.getElementById("profileEditWrap");
    const profileEditCancel = document.getElementById("profileEditCancel");

    if (profileEditButton && profileEditWrap) {
        profileEditButton.addEventListener("click", function () {
            profileEditWrap.classList.add("is-open");
            profileEditButton.hidden = true;
        });
    }

    if (profileEditCancel && profileEditWrap && profileEditButton) {
        profileEditCancel.addEventListener("click", function () {
            profileEditWrap.classList.remove("is-open");
            profileEditButton.hidden = false;
        });
    }

    /* 회원탈퇴 입력창 열기/닫기 및 최종 확인 */
    var withdrawButton = document.getElementById("withdrawOpenButton");
    var withdrawPanel = document.getElementById("withdrawPanel");
    var withdrawCancelButton = document.getElementById("withdrawCancelButton");
    var withdrawForm = document.getElementById("withdrawForm");

    if (withdrawButton && withdrawPanel) {
        withdrawButton.addEventListener("click", function () {
            withdrawPanel.hidden = !withdrawPanel.hidden;
            withdrawButton.setAttribute("aria-expanded", String(!withdrawPanel.hidden));
        });
    }
    if (withdrawCancelButton && withdrawPanel && withdrawButton) {
        withdrawCancelButton.addEventListener("click", function () {
            withdrawPanel.hidden = true;
            withdrawButton.setAttribute("aria-expanded", "false");
        });
    }
    if (withdrawForm) {
        withdrawForm.addEventListener("submit", function (event) {
            if (!window.confirm("정말 탈퇴하시겠습니까? 탈퇴 후에는 다시 로그인할 수 없습니다.")) {
                event.preventDefault();
            }
        });
    }
})();
</script>

<%--
프로필 이미지 저장 전 미리보기
- 이미지 파일을 선택하면 기존 .mypage-avatar에 즉시 표시합니다.
- 취소하거나 잘못된 파일을 선택하면 저장된 프로필 사진으로 되돌립니다.
- 미리보기는 브라우저에서만 진행되며 실제 저장은 업로드 버튼을 눌러야 합니다.
--%>
<script>
(function () {
    "use strict";

    var avatar = document.getElementById("profileAvatar");
    var input = document.getElementById("profileImageInput");
    var cancelButton = document.getElementById("profilePreviewCancel");
    var message = document.getElementById("profilePreviewMessage");

    if (!avatar || !input || !cancelButton || !message) return;

    // 미리보기 전의 실제 프로필 이미지(또는 base.png)를 보존합니다.
    var savedSrc = avatar.getAttribute("src") || avatar.getAttribute("data-default-src");
    var defaultSrc = avatar.getAttribute("data-default-src") || savedSrc;
    var previewUrl = null;
    var maxSize = 5 * 1024 * 1024;
    var allowedTypes = {
        "image/jpeg": true,
        "image/png": true,
        "image/gif": true,
        "image/webp": true
    };

    function clearPreview() {
        if (previewUrl) {
            URL.revokeObjectURL(previewUrl);
            previewUrl = null;
        }
        avatar.onerror = function () {
            avatar.onerror = null;
            avatar.src = defaultSrc;
        };
        avatar.src = savedSrc;
        input.value = "";
        cancelButton.hidden = true;
        message.textContent = "파일을 선택하면 위 프로필 사진에서 미리볼 수 있습니다.";
    }

    input.addEventListener("change", function () {
        var file = input.files && input.files[0];

        if (!file) {
            clearPreview();
            return;
        }

        if (!allowedTypes[file.type]) {
            clearPreview();
            message.textContent = "JPG, PNG, GIF, WEBP 이미지만 선택할 수 있습니다.";
            return;
        }

        if (file.size > maxSize) {
            clearPreview();
            message.textContent = "이미지 크기는 5MB 이하여야 합니다.";
            return;
        }

        // 먼저 이미지로 로딩 가능한 파일인지 확인합니다.
        var candidateUrl = URL.createObjectURL(file);
        var checker = new Image();
        checker.onload = function () {
            // 다른 파일을 다시 선택한 경우 이전 작업은 무시합니다.
            if (!input.files || input.files[0] !== file) {
                URL.revokeObjectURL(candidateUrl);
                return;
            }
            if (previewUrl) URL.revokeObjectURL(previewUrl);
            previewUrl = candidateUrl;
            avatar.onerror = function () {
                clearPreview();
                message.textContent = "이미지를 미리볼 수 없습니다. 다른 파일을 선택해 주세요.";
            };
            avatar.src = previewUrl;
            cancelButton.hidden = false;
            message.textContent = "저장 전 미리보기입니다. '프로필 이미지 변경'을 눌러야 적용됩니다.";
        };
        checker.onerror = function () {
            URL.revokeObjectURL(candidateUrl);
            if (input.files && input.files[0] === file) {
                clearPreview();
                message.textContent = "올바른 이미지 파일을 선택해 주세요.";
            }
        };
        checker.src = candidateUrl;
    });

    cancelButton.addEventListener("click", clearPreview);

    // 사용자가 저장하지 않고 페이지를 떠날 때 미리보기 Blob URL을 해제합니다.
    window.addEventListener("pagehide", function () {
        if (previewUrl) URL.revokeObjectURL(previewUrl);
    });
})();
</script>

<script defer src="<%=request.getContextPath()%>/resources/js/bookmark-ajax.js?v=20261105-1"></script>
<%@ include file="/include/footer.jsp" %>
