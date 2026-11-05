<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.List"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="dao.NoticeDAO"%>
<%@ page import="dao.UnifiedBoardDAO"%>
<%@ page import="dto.NoticeDTO"%>
<%@ page import="dto.UnifiedBoardDTO"%>


<%!
private String h(String value) {
    if (value == null) return "";
    return value.replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace("\"", "&quot;")
        .replace("'", "&#39;");
}

private String shortText(String value, int max) {
    if (value == null) return "";
    String clean = value.replaceAll("<[^>]*>", " ")
        .replaceAll("\\s+", " ")
        .trim();
    if (clean.length() <= max) return clean;
    return clean.substring(0, max) + "...";
}
%>
<%
request.setCharacterEncoding("UTF-8");

List<NoticeDTO> notices = new ArrayList<NoticeDTO>();
List<UnifiedBoardDTO> topViewed = new ArrayList<UnifiedBoardDTO>();
List<UnifiedBoardDTO> latestAll = new ArrayList<UnifiedBoardDTO>();

String noticeError = null;
String postError = null;


try {
	notices = new NoticeDAO().selectPage(1, 5);
} catch (Exception e) {
	noticeError = "공지사항을 불러오지 못했습니다.";
	application.log("home.jsp 공지사항 조회 오류", e);
}

try {
	UnifiedBoardDAO unifiedDAO = new UnifiedBoardDAO();
	topViewed = unifiedDAO.selectTopViewedPosts(6);
	latestAll = unifiedDAO.selectLatest("", 1, 7);
} catch (Exception e) {
	postError = "게시글을 불러오지 못했습니다.";
	application.log("home.jsp 게시글 조회 오류", e);
}

SimpleDateFormat dateFormat = new SimpleDateFormat("yy.MM.dd");
String ctxPath = request.getContextPath();
%>

