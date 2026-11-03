package util;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

public final class OAuthConfig {

	/*
	 * ============================================================ 소셜 로그인 설정
	 *
	 * 실제 Client ID / Client Secret은 코드에 직접 작성하지 않습니다.
	 *
	 * 설정 우선순위: 1. 운영체제 환경변수 2. JVM System Property (-DKEY=value) 3.
	 * src/main/resources/oauth.properties
	 *
	 * Callback URL 예시: Google:
	 * http://localhost:8081/kculture-semi/oauth/google/callback Kakao :
	 * http://localhost:8081/kculture-semi/oauth/kakao/callback Naver :
	 * http://localhost:8081/kculture-semi/oauth/naver/callback
	 * ============================================================
	 */

	private static final Properties PROPERTIES = loadProperties();

	public static final String GOOGLE_CLIENT_ID = getConfig("GOOGLE_CLIENT_ID", "google.client.id");

	public static final String GOOGLE_CLIENT_SECRET = getConfig("GOOGLE_CLIENT_SECRET", "google.client.secret");

	public static final String KAKAO_CLIENT_ID = getConfig("KAKAO_CLIENT_ID", "kakao.client.id");

	public static final String KAKAO_CLIENT_SECRET = getConfig("KAKAO_CLIENT_SECRET", "kakao.client.secret");

	public static final String NAVER_CLIENT_ID = getConfig("NAVER_CLIENT_ID", "naver.client.id");

	public static final String NAVER_CLIENT_SECRET = getConfig("NAVER_CLIENT_SECRET", "naver.client.secret");

	private OAuthConfig() {
	}

	private static Properties loadProperties() {
		Properties properties = new Properties();

		try (InputStream input = OAuthConfig.class.getClassLoader().getResourceAsStream("oauth.properties")) {

			if (input != null) {
				properties.load(input);
			}

		} catch (IOException e) {
			throw new IllegalStateException("oauth.properties 파일을 읽는 중 오류가 발생했습니다.", e);
		}

		return properties;
	}

	private static String getConfig(String envKey, String propertyKey) {

		// 1. 운영체제 환경변수
		String value = System.getenv(envKey);
		if (hasText(value)) {
			return value.trim();
		}

		// 2. JVM System Property: -DGOOGLE_CLIENT_ID=...
		value = System.getProperty(envKey);
		if (hasText(value)) {
			return value.trim();
		}

		// 2-1. JVM System Property: -Dgoogle.client.id=...
		value = System.getProperty(propertyKey);
		if (hasText(value)) {
			return value.trim();
		}

		// 3. src/main/resources/oauth.properties
		value = PROPERTIES.getProperty(propertyKey);
		if (hasText(value)) {
			return value.trim();
		}

		return "";
	}

	private static boolean hasText(String value) {
		return value != null && !value.trim().isEmpty();
	}

	/*
	 * 기존 SocialOAuthService의 OAuthConfig.get("KEY") 호출 방식을 그대로 지원합니다.
	 */
	public static String get(String key) {

		if (key == null) {
			return "";
		}

		switch (key) {

		case "GOOGLE_CLIENT_ID":
			return GOOGLE_CLIENT_ID;

		case "GOOGLE_CLIENT_SECRET":
			return GOOGLE_CLIENT_SECRET;

		case "KAKAO_CLIENT_ID":
			return KAKAO_CLIENT_ID;

		case "KAKAO_CLIENT_SECRET":
			return KAKAO_CLIENT_SECRET;

		case "NAVER_CLIENT_ID":
			return NAVER_CLIENT_ID;

		case "NAVER_CLIENT_SECRET":
			return NAVER_CLIENT_SECRET;

		default:
			return "";
		}
	}

	/*
	 * 필수 설정값 조회. 기존 SocialLoginServlet / SocialOAuthService와 호환됩니다.
	 */
	public static String required(String key) {

		String value = get(key);

		if (!hasText(value)) {
			throw new IllegalStateException(
					key + " 값이 설정되지 않았습니다. " + "환경변수 또는 src/main/resources/oauth.properties를 확인해주세요.");
		}

		return value.trim();
	}

	public static boolean isGoogleConfigured() {
		return hasText(GOOGLE_CLIENT_ID) && hasText(GOOGLE_CLIENT_SECRET);
	}

	public static boolean isKakaoConfigured() {
		return hasText(KAKAO_CLIENT_ID) && hasText(KAKAO_CLIENT_SECRET);
	}

	public static boolean isNaverConfigured() {
		return hasText(NAVER_CLIENT_ID) && hasText(NAVER_CLIENT_SECRET);
	}
}
