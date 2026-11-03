<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%--
[noticeList.jsp] 공지사항 목록 + 관리자 수정 기능 통합 화면

처리 흐름
1. 현재 페이지 번호를 계산합니다.
2. 관리자이고 editId가 전달되면 수정할 공지사항과 기존 첨부파일을 조회합니다.
3. 전체 공지 수와 현재 페이지의 공지 목록을 조회합니다.
4. 관리자에게만 공지 작성 버튼과 수정 버튼을 보여줍니다.
5. 수정 버튼을 누르면 같은 noticeList.jsp 안에 수정 폼을 표시합니다.
6. 수정 저장은 기존 /admin/notice/save로 전송합니다.
7. 목록과 페이지네이션을 출력합니다.

※ 기존 noticeEdit.jsp의 기능을 이 파일에 통합했기 때문에
   noticeEdit.jsp는 더 이상 사용하지 않아도 됩니다.
--%>

<%@ page import="java.util.List" %>
<%@ page import="dao.NoticeDAO" %>
<%@ page import="dao.NoticeMediaDAO" %>
<%@ page import="dto.NoticeDTO" %>
<%@ page import="dto.NoticeImageDTO" %>
<%@ page import="dto.NoticeVideoDTO" %>

<%!
/*
 * 화면에 출력할 문자열의 HTML 특수문자를 치환합니다.
 * 제목/본문에 HTML 태그가 입력되어도 그대로 실행되지 않게 하여
 * XSS 위험을 줄이기 위한 처리입니다.
 */
private String h(String value) {
    if (value == null) return "";

    return value
        .replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace("\"", "&quot;")
        .replace("'", "&#39;");
}
%>

<%
/* =========================================================
   1. 현재 로그인 사용자가 관리자인지 확인
   ========================================================= */
boolean isAdmin =
    "ADMIN".equals(session.getAttribute("role"));


/* =========================================================
   2. 현재 페이지 번호 계산
   - page 값이 없거나 숫자가 아니면 1페이지
   - 1보다 작은 값도 1페이지로 보정
   ========================================================= */
int pageSize = 10;
int currentPage = 1;

try {
    currentPage =
        Integer.parseInt(
            request.getParameter("page")
        );
} catch (Exception ignored) {
    currentPage = 1;
}

if (currentPage < 1) {
    currentPage = 1;
}


/* =========================================================
   3. DAO 생성
   ========================================================= */
NoticeDAO noticeDAO =
    new NoticeDAO();


/* =========================================================
   4. 수정 기능에 사용할 변수 준비
   ========================================================= */
NoticeDTO editNotice = null;

List<NoticeImageDTO> editImages = null;
List<NoticeVideoDTO> editVideos = null;

Long editNoticeId = null;


/* =========================================================
   5. editId가 있으면 수정 모드로 진입
   예)
   noticeList.jsp?editId=3&page=1

   수정 기능은 관리자만 사용할 수 있습니다.
   일반 사용자가 URL에 editId를 직접 넣어 접근해도 차단합니다.
   ========================================================= */
String editIdParam =
    request.getParameter("editId");

if (
    editIdParam != null
    && !editIdParam.trim().isEmpty()
) {

    /* 관리자 권한이 아니면 수정 기능 접근 차단 */
    if (!isAdmin) {

        response.sendRedirect(
            request.getContextPath()
            + "/home.jsp"
        );

        return;
    }

    try {

        editNoticeId =
            Long.parseLong(
                editIdParam
            );

    } catch (Exception e) {

        response.sendRedirect(
            request.getContextPath()
            + "/board/noticeList.jsp?page="
            + currentPage
        );

        return;
    }


    /* =====================================================
       6. 수정할 공지사항 조회
       ===================================================== */
    editNotice =
        noticeDAO.selectById(
            editNoticeId.longValue()
        );

    /* 존재하지 않는 공지사항 번호이면 목록으로 이동 */
    if (editNotice == null) {

        response.sendRedirect(
            request.getContextPath()
            + "/board/noticeList.jsp?page="
            + currentPage
        );

        return;
    }


    /* =====================================================
       7. 기존 첨부 이미지 / 영상 조회
       - 수정 화면에서 기존 파일을 확인
       - 체크한 파일은 저장 처리에서 삭제 대상으로 전달
       ===================================================== */
    NoticeMediaDAO mediaDAO =
        new NoticeMediaDAO();

    editImages =
        mediaDAO.selectImages(
            editNoticeId.longValue()
        );

    editVideos =
        mediaDAO.selectVideos(
            editNoticeId.longValue()
        );
}


