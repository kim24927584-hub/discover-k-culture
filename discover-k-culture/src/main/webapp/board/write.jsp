<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="dao.CategoryDAO" %>
<%@ page import="dao.MemberDAO" %>
<%@ page import="dto.CategoryDTO" %>
<%@ page import="dto.MemberDTO" %>

<%!
private String writeH(String value) {
    if (value == null) return "";
    return value.replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace("\"", "&quot;")
        .replace("'", "&#39;");
}
%>

<%
request.setCharacterEncoding("UTF-8");

/* =========================================================
   1. 로그인 확인
   ========================================================= */
Long memberId = (Long) session.getAttribute("memberId");
if (memberId == null) {
    response.sendRedirect(request.getContextPath() + "/member/login.jsp");
    return;
}

/* 정지 회원은 게시글을 작성할 수 없습니다. */
MemberDTO currentMember = new MemberDAO().selectById(memberId.longValue());
if (currentMember == null) {
    response.sendRedirect(request.getContextPath() + "/member/logout");
    return;
}
if ("SUSPENDED".equals(currentMember.getStatus())) {
    response.sendRedirect(request.getContextPath() + "/member/mypage.jsp?restricted=post");
    return;
}

/* =========================================================
   2. 처음 선택할 게시판 결정
   FREE / KCULTURE / QUESTION을 지원하고,
   NOTICE는 관리자에게만 허용합니다.
   ========================================================= */
String selectedBoardType = request.getParameter("boardType");
boolean admin = "ADMIN".equals(session.getAttribute("role"));

if (!"FREE".equals(selectedBoardType)
        && !"KCULTURE".equals(selectedBoardType)
        && !"QUESTION".equals(selectedBoardType)
        && !(admin && "NOTICE".equals(selectedBoardType))) {
    selectedBoardType = "FREE";
}

/* =========================================================
   3. K-컬처 카테고리 DB 조회
   ========================================================= */
List<CategoryDTO> categories = new CategoryDAO().selectAll();

request.setAttribute("pageCss", "board/common/writeCommon.css");
request.setAttribute("pageTitle", "글쓰기");
request.setAttribute("activeMenu",
        "NOTICE".equals(selectedBoardType) ? "NOTICE"
        : "QUESTION".equals(selectedBoardType) ? "QUESTION"
        : "KCULTURE".equals(selectedBoardType) ? "KCULTURE" : "ALL");
%>

<%@ include file="/include/header.jsp" %>

<div class="write-page">
    <div class="write-layout">
        <main class="write-main">
            <section class="write-card">

                <div class="write-heading">
                    <span class="write-label"><%="NOTICE".equals(selectedBoardType) ? "NOTICE" : "NEW POST"%></span>
                    <h1><%="NOTICE".equals(selectedBoardType) ? "공지사항 작성" : "글쓰기"%></h1>
                    <p>다양한 이야기와 정보를 함께 나눠 보세요.</p>
                </div>

                <%--
                일반 게시글은 PostWriteServlet로 전송하고,
                관리자가 NOTICE를 선택하면 JS가 공지 저장 Servlet로 action을 변경합니다.
                JavaScript가 꺼져 있어도 PostWriteServlet에서 NOTICE를 다시 전달합니다.
                --%>
                <form
                    class="write-form"
                    action="<%=request.getContextPath()%>/board/process/board/write"
                    data-post-action="<%=request.getContextPath()%>/board/process/board/write"
                    data-notice-action="<%=request.getContextPath()%>/admin/notice/save"
                    method="post"
                    enctype="multipart/form-data">

                    <div class="write-field">
                        <label for="boardType">게시판</label>
                        <select id="boardType" name="boardType" data-write-board-select required>
                            <option value="FREE" <%="FREE".equals(selectedBoardType) ? "selected" : ""%>>자유게시판</option>
                            <option value="KCULTURE" <%="KCULTURE".equals(selectedBoardType) ? "selected" : ""%>>K-컬처 탐색</option>
                            <option value="QUESTION" <%="QUESTION".equals(selectedBoardType) ? "selected" : ""%>>질문게시판</option>
                            <% if (admin) { %>
                                <option value="NOTICE" <%="NOTICE".equals(selectedBoardType) ? "selected" : ""%>>공지사항</option>
                            <% } %>
                        </select>
                    </div>

                    <div class="write-field">
                        <label for="categoryId">카테고리</label>
                        <select id="categoryId" name="categoryId" data-write-category-select>
                            <option value="">카테고리 선택</option>
                            <% for (CategoryDTO category : categories) { %>
                                <option value="<%=category.getCategoryId()%>"><%=writeH(category.getName())%></option>
                            <% } %>
                        </select>
                    </div>

                    <div class="write-field">
                        <label for="postTitle">제목</label>
                        <input type="text" id="postTitle" name="title" maxlength="200"
                               placeholder="제목을 입력해 주세요." required>
                    </div>

                    <div class="write-field">
                        <label for="postContent">내용</label>
                        <textarea id="postContent" name="content"
                                  placeholder="내용을 입력해 주세요." required></textarea>
                    </div>

                    <div class="write-field">
                        <label for="imageFiles">이미지 첨부</label>
                        <div class="write-upload">
                            <p>게시글에 함께 올릴 이미지를 선택해 주세요.</p>
                            <input type="file" id="imageFiles" name="images"
                                   accept="image/jpeg,image/png,image/gif,image/webp" multiple>
                        </div>
                        <p class="write-file-guide">JPG, PNG, GIF, WEBP 형식을 사용할 수 있습니다.</p>
                    </div>

                    <div class="write-field">
                        <label for="videoFiles">영상 첨부</label>
                        <div class="write-upload">
                            <p>게시글에 함께 올릴 영상을 선택해 주세요.</p>
                            <input type="file" id="videoFiles" name="videos"
                                   accept="video/mp4,video/webm,video/ogg,video/quicktime" multiple>
                        </div>
                        <p class="write-file-guide">MP4, WebM, OGG, MOV 형식을 사용할 수 있습니다.</p>
                    </div>

                    <div class="write-actions">
                        <button type="button" id="cancelButton"
                                class="write-button write-button-cancel">취소</button>
                        <button type="submit"
                                class="write-button write-button-submit">등록</button>
                    </div>
                </form>
            </section>
        </main>

        <%@ include file="/include/sidebar.jsp" %>
    </div>
</div>

<script src="<%=request.getContextPath()%>/resources/js/write.js"></script>
<%@ include file="/include/footer.jsp" %>
