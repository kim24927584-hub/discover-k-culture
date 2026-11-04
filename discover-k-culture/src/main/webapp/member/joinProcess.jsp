<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.MemberDAO" %>
<%@ page import="dto.MemberDTO" %>
<%@ page import="java.util.Locale" %>

<%
request.setCharacterEncoding("UTF-8");

/* =========================================================
   1. 회원가입은 POST 요청만 처리
   ========================================================= */
if (!"POST".equalsIgnoreCase(request.getMethod())) {
    response.sendRedirect(request.getContextPath() + "/member/join.jsp");
    return;
}

/* =========================================================
   2. 입력값 정리 및 기본 검증
   ========================================================= */
String loginId = request.getParameter("loginId");
String password = request.getParameter("password");
String nickname = request.getParameter("nickname");
String email = request.getParameter("email");
String nationality = request.getParameter("nationality");
String languageIdText = request.getParameter("languageId");

loginId = loginId == null ? "" : loginId.trim();
nickname = nickname == null ? "" : nickname.trim();
email = email == null ? "" : email.trim();
nationality = nationality == null ? "" : nationality.trim();
password = password == null ? "" : password;

int languageId = 1;
try {
    languageId = Integer.parseInt(languageIdText);
} catch (Exception ignored) {
    languageId = 1;
}

if (loginId.isEmpty() || loginId.length() > 50
        || password.length() < 4 || password.length() > 100
        || nickname.isEmpty() || nickname.length() > 50
        || email.isEmpty() || email.length() > 100
        || languageId < 1 || languageId > 4) {

    response.sendRedirect(request.getContextPath() + "/member/join.jsp?error=invalid");
    return;
}

try {
    MemberDAO dao = new MemberDAO();

    /* =====================================================
       3. 아이디 / 닉네임 / 이메일 중복 검사
       ===================================================== */
    if (dao.existsLoginId(loginId)
            || dao.existsNickname(nickname)
            || dao.existsEmail(email)) {

        response.sendRedirect(request.getContextPath() + "/member/join.jsp?error=duplicate");
        return;
    }

    /* =====================================================
       4. 회원 저장
       MemberDAO.insert()에서 비밀번호를 해시하여 저장합니다.
       ===================================================== */
    MemberDTO member = new MemberDTO();
    member.setLoginId(loginId);
    member.setPassword(password);
    member.setNickname(nickname);
    member.setEmail(email);
    member.setNationality(nationality.isEmpty() ? null : nationality);
    member.setLanguageId(languageId);

    if (dao.insert(member) != 1) {
        response.sendRedirect(request.getContextPath() + "/member/join.jsp?error=save");
        return;
    }

    /* =====================================================
       5. 선택 언어를 로그인 화면에도 유지
       ===================================================== */
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

    session.setAttribute("languageId", languageId);
    session.setAttribute("siteLanguage", siteLanguage);
    session.setAttribute("siteLocale", siteLocale);

    response.sendRedirect(request.getContextPath() + "/member/login.jsp?joined=1");

} catch (Exception e) {
    application.log("회원가입 처리 오류", e);
    response.sendRedirect(request.getContextPath() + "/member/join.jsp?error=save");
}
%>