<!-- css 세팅 -->
<%
request.setAttribute("pageCss", "home.css");
%>
<%@ include file="/include/header.jsp"%>
<!-- 메인 -->

	<main>
		<div class="wrapper">
			<section class="main-s1">
				<table class="board board-notice">
					<caption>
						<div class="main-caption">
							<a href="<%=ctxPath%>/board/noticeList.jsp">공지사항</a> <a href="<%=ctxPath%>/board/noticeList.jsp"> <img
								src="${ctx}/resources/assets/icon-arrow-right-6423875.png"
								alt="" />
							</a>
						</div>
					</caption>

					<%
					if (noticeError != null) {
					%>
					<tr>
						<td class="notice-symbol notice">공지사항</td>
						<td class="notice-title"><a href="<%=ctxPath%>/board/noticeList.jsp"><%=noticeError%></a></td>
						<td class="notice-hits">-</td>
					</tr>
					<%
					} else if (notices == null || notices.isEmpty()) {
					%>
					<tr>
						<td class="notice-symbol notice">공지사항</td>
						<td class="notice-title"><a href="<%=ctxPath%>/board/noticeList.jsp">등록된 공지가 없습니다.</a></td>
						<td class="notice-hits">0</td>
					</tr>
					<%
					} else {
					for (NoticeDTO notice : notices) {
					%>
					<tr>
						<td class="notice-symbol notice">공지사항</td>
						<td class="notice-title"><a
                                href="<%=ctxPath%>/board/noticeView.jsp?id=<%=notice.getNoticeId()%>"
                                title="<%=h(notice.getTitle())%>"><%=h(shortText(notice.getTitle(), 26))%></a>
						</td>
						<td class="notice-hits"><%=notice.getViewCount()%></td>
					</tr>
					<%
					}
					}
					%>
				</table>
			</section>

			<section class="main-s2">
                <%-- 홈 HTML을 관광 API 네트워크 응답보다 먼저 출력합니다.
                     데이터는 /api/tour/home(서버 30분 캐시)에서 비동기로 수신합니다. --%>
                <div class="festival-api" id="tourRecommendation"
                     data-api-url="<%=ctxPath%>/api/tour/home"
                     data-fallback-image="<%=ctxPath%>/resources/img/no-image.jpg"
                     style="position:relative; box-sizing:border-box; padding-bottom:46px; overflow:hidden;">
                    <div class="festival-caption"><span>여행 추천</span></div>
                    <div id="tourSlider" style="padding-bottom:4px;">
                        <table class="board"><tbody><tr><td>여행 정보를 불러오는 중...</td></tr></tbody></table>
                    </div>
                    <div class="tour-slider-controls"
                         aria-label="여행 추천 슬라이드 이동" hidden
                         style="position:absolute; left:10px; right:10px; bottom:8px; height:34px; display:flex; align-items:center; justify-content:center; gap:14px; background:var(--color-bg-muted, #f1f3f4); color:var(--color-text, #333333); z-index:5;">
                        <button type="button" id="tourPrevButton" aria-label="이전 관광지" title="이전"
                                style="width:30px; height:30px; display:flex; align-items:center; justify-content:center; cursor:pointer; color:var(--color-text, #333333);">◀</button>
                        <span id="tourSlideCounter" style="min-width:48px; text-align:center; white-space:nowrap;">0 / 0</span>
                        <button type="button" id="tourNextButton" aria-label="다음 관광지" title="다음"
                                style="width:30px; height:30px; display:flex; align-items:center; justify-content:center; cursor:pointer; color:var(--color-text, #333333);">▶</button>
                    </div>
                </div>
            </section>
		</div>

		<div class="wrapper">
			<section class="main-s3">
				<ul>
					<%
					if (postError != null || topViewed == null || topViewed.isEmpty()) {
					%>
					<li class="picture-posts">
						<dl class="p-post">
							<dt class="p-img">
								<a href="<%=ctxPath%>/board/allList.jsp"><img src="${ctx}/resources/img/no-image.jpg"
									alt="" /></a>
							</dt>
							<dd class="p-title">
								<a href="<%=ctxPath%>/board/allList.jsp"><%=postError != null ? postError : "등록된 게시글이 없습니다."%></a>
							</dd>
							<dd class="p-writer">-</dd>
							<dd class="p-info">
								<span>-</span><span class="p-view"><img
									src="${ctx}/resources/assets/icon-open-eye-829117.png" alt="" /><span
									class="p-hits">0</span></span>
							</dd>
						</dl>
					</li>
					<%
					} else {
					for (int rowStart = 0; rowStart < topViewed.size(); rowStart += 3) {
					%>
					<li class="picture-posts">
						<%
						for (int i = rowStart; i < rowStart + 3 && i < topViewed.size(); i++) {
							UnifiedBoardDTO post = topViewed.get(i);

							String imageSrc = null;
							if (post.getImagePath() != null && !post.getImagePath().trim().isEmpty()) {
								imageSrc = ctxPath + post.getImagePath();
							} else if (post.getVideoThumbnailPath() != null && !post.getVideoThumbnailPath().trim().isEmpty()) {
								imageSrc = ctxPath + post.getVideoThumbnailPath();
							} else {
								imageSrc = ctxPath + "/resources/img/icon-no-img512.png";
							}

							String postLink;
							if ("KCULTURE".equals(post.getBoardType())) {
								postLink = ctxPath + "/board/category-view.jsp?postId=" + post.getId();
							} else if ("QUESTION".equals(post.getBoardType())) {
								postLink = ctxPath + "/board/qnaView.jsp?id=" + post.getId();
							} else {
								postLink = ctxPath + "/board/allView.jsp?id=" + post.getId();
							}
						%>
						<dl class="p-post">
							<dt class="p-img">
								<a href="<%=postLink%>"><img src="<%=imageSrc%>" alt="" /></a>
							</dt>
							<dd class="p-title">
								<a href="<%=postLink%>" title="<%=h(post.getTitle())%>"><%=h(shortText(post.getTitle(), 18))%></a>
							</dd>
							<dd class="p-writer" title="<%=h(post.getWriterNickname())%>"><%=h(shortText(post.getWriterNickname(), 12))%></dd>
							<dd class="p-info">
								<span><%=post.getCreatedAt() == null ? "-" : dateFormat.format(post.getCreatedAt())%></span>
								<span class="p-view"> <img
									src="${ctx}/resources/assets/icon-open-eye-829117.png" alt="" />
									<span class="p-hits"><%=post.getViewCount()%></span>
								</span>
							</dd>
						</dl> <%
 }
 %>
					</li>
					<%
					}
					}
					%>
				</ul>
			</section>

			<section class="main-s4">
				<div class="main-caption">
					<a href="<%=ctxPath%>/board/allList.jsp">전체 게시판</a>
					<a href="<%=ctxPath%>/board/allList.jsp">
						<img src="${ctx}/resources/assets/icon-arrow-right-6423875.png" alt="" />
					</a>
				</div>
				<table class="board">
					<%
					if (postError != null) {
					%>
					<tr class="board-line">
						<td class="notice-hits">-</td>
						<td class="notice-title"><a href="<%=ctxPath%>/board/allList.jsp"><%=postError%></a></td>
						<td class="notice-hits">-</td>
					</tr>
					<%
					} else if (latestAll == null || latestAll.isEmpty()) {
					%>
					<tr class="board-line">
						<td class="notice-hits">-</td>
						<td class="notice-title"><a href="<%=ctxPath%>/board/allList.jsp">등록된 게시글이 없습니다.</a></td>
						<td class="notice-hits">0</td>
					</tr>
					<%
					} else {
					for (UnifiedBoardDTO item : latestAll) {
                            /* 순번 대신 실제 게시판 종류를 왼쪽에 표시합니다. */
                            String boardLabel;
                            if ("NOTICE".equals(item.getSourceType())) {
                                boardLabel = "공지사항";
                            } else if ("KCULTURE".equals(item.getBoardType())) {
                                boardLabel = "K-컬처";
                            } else if ("QUESTION".equals(item.getBoardType())) {
                                boardLabel = "질문게시판";
                            } else if ("FREE".equals(item.getBoardType())) {
                                boardLabel = "자유게시판";
                            } else {
                                boardLabel = "기타";
                            }

						String itemLink = "#";
						if ("NOTICE".equals(item.getSourceType())) {
							itemLink = ctxPath + "/board/noticeView.jsp?id=" + item.getId();
						} else if ("KCULTURE".equals(item.getBoardType())) {
							itemLink = ctxPath + "/board/category-view.jsp?postId=" + item.getId();
						} else if ("QUESTION".equals(item.getBoardType())) {
							itemLink = ctxPath + "/board/qnaView.jsp?id=" + item.getId();
						} else {
							itemLink = ctxPath + "/board/allView.jsp?id=" + item.getId();
						}
					%>
					<tr class="board-line">
						<td class="notice-hits" style="text-align:left; white-space:nowrap; font-size:11px;"><%=h(boardLabel)%></td>
						<td class="notice-title"><a href="<%=itemLink%>" title="<%=h(item.getTitle())%>"><%=h(shortText(item.getTitle(), 24))%></a></td>
						<td class="notice-hits"><%=item.getViewCount()%></td>
					</tr>
					<%
					}
					}
					%>
				</table>
			</section>
		</div>
	</main>

	<script src="<%=ctxPath%>/resources/js/tour-home-slider.js?v=20261105-1" defer></script>

	<%@ include file="/include/sidebar.jsp"%>
	<%@ include file="/include/footer.jsp"%>