/* =========================================================
   8. 전체 공지 개수 조회
   ========================================================= */
int totalCount =
    noticeDAO.countAll();


/* =========================================================
   9. 전체 페이지 수 계산
   - 공지가 없어도 화면 계산 편의를 위해 최소 1페이지로 처리
   ========================================================= */
int totalPages =
    Math.max(
        1,
        (int) Math.ceil(
            totalCount / (double) pageSize
        )
    );

if (currentPage > totalPages) {
    currentPage = totalPages;
}


/* =========================================================
   10. 현재 페이지에 표시할 공지사항 조회
   ========================================================= */
List<NoticeDTO> notices =
    noticeDAO.selectPage(
        currentPage,
        pageSize
    );


/* =========================================================
   11. 페이지네이션 계산
   - 페이지 번호를 5개씩 한 묶음으로 표시
   ========================================================= */
int blockSize = 5;

int startPage =
    (
        (currentPage - 1)
        / blockSize
    )
    * blockSize
    + 1;

int endPage =
    Math.min(
        startPage + blockSize - 1,
        totalPages
    );


/* =========================================================
   12. header.jsp에서 사용할 페이지 정보 설정
   ========================================================= */
request.setAttribute(
    "pageCss",
    "board/common/listCommon.css"
);

request.setAttribute(
    "activeMenu",
    "NOTICE"
);

request.setAttribute(
    "pageTitle",
    editNotice == null
        ? "공지사항"
        : "공지사항 수정"
);
%>

<%@include file="/include/header.jsp" %>

<%--
수정 폼은 기존 write.css의 디자인을 그대로 사용합니다.
목록은 listCommon.css를 사용하므로 두 CSS를 함께 불러옵니다.
--%>
<link rel="stylesheet"
      href="<%=request.getContextPath()%>/css/board/write.css">


