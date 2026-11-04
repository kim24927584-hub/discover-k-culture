<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="dao.BookmarkDAO"%>
<%@ page import="dao.PostDAO"%>
<%@ page import="dto.PostDTO"%>

<%!
/*
 * 게시판 종류별 상세보기 주소
 *
 * 북마크 등록/해제 후 사용자가 보고 있던 게시글로 돌아가기 위해
 * boardType에 맞는 상세보기 주소를 만들어 줍니다.
 */
private String viewUrl(
    PostDTO post
) {

    if (
        "KCULTURE".equals(
            post.getBoardType()
        )
    ) {

        return "/board/category-view.jsp?postId="
            + post.getPostId()
            + "&skipView=1";
    }

    if (
        "QUESTION".equals(
            post.getBoardType()
        )
    ) {

        return "/board/qnaView.jsp?id="
            + post.getPostId()
            + "&skipView=1";
    }

    return "/board/allView.jsp?id="
        + post.getPostId()
        + "&skipView=1";
}
%>


<%
/* =========================================================
   1. 로그인 확인
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
   2. 게시글 번호 확인
   ========================================================= */
/* 데이터 변경 처리는 POST 요청만 허용합니다. */
if (!"POST".equalsIgnoreCase(request.getMethod())) {
    response.sendRedirect(request.getContextPath() + "/home.jsp");
    return;
}

long postId;

try {

    postId =
        Long.parseLong(
            request.getParameter(
                "postId"
            )
        );

} catch (Exception e) {

    response.sendRedirect(
        request.getContextPath()
        + "/board/allList.jsp"
    );

    return;
}


/* =========================================================
   3. 실제 존재하는 게시글인지 확인
   ========================================================= */
PostDTO post =
    new PostDAO().selectById(
        postId
    );

if (post == null) {

    response.sendRedirect(
        request.getContextPath()
        + "/board/allList.jsp"
    );

    return;
}


/* =========================================================
   4. 북마크 토글
   ---------------------------------------------------------
   기존 BookmarkDAO.toggle()을 그대로 사용합니다.

   북마크가 없으면 INSERT
   북마크가 있으면 DELETE
   ========================================================= */
new BookmarkDAO().toggle(
    memberId.longValue(),
    postId
);


/* =========================================================
   5. 원래 게시글 상세화면으로 이동
   ========================================================= */
response.sendRedirect(
    request.getContextPath()
    + viewUrl(post)
);
%>
