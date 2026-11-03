<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="dao.PostDAO" %>
<%@ page import="dao.CategoryDAO" %>
<%@ page import="dao.MemberDAO" %>
<%@ page import="dao.PostImageDAO" %>
<%@ page import="dao.PostVideoDAO" %>
<%@ page import="dto.PostDTO" %>
<%@ page import="dto.CategoryDTO" %>
<%@ page import="dto.MemberDTO" %>
<%@ page import="dto.PostImageDTO" %>
<%@ page import="dto.PostVideoDTO" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
request.setCharacterEncoding("UTF-8");

Long memberId = (Long) session.getAttribute("memberId");
if (memberId == null) {
    response.sendRedirect(request.getContextPath() + "/member/login.jsp");
    return;
}

long postId;
try {
    postId = Long.parseLong(request.getParameter("id"));
} catch (Exception e) {
    response.sendRedirect(request.getContextPath() + "/home.jsp");
    return;
}

PostDTO post = new PostDAO().selectById(postId);
if (post == null || post.getMemberId() != memberId.longValue()) {
    response.sendRedirect(request.getContextPath() + "/home.jsp");
    return;
}

MemberDTO member = new MemberDAO().selectById(memberId.longValue());
if (member == null) {
    response.sendRedirect(request.getContextPath() + "/member/logout.jsp");
    return;
}

if ("SUSPENDED".equals(member.getStatus())) {
    response.sendRedirect(request.getContextPath() + "/member/mypage.jsp?restricted=post");
    return;
}

List<CategoryDTO> categories = new CategoryDAO().selectAll();
List<PostImageDTO> existingImages = new PostImageDAO().selectByPostId(postId);
List<PostVideoDTO> existingVideos = new PostVideoDAO().selectByPostId(postId);

request.setAttribute("editPost", post);
request.setAttribute("pageTitle", "게시글 수정");
request.setAttribute("pageCss", "board/write.css");

if ("QUESTION".equals(post.getBoardType())) {
    request.setAttribute("activeMenu", "QUESTION");
} else if ("KCULTURE".equals(post.getBoardType())) {
    request.setAttribute("activeMenu", "KCULTURE");
} else {
    request.setAttribute("activeMenu", "ALL");
}
%>

<%@ include file="/include/header.jsp" %>

<div class="write-page">
    <div class="write-layout">
        <main class="write-main">
            <section class="write-card">
                <div class="write-heading">
                    <span class="write-label">EDIT POST</span>
                    <h1>게시글 수정</h1>
                    <p>기존 첨부파일은 유지하거나 선택해서 제외할 수 있고, 새 파일도 추가할 수 있습니다.</p>
                </div>

                <form class="write-form"
                      action="<%=request.getContextPath()%>/board/process/board/edit"
                      method="post"
                      enctype="multipart/form-data">

                    <input type="hidden" name="postId" value="<%=postId%>">

                    <div class="write-field">
                        <label>게시판</label>
                        <select disabled>
                            <option selected>
                                <%= "QUESTION".equals(post.getBoardType())
                                    ? "질문게시판"
                                    : "KCULTURE".equals(post.getBoardType())
                                        ? "K-컬처 탐색"
                                        : "기존 일반 게시글" %>
                            </option>
                        </select>
                    </div>

                    <% if ("KCULTURE".equals(post.getBoardType())) { %>
                    <div class="write-field">
                        <label for="categoryId">카테고리</label>
                        <select id="categoryId" name="categoryId" required>
                            <option value="">카테고리 선택</option>
                            <% for (CategoryDTO category : categories) { %>
                            <option value="<%=category.getCategoryId()%>"
                                <%=category.getCategoryId() == post.getCategoryId() ? "selected" : ""%>>
                                <%=category.getName()%>
                            </option>
                            <% } %>
                        </select>
                    </div>
                    <% } %>

                    <div class="write-field">
                        <label for="postTitle">제목</label>
                        <input type="text" id="postTitle" name="title" maxlength="200"
                               value="<c:out value='${editPost.title}'/>" required>
                    </div>

                    <div class="write-field">
                        <label for="postContent">내용</label>
                        <textarea id="postContent" name="content" required><c:out value="${editPost.content}"/></textarea>
                    </div>

                    <% if (existingImages != null && !existingImages.isEmpty()) { %>
                    <div class="write-field">
                        <label>기존 이미지</label>
                        <div class="write-upload">
                            <p>삭제할 이미지만 체크해 주세요. 체크하지 않은 이미지는 그대로 유지됩니다.</p>
                            <% for (PostImageDTO image : existingImages) { %>
                            <label style="display:inline-block; margin:0 14px 14px 0; vertical-align:top;">
                                <img src="<%=request.getContextPath() + image.getImagePath()%>"
                                     alt="<%=image.getImageName() == null ? "기존 이미지" : image.getImageName()%>"
                                     style="display:block; width:140px; height:100px; object-fit:cover; margin-bottom:6px;">
                                <input type="checkbox" name="deleteImageIds" value="<%=image.getImageId()%>">
                                이 이미지 제외
                            </label>
                            <% } %>
                        </div>
                    </div>
                    <% } %>

                    <div class="write-field">
                        <label for="imageFiles">이미지 추가</label>
                        <div class="write-upload">
                            <p>새로 추가할 이미지를 선택해 주세요.</p>
                            <input type="file" id="imageFiles" name="images" accept="image/*" multiple>
                        </div>
                    </div>

                    <% if (existingVideos != null && !existingVideos.isEmpty()) { %>
                    <div class="write-field">
                        <label>기존 영상</label>
                        <div class="write-upload">
                            <p>삭제할 영상만 체크해 주세요. 체크하지 않은 영상은 그대로 유지됩니다.</p>
                            <% for (PostVideoDTO video : existingVideos) { %>
                            <label style="display:block; margin-bottom:16px;">
                                <video src="<%=request.getContextPath() + video.getVideoPath()%>"
                                       controls preload="metadata" style="display:block; width:260px; max-width:100%; margin-bottom:6px;"></video>
                                <input type="checkbox" name="deleteVideoIds" value="<%=video.getVideoId()%>">
                                이 영상 제외
                            </label>
                            <% } %>
                        </div>
                    </div>
                    <% } %>

                    <div class="write-field">
                        <label for="videoFiles">영상 추가</label>
                        <div class="write-upload">
                            <p>새로 추가할 MP4, WebM 영상을 선택해 주세요.</p>
                            <input type="file" id="videoFiles" name="videos" accept="video/mp4,video/webm" multiple>
                        </div>
                    </div>

                    <div class="write-actions">
                        <button type="button" id="cancelEditButton" class="write-button write-button-cancel">취소</button>
                        <button type="submit" class="write-button write-button-submit">수정 저장</button>
                    </div>
                </form>
            </section>
        </main>

        <%@ include file="/include/sidebar.jsp" %>
    </div>
</div>

<script>
(function () {
    var button = document.getElementById("cancelEditButton");
    if (!button) return;

    button.addEventListener("click", function () {
        <% if ("QUESTION".equals(post.getBoardType())) { %>
        window.location.href = "<%=request.getContextPath()%>/board/qnaView.jsp?id=<%=postId%>";
        <% } else if ("KCULTURE".equals(post.getBoardType())) { %>
        window.location.href = "<%=request.getContextPath()%>/board/category-view.jsp?postId=<%=postId%>";
        <% } else { %>
        window.location.href = "<%=request.getContextPath()%>/board/allView.jsp?id=<%=postId%>";
        <% } %>
    });
})();
</script>

<%@ include file="/include/footer.jsp" %>
