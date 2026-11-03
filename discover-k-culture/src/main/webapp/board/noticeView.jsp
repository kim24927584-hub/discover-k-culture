<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%--
[noticeView.jsp] 공지사항 상세보기

처리 흐름
1. URL의 id 파라미터로 공지사항 번호를 확인합니다.
2. NoticeDAO로 공지사항을 조회합니다.
3. 일반 상세보기 접근일 때 조회수를 1 증가시킵니다.
4. NoticeMediaDAO로 첨부 이미지와 영상을 조회합니다.
5. 제목, 작성자, 조회수, 내용, 첨부파일을 출력합니다.
6. 관리자에게만 수정/삭제 버튼을 보여줍니다.
7. 수정 버튼은 별도 noticeEdit.jsp가 아니라
   통합된 noticeList.jsp의 수정 모드로 이동합니다.
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
 * 사용자가 입력한 문자열이 HTML 태그로 실행되지 않도록 하기 위한 처리입니다.
 */
private String h(String value) {

    if (value == null) {
        return "";
    }

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
   1. 공지사항 번호 확인
   ========================================================= */
long noticeId;

try {

    noticeId =
        Long.parseLong(
            request.getParameter("id")
        );

} catch (Exception e) {

    response.sendRedirect(
        request.getContextPath()
        + "/board/noticeList.jsp"
    );

    return;
}


/* =========================================================
   2. 공지사항 조회
   ========================================================= */
NoticeDAO noticeDAO =
    new NoticeDAO();

NoticeDTO notice =
    noticeDAO.selectById(
        noticeId
    );


/* 존재하지 않는 공지사항이면 목록으로 이동 */
if (notice == null) {

    response.sendRedirect(
        request.getContextPath()
        + "/board/noticeList.jsp"
    );

    return;
}


/* =========================================================
   3. 조회수 증가

   skipView=1은 수정 처리 후 다시 상세페이지에 들어왔을 때처럼
   조회수를 증가시키고 싶지 않은 경우 사용할 수 있습니다.
   ========================================================= */
if (
    !"1".equals(
        request.getParameter("skipView")
    )
) {

    noticeDAO.increaseView(
        noticeId
    );

    /* 증가된 조회수를 화면에 보여주기 위해 다시 조회 */
    notice =
        noticeDAO.selectById(
            noticeId
        );
}


/* =========================================================
   4. 첨부 이미지 / 영상 조회
   ========================================================= */
NoticeMediaDAO mediaDAO =
    new NoticeMediaDAO();

List<NoticeImageDTO> images =
    mediaDAO.selectImages(
        noticeId
    );

List<NoticeVideoDTO> videos =
    mediaDAO.selectVideos(
        noticeId
    );


/* =========================================================
   5. 관리자 여부 확인
   - 수정 / 삭제 버튼 표시 여부에 사용
   ========================================================= */
boolean isAdmin =
    "ADMIN".equals(
        session.getAttribute("role")
    );


/* =========================================================
   6. 공통 header.jsp에서 사용할 페이지 정보
   ========================================================= */
request.setAttribute(
    "pageCss",
    "board/common/viewCommon.css"
);

request.setAttribute(
    "activeMenu",
    "NOTICE"
);

request.setAttribute(
    "pageTitle",
    "공지사항 상세보기"
);
%>

<%@include file="/include/header.jsp" %>


<main class="container">

    <%-- =====================================================
         공지사항 제목
         ===================================================== --%>
    <h1 class="post-title">

        <span>
            [공지]
        </span>

        <%=h(notice.getTitle())%>

    </h1>


    <%-- =====================================================
         작성자 / 조회수 / 작성일
         ===================================================== --%>
    <p class="post-meta">

        작성자

        <span class="post-writer">
            <%=h(notice.getWriterNickname())%>
        </span>

        · 조회
        <%=notice.getViewCount()%>

        ·

        <%=
        notice.getCreatedAt() == null
            ? "-"
            : notice.getCreatedAt()
                .toString()
                .substring(0, 16)
        %>

    </p>


    <%-- =====================================================
         공지사항 본문 / 이미지 / 영상
         ===================================================== --%>
    <div class="post-body">


        <%-- 첨부 이미지 출력 --%>
        <%
        if (images != null) {

            for (
                NoticeImageDTO image
                : images
            ) {
        %>

        <img
            src="<%=request.getContextPath() + image.getImagePath()%>"
            alt="<%=h(image.getImageName())%>"
            style="
                max-width:100%;
                height:auto;
                display:block;
                margin-bottom:12px;
            ">

        <%
            }
        }
        %>


        <%-- 첨부 영상 출력 --%>
        <%
        if (videos != null) {

            for (
                NoticeVideoDTO video
                : videos
            ) {
        %>

        <video
            src="<%=request.getContextPath() + video.getVideoPath()%>"
            controls
            style="
                width:100%;
                max-height:520px;
                display:block;
                margin-bottom:12px;
            ">

            이 브라우저는 video 태그를 지원하지 않습니다.

        </video>

        <%
            }
        }
        %>


        <%-- 공지사항 본문 출력 --%>
        <p class="post-content">
            <%=h(notice.getContent()).replace("\n", "<br>")%>
        </p>

    </div>


    <%-- =====================================================
         하단 버튼 영역
         ===================================================== --%>
    <div style="
        display:flex;
        gap:8px;
        flex-wrap:wrap;
        align-items:center;
    ">


        <%-- 목록으로 이동 --%>
        <a
            href="<%=request.getContextPath()%>/board/noticeList.jsp"
            class="btn btn-list">

            <span class="btn-arrow">
                ←
            </span>

            목록

        </a>


        <%-- =================================================
             관리자 전용 수정 / 삭제
             ================================================= --%>
        <% if (isAdmin) { %>


        <%--
        수정 기능은 noticeList.jsp에 통합되었습니다.

        noticeList.jsp?editId=공지번호
        형태로 이동하면 목록 위에 수정 폼이 표시됩니다.
        --%>
        <a
            href="<%=request.getContextPath()%>/board/noticeList.jsp?editId=<%=noticeId%>"
            class="btn btn-list">
            수정
        </a>


        <%--
        삭제는 기존 관리자 삭제 Servlet을 그대로 사용합니다.
        --%>
        <form
            action="<%=request.getContextPath()%>/admin/notice/delete"
            method="post"
            style="display:inline;"
            onsubmit="return confirm('이 공지사항을 삭제하시겠습니까? 첨부된 이미지와 영상도 함께 삭제됩니다.');">

            <input
                type="hidden"
                name="id"
                value="<%=noticeId%>">

            <button
                type="submit"
                class="btn btn-list">
                삭제
            </button>

        </form>

        <% } %>

    </div>

</main>

<%@include file="/include/sidebar.jsp" %>
<%@include file="/include/footer.jsp" %>
