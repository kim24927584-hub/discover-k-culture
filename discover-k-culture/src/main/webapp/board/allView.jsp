<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%--
[allView.jsp] 기존 일반(FREE) 게시글 상세보기
처리 흐름
1. id 파라미터로 게시글을 조회하고 FREE 글인지 확인합니다.
2. 일반 상세 진입일 때 조회수를 증가시킵니다.
3. 첨부 이미지/영상과 댓글을 조회합니다.
4. 로그인/정지/작성자/관리자 여부를 판별합니다.
5. 추천/비추천/북마크 및 게시글 수정/삭제 기능을 제공합니다.
6. 댓글 작성/삭제/추천/비추천 기능을 권한에 따라 제공합니다.
--%>

<%@ page import="java.util.List" %>
<%@ page import="dao.PostDAO" %>
<%@ page import="dao.PostImageDAO" %>
<%@ page import="dao.PostVideoDAO" %>
<%@ page import="dao.CommentDAO" %>
<%@ page import="dao.PostLikeDAO" %>
<%@ page import="dao.PostDislikeDAO" %>
<%@ page import="dao.BookmarkDAO" %>
<%@ page import="dao.CommentLikeDAO" %>
<%@ page import="dao.CommentDislikeDAO" %>
<%@ page import="dao.MemberDAO" %>
<%@ page import="dto.PostDTO" %>
<%@ page import="dto.PostImageDTO" %>
<%@ page import="dto.PostVideoDTO" %>
<%@ page import="dto.CommentDTO" %>
<%@ page import="dto.MemberDTO" %>
<%!
// 화면에 출력할 문자열의 HTML 특수문자를 치환하여 XSS 위험을 줄입니다.
private String h(String value) {
    if (value == null) return "";
    return value.replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;");
}
%>
<%
// 한글 파라미터가 깨지지 않도록 요청 인코딩을 UTF-8로 지정합니다.
request.setCharacterEncoding("UTF-8");

// 1. URL에서 게시글 번호를 읽고 숫자가 아니면 목록 화면으로 이동합니다.
long postId;
try { postId = Long.parseLong(request.getParameter("id")); }
catch (Exception e) { response.sendRedirect(request.getContextPath() + "/board/allList.jsp"); return; }

// 2. 게시글을 조회하고 이 상세화면에서 처리할 게시판 종류가 맞는지 확인합니다.
PostDAO postDAO = new PostDAO();
PostDTO post = postDAO.selectById(postId);
if (post == null || !"FREE".equals(post.getBoardType())) {
    response.sendRedirect(request.getContextPath() + "/board/allList.jsp");
    return;
}

// 3. 추천/댓글 처리 후 돌아온 요청은 skipView=1로 조회수 중복 증가를 막습니다.
boolean skipViewCount = "1".equals(request.getParameter("skipView"));
if (!skipViewCount) {
    postDAO.increaseViewCount(postId);
    post = postDAO.selectById(postId);
}

// 4. 게시글에 연결된 이미지, 영상, 댓글을 각각 조회합니다.
List<PostImageDTO> images = new PostImageDAO().selectByPostId(postId);
List<PostVideoDTO> videos = new PostVideoDAO().selectByPostId(postId);
List<CommentDTO> comments = new CommentDAO().selectByPostId(postId);

// 5. 현재 로그인 사용자와 권한 상태를 확인합니다.
Long memberId = (Long) session.getAttribute("memberId");
boolean loggedIn = memberId != null;
MemberDTO currentMember = loggedIn ? new MemberDAO().selectById(memberId.longValue()) : null;
boolean suspended = currentMember != null && "SUSPENDED".equals(currentMember.getStatus());
boolean owner = loggedIn && post.getMemberId() == memberId.longValue();
boolean admin = "ADMIN".equals(session.getAttribute("role"));

// 6. 게시글/댓글의 추천·비추천·북마크 상태 확인에 사용할 DAO를 준비합니다.
PostLikeDAO postLikeDAO = new PostLikeDAO();
PostDislikeDAO postDislikeDAO = new PostDislikeDAO();
BookmarkDAO bookmarkDAO = new BookmarkDAO();
CommentLikeDAO commentLikeDAO = new CommentLikeDAO();
CommentDislikeDAO commentDislikeDAO = new CommentDislikeDAO();

