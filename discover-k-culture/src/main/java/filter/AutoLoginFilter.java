package filter;

import dao.MemberDAO;
import dao.RememberLoginDAO;

import dto.MemberDTO;

import util.RememberLoginUtil;

import java.io.IOException;
import java.util.Locale;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;

import jakarta.servlet.annotation.WebFilter;

import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebFilter("/*")
public class AutoLoginFilter implements Filter {

	private static final String COOKIE_NAME = "KCULTURE_REMEMBER";

	@Override
	public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
			throws IOException, ServletException {

		HttpServletRequest req = (HttpServletRequest) request;

		HttpServletResponse res = (HttpServletResponse) response;

		HttpSession session = req.getSession(false);

		if (session == null || session.getAttribute("memberId") == null) {

			String rawToken = findCookie(req, COOKIE_NAME);

			if (rawToken != null && !rawToken.isBlank()) {

				try {

					String tokenHash = RememberLoginUtil.sha256(rawToken);

					Long memberId = new RememberLoginDAO().findMemberId(tokenHash);

					if (memberId != null) {

						MemberDTO member = new MemberDAO().selectById(memberId);

						if (member != null
								&& ("ACTIVE".equals(member.getStatus()) || "SUSPENDED".equals(member.getStatus()))) {

							HttpSession newSession = req.getSession(true);

							saveSession(newSession, member);

						} else {

							clearCookie(req, res);
						}

					} else {

						clearCookie(req, res);
					}

				} catch (Exception e) {

					clearCookie(req, res);
				}
			}
		}

		chain.doFilter(request, response);
	}

	private void saveSession(HttpSession session, MemberDTO m) {

		session.setAttribute("memberId", m.getMemberId());

		session.setAttribute("loginId", m.getLoginId());

		session.setAttribute("nickname", m.getNickname());

		session.setAttribute("role", m.getRole());

		session.setAttribute("languageId", m.getLanguageId());

		// 자동 로그인에서도 DB에 저장된 사용 언어를 즉시 복원합니다.
		applyLanguagePreference(session, m.getLanguageId());

		session.setAttribute("profileImage", m.getProfileImage());

		session.setAttribute("memberStatus", m.getStatus());

		session.setAttribute("suspendedUntil", m.getSuspendedUntil());

		session.setAttribute("suspensionReason", m.getSuspensionReason());
	}

	private void applyLanguagePreference(HttpSession session, int languageId) {
		String siteLanguage = "ko";
		String siteLocale = Locale.KOREA.toLanguageTag();

		switch (languageId) {
		case 2:
			siteLanguage = "ja";
			siteLocale = Locale.JAPAN.toLanguageTag();
			break;
		case 3:
			siteLanguage = "zh";
			siteLocale = Locale.CHINA.toLanguageTag();
			break;
		case 4:
			siteLanguage = "en";
			siteLocale = Locale.US.toLanguageTag();
			break;
		default:
			break;
		}

		session.setAttribute("siteLanguage", siteLanguage);

		session.setAttribute("siteLocale", siteLocale);
	}

	private String findCookie(HttpServletRequest request, String name) {

		Cookie[] cookies = request.getCookies();

		if (cookies == null) {
			return null;
		}

		for (Cookie cookie : cookies) {

			if (name.equals(cookie.getName())) {

				return cookie.getValue();
			}
		}

		return null;
	}

	private void clearCookie(HttpServletRequest request, HttpServletResponse response) {

		Cookie cookie = new Cookie(COOKIE_NAME, "");

		cookie.setHttpOnly(true);
		cookie.setSecure(request.isSecure());
		cookie.setMaxAge(0);

		String path = request.getContextPath();

		cookie.setPath(path == null || path.isEmpty() ? "/" : path);

		response.addCookie(cookie);
	}
}
