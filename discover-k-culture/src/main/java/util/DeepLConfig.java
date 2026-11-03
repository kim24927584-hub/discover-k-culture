package util;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

import jakarta.servlet.ServletContext;

/**
 * DeepL API configuration.
 *
 * Priority: 1) JVM option: -Ddeepl.api.key=... 2) Environment variable:
 * DEEPL_API_KEY 3) /WEB-INF/deepl.properties 4) Classpath deepl.properties
 * (legacy fallback)
 *
 * /WEB-INF/deepl.properties is loaded directly from the deployed web app, so it
 * does not depend on Eclipse Deployment Assembly.
 */
public final class DeepLConfig {

	private static final String FREE_URL = "https://api-free.deepl.com/v2/translate";

	private static final String PRO_URL = "https://api.deepl.com/v2/translate";

	private static final String WEB_INF_PROPERTIES = "/WEB-INF/deepl.properties";

	private static final String CLASSPATH_PROPERTIES = "deepl.properties";

	private static final String KEY_PLACEHOLDER = "PUT_YOUR_DEEPL_API_KEY_HERE";

	private static final Properties WEB_PROPERTIES = new Properties();

	private static final Properties CLASSPATH_PROPERTIES_CACHE = loadClasspathProperties();

	private static volatile boolean initialized;

	private DeepLConfig() {
	}

	public static synchronized void initialize(ServletContext context) {

		if (initialized) {
			return;
		}

		if (context != null) {
			try (InputStream input = context.getResourceAsStream(WEB_INF_PROPERTIES)) {

				if (input != null) {
					WEB_PROPERTIES.load(input);
				} else {
					System.err.println("[K-culture DeepL] " + WEB_INF_PROPERTIES + " 파일을 찾지 못했습니다.");
				}

			} catch (IOException e) {

				System.err.println("[K-culture DeepL] " + WEB_INF_PROPERTIES + " 파일을 읽지 못했습니다: " + e.getMessage());
			}
		}

		initialized = true;

		System.out.println("[K-culture DeepL] config initialized" + " / configured=" + isConfigured() + " / source="
				+ getConfigSource() + " / endpoint=" + getApiUrl());
	}

	public static String getApiKey() {

		String value = cleanValue(System.getProperty("deepl.api.key"));

		if (value != null) {
			return value;
		}

		value = cleanValue(System.getenv("DEEPL_API_KEY"));

		if (value != null) {
			return value;
		}

		value = cleanValue(WEB_PROPERTIES.getProperty("deepl.api.key"));

		if (value != null) {
			return value;
		}

		return cleanValue(CLASSPATH_PROPERTIES_CACHE.getProperty("deepl.api.key"));
	}

	public static String getApiUrl() {

		String value = cleanValue(System.getProperty("deepl.api.url"));

		if (value == null) {
			value = cleanValue(System.getenv("DEEPL_API_URL"));
		}

		if (value == null) {
			value = cleanValue(WEB_PROPERTIES.getProperty("deepl.api.url"));
		}

		if (value == null) {
			value = cleanValue(CLASSPATH_PROPERTIES_CACHE.getProperty("deepl.api.url"));
		}

		if (value != null) {
			return value;
		}

		String apiKey = getApiKey();

		if (apiKey != null && apiKey.endsWith(":fx")) {

			return FREE_URL;
		}

		return PRO_URL;
	}

	public static boolean isConfigured() {
		return getApiKey() != null;
	}

	public static String getConfigSource() {

		if (cleanValue(System.getProperty("deepl.api.key")) != null) {

			return "JVM_PROPERTY";
		}

		if (cleanValue(System.getenv("DEEPL_API_KEY")) != null) {

			return "ENVIRONMENT";
		}

		if (cleanValue(WEB_PROPERTIES.getProperty("deepl.api.key")) != null) {

			return "WEB_INF_PROPERTIES";
		}

		if (cleanValue(CLASSPATH_PROPERTIES_CACHE.getProperty("deepl.api.key")) != null) {

			return "CLASSPATH_PROPERTIES";
		}

		return "NONE";
	}

	private static Properties loadClasspathProperties() {

		Properties properties = new Properties();

		ClassLoader loader = DeepLConfig.class.getClassLoader();

		try (InputStream input = loader.getResourceAsStream(CLASSPATH_PROPERTIES)) {

			if (input != null) {
				properties.load(input);
			}

		} catch (IOException e) {

			System.err.println(
					"[K-culture DeepL] classpath " + CLASSPATH_PROPERTIES + " 파일을 읽지 못했습니다: " + e.getMessage());
		}

		return properties;
	}

	private static String cleanValue(String value) {

		if (value == null) {
			return null;
		}

		value = value.trim();

		if (value.isEmpty() || KEY_PLACEHOLDER.equals(value)) {

			return null;
		}

		return value;
	}
}
