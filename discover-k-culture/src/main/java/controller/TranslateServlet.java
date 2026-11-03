package controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import service.DeepLService;
import service.DeepLService.DeepLApiException;
import util.DeepLConfig;

@WebServlet(urlPatterns = { "/api/deepl/translate", "/api/deepl/status" })
public class TranslateServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private static final int MAX_TEXTS_PER_REQUEST = 30;
	private static final int MAX_TOTAL_CHARACTERS = 60_000;

	private final DeepLService deepLService = new DeepLService();

	@Override
	public void init() throws ServletException {

		super.init();

		DeepLConfig.initialize(getServletContext());
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		prepareJsonResponse(response);

		HttpSession session = request.getSession(false);

		String siteLanguage = session == null ? "ko" : (String) session.getAttribute("siteLanguage");

		String targetLanguage = toDeepLTarget(siteLanguage);

		String json = "{" + "\"ok\":true," + "\"configured\":" + DeepLConfig.isConfigured() + ","
				+ "\"configSource\":\"" + DeepLService.escapeJson(DeepLConfig.getConfigSource()) + "\","
				+ "\"apiUrl\":\"" + DeepLService.escapeJson(DeepLConfig.getApiUrl()) + "\"," + "\"siteLanguage\":\""
				+ DeepLService.escapeJson(siteLanguage == null ? "ko" : siteLanguage) + "\"," + "\"targetLanguage\":\""
				+ DeepLService.escapeJson(targetLanguage) + "\"" + "}";

		response.getWriter().write(json);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		request.setCharacterEncoding("UTF-8");

		prepareJsonResponse(response);

		HttpSession session = request.getSession(false);

		String siteLanguage = session == null ? "ko" : (String) session.getAttribute("siteLanguage");

		String targetLanguage = toDeepLTarget(siteLanguage);

		String[] requestTexts = request.getParameterValues("text");

		if (requestTexts == null || requestTexts.length == 0) {

			writeError(response, HttpServletResponse.SC_BAD_REQUEST, "EMPTY_TEXT", "번역할 텍스트가 없습니다.");

			return;
		}

		if (requestTexts.length > MAX_TEXTS_PER_REQUEST) {

			writeError(response, HttpServletResponse.SC_BAD_REQUEST, "TOO_MANY_TEXTS", "한 번에 번역할 수 있는 문장 수를 초과했습니다.");

			return;
		}

		List<String> texts = new ArrayList<String>(Arrays.asList(requestTexts));

		int totalCharacters = 0;

		for (int i = 0; i < texts.size(); i++) {

			String value = texts.get(i);

			if (value == null) {
				value = "";
				texts.set(i, value);
			}

			totalCharacters += value.length();
		}

		if (totalCharacters > MAX_TOTAL_CHARACTERS) {

			writeError(response, HttpServletResponse.SC_REQUEST_ENTITY_TOO_LARGE, "TEXT_TOO_LARGE",
					"번역 요청의 전체 텍스트가 너무 큽니다.");

			return;
		}

		if ("KO".equals(targetLanguage)) {

			writeSuccess(response, texts);

			return;
		}

		if (!DeepLConfig.isConfigured()) {

			writeError(response, HttpServletResponse.SC_SERVICE_UNAVAILABLE, "DEEPL_NOT_CONFIGURED",
					"DeepL API Key를 읽지 못했습니다. DEEPL_API_KEY 환경변수 또는 로컬 /WEB-INF/deepl.properties를 확인해주세요.");

			return;
		}

		try {

			List<String> translations = deepLService.translate(texts, targetLanguage);

			writeSuccess(response, translations);

		} catch (DeepLApiException e) {

			int status = e.getStatusCode();

			if (status < 400 || status > 599) {

				status = HttpServletResponse.SC_BAD_GATEWAY;
			}

			writeError(response, status, "DEEPL_API_ERROR", e.getMessage());

		} catch (IllegalStateException e) {

			writeError(response, HttpServletResponse.SC_SERVICE_UNAVAILABLE, "DEEPL_NOT_CONFIGURED", e.getMessage());

		} catch (Exception e) {

			e.printStackTrace();

			writeError(response, HttpServletResponse.SC_BAD_GATEWAY, "DEEPL_REQUEST_FAILED",
					"DeepL 번역 요청에 실패했습니다: " + safeMessage(e));
		}
	}

	private void prepareJsonResponse(HttpServletResponse response) {

		response.setCharacterEncoding("UTF-8");

		response.setContentType("application/json; charset=UTF-8");

		response.setHeader("Cache-Control", "no-store");
	}

	private String toDeepLTarget(String siteLanguage) {

		if ("ja".equals(siteLanguage)) {
			return "JA";
		}

		if ("zh".equals(siteLanguage)) {
			return "ZH-HANS";
		}

		if ("en".equals(siteLanguage)) {
			return "EN-US";
		}

		return "KO";
	}

	private void writeSuccess(HttpServletResponse response, List<String> translations) throws IOException {

		StringBuilder json = new StringBuilder();

		json.append("{\"ok\":true,\"translations\":[");

		for (int i = 0; i < translations.size(); i++) {

			if (i > 0) {
				json.append(',');
			}

			json.append('"').append(DeepLService.escapeJson(translations.get(i))).append('"');
		}

		json.append("]}");

		response.getWriter().write(json.toString());
	}

	private void writeError(HttpServletResponse response, int status, String code, String message) throws IOException {

		response.setStatus(status);

		String json = "{\"ok\":false," + "\"code\":\"" + DeepLService.escapeJson(code) + "\"," + "\"message\":\""
				+ DeepLService.escapeJson(message) + "\"," + "\"configured\":" + DeepLConfig.isConfigured() + ","
				+ "\"configSource\":\"" + DeepLService.escapeJson(DeepLConfig.getConfigSource()) + "\","
				+ "\"apiUrl\":\"" + DeepLService.escapeJson(DeepLConfig.getApiUrl()) + "\"" + "}";

		response.getWriter().write(json);
	}

	private String safeMessage(Exception e) {

		String message = e.getMessage();

		if (message == null || message.trim().isEmpty()) {

			return e.getClass().getSimpleName();
		}

		return message;
	}
}
