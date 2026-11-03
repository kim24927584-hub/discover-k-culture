package util;

import java.net.URI;
import java.net.URLEncoder;

import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

import java.nio.charset.StandardCharsets;

import java.util.LinkedHashMap;
import java.util.Map;


public class OAuthHttpClient {

    private final HttpClient client =
        HttpClient.newHttpClient();


    public String postForm(
        String url,
        Map<String,String> form
    ) throws Exception {

        String body =
            formEncode(form);


        HttpRequest request =
            HttpRequest
                .newBuilder(
                    URI.create(url)
                )
                .header(
                    "Content-Type",
                    "application/x-www-form-urlencoded;charset=UTF-8"
                )
                .POST(
                    HttpRequest.BodyPublishers
                        .ofString(body)
                )
                .build();


        HttpResponse<String> response =
            client.send(
                request,
                HttpResponse.BodyHandlers
                    .ofString(
                        StandardCharsets.UTF_8
                    )
            );


        if (
            response.statusCode() < 200
            || response.statusCode() >= 300
        ) {

            throw new IllegalStateException(
                "OAuth 요청 실패: HTTP "
                + response.statusCode()
                + " / "
                + response.body()
            );
        }


        return response.body();
    }


    public String getBearer(
        String url,
        String accessToken
    ) throws Exception {

        HttpRequest request =
            HttpRequest
                .newBuilder(
                    URI.create(url)
                )
                .header(
                    "Authorization",
                    "Bearer "
                    + accessToken
                )
                .GET()
                .build();


        HttpResponse<String> response =
            client.send(
                request,
                HttpResponse.BodyHandlers
                    .ofString(
                        StandardCharsets.UTF_8
                    )
            );


        if (
            response.statusCode() < 200
            || response.statusCode() >= 300
        ) {

            throw new IllegalStateException(
                "사용자 정보 조회 실패: HTTP "
                + response.statusCode()
                + " / "
                + response.body()
            );
        }


        return response.body();
    }


    public static String formEncode(
        Map<String,String> values
    ) {

        StringBuilder out =
            new StringBuilder();


        for (
            Map.Entry<String,String> entry
            : values.entrySet()
        ) {

            if (entry.getValue() == null) {
                continue;
            }


            if (out.length() > 0) {
                out.append('&');
            }


            out.append(
                encode(
                    entry.getKey()
                )
            );

            out.append('=');

            out.append(
                encode(
                    entry.getValue()
                )
            );
        }


        return out.toString();
    }


    public static String encode(
        String value
    ) {

        return URLEncoder.encode(
            value,
            StandardCharsets.UTF_8
        );
    }


    public static Map<String,String> map() {
        return new LinkedHashMap<String,String>();
    }
}
