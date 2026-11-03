<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="dao.BookmarkListDAO" %>

<%
request.setCharacterEncoding(
    "UTF-8"
);


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
   2. POST 요청만 허용
   ---------------------------------------------------------
   URL 직접 입력으로 북마크가 삭제되는 것을 방지합니다.
   ========================================================= */
if (
    !"POST".equalsIgnoreCase(
        request.getMethod()
    )
) {

    response.sendRedirect(
        request.getContextPath()
        + "/member/bookmarkList.jsp"
    );

    return;
}


/* =========================================================
   3. 삭제할 게시글 번호 확인
   ========================================================= */
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
        + "/member/bookmarkList.jsp"
    );

    return;
}


/* =========================================================
   4. 북마크 삭제
   ---------------------------------------------------------
   memberId + postId를 함께 조건으로 사용하므로
   현재 로그인 회원의 북마크만 삭제됩니다.
   ========================================================= */
try {

    BookmarkListDAO dao =
        new BookmarkListDAO();

    dao.delete(
        memberId.longValue(),
        postId
    );

} catch (Exception e) {

    throw new ServletException(
        "북마크 해제 중 오류가 발생했습니다.",
        e
    );
}


/* =========================================================
   5. 다시 북마크 목록으로 이동
   ========================================================= */
response.sendRedirect(
    request.getContextPath()
    + "/member/bookmarkList.jsp"
);
%>
