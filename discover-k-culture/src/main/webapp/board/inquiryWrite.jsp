<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
request.setCharacterEncoding("UTF-8");

/* 문의 작성은 로그인 회원 전용이며 정지 회원도 사용할 수 있습니다. */
Long memberId = (Long) session.getAttribute("memberId");
if (memberId == null) {
    response.sendRedirect(request.getContextPath() + "/member/login.jsp");
    return;
}

request.setAttribute("pageCss", "board/common/writeCommon.css");
request.setAttribute("pageTitle", "1:1 문의 작성");
request.setAttribute("activeMenu", "INQUIRY");
%>

<%@ include file="/include/header.jsp" %>

<div class="write-page">
    <div class="write-layout">
        <main class="write-main">
            <section class="write-card">
                <div class="write-heading">
                    <span class="write-label">1:1 INQUIRY</span>
                    <h1>1:1 문의</h1>
                    <p>운영자에게 문의할 내용을 작성해 주세요.</p>
                </div>

                <%-- inquiry 테이블에는 이미지/영상 컬럼이 없으므로 제목과 내용만 저장합니다. --%>
                <form class="write-form"
                      action="<%=request.getContextPath()%>/board/process/inquiry/writeProcess.jsp"
                      method="post">

                    <div class="write-field">
                        <label for="inquiryTitle">제목</label>
                        <input type="text" id="inquiryTitle" name="title"
                               maxlength="200" placeholder="제목을 입력해 주세요." required>
                    </div>

                    <div class="write-field">
                        <label for="inquiryContent">내용</label>
                        <textarea id="inquiryContent" name="content"
                                  maxlength="5000" placeholder="내용을 입력해 주세요." required></textarea>
                    </div>

                    <div class="write-actions">
                        <button type="button" class="write-button write-button-cancel"
                                onclick="location.href='<%=request.getContextPath()%>/board/inquiryList.jsp'">취소</button>
                        <button type="submit" class="write-button write-button-submit">등록</button>
                    </div>
                </form>
            </section>
        </main>

        <%@ include file="/include/sidebar.jsp" %>
    </div>
</div>

<%@ include file="/include/footer.jsp" %>
