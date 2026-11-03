<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="dao.MemberDAO" %>
<%@ page import="dto.MemberDTO" %>
<%@ page import="java.util.Locale" %>

<%
request.setCharacterEncoding("UTF-8");

Long memberId = (Long) session.getAttribute("memberId");
if (memberId == null) {
    response.sendRedirect(request.getContextPath() + "/member/login.jsp");
    return;
}

String nickname = request.getParameter("nickname");
String email = request.getParameter("email");
String nationality = request.getParameter("nationality");
String languageIdParam = request.getParameter("languageId");

nickname = nickname == null ? "" : nickname.trim();
email = email == null ? "" : email.trim();
nationality = nationality == null ? "" : nationality.trim();

int languageId;
try {
    languageId = Integer.parseInt(languageIdParam);
} catch (Exception e) {
    response.sendRedirect("mypage.jsp?updateError=invalid");
    return;
}

if (nickname.isEmpty() || email.isEmpty() || languageId < 1 || languageId > 4) {
    response.sendRedirect("mypage.jsp?updateError=invalid");
    return;
}

MemberDAO dao = new MemberDAO();
MemberDTO current = dao.selectById(memberId.longValue());
if (current == null) {
    session.invalidate();
    response.sendRedirect(request.getContextPath() + "/member/login.jsp");
    return;
}

if (!nickname.equals(current.getNickname()) && dao.existsNickname(nickname)) {
    response.sendRedirect("mypage.jsp?updateError=nickname");
    return;
}

if (!email.equals(current.getEmail()) && dao.existsEmail(email)) {
    response.sendRedirect("mypage.jsp?updateError=email");
    return;
}

MemberDTO member = new MemberDTO();
member.setMemberId(memberId.longValue());
member.setNickname(nickname);
member.setEmail(email);
member.setNationality(nationality);
member.setLanguageId(languageId);

dao.update(member);

session.setAttribute("nickname", nickname);
session.setAttribute("languageId", languageId);

String siteLanguage = "ko";
String siteLocale = Locale.KOREA.toLanguageTag();

if (languageId == 2) {
    siteLanguage = "ja";
    siteLocale = Locale.JAPAN.toLanguageTag();
} else if (languageId == 3) {
    siteLanguage = "zh";
    siteLocale = Locale.CHINA.toLanguageTag();
} else if (languageId == 4) {
    siteLanguage = "en";
    siteLocale = Locale.US.toLanguageTag();
}

session.setAttribute("siteLanguage", siteLanguage);
session.setAttribute("siteLocale", siteLocale);

response.sendRedirect("mypage.jsp?updated=1");
%>
