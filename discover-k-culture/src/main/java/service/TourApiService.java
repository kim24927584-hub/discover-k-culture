package service;

import dto.TourContentDTO;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URI;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

import java.util.ArrayList;
import java.util.List;

import javax.xml.XMLConstants;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;


public class TourApiService {

    private static final String BASE_URL =
        "https://apis.data.go.kr/B551011/KorService2";


    /*
     * 홈 관광 추천:
     * - 전국 관광지(contentTypeId=12)
     * - 대표 이미지가 있는 콘텐츠 우선
     * - 최대 limit개
     */
    public List<TourContentDTO> selectHomeRecommendations(
        String serviceKey,
        int limit
    ) throws Exception {

        if (limit < 1) {
            limit = 4;
        }

        if (
            serviceKey == null
            || serviceKey.trim().isEmpty()
        ) {

            throw new IllegalStateException(
                "TourAPI 활용키가 입력되지 않았습니다."
            );
        }

        serviceKey =
            serviceKey.trim();


        String url =
            BASE_URL
            + "/areaBasedList2"
            + "?serviceKey="
            + encodeServiceKey(
                serviceKey
            )
            + "&MobileOS=ETC"
            + "&MobileApp="
            + encode(
                "kculture-semi"
            )
            + "&_type=xml"
            + "&contentTypeId=12"
            + "&arrange=Q"
            + "&numOfRows="
            + Math.max(
                limit * 3,
                12
            )
            + "&pageNo=1";


        HttpURLConnection conn =
            (HttpURLConnection)
            URI.create(url)
                .toURL()
                .openConnection();

        conn.setRequestMethod("GET");
        conn.setConnectTimeout(5000);
        conn.setReadTimeout(7000);
        conn.setRequestProperty(
            "Accept",
            "application/xml,text/xml,*/*"
        );
        conn.setRequestProperty(
            "User-Agent",
            "kculture-semi/1.0"
        );


        int status =
            conn.getResponseCode();

        if (
            status < 200
            || status >= 300
        ) {

            throw new IllegalStateException(
                "TourAPI 호출 실패: HTTP "
                + status
            );
        }


        try (
            InputStream in =
                conn.getInputStream()
        ) {

            Document document =
                parseXml(in);

            validateResult(
                document
            );

            NodeList nodes =
                document.getElementsByTagName(
                    "item"
                );

            List<TourContentDTO> list =
                new ArrayList<TourContentDTO>();


            for (
                int i = 0;
                i < nodes.getLength()
                && list.size() < limit;
                i++
            ) {

                Node node =
                    nodes.item(i);

                if (
                    node.getNodeType()
                    != Node.ELEMENT_NODE
                ) {
                    continue;
                }


                Element item =
                    (Element) node;

                String title =
                    text(
                        item,
                        "title"
                    );

                if (
                    title == null
                    || title.isEmpty()
                ) {
                    continue;
                }


                TourContentDTO dto =
                    new TourContentDTO();

                dto.setContentId(
                    text(
                        item,
                        "contentid"
                    )
                );

                dto.setContentTypeId(
                    text(
                        item,
                        "contenttypeid"
                    )
                );

                dto.setTitle(
                    title
                );

                String address =
                    text(
                        item,
                        "addr1"
                    );

                String addr2 =
                    text(
                        item,
                        "addr2"
                    );

                if (
                    addr2 != null
                    && !addr2.isEmpty()
                ) {

                    address =
                        (
                            address == null
                            ? ""
                            : address + " "
                        )
                        + addr2;
                }

                dto.setAddress(
                    address == null
                    ? ""
                    : address.trim()
                );

                String image =
                    text(
                        item,
                        "firstimage"
                    );

                if (
                    image == null
                    || image.isEmpty()
                ) {

                    image =
                        text(
                            item,
                            "firstimage2"
                        );
                }

                dto.setImageUrl(
                    image == null
                    ? ""
                    : image
                );

                dto.setTel(
                    text(
                        item,
                        "tel"
                    )
                );

                list.add(dto);
            }


            return list;

        } finally {

            conn.disconnect();
        }
    }


