<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dao.PostDislikeDAO" %>
<%@ page import="dao.PostLikeDAO" %>
<%@ page import="dao.PostDAO" %>
<%@ page import="dao.MemberDAO" %>
<%@ page import="dto.PostDTO" %>
<%!
/*
 * 기존 일반 폼 POST 방식도 지원합니다. (JavaScript 비활성/구형 호출)
 * JavaScript fetch 요청이면 페이지 이동 대신 최신 반응 상태를 JSON으로 반환합니다.
 */
private String viewUrl(PostDTO post) {
    if ("KCULTURE".equals(post.getBoardType())) return "/board/category-view.jsp?postId=" + post.getPostId() + "&skipView=1";
    if ("QUESTION".equals(post.getBoardType())) return "/board/qnaView.jsp?id=" + post.getPostId() + "&skipView=1";
    return "/board/allView.jsp?id=" + post.getPostId() + "&skipView=1";
}

private void replyError(jakarta.servlet.http.HttpServletResponse response,
        jakarta.servlet.jsp.JspWriter out, int status, String code) throws java.io.IOException {
    response.setStatus(status);
    response.setContentType("application/json; charset=UTF-8");
    // code는 아래에서 사용하는 고정 문자열만 전달하므로 JSON에 외부 입력값이 들어가지 않습니다.
    out.print("{\"success\":false,\"error\":\"" + code + "\"}");
}
%>
<%
request.setCharacterEncoding("UTF-8");
String ctx = request.getContextPath();
boolean ajax = "XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With"));

/* 1. 로그인 확인 */
Long memberId = (Long) session.getAttribute("memberId");
if (memberId == null) {
    if (ajax) { replyError(response, out, 401, "LOGIN_REQUIRED"); return; }
    response.sendRedirect(ctx + "/member/login.jsp"); return;
}

/* 2. 변경 요청은 POST만 허용: 공통 CsrfFilter의 _csrf 검증을 그대로 적용 */
if (!"POST".equalsIgnoreCase(request.getMethod())) {
    if (ajax) { replyError(response, out, 405, "METHOD_NOT_ALLOWED"); return; }
    response.sendRedirect(ctx + "/home.jsp"); return;
}

/* 3. 대상 ID와 존재 여부 확인 */
long postId;
try { postId = Long.parseLong(request.getParameter("postId")); if (postId <= 0) throw new NumberFormatException(); }
catch (Exception e) {
    if (ajax) { replyError(response, out, 400, "BAD_REQUEST"); return; }
    response.sendRedirect(ctx + "/board/allList.jsp"); return;
}

PostDTO post = new PostDAO().selectById(postId);
if (post == null) {
    if (ajax) { replyError(response, out, 404, "POST_NOT_FOUND"); return; }
    response.sendRedirect(ctx + "/board/allList.jsp"); return;
}

/* 4. 정지된 회원은 반응을 변경할 수 없습니다. */
try {
    if (new MemberDAO().isSuspended(memberId.longValue())) {
        if (ajax) { replyError(response, out, 403, "SUSPENDED"); return; }
        response.sendRedirect(ctx + viewUrl(post)); return;
    }

    /* 5. 기존 DAO의 토글/상호해제/트랜잭션 기능은 변경하지 않습니다. */
    new PostDislikeDAO().toggle(memberId.longValue(), postId);

    if (ajax) {
        /* 6. 화면 표시 값은 요청 전 숫자를 임의로 +/-하지 않고 DB에서 다시 확인합니다. */
        PostDTO fresh = new PostDAO().selectById(postId);
        if (fresh == null) { replyError(response, out, 404, "NOT_FOUND"); return; }
        boolean liked = new PostLikeDAO().exists(memberId.longValue(), postId);
        boolean disliked = new PostDislikeDAO().exists(memberId.longValue(), postId);
        response.setContentType("application/json; charset=UTF-8");
        response.setHeader("Cache-Control", "no-store");
        out.print("{\"success\":true,\"liked\":" + liked
                + ",\"disliked\":" + disliked
                + ",\"likeCount\":" + fresh.getLikeCount()
                + ",\"dislikeCount\":" + fresh.getDislikeCount() + "}");
        return;
    }
} catch (Exception e) {
    application.log("board dislike 처리 실패", e);
    if (ajax) { replyError(response, out, 500, "SERVER_ERROR"); return; }
    throw new jakarta.servlet.ServletException("추천/비추천 처리 실패", e);
}

/* JavaScript 없는 환경에서는 이전과 같이 상세보기로 돌아갑니다. */
response.sendRedirect(ctx + viewUrl(post));
%>
