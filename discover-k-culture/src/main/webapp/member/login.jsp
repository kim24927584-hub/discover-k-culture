<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<%
request.setAttribute("pageCss", "member/login.css");
%>

<%@include file="/include/header.jsp"%>

<div class="login-page">
	<div class="login-box">
		<h2>로그인</h2>
		<%
		String loginError = request.getParameter("error");
		if ("empty".equals(loginError)) {
		%>
		<p style="color: #d33; margin: 0 0 12px;">아이디와 비밀번호를 입력해 주세요.</p>
		<%
		} else if ("1".equals(loginError)) {
		%>
		<p style="color: #d33; margin: 0 0 12px;">아이디 또는 비밀번호가 올바르지 않습니다.</p>
		<%
		}
		%>
		<!-- <img
                src="../resources/img/logo.jpg"
                alt=""
                class="login-logo"
                alt="K-Culture 로고"
              /> -->
		<form action="<%=request.getContextPath()%>/member/login"
			class="login-form" method="post">
			<div class="form-group">
				<input type="text" name="id" class="form-input" placeholder="아이디"
					required autofocus />
			</div>
			<div class="form-group">
				<input type="password" name="password" class="form-input"
					placeholder="비밀번호" required />
			</div>
			<div class="login-option">
				<label> <input type="checkbox" name="rememberId"
					class="remember-me" value="true" />아이디 기억
				</label> <label> <input type="checkbox" name="autoLogin"
					class="auto-login" value="true" />자동 로그인
				</label>
			</div>
			<button type="submit" class="btn btn-primary">로그인</button>
		</form>

		<div class="social-login">
			<div class="social-divider">소셜 로그인</div>
			<div class="social-btn">
				<a href="<%=request.getContextPath()%>/oauth/google/login"
					class="google-btn"> <img src="${ctx}/resources/img/google.png"
					alt="Google로 로그인" />Google로 로그인
				</a> <a href="<%=request.getContextPath()%>/oauth/kakao/login"
					class="kakao-btn"> <img
					src="${ctx}/resources/img/kakao_login_kr_medium.png" alt="카카오로 로그인" /></a>
				<a href="<%=request.getContextPath()%>/oauth/naver/login"
					class="naver-btn"> <img
					src="${ctx}/resources/img/NAVER_login_Light_KR_green_narrow_H48.png"
					alt="네이버로 로그인" /></a>
			</div>
			<div class="social-desc">최초 로그인 시 소셜 계정 정보로 회원 계정이 자동 생성되거나 기존
				계정에 연결됩니다.</div>
		</div>
		<div class="login-footer">
			<div class="login-links">
				<a href="#">아이디 찾기</a> <a href="#">비밀번호 찾기</a> <a
					href="<%=request.getContextPath()%>/member/join.jsp">회원가입</a>
			</div>
		</div>
	</div>
</div>
<%@include file="/include/sidebar.jsp"%>
<%@include file="/include/footer.jsp"%>