<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="java.util.List" %>

<%@ page import="dao.MemberDAO" %>
<%@ page import="dao.PostDAO" %>
<%@ page import="dao.BookmarkListDAO" %>

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

if (member == null) {

    response.sendRedirect(
        request.getContextPath()
        + "/member/logout.jsp"
    );

    return;
}


/* =========================================================
   3. 프로필 이미지 주소 결정
   ========================================================= */
String profileSrc =
    request.getContextPath()
    + "/resources/assets/icon-user-profile-3682323.png";

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
   6. 처음 표시할 탭
   ---------------------------------------------------------
   상단 헤더의 북마크 버튼에서

   mypage.jsp?tab=bookmark#bookmarkSection

   으로 들어오면 북마크 탭을 바로 표시합니다.
   ========================================================= */
String selectedTab =
    request.getParameter("tab");

boolean showBookmarkTab =
    "bookmark".equals(
        selectedTab
    );


/* =========================================================
   7. 공통 헤더 설정
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
    "mypage.css"
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
            src="<%=profileSrc%>"
            alt="프로필 이미지"
            class="mypage-avatar">


        <div class="mypage-info">

            <h2>
                <%=h(member.getNickname())%>님
            </h2>


            <ul class="mypage-meta">

                <li>
                    아이디 :
                    <%=h(member.getLoginId())%>
                </li>

                <li>
                    이메일 :
                    <%=h(member.getEmail())%>
                </li>

                <li>
                    국적 :
                    <%=member.getNationality() == null
                        || member.getNationality()
                            .trim()
                            .isEmpty()
                        ? "-"
                        : h(member.getNationality())%>
                </li>

                <li>
                    회원 상태 :
                    <%=h(member.getStatus())%>
                </li>

            </ul>


            <%-- =============================================
                 프로필 이미지 변경

                 기존 ProfileImageUploadServlet의
                 /member/profile-image 주소를 그대로 사용합니다.
                 ============================================= --%>
            <form
                action="<%=request.getContextPath()%>/member/profile-image"
                method="post"
                enctype="multipart/form-data">

                <input
                    type="file"
                    name="profileImage"
                    accept="image/jpeg,image/png,image/gif,image/webp"
                    required>

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
         내 활동 탭
         -----------------------------------------------------
         기존 CSS의 .tabs / .tab-btn 클래스를 그대로 사용합니다.

         1. 내 게시글
         2. 내 북마크
         ===================================================== --%>
    <div class="tabs">

        <button
            type="button"
            id="myPostTabButton"
            class="tab-btn <%=showBookmarkTab ? "" : "is-active"%>">

            내 게시글
            (<%=myPosts == null ? 0 : myPosts.size()%>)

        </button>


        <button
            type="button"
            id="bookmarkTabButton"
            class="tab-btn <%=showBookmarkTab ? "is-active" : ""%>">

            ★ 내 북마크
            (<%=myBookmarks == null ? 0 : myBookmarks.size()%>)

        </button>

    </div>


    <%-- =====================================================
         내 게시글 영역
         ===================================================== --%>
    <section
        id="myPostSection"
        <%=showBookmarkTab ? "hidden" : ""%>>

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


        <div class="board-list">

            <%
            if (
                myBookmarks == null
                || myBookmarks.isEmpty()
            ) {
            %>

                <div class="board-item">

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

                        <%-- 제목 클릭 → 원래 게시글 상세보기 --%>
                        <a
                            class="board-title"
                            href="<%=bookmarkDetailUrl(request.getContextPath(), post)%>">

                            <%=h(post.getTitle())%>

                        </a>


                        <div class="board-meta">

                            작성자
                            <%=h(post.getMemberNickname())%>

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
                            method="post">

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

</main>


<%@ include file="/include/sidebar.jsp" %>


<%-- ========================================================
     탭 전환 JavaScript
     --------------------------------------------------------
     별도 CSS 추가 없이 hidden 속성만 변경합니다.

     URL에 ?tab=bookmark가 있거나
     #bookmarkSection으로 접근하면 북마크 탭을 활성화합니다.
     ======================================================== --%>
<script>
(function () {

    const myPostButton =
        document.getElementById(
            "myPostTabButton"
        );

    const bookmarkButton =
        document.getElementById(
            "bookmarkTabButton"
        );

    const myPostSection =
        document.getElementById(
            "myPostSection"
        );

    const bookmarkSection =
        document.getElementById(
            "bookmarkSection"
        );


    /*
     * 내 게시글 탭 표시
     */
    function showMyPosts() {

        myPostSection.hidden =
            false;

        bookmarkSection.hidden =
            true;

        myPostButton.classList.add(
            "is-active"
        );

        bookmarkButton.classList.remove(
            "is-active"
        );
    }


    /*
     * 북마크 탭 표시
     */
    function showBookmarks() {

        myPostSection.hidden =
            true;

        bookmarkSection.hidden =
            false;

        bookmarkButton.classList.add(
            "is-active"
        );

        myPostButton.classList.remove(
            "is-active"
        );
    }


    myPostButton.addEventListener(
        "click",
        showMyPosts
    );


    bookmarkButton.addEventListener(
        "click",
        function () {

            showBookmarks();

            /*
             * 북마크 영역 위치로 부드럽게 이동
             */
            bookmarkSection.scrollIntoView({
                behavior: "smooth",
                block: "start"
            });
        }
    );


    /*
     * 상단 헤더의 북마크 버튼으로 들어온 경우
     * 자동으로 북마크 탭을 엽니다.
     */
    const params =
        new URLSearchParams(
            window.location.search
        );

    if (
        params.get("tab") === "bookmark"
        || window.location.hash === "#bookmarkSection"
    ) {

        showBookmarks();
    }

})();
</script>


<%@ include file="/include/footer.jsp" %>
