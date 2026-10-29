<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<% request.setAttribute("pageCss", "login.css"); %>

<%@include file="/include/header.jsp" %>

  <div class="login-page">
  	<div class="login-box">
	    <img src="../resources/img/logo.jpg" alt="" class="login-logo" alt="K-Culture 로고">
	    <form action="" class="login-form" method="post">
	      <div class="form-group">
	        <label class="form-label">아이디</label>
	        <input type="text" name="id" class="form-input" requried autofocus>
	      </div>
	      <div class="form-group">
	        <label class="form-label">비밀번호</label>
	        <input type="password" name="password" class="form-input" requried>
	      </div>
	      <button type="submit" class="btn btn-primary ">로그인</button>
	    </form>
    </div>
  </div>
<%@include file="/include/sidebar.jsp" %>
<%@include file="/include/footer.jsp" %>