<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%-- header.jsp에서 write.css를 불러오도록 설정 --%>
<%
request.setAttribute("pageCss", "board/write.css");
%>

<%@ include file="/include/header.jsp" %>

<div class="write-page">
    <div class="write-layout">

        <main class="write-main">
            <section class="write-card">

                <div class="write-heading">
                    <span class="write-label">NEW POST</span>
                    <h1>글쓰기</h1>
                    <p>다양한 이야기와 정보를 함께 나눠 보세요.</p>
                </div>

                <div class="write-form">

                    <div class="write-field">
                        <label for="boardType">게시판</label>

                        <select id="boardType">
                            <option>K-컬쳐 탐색</option>
                            <option>자유게시판</option>
                            <option>질문게시판</option>
                        </select>
                    </div>

                    <div class="write-field">
                        <label for="categoryId">카테고리</label>

                        <select id="categoryId">
                            <option value="">카테고리 선택</option>
                            <option>음식</option>
                            <option>음악</option>
                            <option>드라마</option>
                            <option>여행</option>
                        </select>
                    </div>

                    <div class="write-field">
                        <label for="postTitle">제목</label>

                        <input
                            type="text"
                            id="postTitle"
                            placeholder="제목을 입력해 주세요.">
                    </div>

                    <div class="write-field">
                        <label for="postContent">내용</label>

                        <textarea
                            id="postContent"
                            placeholder="내용을 입력해 주세요."></textarea>
                    </div>

                    <div class="write-field">
                        <label for="imageFiles">이미지 첨부</label>

                        <div class="write-upload">
                            <p>게시글에 함께 올릴 이미지를 선택해 주세요.</p>

                            <input
                                type="file"
                                id="imageFiles"
                                accept="image/*"
                                multiple>
                        </div>

                        <p class="write-file-guide">
                            이미지 첨부 영역
                        </p>
                    </div>

                    <div class="write-field">
                        <label for="videoFiles">영상 첨부</label>

                        <div class="write-upload">
                            <p>MP4, WebM 형식의 영상을 선택해 주세요.</p>

                            <input
                                type="file"
                                id="videoFiles"
                                accept="video/mp4,video/webm"
                                multiple>
                        </div>

                        <p class="write-file-guide">
                            영상 첨부 영역
                        </p>
                    </div>

                    <div class="write-actions">
                        <button
                            type="button"
                            class="write-button write-button-cancel">
                            취소
                        </button>

                        <button
                            type="button"
                            class="write-button write-button-submit">
                            등록
                        </button>
                    </div>

                </div>
            </section>
        </main>

        <%@ include file="/include/sidebar.jsp" %>

    </div><!-- .write-layout -->
</div><!-- .write-page -->

<%@ include file="/include/footer.jsp" %>