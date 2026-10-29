<%@ page
    language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Document</title>
  <link rel="stylesheet" href="../resources/css/common.css">
  <link rel="stylesheet" href="../resources/css/join.css">
</head>
<body>
  <div class="join-page">
  	<div class="join-box">
	    <img src="../resources/img/logo.jpg" class="login-logo" alt="K-Culture 로고">
	    <form action="" class="join-form" method="post">
	      <div class="form-group">
	        <label class="form-label">아이디</label>
	        <input type="text" name="id" class="form-input" requried autofocus>
	      </div>
	      <div class="form-group">
	        <label class="form-label">비밀번호</label>
	        <input type="password" name="password" class="form-input" requried>
	      </div>
	      <div class="form-group">
	        <label class="form-label">이름</label>
	        <input type="text" name="name" class="form-input" requried >
	      </div>
	      <div class="form-group">
	        <label class="form-label">국적</label>
	        <input type="text" name="nationality" class="form-input" requried >
	      </div>
	      <div class="form-group">
	        <label class="form-label">이메일</label>
	        <input type="email" name="email" class="form-input" requried >
	      </div>
	      <div class="form-group">
     	      <label class="form-label">언어</label>
	      
		      <select name="language" class="form-input">
		      	<option value="korean">한국어</option>
		      	<option value="english">English</option> 
		      </select>
	      </div>
	      <button type="submit" class="btn btn-primary ">회원가입</button>
	    </form>
    </div>
  </div>
</body>
</html>