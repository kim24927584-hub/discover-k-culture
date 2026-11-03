package service;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import util.DeepLConfig;

/**
 * Small DeepL HTTP client with no third-party dependency.
 */
public class DeepLService {

    private static final int CONNECT_TIMEOUT_MS = 10_000;
    private static final int READ_TIMEOUT_MS = 30_000;

    private static final Pattern TRANSLATED_TEXT_PATTERN = Pattern.compile(
            "\\\"text\\\"\\s*:\\s*\\\"((?:\\\\.|[^\\\"\\\\])*)\\\"");

    public List<String> translate(List<String> texts, String targetLanguage) throws IOException {
        if (texts == null || texts.isEmpty()) {
            return new ArrayList<String>();
        }

        String apiKey = DeepLConfig.getApiKey();

        if (apiKey == null) {
            throw new IllegalStateException("DEEPL_API_KEY is not configured.");
        }

        String requestBody = buildRequestBody(texts, targetLanguage);
        byte[] requestBytes = requestBody.getBytes(StandardCharsets.UTF_8);

        HttpURLConnection connection = null;

        try {
            URL url = new URL(DeepLConfig.getApiUrl());
            connection = (HttpURLConnection) url.openConnection();

            connection.setRequestMethod("POST");
            connection.setConnectTimeout(CONNECT_TIMEOUT_MS);
            connection.setReadTimeout(READ_TIMEOUT_MS);
            connection.setDoOutput(true);

            connection.setRequestProperty("Authorization", "DeepL-Auth-Key " + apiKey);
            connection.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
            connection.setRequestProperty("Accept", "application/json");
            connection.setRequestProperty("User-Agent", "KCultureSemi/1.0");

            try (OutputStream output = connection.getOutputStream()) {
                output.write(requestBytes);
            }

            int status = connection.getResponseCode();
            String responseBody = readResponse(
                    status >= 200 && status < 300
                            ? connection.getInputStream()
                            : connection.getErrorStream());

            if (status != HttpURLConnection.HTTP_OK) {
                throw new DeepLApiException(status, readableMessage(status, responseBody));
            }

            List<String> translations = parseTranslations(responseBody);

            if (translations.size() != texts.size()) {
                throw new IOException(
                        "DeepL response count mismatch. requested=" + texts.size()
                        + ", received=" + translations.size());
            }

            return translations;

        } finally {
            if (connection != null) {
                connection.disconnect();
            }
        }
    }

    private String buildRequestBody(List<String> texts, String targetLanguage) {
        StringBuilder json = new StringBuilder();
        json.append('{');
        json.append("\"text\":[");

        for (int i = 0; i < texts.size(); i++) {
            if (i > 0) {
                json.append(',');
            }

            json.append('"')
                .append(escapeJson(texts.get(i)))
                .append('"');
        }

        json.append("],");
        json.append("\"target_lang\":\"")
            .append(escapeJson(targetLanguage))
            .append("\",");
        json.append("\"preserve_formatting\":true");
        json.append('}');

        return json.toString();
    }

    private List<String> parseTranslations(String json) {
        List<String> result = new ArrayList<String>();

        if (json == null || json.isEmpty()) {
            return result;
        }

        Matcher matcher = TRANSLATED_TEXT_PATTERN.matcher(json);

        while (matcher.find()) {
            result.add(unescapeJson(matcher.group(1)));
        }

        return result;
    }

    private String readResponse(InputStream input) throws IOException {
        if (input == null) {
            return "";
        }

        StringBuilder text = new StringBuilder();

        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(input, StandardCharsets.UTF_8))) {

            String line;

            while ((line = reader.readLine()) != null) {
                text.append(line);
            }
        }

        return text.toString();
    }

    private String readableMessage(int status, String responseBody) {
        switch (status) {
            case 400:
                return "DeepL request is invalid.";
            case 403:
                return "DeepL authentication failed. Check DEEPL_API_KEY and the API endpoint.";
            case 413:
                return "DeepL request is too large.";
            case 429:
                return "DeepL request limit reached. Please retry later.";
            case 456:
                return "DeepL quota has been exceeded.";
            case 529:
                return "DeepL service is temporarily overloaded.";
            default:
                return "DeepL API error (HTTP " + status + "). " + safePreview(responseBody);
        }
    }

    private String safePreview(String value) {
        if (value == null) {
            return "";
        }

        value = value.replace('\n', ' ').replace('\r', ' ').trim();
        return value.length() > 180 ? value.substring(0, 180) + "..." : value;
    }

    public static String escapeJson(String value) {
        if (value == null) {
            return "";
        }

        StringBuilder out = new StringBuilder(value.length() + 16);

        for (int i = 0; i < value.length(); i++) {
            char c = value.charAt(i);

            switch (c) {
                case '"':
                    out.append("\\\"");
                    break;
                case '\\':
                    out.append("\\\\");
                    break;
                case '\b':
                    out.append("\\b");
                    break;
                case '\f':
                    out.append("\\f");
                    break;
                case '\n':
                    out.append("\\n");
                    break;
                case '\r':
                    out.append("\\r");
                    break;
                case '\t':
                    out.append("\\t");
                    break;
                default:
                    if (c < 0x20) {
                        out.append(String.format("\\u%04x", (int) c));
                    } else {
                        out.append(c);
                    }
            }
        }

        return out.toString();
    }

    private String unescapeJson(String value) {
        StringBuilder out = new StringBuilder();

        for (int i = 0; i < value.length(); i++) {
            char c = value.charAt(i);

            if (c != '\\' || i + 1 >= value.length()) {
                out.append(c);
                continue;
            }

            char next = value.charAt(++i);

            switch (next) {
                case '"':
                    out.append('"');
                    break;
                case '\\':
                    out.append('\\');
                    break;
                case '/':
                    out.append('/');
                    break;
                case 'b':
                    out.append('\b');
                    break;
                case 'f':
                    out.append('\f');
                    break;
                case 'n':
                    out.append('\n');
                    break;
                case 'r':
                    out.append('\r');
                    break;
                case 't':
                    out.append('\t');
                    break;
                case 'u':
                    if (i + 4 < value.length()) {
                        String hex = value.substring(i + 1, i + 5);

                        try {
                            out.append((char) Integer.parseInt(hex, 16));
                            i += 4;
                        } catch (NumberFormatException e) {
                            out.append("\\u").append(hex);
                            i += 4;
                        }
                    } else {
                        out.append("\\u");
                    }
                    break;
                default:
                    out.append(next);
            }
        }

        return out.toString();
    }

    public static class DeepLApiException extends IOException {
        private static final long serialVersionUID = 1L;

        private final int statusCode;

        public DeepLApiException(int statusCode, String message) {
            super(message);
            this.statusCode = statusCode;
        }

        public int getStatusCode() {
            return statusCode;
        }
    }
}