    /*
     * 홈 슬라이드용 공통 상세 설명 조회.
     * KorService2/detailCommon2는 contentId를 기준으로 overview를 반환합니다.
     */
    public String selectOverview(
        String serviceKey,
        String contentId
    ) throws Exception {

        if (
            serviceKey == null
            || serviceKey.trim().isEmpty()
            || contentId == null
            || contentId.trim().isEmpty()
        ) {
            return "";
        }

        String url =
            BASE_URL
            + "/detailCommon2"
            + "?serviceKey="
            + encodeServiceKey(serviceKey.trim())
            + "&MobileOS=ETC"
            + "&MobileApp="
            + encode("kculture-semi")
            + "&_type=xml"
            + "&contentId="
            + encode(contentId.trim());

        HttpURLConnection conn =
            (HttpURLConnection)
            URI.create(url)
                .toURL()
                .openConnection();

        conn.setRequestMethod("GET");
        conn.setConnectTimeout(5000);
        conn.setReadTimeout(7000);
        conn.setRequestProperty(
            "Accept",
            "application/xml,text/xml,*/*"
        );
        conn.setRequestProperty(
            "User-Agent",
            "kculture-semi/1.0"
        );

        int status = conn.getResponseCode();

        if (status < 200 || status >= 300) {
            throw new IllegalStateException(
                "TourAPI 상세 호출 실패: HTTP " + status
            );
        }

        try (InputStream in = conn.getInputStream()) {

            Document document = parseXml(in);
            validateResult(document);

            NodeList items = document.getElementsByTagName("item");
            if (items.getLength() == 0) {
                return "";
            }

            Node node = items.item(0);
            if (node.getNodeType() != Node.ELEMENT_NODE) {
                return "";
            }

            String overview = text((Element) node, "overview");
            return normalizeOverview(overview);

        } finally {
            conn.disconnect();
        }
    }


    private String normalizeOverview(
        String value
    ) {

        if (value == null || value.isEmpty()) {
            return "";
        }

        return value
            .replaceAll("(?i)<br\\s*/?>", " ")
            .replaceAll("<[^>]+>", " ")
            .replace("&nbsp;", " ")
            .replaceAll("\\s+", " ")
            .trim();
    }


    private Document parseXml(
        InputStream in
    ) throws Exception {

        DocumentBuilderFactory factory =
            DocumentBuilderFactory
                .newInstance();

        factory.setFeature(
            "http://apache.org/xml/features/disallow-doctype-decl",
            true
        );

        factory.setFeature(
            "http://xml.org/sax/features/external-general-entities",
            false
        );

        factory.setFeature(
            "http://xml.org/sax/features/external-parameter-entities",
            false
        );

        factory.setAttribute(
            XMLConstants.ACCESS_EXTERNAL_DTD,
            ""
        );

        factory.setAttribute(
            XMLConstants.ACCESS_EXTERNAL_SCHEMA,
            ""
        );


        DocumentBuilder builder =
            factory.newDocumentBuilder();

        return builder.parse(in);
    }


    private void validateResult(
        Document document
    ) {

        NodeList codeNodes =
            document.getElementsByTagName(
                "resultCode"
            );

        if (
            codeNodes.getLength() == 0
        ) {
            return;
        }

        String code =
            codeNodes.item(0)
                .getTextContent();

        if (
            code == null
            || "0000".equals(
                code.trim()
            )
        ) {
            return;
        }


        String message =
            "";

        NodeList messageNodes =
            document.getElementsByTagName(
                "resultMsg"
            );

        if (
            messageNodes.getLength() > 0
        ) {

            message =
                messageNodes.item(0)
                    .getTextContent();
        }


        throw new IllegalStateException(
            "TourAPI 오류 "
            + code
            + " / "
            + message
        );
    }


    private String text(
        Element parent,
        String tagName
    ) {

        NodeList nodes =
            parent.getElementsByTagName(
                tagName
            );

        if (
            nodes.getLength() == 0
        ) {
            return "";
        }

        String value =
            nodes.item(0)
                .getTextContent();

        return value == null
            ? ""
            : value.trim();
    }


    private String encode(
        String value
    ) {

        return URLEncoder.encode(
            value == null
            ? ""
            : value,
            StandardCharsets.UTF_8
        );
    }


    /*
     * 공공데이터포털은 Encoding Key / Decoding Key를 모두 보여주는 경우가 있습니다.
     * 사용자가 이미 %2F, %2B 형태의 Encoding Key를 넣었으면 재인코딩하지 않습니다.
     */
    private String encodeServiceKey(
        String key
    ) {

        if (
            key.contains("%")
        ) {

            return key;
        }

        return encode(key);
    }
}
