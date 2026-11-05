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
        // 30분 캐시는 브라우저가 아니라 서버에서 공유합니다.
        response.setHeader("Cache-Control", "no-store");

        long now = System.currentTimeMillis();
        String result = cachedJson;
        if (result != null && now < cacheExpiresAt) {
            response.setHeader("X-Tour-Cache", "HIT");
            response.getWriter().write(result);
            return;
        }

        // 최초 방문과 캐시 만료 직후 동시 요청이 겹쳐도 외부 API는 1회만 호출합니다.
        synchronized (this) {
            now = System.currentTimeMillis();
            result = cachedJson;
            if (result != null && now < cacheExpiresAt) {
                response.setHeader("X-Tour-Cache", "HIT");
                response.getWriter().write(result);
                return;
            }
            try {
                String serviceKey = loadServiceKey();
                if (serviceKey == null || serviceKey.isBlank()) {
                    throw new IllegalStateException("TOUR_API_KEY_NOT_CONFIGURED");
                }

                List<TourContentDTO> items =
                    tourApiService.selectHomeRecommendations(serviceKey, HOME_ITEM_COUNT);
                // 데이터가 정상적으로 조회된 경우에만 캐시를 갱신합니다.
                if (items == null || items.isEmpty()) {
                    throw new IllegalStateException("TourAPI returned an empty list");
                }
                String freshJson = buildJson(serviceKey, items);
                cachedJson = freshJson;
                cacheExpiresAt = System.currentTimeMillis() + CACHE_MILLIS;
                response.setHeader("X-Tour-Cache", "MISS");
                response.getWriter().write(freshJson);
                return;
            } catch (Exception e) {
                getServletContext().log("TourAPI 홈 슬라이드 조회 오류", e);
                // 일시적인 API 장애일 때 마지막 정상 데이터를 보여줍니다.
                if (cachedJson != null) {
                    // 실패 직후 반복적인 API 재호출을 1분 동안 억제합니다.
                    cacheExpiresAt = System.currentTimeMillis() + 60_000L;
                    response.setHeader("X-Tour-Cache", "STALE");
                    response.getWriter().write(cachedJson);
                    return;
                }
                response.setStatus(HttpServletResponse.SC_BAD_GATEWAY);
                response.setHeader("X-Tour-Cache", "ERROR");
                response.getWriter().write(errorJson("관광 정보를 불러오지 못했습니다."));
            }
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
