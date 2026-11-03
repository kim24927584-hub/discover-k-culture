<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.PostDAO" %>
<%@ page import="dto.PostDTO" %>
<%
request.setCharacterEncoding("UTF-8");

Long memberId = (Long) session.getAttribute("memberId");
if (memberId == null) {
    response.sendRedirect(request.getContextPath() + "/member/login.jsp");
    return;
}

if (!"POST".equalsIgnoreCase(request.getMethod())) {
    response.sendRedirect(request.getContextPath() + "/home.jsp");
    return;
}

try {
    long postId = Long.parseLong(request.getParameter("id"));
    PostDAO postDAO = new PostDAO();
    PostDTO post = postDAO.selectById(postId);

    if (post == null) {
        response.sendRedirect(request.getContextPath() + "/home.jsp");
        return;
    }

    if (post.getMemberId() != memberId.longValue()) {

String redirectPath;
if ("FREE".equals(post.getBoardType())) {
    redirectPath = "/board/allView.jsp?id=" + post.getPostId();
} else if ("QUESTION".equals(post.getBoardType())) {
    redirectPath = "/board/qnaView.jsp?id=" + post.getPostId();
} else {
    redirectPath = "/board/category-view.jsp?postId=" + post.getPostId();
}
response.sendRedirect(request.getContextPath() + redirectPath);

        return;
    }

    int result = postDAO.delete(postId, memberId.longValue());

    if (result <= 0) {

String redirectPath;
if ("FREE".equals(post.getBoardType())) {
    redirectPath = "/board/allView.jsp?id=" + post.getPostId();
} else if ("QUESTION".equals(post.getBoardType())) {
    redirectPath = "/board/qnaView.jsp?id=" + post.getPostId();
} else {
    redirectPath = "/board/category-view.jsp?postId=" + post.getPostId();
}
response.sendRedirect(request.getContextPath() + redirectPath);

        return;
    }

    String listPath;
    if ("FREE".equals(post.getBoardType())) {
        listPath = "/board/allList.jsp";
    } else if ("QUESTION".equals(post.getBoardType())) {
        listPath = "/board/qnaList.jsp";
    } else {
        listPath = "/board/category.jsp";
    }

    response.sendRedirect(request.getContextPath() + listPath);
} catch (Exception e) {
    throw new ServletException("게시글 삭제 처리 중 오류가 발생했습니다.", e);
}
%>
