<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="java.util.List" %>
<%@ page import="dao.BookmarkListDAO" %>
<%@ page import="dto.BookmarkPostDTO" %>

<%!
/*
 * 화면에 문자열을 안전하게 출력하기 위한 HTML 이스케이프 함수
 */
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


/*
 * 게시판 종류에 따라 실제 상세보기 주소를 반환합니다.
 */
private String detailUrl(
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


/*
 * DB의 board_type을 화면에서 사용할 한글 이름으로 변경합니다.
 */
private String boardName(
    BookmarkPostDTO post
) {

    if (
        "KCULTURE".equals(
            post.getBoardType()
        )
    ) {

        if (
            post.getCategoryName() != null
            && !post.getCategoryName()
                .trim()
                .isEmpty()
        ) {

            return "K-컬처 · "
                + post.getCategoryName();
        }

        return "K-컬처";
    }

    if (
        "QUESTION".equals(
            post.getBoardType()
        )
    ) {

        return "질문게시판";
    }

    return "자유게시판";
}
%>


<%
request.setCharacterEncoding(
    "UTF-8"
);


/* =========================================================
   1. 로그인 확인
   ---------------------------------------------------------
   북마크는 회원 개인 데이터이므로 로그인하지 않은 사용자는
   로그인 화면으로 이동시킵니다.
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
   2. 로그인 회원의 북마크 목록 조회
   ========================================================= */
BookmarkListDAO bookmarkDAO =
    new BookmarkListDAO();

List<BookmarkPostDTO> bookmarks =
    bookmarkDAO.selectByMemberId(
        memberId.longValue()
    );


/* =========================================================
   3. 공통 header.jsp 설정
   ---------------------------------------------------------
   listCommon.css를 재사용하므로 새 CSS 파일은 필요하지 않습니다.
   ========================================================= */
request.setAttribute(
    "pageTitle",
    "내 북마크"
);

request.setAttribute(
    "pageCss",
    "board/common/listCommon.css"
);

request.setAttribute(
    "activeMenu",
    "BOOKMARK"
);
%>


<%@ include file="/include/header.jsp" %>


<main class="container">


    <%-- 페이지 제목 --%>
    <h1 class="board-title">
        내 북마크
    </h1>


    <%-- =====================================================
         북마크 목록
         -----------------------------------------------------
         기존 게시판 목록 CSS인 board-table을 그대로 사용합니다.
         ===================================================== --%>
    <table class="board-table">

        <thead>

            <tr>

                <th class="col-num">
                    번호
                </th>

                <th>
                    게시판
                </th>

                <th class="col-title">
                    제목
                </th>

                <th class="col-author">
                    작성자
                </th>

                <th class="col-date">
                    북마크 날짜
                </th>

                <th class="col-views">
                    조회
                </th>

                <th class="col-like">
                    추천
                </th>

                <th>
                    관리
                </th>

            </tr>

        </thead>


        <tbody data-bookmark-list>

        <%
        if (
            bookmarks == null
            || bookmarks.isEmpty()
        ) {
        %>

            <tr data-bookmark-empty>

                <td colspan="8">
                    북마크한 게시글이 없습니다.
                </td>

            </tr>

        <%
        } else {

            int number =
                bookmarks.size();

            for (
                BookmarkPostDTO post
                : bookmarks
            ) {
        %>

            <tr data-bookmark-item>


                <%-- 화면 순번 --%>
                <td class="col-num" data-bookmark-number>
                    <%=number--%>
                </td>


                <%-- 게시판 구분 --%>
                <td>
                    <%=h(boardName(post))%>
                </td>


                <%-- 제목 클릭 → 해당 게시글 상세보기 --%>
                <td class="col-title">

                    <a href="<%=detailUrl(request.getContextPath(), post)%>">
                        <%=h(post.getTitle())%>
                    </a>

                </td>


                <%-- 작성자 --%>
                <td class="col-author">
                    <%=h(post.getMemberNickname())%>
                </td>


                <%-- 북마크한 날짜 --%>
                <td class="col-date">

                    <%=
                    post.getBookmarkedAt() == null
                        ? "-"
                        : post.getBookmarkedAt()
                            .toString()
                            .substring(0, 10)
                    %>

                </td>


                <%-- 조회수 --%>
                <td class="col-views">
                    <%=post.getViewCount()%>
                </td>


                <%-- 추천수 --%>
                <td class="col-like">
                    <%=post.getLikeCount()%>
                </td>


                <%-- =========================================
                     북마크 해제
                     -----------------------------------------
                     현재 로그인 회원의 해당 북마크만 삭제합니다.
                     ========================================= --%>
                <td>

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
                            class="btn btn-list">
                            해제
                        </button>

                    </form>

                </td>

            </tr>

        <%
            }
        }
        %>

        </tbody>

    </table>


    <%-- 전체 게시글로 돌아가기 --%>
    <a
        href="<%=request.getContextPath()%>/board/allList.jsp"
        class="btn btn-list">

        ← 전체 게시글

    </a>

</main>


<%@ include file="/include/sidebar.jsp" %>
<script defer src="<%=request.getContextPath()%>/resources/js/bookmark-ajax.js?v=20261105-1"></script>
<%@ include file="/include/footer.jsp" %>
