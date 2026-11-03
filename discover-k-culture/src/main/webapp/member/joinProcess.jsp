<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%><%@ page import="dao.MemberDAO,dto.MemberDTO,java.util.Locale"%>
<%
request.setCharacterEncoding("UTF-8");
String id = request.getParameter("loginId"), nick = request.getParameter("nickname"),
		email = request.getParameter("email");
MemberDAO d = new MemberDAO();
if (d.existsLoginId(id) || d.existsNickname(nick) || d.existsEmail(email)) {
	response.sendRedirect("join.jsp?error=1");
	return;
}
MemberDTO m = new MemberDTO();
m.setLoginId(id);
m.setPassword(request.getParameter("password"));
m.setNickname(nick);
m.setEmail(email);
m.setNationality(request.getParameter("nationality"));
try {
	m.setLanguageId(Integer.parseInt(request.getParameter("languageId")));
} catch (Exception e) {
	m.setLanguageId(1);
}
d.insert(m);

/* 회원가입에서 선택한 언어를 로그인 화면에도 바로 반영 */
String siteLanguage = "ko";
String siteLocale = Locale.KOREA.toLanguageTag();
if (m.getLanguageId() == 2) {
	siteLanguage = "ja";
	siteLocale = Locale.JAPAN.toLanguageTag();
} else if (m.getLanguageId() == 3) {
	siteLanguage = "zh";
	siteLocale = Locale.CHINA.toLanguageTag();
} else if (m.getLanguageId() == 4) {
	siteLanguage = "en";
	siteLocale = Locale.US.toLanguageTag();
}
session.setAttribute("languageId", m.getLanguageId());
session.setAttribute("siteLanguage", siteLanguage);
session.setAttribute("siteLocale", siteLocale);

response.sendRedirect("login.jsp");
%>
