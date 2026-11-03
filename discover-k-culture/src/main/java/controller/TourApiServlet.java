package controller;

import dto.TourContentDTO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import service.TourApiService;

import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Properties;

@WebServlet("/api/tour/home")
public class TourApiServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final long CACHE_MILLIS = 30L * 60L * 1000L;
    private static final int HOME_ITEM_COUNT = 5;

    private final TourApiService tourApiService = new TourApiService();

    private volatile String cachedJson;
    private volatile long cacheExpiresAt;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setCharacterEncoding(StandardCharsets.UTF_8.name());
        response.setContentType("application/json; charset=UTF-8");
        response.setHeader("Cache-Control", "no-store");

        long now = System.currentTimeMillis();
        String cache = cachedJson;

        if (cache != null && now < cacheExpiresAt) {
            response.getWriter().write(cache);
            return;
        }

        try {
            String serviceKey = loadServiceKey();

            if (serviceKey == null || serviceKey.isBlank()) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write(errorJson("TourAPI 키가 설정되지 않았습니다."));
                return;
            }

            List<TourContentDTO> items =
                tourApiService.selectHomeRecommendations(serviceKey, HOME_ITEM_COUNT);

            String json = buildJson(serviceKey, items);

            cachedJson = json;
            cacheExpiresAt = now + CACHE_MILLIS;

            response.getWriter().write(json);

        } catch (Exception e) {
            getServletContext().log("TourAPI 홈 슬라이드 조회 오류", e);
            response.setStatus(HttpServletResponse.SC_BAD_GATEWAY);
            response.getWriter().write(errorJson("관광 정보를 불러오지 못했습니다."));
        }
    }

    private String buildJson(String serviceKey, List<TourContentDTO> items) {

        StringBuilder json = new StringBuilder();
        json.append("{\"success\":true,\"items\":[");

        boolean first = true;

        for (TourContentDTO item : items) {
            if (item == null || item.getTitle() == null || item.getTitle().isBlank()) {
                continue;
            }

            String description = "";

            try {
                description = tourApiService.selectOverview(
                    serviceKey,
                    item.getContentId()
                );
            } catch (Exception e) {
                getServletContext().log(
                    "TourAPI 상세 설명 조회 실패: " + item.getContentId(),
                    e
                );
            }

            if (!first) {
                json.append(',');
            }
            first = false;

            json.append('{')
                .append("\"contentId\":\"").append(jsonEscape(item.getContentId())).append("\",")
                .append("\"title\":\"").append(jsonEscape(item.getTitle())).append("\",")
                .append("\"address\":\"").append(jsonEscape(item.getAddress())).append("\",")
                .append("\"imageUrl\":\"").append(jsonEscape(item.getImageUrl())).append("\",")
                .append("\"description\":\"").append(jsonEscape(description)).append("\"")
                .append('}');
        }

        json.append("]}");
        return json.toString();
    }

    private String loadServiceKey() throws IOException {

        String envKey = System.getenv("TOUR_API_KEY");
        if (envKey != null && !envKey.isBlank()) {
            return envKey.trim();
        }

        Properties properties = new Properties();

        InputStream in = Thread.currentThread()
            .getContextClassLoader()
            .getResourceAsStream("tour.properties");

        if (in == null) {
            in = getServletContext().getResourceAsStream("/WEB-INF/tour.properties");
        }

        if (in == null) {
            return null;
        }

        try (InputStream configIn = in) {
            properties.load(configIn);
        }

        String key = properties.getProperty("tour.api.key");
        return key == null ? null : key.trim();
    }

    private String errorJson(String message) {
        return "{\"success\":false,\"message\":\""
            + jsonEscape(message)
            + "\",\"items\":[]}";
    }

    private String jsonEscape(String value) {
        if (value == null) {
            return "";
        }

        StringBuilder out = new StringBuilder(value.length() + 16);

        for (int i = 0; i < value.length(); i++) {
            char c = value.charAt(i);

            switch (c) {
                case '"': out.append("\\\""); break;
                case '\\': out.append("\\\\"); break;
                case '\b': out.append("\\b"); break;
                case '\f': out.append("\\f"); break;
                case '\n': out.append("\\n"); break;
                case '\r': out.append("\\r"); break;
                case '\t': out.append("\\t"); break;
                default:
                    if (c < 0x20) {
                        out.append(String.format("\\u%04x", (int)c));
                    } else {
                        out.append(c);
                    }
            }
        }

        return out.toString();
    }
}
