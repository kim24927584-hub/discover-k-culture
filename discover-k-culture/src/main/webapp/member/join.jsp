<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
/* =========================================================
   회원가입 화면
   joinProcess.jsp가 기대하는 파라미터 이름과 정확히 맞춥니다.
   ========================================================= */
request.setAttribute("pageCss", "member/join.css");
request.setAttribute("pageTitle", "회원가입");
String joinError = request.getParameter("error");
%>

<%@include file="/include/header.jsp" %>

<div class="join-page">
    <div class="join-box">
        <img src="${ctx}/resources/img/logo.jpg" class="login-logo" alt="K-Culture 로고">

        <% if (joinError != null) { %>
            <p class="form-hint">
                <% if ("duplicate".equals(joinError) || "1".equals(joinError)) { %>
                    이미 사용 중인 아이디, 닉네임 또는 이메일이 있습니다.
                <% } else if ("invalid".equals(joinError)) { %>
                    입력 내용을 다시 확인해 주세요.
                <% } else { %>
                    회원가입 처리 중 오류가 발생했습니다.
                <% } %>
            </p>
        <% } %>

        <form action="<%=request.getContextPath()%>/member/joinProcess.jsp" class="join-form" method="post">
            <div class="form-group">
                <label class="form-label" for="loginId">아이디</label>
                <input type="text" id="loginId" name="loginId" class="form-input" maxlength="50" required autofocus>
            </div>

            <div class="form-group">
                <label class="form-label" for="password">비밀번호</label>
                <input type="password" id="password" name="password" class="form-input" minlength="4" maxlength="100" required>
            </div>

            <div class="form-group">
                <label class="form-label" for="nickname">닉네임</label>
                <input type="text" id="nickname" name="nickname" class="form-input" maxlength="50" required>
            </div>

            <div class="form-group">
                <label class="form-label" for="nationality">국적</label>
                <input type="text" id="nationality" name="nationality" class="form-input" maxlength="50">
            </div>

            <div class="form-group">
                <label class="form-label" for="email">이메일</label>
                <input type="email" id="email" name="email" class="form-input" maxlength="100" required>
            </div>

            <div class="form-group">
                <label class="form-label" for="languageId">언어</label>
                <select id="languageId" name="languageId" class="form-input" required>
                    <option value="1">한국어</option>
                    <option value="2">日本語</option>
                    <option value="3">中文</option>
                    <option value="4">English</option>
                </select>
            </div>

            <button type="submit" class="btn btn-primary">회원가입</button>
        </form>
    </div>
</div>

<%@include file="/include/sidebar.jsp" %>
<%@include file="/include/footer.jsp" %>
