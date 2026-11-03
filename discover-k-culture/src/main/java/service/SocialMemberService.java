package service;

import dao.MemberDAO;
import dao.SocialAccountDAO;

import dto.MemberDTO;
import dto.SocialUserInfo;

import java.util.UUID;

public class SocialMemberService {

	public MemberDTO loginOrCreate(SocialUserInfo social) throws Exception {

		SocialAccountDAO socialDAO = new SocialAccountDAO();

		MemberDAO memberDAO = new MemberDAO();

		Long linkedMemberId = socialDAO.findMemberId(social.getProvider(), social.getProviderUserId());

		if (linkedMemberId != null) {

			MemberDTO member = memberDAO.selectById(linkedMemberId);

			if (member == null) {

				throw new IllegalStateException("연결된 회원을 찾을 수 없습니다.");
			}

			if (!"ACTIVE".equals(member.getStatus()) && !"SUSPENDED".equals(member.getStatus())) {

				throw new IllegalStateException("탈퇴 처리된 회원입니다.");
			}

			return member;
		}

		MemberDTO member = null;

		if (social.getEmail() != null && !social.getEmail().isBlank()) {

			member = memberDAO.selectByEmail(social.getEmail());
		}

		if (member == null) {

			member = createMember(social, memberDAO);
		}

		try {

			socialDAO.link(member.getMemberId(), social.getProvider(), social.getProviderUserId(), social.getEmail());

		} catch (Exception duplicateRace) {

			Long retryMemberId = socialDAO.findMemberId(social.getProvider(), social.getProviderUserId());

			if (retryMemberId == null) {
				throw duplicateRace;
			}

			member = memberDAO.selectById(retryMemberId);
		}

		return member;
	}

	private MemberDTO createMember(SocialUserInfo social, MemberDAO memberDAO) throws Exception {

		String providerLower = social.getProvider().toLowerCase();

		String idSuffix = clean(social.getProviderUserId());

		if (idSuffix.length() > 18) {
			idSuffix = idSuffix.substring(0, 18);
		}

		String baseLoginId = providerLower + "_" + idSuffix;

		String loginId = uniqueLoginId(baseLoginId, memberDAO);

		String nickname = uniqueNickname(safeNickname(social.getNickname(), social.getProvider()), memberDAO);

		String email = social.getEmail();

		if (email == null || email.isBlank()) {

			email = providerLower + "_" + social.getProviderUserId() + "@social.kculture.local";
		}

		MemberDTO m = new MemberDTO();

		m.setLoginId(loginId);

		m.setPassword(UUID.randomUUID().toString());

		m.setNickname(nickname);

		m.setEmail(email);

		m.setNationality(null);

		m.setLanguageId(1);

		m.setProfileImage(null);

		int inserted = memberDAO.insert(m);

		if (inserted != 1) {

			throw new IllegalStateException("소셜 회원 생성에 실패했습니다.");
		}

		MemberDTO created = memberDAO.selectByEmail(email);

		if (created == null) {

			throw new IllegalStateException("생성된 소셜 회원을 다시 찾지 못했습니다.");
		}

		return created;
	}

	private String uniqueLoginId(String base, MemberDAO dao) throws Exception {

		String value = limit(base, 45);

		if (!dao.existsLoginId(value)) {
			return value;
		}

		for (int i = 2; i < 1000; i++) {

			String candidate = limit(base, 40) + "_" + i;

			if (!dao.existsLoginId(candidate)) {
				return candidate;
			}
		}

		return "social_" + UUID.randomUUID().toString().replace("-", "").substring(0, 20);
	}

	private String uniqueNickname(String base, MemberDAO dao) throws Exception {

		String value = limit(base, 40);

		if (!dao.existsNickname(value)) {
			return value;
		}

		for (int i = 2; i < 1000; i++) {

			String candidate = limit(base, 35) + i;

			if (!dao.existsNickname(candidate)) {
				return candidate;
			}
		}

		return "소셜회원" + System.currentTimeMillis() % 1000000;
	}

	private String safeNickname(String nickname, String provider) {

		if (nickname == null || nickname.isBlank()) {

			return provider + "회원";
		}

		return nickname.trim();
	}

	private String clean(String value) {

		String cleaned = value.replaceAll("[^A-Za-z0-9]", "");

		if (cleaned.isBlank()) {
			cleaned = "user";
		}

		return cleaned;
	}

	private String limit(String value, int max) {

		if (value.length() <= max) {
			return value;
		}

		return value.substring(0, max);
	}
}
