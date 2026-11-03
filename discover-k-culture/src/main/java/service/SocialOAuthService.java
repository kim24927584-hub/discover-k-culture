package service;

import dto.SocialUserInfo;

import util.OAuthConfig;
import util.OAuthHttpClient;
import util.SimpleJson;

import java.util.Map;

public class SocialOAuthService {

	private final OAuthHttpClient http = new OAuthHttpClient();

	public String authorizationUrl(String provider, String clientId, String redirectUri, String state) {

		Map<String, String> q = OAuthHttpClient.map();

		if ("GOOGLE".equals(provider)) {

			q.put("response_type", "code");

			q.put("client_id", clientId);

			q.put("redirect_uri", redirectUri);

			q.put("scope", "openid email profile");

			q.put("state", state);

			return "https://accounts.google.com/o/oauth2/v2/auth?" + OAuthHttpClient.formEncode(q);
		}

		if ("KAKAO".equals(provider)) {

			q.put("response_type", "code");

			q.put("client_id", clientId);

			q.put("redirect_uri", redirectUri);

			q.put("state", state);

			return "https://kauth.kakao.com/oauth/authorize?" + OAuthHttpClient.formEncode(q);
		}

		if ("NAVER".equals(provider)) {

			q.put("response_type", "code");

			q.put("client_id", clientId);

			q.put("redirect_uri", redirectUri);

			q.put("state", state);

			return "https://nid.naver.com/oauth2.0/authorize?" + OAuthHttpClient.formEncode(q);
		}

		throw new IllegalArgumentException("지원하지 않는 소셜 로그인입니다.");
	}

	public SocialUserInfo fetchUser(String provider, String code, String redirectUri, String state) throws Exception {

		if ("GOOGLE".equals(provider)) {
			return google(code, redirectUri);
		}

		if ("KAKAO".equals(provider)) {
			return kakao(code, redirectUri);
		}

		if ("NAVER".equals(provider)) {
			return naver(code, redirectUri, state);
		}

		throw new IllegalArgumentException("지원하지 않는 소셜 로그인입니다.");
	}

	private SocialUserInfo google(String code, String redirectUri) throws Exception {

		Map<String, String> form = OAuthHttpClient.map();

		form.put("client_id", OAuthConfig.required("GOOGLE_CLIENT_ID"));

		form.put("client_secret", OAuthConfig.required("GOOGLE_CLIENT_SECRET"));

		form.put("code", code);

		form.put("grant_type", "authorization_code");

		form.put("redirect_uri", redirectUri);

		String tokenJson = http.postForm("https://oauth2.googleapis.com/token", form);

		String accessToken = SimpleJson.string(tokenJson, "access_token");

		if (accessToken == null) {
			throw new IllegalStateException("Google access_token을 받지 못했습니다.");
		}

		String userJson = http.getBearer("https://openidconnect.googleapis.com/v1/userinfo", accessToken);

		String id = SimpleJson.string(userJson, "sub");

		String email = SimpleJson.string(userJson, "email");

		String nickname = SimpleJson.string(userJson, "name");

		return normalize("GOOGLE", id, email, nickname);
	}

	private SocialUserInfo kakao(String code, String redirectUri) throws Exception {

		Map<String, String> form = OAuthHttpClient.map();

		form.put("grant_type", "authorization_code");

		form.put("client_id", OAuthConfig.required("KAKAO_CLIENT_ID"));

		form.put("redirect_uri", redirectUri);

		form.put("code", code);

		String secret = OAuthConfig.get("KAKAO_CLIENT_SECRET");

		if (secret != null) {
			form.put("client_secret", secret);
		}

		String tokenJson = http.postForm("https://kauth.kakao.com/oauth/token", form);

		String accessToken = SimpleJson.string(tokenJson, "access_token");

		if (accessToken == null) {
			throw new IllegalStateException("Kakao access_token을 받지 못했습니다.");
		}

		String userJson = http.getBearer("https://kapi.kakao.com/v2/user/me", accessToken);

		String id = SimpleJson.number(userJson, "id");

		String email = SimpleJson.string(userJson, "email");

		String nickname = SimpleJson.string(userJson, "nickname");

		return normalize("KAKAO", id, email, nickname);
	}

	private SocialUserInfo naver(String code, String redirectUri, String state) throws Exception {

		Map<String, String> form = OAuthHttpClient.map();

		form.put("grant_type", "authorization_code");

		form.put("client_id", OAuthConfig.required("NAVER_CLIENT_ID"));

		form.put("client_secret", OAuthConfig.required("NAVER_CLIENT_SECRET"));

		form.put("code", code);

		/*
		 * 네이버 OAuth 토큰 발급 시 인증 요청에서 사용하고 callback으로 받은 동일한 state 전달.
		 */
		form.put("state", state);

		/*
		 * 현재 네이버 OAuth 명세의 redirect_uri 방식과도 호환되도록 인증 요청에서 사용한 callback URL을 동일하게
		 * 전달합니다.
		 */
		form.put("redirect_uri", redirectUri);

		/*
		 * 디버깅 로그: Secret / authorization code 원문은 출력하지 않습니다.
		 */
		System.out.println("[NAVER OAuth] redirectUri=" + redirectUri);

		System.out.println("[NAVER OAuth] statePresent=" + (state != null && !state.isBlank()));

		System.out.println("[NAVER OAuth] codePresent=" + (code != null && !code.isBlank()));

		System.out.println("[NAVER OAuth] clientIdPresent=" + (OAuthConfig.get("NAVER_CLIENT_ID") != null));

		String tokenJson = http.postForm("https://nid.naver.com/oauth2.0/token", form);

		String accessToken = SimpleJson.string(tokenJson, "access_token");

		if (accessToken == null) {
			throw new IllegalStateException("Naver access_token을 받지 못했습니다.");
		}

		String userJson = http.getBearer("https://openapi.naver.com/v1/nid/me", accessToken);

		String id = SimpleJson.string(userJson, "id");

		String email = SimpleJson.string(userJson, "email");

		String nickname = SimpleJson.string(userJson, "nickname");

		if (nickname == null || nickname.isBlank()) {

			nickname = SimpleJson.string(userJson, "name");
		}

		return normalize("NAVER", id, email, nickname);
	}

	private SocialUserInfo normalize(String provider, String id, String email, String nickname) {

		if (id == null || id.isBlank()) {

			throw new IllegalStateException(provider + " 사용자 식별자를 받지 못했습니다.");
		}

		if (nickname == null || nickname.isBlank()) {

			nickname = provider + " 사용자";
		}

		return new SocialUserInfo(provider, id, email, nickname);
	}
}