// 7. 현재 사용자가 이미 누른 반응을 확인하여 버튼 상태에 반영합니다.
boolean postLiked = loggedIn && postLikeDAO.exists(memberId.longValue(), postId);
boolean postDisliked = loggedIn && postDislikeDAO.exists(memberId.longValue(), postId);
boolean bookmarked = loggedIn && bookmarkDAO.exists(memberId.longValue(), postId);

// 8. header.jsp에서 사용할 메뉴/CSS/제목 정보를 설정합니다.
request.setAttribute("activeMenu", "ALL");
request.setAttribute("pageTitle", "게시글 상세보기");
request.setAttribute("pageCss", "board/common/viewCommon.css");
%>

<%@include file="/include/header.jsp" %>

<%-- ===== 기존 일반 게시글 제목/작성자/조회 정보 ===== --%>
<main class="container">
  <h1 class="post-title"><%=h(post.getTitle())%></h1>
  <span class="post-meta">
    <span class="post-writer"><%=h(post.getMemberNickname())%></span> · 조회 <%=post.getViewCount()%> ·
    추천 <%=post.getLikeCount()%> · 비추천 <%=post.getDislikeCount()%> ·
    <%=post.getCreatedAt() == null ? "-" : post.getCreatedAt().toString().substring(0, 16)%>
  </span>

  <%-- ===== 첨부파일과 게시글 본문 ===== --%>
  <div class="post-body">
    <% if (images != null) { for (PostImageDTO image : images) { %>
      <img src="<%=request.getContextPath() + image.getImagePath()%>"
           alt="<%=h(image.getImageName() == null ? "게시글 이미지" : image.getImageName())%>">
    <% } } %>

    <% if (videos != null) { for (PostVideoDTO video : videos) { %>
      <video src="<%=request.getContextPath() + video.getVideoPath()%>" controls
        <% if (video.getThumbnailPath() != null && !video.getThumbnailPath().trim().isEmpty()) { %>
        poster="<%=request.getContextPath() + video.getThumbnailPath()%>"
        <% } %> width="640">이 브라우저는 video 태그를 지원하지 않습니다.</video>
    <% } } %>

    <p class="post-content"><%=h(post.getContent()).replace("\n", "<br>")%></p>

    <%-- ===== 게시글 추천/비추천/북마크 ===== --%>
    <div class="post-actions">
      <div class="like-box">
        <% if (loggedIn && !suspended) { %>
          <form action="<%=request.getContextPath()%>/board/process/board/likeProcess.jsp" method="post">
            <input type="hidden" name="postId" value="<%=postId%>">
            <button type="submit" class="action-btn post-reaction <%=postLiked ? "active" : ""%>">👍 <%=post.getLikeCount()%></button>
          </form>
          <form action="<%=request.getContextPath()%>/board/process/board/dislikeProcess.jsp" method="post">
            <input type="hidden" name="postId" value="<%=postId%>">
            <button type="submit" class="action-btn post-reaction <%=postDisliked ? "active" : ""%>">👎 <%=post.getDislikeCount()%></button>
          </form>
        <% } else { %>
          <span class="action-btn post-reaction">👍 <%=post.getLikeCount()%></span>
          <span class="action-btn post-reaction">👎 <%=post.getDislikeCount()%></span>
        <% } %>
      </div>

      <% if (loggedIn) { %>
      <form action="<%=request.getContextPath()%>/board/process/board/bookmarkProcess.jsp" method="post"
            class="post-bookmark <%=bookmarked ? "active" : ""%>">
        <input type="hidden" name="postId" value="<%=postId%>">
        <button type="submit" class="action-btn">
          <span class="icon-off">☆</span><span class="icon-on">★</span> 북마크
        </button>
      </form>
      <% } %>
    </div>
  </div>

  <%-- ===== 목록 이동 및 작성자 전용 수정/삭제 ===== --%>
  <a href="<%=request.getContextPath()%>/board/allList.jsp" class="btn btn-list"><span class="btn-arrow">←</span>목록</a>
  <% if (owner && !suspended) { %>
    <a href="<%=request.getContextPath()%>/board/process/board/edit.jsp?id=<%=postId%>" class="btn">수정</a>
  <% } %>
  <% if (owner) { %>
    <form action="<%=request.getContextPath()%>/board/process/board/deleteProcess.jsp" method="post"
          onsubmit="return confirm('삭제하시겠습니까?');">
      <input type="hidden" name="id" value="<%=postId%>">
      <button type="submit" class="btn">삭제</button>
    </form>
  <% } %>

  <%-- ===== 댓글 영역 ===== --%>
  <h3 class="comments-title">Comments <span class="comment-count">(<%=comments == null ? 0 : comments.size()%>)</span></h3>

  <% if (loggedIn && !suspended) { %>
    <form class="comment-write" action="<%=request.getContextPath()%>/board/process/comment/writeProcess.jsp" method="post">
      <input type="hidden" name="postId" value="<%=postId%>">
      <input class="comment-write-input" type="text" name="content" maxlength="1000" placeholder="댓글을 입력하세요" required>
      <button type="submit" class="btn comment-button">댓글 작성</button>
    </form>
  <% } else if (!loggedIn) { %>
    <p><a href="<%=request.getContextPath()%>/member/login.jsp">로그인</a> 후 댓글과 추천 기능을 사용할 수 있습니다.</p>
  <% } else if (suspended) { %>
    <p>정지 회원은 댓글 및 반응 기능을 사용할 수 없습니다.</p>
  <% } %>

  <%-- 댓글 목록: 삭제 권한과 추천/비추천 상태를 댓글마다 계산합니다. --%>
  <div class="comments" id="comments">
  <% if (comments == null || comments.isEmpty()) { %>
    <div class="comment"><div class="comment-body"><p class="comment-text">아직 등록된 댓글이 없습니다.</p></div></div>
  <% } else { for (CommentDTO comment : comments) {
       boolean commentLiked = loggedIn && commentLikeDAO.exists(memberId.longValue(), comment.getCommentId());
       boolean commentDisliked = loggedIn && commentDislikeDAO.exists(memberId.longValue(), comment.getCommentId());
       boolean canDelete = loggedIn && (comment.getMemberId() == memberId.longValue() || admin);
  %>
    <div class="comment" id="comment-<%=comment.getCommentId()%>">
      <div class="comment-body">
        <span><%=h(comment.getMemberNickname())%></span>
        <span class="comment-meta"><%=comment.getCreatedAt() == null ? "-" : comment.getCreatedAt().toString().substring(0, 16)%></span>
        <p class="comment-text"><%=h(comment.getContent()).replace("\n", "<br>")%></p>
        <% if (canDelete) { %>
          <form action="<%=request.getContextPath()%>/board/process/comment/deleteProcess.jsp" method="post"
                onsubmit="return confirm('댓글을 삭제하시겠습니까?');">
            <input type="hidden" name="commentId" value="<%=comment.getCommentId()%>">
            <input type="hidden" name="postId" value="<%=postId%>">
            <button type="submit" class="btn">삭제</button>
          </form>
        <% } %>
      </div>
      <div>
        <% if (loggedIn && !suspended) { %>
          <form action="<%=request.getContextPath()%>/board/process/comment/likeProcess.jsp" method="post">
            <input type="hidden" name="commentId" value="<%=comment.getCommentId()%>">
            <input type="hidden" name="postId" value="<%=postId%>">
            <button type="submit" class="comment-like <%=commentLiked ? "active" : ""%>">👍 <%=comment.getLikeCount()%></button>
          </form>
          <form action="<%=request.getContextPath()%>/board/process/comment/dislikeProcess.jsp" method="post">
            <input type="hidden" name="commentId" value="<%=comment.getCommentId()%>">
            <input type="hidden" name="postId" value="<%=postId%>">
            <button type="submit" class="comment-like <%=commentDisliked ? "active" : ""%>">👎 <%=comment.getDislikeCount()%></button>
          </form>
        <% } else { %>
          <span class="comment-like">👍 <%=comment.getLikeCount()%></span>
          <span class="comment-like">👎 <%=comment.getDislikeCount()%></span>
        <% } %>
      </div>
    </div>
  <% } } %>
  </div>
</main>

<%@include file="/include/sidebar.jsp" %>
<%@include file="/include/footer.jsp" %>
