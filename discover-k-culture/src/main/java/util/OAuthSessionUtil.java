package util;

import java.util.Locale;

import dto.MemberDTO;
import jakarta.servlet.http.HttpSession;

public class OAuthSessionUtil {

    private OAuthSessionUtil() {
    }

    public static void saveMember(HttpSession session, MemberDTO m) {
        session.setAttribute("memberId", m.getMemberId());
        session.setAttribute("loginId", m.getLoginId());
        session.setAttribute("nickname", m.getNickname());
        session.setAttribute("role", m.getRole());
        session.setAttribute("languageId", m.getLanguageId());
        session.setAttribute("profileImage", m.getProfileImage());
        session.setAttribute("memberStatus", m.getStatus());
        session.setAttribute("suspendedUntil", m.getSuspendedUntil());
        session.setAttribute("suspensionReason", m.getSuspensionReason());

        applyLanguagePreference(session, m.getLanguageId());
    }

    private static void applyLanguagePreference(HttpSession session, int languageId) {
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
}