<main class="container">

    <%-- =====================================================
         공지사항 제목
         ===================================================== --%>
    <h1 class="board-title">
        공지사항
    </h1>


    <%-- =====================================================
         관리자 전용 상단 버튼
         - 공지 작성
         - 수정 중이면 수정 취소
         ===================================================== --%>
    <% if (isAdmin) { %>

    <div style="
        display:flex;
        justify-content:flex-end;
        gap:8px;
        margin-bottom:10px;
        flex-wrap:wrap;
    ">

        <% if (editNotice != null) { %>

        <a
            href="<%=request.getContextPath()%>/board/noticeList.jsp?page=<%=currentPage%>"
            class="btn btn-list">
            수정 취소
        </a>

        <% } %>

        <a
            href="<%=request.getContextPath()%>/board/write.jsp?boardType=NOTICE"
            class="btn btn-primary">
            공지 작성
        </a>

    </div>

    <% } %>


    <%-- =====================================================
         관리자 전용 공지 수정 영역

         editId가 전달된 경우에만 표시됩니다.
         기존 noticeEdit.jsp의 수정 기능을 이곳으로 통합했습니다.
         ===================================================== --%>
    <% if (isAdmin && editNotice != null) { %>

    <section
        class="write-card"
        style="margin-bottom:30px;">

        <div class="write-heading">

            <span class="write-label">
                EDIT NOTICE
            </span>

            <h2>
                공지사항 수정
            </h2>

            <p>
                제목, 내용, 이미지, 영상을 수정할 수 있습니다.
            </p>

        </div>


        <%-- =================================================
             공지 수정 폼

             파일 업로드가 포함되어 있기 때문에
             enctype="multipart/form-data"가 반드시 필요합니다.
             ================================================= --%>
        <form
            class="write-form"
            action="<%=request.getContextPath()%>/admin/notice/save"
            method="post"
            enctype="multipart/form-data">

            <%--
            수정할 공지 번호.
            서버에서 INSERT가 아니라 UPDATE를 판단하는 데 사용합니다.
            --%>
            <input
                type="hidden"
                name="id"
                value="<%=editNotice.getNoticeId()%>">


            <%-- ===== 제목 수정 ===== --%>
            <div class="write-field">

                <label for="noticeTitle">
                    제목
                </label>

                <input
                    type="text"
                    id="noticeTitle"
                    name="title"
                    maxlength="200"
                    value="<%=h(editNotice.getTitle())%>"
                    required>

            </div>


            <%-- ===== 내용 수정 ===== --%>
            <div class="write-field">

                <label for="noticeContent">
                    내용
                </label>

                <textarea
                    id="noticeContent"
                    name="content"
                    required><%=h(editNotice.getContent())%></textarea>

            </div>


            <%-- =================================================
                 기존 이미지
                 체크한 이미지 ID만 deleteImageIds로 서버에 전달합니다.
                 ================================================= --%>
            <%
            if (
                editImages != null
                && !editImages.isEmpty()
            ) {
            %>

            <div class="write-field">

                <label>
                    기존 이미지
                </label>

                <div class="write-upload">

                    <p>
                        삭제할 이미지만 체크해 주세요.
                    </p>

                    <%
                    for (
                        NoticeImageDTO image
                        : editImages
                    ) {
                    %>

                    <label style="
                        display:inline-block;
                        margin:0 14px 14px 0;
                        vertical-align:top;
                    ">

                        <img
                            src="<%=request.getContextPath() + image.getImagePath()%>"
                            alt="<%=h(image.getImageName())%>"
                            style="
                                display:block;
                                width:140px;
                                height:100px;
                                object-fit:cover;
                                margin-bottom:6px;
                            ">

                        <input
                            type="checkbox"
                            name="deleteImageIds"
                            value="<%=image.getImageId()%>">

                        이 이미지 삭제

                    </label>

                    <%
                    }
                    %>

                </div>

            </div>

            <%
            }
            %>


            <%-- ===== 새 이미지 추가 ===== --%>
            <div class="write-field">

                <label for="noticeImages">
                    이미지 추가
                </label>

                <div class="write-upload">

                    <p>
                        새로 추가할 이미지를 선택해 주세요.
                    </p>

                    <input
                        type="file"
                        id="noticeImages"
                        name="images"
                        accept="image/*"
                        multiple>

                </div>

            </div>


            <%-- =================================================
                 기존 영상
                 체크한 영상 ID만 deleteVideoIds로 서버에 전달합니다.
                 ================================================= --%>
            <%
            if (
                editVideos != null
                && !editVideos.isEmpty()
            ) {
            %>

            <div class="write-field">

                <label>
                    기존 영상
                </label>

                <div class="write-upload">

                    <p>
                        삭제할 영상만 체크해 주세요.
                    </p>

                    <%
                    for (
                        NoticeVideoDTO video
                        : editVideos
                    ) {
                    %>

                    <label style="
                        display:block;
                        margin-bottom:16px;
                    ">

                        <video
                            src="<%=request.getContextPath() + video.getVideoPath()%>"
                            controls
                            preload="metadata"
                            style="
                                display:block;
                                width:260px;
                                max-width:100%;
                                margin-bottom:6px;
                            ">
                        </video>

                        <input
                            type="checkbox"
                            name="deleteVideoIds"
                            value="<%=video.getVideoId()%>">

                        이 영상 삭제

                    </label>

                    <%
                    }
                    %>

                </div>

            </div>

            <%
            }
            %>


            <%-- ===== 새 영상 추가 ===== --%>
            <div class="write-field">

                <label for="noticeVideos">
                    영상 추가
                </label>

                <div class="write-upload">

                    <p>
                        새로 추가할 영상을 선택해 주세요.
                    </p>

                    <input
                        type="file"
                        id="noticeVideos"
                        name="videos"
                        accept="video/mp4,video/webm,video/ogg,video/quicktime"
                        multiple>

                </div>

            </div>


            <%-- ===== 수정 취소 / 저장 ===== --%>
            <div class="write-actions">

                <button
                    type="button"
                    class="write-button write-button-cancel"
                    onclick="location.href='<%=request.getContextPath()%>/board/noticeList.jsp?page=<%=currentPage%>'">
                    취소
                </button>

                <button
                    type="submit"
                    class="write-button write-button-submit">
                    수정 저장
                </button>

            </div>

        </form>

    </section>

    <% } %>


    <%-- =====================================================
         공지사항 목록
         ===================================================== --%>
    <table class="board-table">

        <thead>

        <tr>

            <th class="col-num">
                번호
            </th>

            <th class="col-title">
                제목
            </th>

            <th class="col-author">
                작성자
            </th>

            <th class="col-views">
                조회
            </th>

            <th class="col-date">
                작성일
            </th>

            <%-- 관리자에게만 관리 열 표시 --%>
            <% if (isAdmin) { %>

            <th style="width:90px;">
                관리
            </th>

            <% } %>

        </tr>

        </thead>


        <tbody>

        <%
        if (
            notices == null
            || notices.isEmpty()
        ) {
        %>

        <tr>

            <td colspan="<%=isAdmin ? 6 : 5%>">
                등록된 공지사항이 없습니다.
            </td>

        </tr>

        <%
        } else {

            for (
                NoticeDTO notice
                : notices
            ) {
        %>

        <tr>

            <td class="col-num">
                <%=notice.getNoticeId()%>
            </td>


            <%-- 제목을 누르면 상세보기로 이동 --%>
            <td class="col-title">

                <a href="<%=request.getContextPath()%>/board/noticeView.jsp?id=<%=notice.getNoticeId()%>">
                    <%=h(notice.getTitle())%>
                </a>

            </td>


            <td class="col-author">
                <%=h(notice.getWriterNickname())%>
            </td>


            <td class="col-views">
                <%=notice.getViewCount()%>
            </td>


            <td class="col-date">

                <%=
                notice.getCreatedAt() == null
                    ? "-"
                    : notice.getCreatedAt()
                        .toString()
                        .substring(0, 10)
                %>

            </td>


            <%-- =================================================
                 관리자 전용 수정 버튼

                 별도 noticeEdit.jsp로 이동하지 않고
                 현재 noticeList.jsp에 editId를 전달합니다.
                 ================================================= --%>
            <% if (isAdmin) { %>

            <td style="text-align:center;">

                <a
                    href="<%=request.getContextPath()%>/board/noticeList.jsp?page=<%=currentPage%>&editId=<%=notice.getNoticeId()%>"
                    class="btn btn-list"
                    style="padding:6px 10px;">
                    수정
                </a>

            </td>

            <% } %>

        </tr>

        <%
            }
        }
        %>

        </tbody>

    </table>


    <%-- =====================================================
         페이지네이션
         ===================================================== --%>
    <nav
        class="pagination"
        aria-label="페이지 이동">

        <%-- 이전 페이지 --%>
        <a
            href="<%=currentPage > 1 ? ("?page=" + (currentPage - 1)) : "#"%>"
            class="page-move <%=currentPage > 1 ? "" : "is-disabled"%>">
            ← 이전
        </a>


        <%-- 페이지 번호 --%>
        <div class="page-numbers">

            <%
            for (
                int p = startPage;
                p <= endPage;
                p++
            ) {
            %>

            <a
                href="?page=<%=p%>"
                class="page <%=p == currentPage ? "is-active" : ""%>">
                <%=p%>
            </a>

            <%
            }
            %>

        </div>


        <%-- 다음 페이지 --%>
        <a
            href="<%=currentPage < totalPages ? ("?page=" + (currentPage + 1)) : "#"%>"
            class="page-move <%=currentPage < totalPages ? "" : "is-disabled"%>">
            다음 →
        </a>

    </nav>

</main>

<%@include file="/include/sidebar.jsp" %>
<%@include file="/include/footer.jsp" %>
