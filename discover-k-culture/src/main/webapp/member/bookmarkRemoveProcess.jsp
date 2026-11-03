<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="dao.BookmarkListDAO" %>

<%
request.setCharacterEncoding("UTF-8");


/* =========================================================
   1. 로그인 확인
   ---------------------------------------------------------
   북마크는 회원 개인 데이터이므로 로그인한 회원만
   삭제할 수 있습니다.
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
   주소창에 URL을 직접 입력하는 방식으로 북마크가
   삭제되지 않도록 POST 요청만 처리합니다.
   ========================================================= */
if (
    !"POST".equalsIgnoreCase(
        request.getMethod()
    )
) {

    response.sendRedirect(
        request.getContextPath()
        + "/member/mypage.jsp"
        + "?tab=bookmark#bookmarkSection"
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
        + "/member/mypage.jsp"
        + "?tab=bookmark#bookmarkSection"
    );

    return;
}


/* =========================================================
   4. 현재 로그인 사용자의 북마크만 삭제
   ---------------------------------------------------------
   BookmarkListDAO.delete()는

   WHERE member_id = ?
   AND post_id = ?

   조건을 사용하므로 다른 회원의 북마크를 삭제할 수 없습니다.
   ========================================================= */
try {

    BookmarkListDAO bookmarkDAO =
        new BookmarkListDAO();

    bookmarkDAO.delete(
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
   5. 별도 bookmarkList.jsp가 아니라
      마이페이지의 북마크 탭으로 다시 이동
   ========================================================= */
response.sendRedirect(
    request.getContextPath()
    + "/member/mypage.jsp"
    + "?tab=bookmark#bookmarkSection"
);
%>
