<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="dao.PostDAO" %>
<%@ page import="dao.UnifiedBoardDAO" %>
<%@ page import="dto.PostDTO" %>
<%@ page import="dto.UnifiedBoardDTO" %>

<%!
/* 사이드바는 모든 페이지에 포함되므로 게시글 제목을 HTML 이스케이프합니다. */
private String sbH(String value) {
    if (value == null) return "";
    return value.replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace("\"", "&quot;")
        .replace("'", "&#39;");
}
%>

<%
List<UnifiedBoardDTO> sbAllPopular = new ArrayList<UnifiedBoardDTO>();
List<UnifiedBoardDTO> sbAllViewed = new ArrayList<UnifiedBoardDTO>();
List<PostDTO> sbKPopular = new ArrayList<PostDTO>();
List<PostDTO> sbQuestionPopular = new ArrayList<PostDTO>();
List<PostDTO> sbKViewed = new ArrayList<PostDTO>();
List<PostDTO> sbQuestionViewed = new ArrayList<PostDTO>();

try {
    UnifiedBoardDAO sbUnifiedDAO = new UnifiedBoardDAO();
    PostDAO sbPostDAO = new PostDAO();

    sbAllPopular = sbUnifiedDAO.selectRecommended(5);
    sbAllViewed = sbUnifiedDAO.selectTopViewedPosts(5);
    sbKPopular = sbPostDAO.searchBoardPaged("KCULTURE", null, "", "likes", 1, 10);
    sbQuestionPopular = sbPostDAO.searchBoardPaged("QUESTION", null, "", "likes", 1, 10);
    sbKViewed = sbPostDAO.searchBoardPaged("KCULTURE", null, "", "views", 1, 10);
    sbQuestionViewed = sbPostDAO.searchBoardPaged("QUESTION", null, "", "views", 1, 10);
} catch (Exception sbError) {
    application.log("sidebar.jsp 게시글 조회 오류", sbError);
}
%>
 
<div class="sidebar">
  <div class="sidebar-s1">
    <p class="side-title">가장 많이 좋아한 게시글</p>
    <ul class="sidebar-tabs">
      <li class="tab-btn active-tab-btn" data-tab="side-s1-all">전체 게시글</li>
      <li class="tab-btn" data-tab="side-s1-kculture">K-컬처</li>
      <li class="tab-btn" data-tab="side-s1-question">질문</li>
    </ul>

    <div class="sidebar-contents">
      <table>
        <tbody class="tab-contents active-tab-contents" id="side-s1-all">
<%
if (sbAllPopular.isEmpty()) {
%>
          <tr class="tab-content"><td class="content-title">게시글이 없습니다.</td></tr>
<%
} else {
    int sbRank = 1;
    for (UnifiedBoardDTO sbItem : sbAllPopular) {
        String sbHref;
        if ("KCULTURE".equals(sbItem.getBoardType())) {
            sbHref = request.getContextPath() + "/board/category-view.jsp?postId=" + sbItem.getId();
        } else if ("QUESTION".equals(sbItem.getBoardType())) {
            sbHref = request.getContextPath() + "/board/qnaView.jsp?id=" + sbItem.getId();
        } else {
            sbHref = request.getContextPath() + "/board/allView.jsp?id=" + sbItem.getId();
        }
%>
          <tr class="tab-content">
            <td class="content-rank"><%=sbRank++%></td>
            <td class="content-title"><a href="<%=sbHref%>"><%=sbH(sbItem.getTitle())%></a></td>
            <td class="content-like"><img src="${ctx}/resources/assets/icons-like-96.png" alt="" /><%=sbItem.getLikeCount()%></td>
          </tr>
<%
    }
}
%>
        </tbody>

        <tbody class="tab-contents" id="side-s1-kculture">
<%
if (sbKPopular.isEmpty()) {
%>
          <tr class="tab-content"><td class="content-title">게시글이 없습니다.</td></tr>
<%
} else {
    int sbRank = 1;
    int sbLimit = Math.min(5, sbKPopular.size());
    for (int sbI = 0; sbI < sbLimit; sbI++) {
        PostDTO sbItem = sbKPopular.get(sbI);
%>
          <tr class="tab-content">
            <td class="content-rank"><%=sbRank++%></td>
            <td class="content-title"><a href="<%=request.getContextPath()%>/board/category-view.jsp?postId=<%=sbItem.getPostId()%>"><%=sbH(sbItem.getTitle())%></a></td>
            <td class="content-like"><img src="${ctx}/resources/assets/icons-like-96.png" alt="" /><%=sbItem.getLikeCount()%></td>
          </tr>
<%
    }
}
%>
        </tbody>

        <tbody class="tab-contents" id="side-s1-question">
<%
if (sbQuestionPopular.isEmpty()) {
%>
          <tr class="tab-content"><td class="content-title">게시글이 없습니다.</td></tr>
<%
} else {
    int sbRank = 1;
    int sbLimit = Math.min(5, sbQuestionPopular.size());
    for (int sbI = 0; sbI < sbLimit; sbI++) {
        PostDTO sbItem = sbQuestionPopular.get(sbI);
%>
          <tr class="tab-content">
            <td class="content-rank"><%=sbRank++%></td>
            <td class="content-title"><a href="<%=request.getContextPath()%>/board/qnaView.jsp?id=<%=sbItem.getPostId()%>"><%=sbH(sbItem.getTitle())%></a></td>
            <td class="content-like"><img src="${ctx}/resources/assets/icons-like-96.png" alt="" /><%=sbItem.getLikeCount()%></td>
          </tr>
<%
    }
}
%>
        </tbody>
      </table>
    </div>
  </div>

  <div class="sidebar-s2">
  <p class="side-title">가장 많이 본 게시글</p>
    <ul class="sidebar-tabs">
      <li class="tab-btn active-tab-btn" data-tab="side-s2-all">전체 게시글</li>
      <li class="tab-btn" data-tab="side-s2-kculture">K-컬처</li>
      <li class="tab-btn" data-tab="side-s2-question">질문</li>
    </ul>

    <div class="sidebar-contents">
      <table>
        <tbody class="tab-contents active-tab-contents" id="side-s2-all">
<%
if (sbAllViewed.isEmpty()) {
%>
          <tr class="tab-content"><td class="content-title">게시글이 없습니다.</td></tr>
<%
} else {
    int sbRank = 1;
    for (UnifiedBoardDTO sbItem : sbAllViewed) {
        String sbHref;
        if ("KCULTURE".equals(sbItem.getBoardType())) {
            sbHref = request.getContextPath() + "/board/category-view.jsp?postId=" + sbItem.getId();
        } else if ("QUESTION".equals(sbItem.getBoardType())) {
            sbHref = request.getContextPath() + "/board/qnaView.jsp?id=" + sbItem.getId();
        } else {
            sbHref = request.getContextPath() + "/board/allView.jsp?id=" + sbItem.getId();
        }
%>
          <tr class="tab-content">
            <td class="content-rank"><%=sbRank++%></td>
            <td class="content-title"><a href="<%=sbHref%>"><%=sbH(sbItem.getTitle())%></a></td>
            <td class="content-like"><img src="${ctx}/resources/assets/icon-open-eye-829117.png" alt="" /><%=sbItem.getViewCount()%></td>
          </tr>
<%
    }
}
%>
        </tbody>

        <tbody class="tab-contents" id="side-s2-kculture">
<%
if (sbKViewed.isEmpty()) {
%>
          <tr class="tab-content"><td class="content-title">게시글이 없습니다.</td></tr>
<%
} else {
    int sbRank = 1;
    int sbLimit = Math.min(5, sbKViewed.size());
    for (int sbI = 0; sbI < sbLimit; sbI++) {
        PostDTO sbItem = sbKViewed.get(sbI);
%>
          <tr class="tab-content">
            <td class="content-rank"><%=sbRank++%></td>
            <td class="content-title"><a href="<%=request.getContextPath()%>/board/category-view.jsp?postId=<%=sbItem.getPostId()%>"><%=sbH(sbItem.getTitle())%></a></td>
            <td class="content-like"><img src="${ctx}/resources/assets/icon-open-eye-829117.png" alt="" /><%=sbItem.getViewCount()%></td>
          </tr>
<%
    }
}
%>
        </tbody>

        <tbody class="tab-contents" id="side-s2-question">
<%
if (sbQuestionViewed.isEmpty()) {
%>
          <tr class="tab-content"><td class="content-title">게시글이 없습니다.</td></tr>
<%
} else {
    int sbRank = 1;
    int sbLimit = Math.min(5, sbQuestionViewed.size());
    for (int sbI = 0; sbI < sbLimit; sbI++) {
        PostDTO sbItem = sbQuestionViewed.get(sbI);
%>
          <tr class="tab-content">
            <td class="content-rank"><%=sbRank++%></td>
            <td class="content-title"><a href="<%=request.getContextPath()%>/board/qnaView.jsp?id=<%=sbItem.getPostId()%>"><%=sbH(sbItem.getTitle())%></a></td>
            <td class="content-like"><img src="${ctx}/resources/assets/icon-open-eye-829117.png" alt="" /><%=sbItem.getViewCount()%></td>
          </tr>
<%
    }
}
%>
        </tbody>
      </table>
    </div>
  </div>
</div>

<script>
(function () {
  document.querySelectorAll('.sidebar-s1, .sidebar-s2').forEach(function (section) {
    var tabs = section.querySelectorAll('.tab-btn');
    var contents = section.querySelectorAll('.tab-contents');

    tabs.forEach(function (tab) {
      tab.addEventListener('click', function () {
        tabs.forEach(function (item) {
          item.classList.remove('active-tab-btn');
        });
        contents.forEach(function (item) {
          item.classList.remove('active-tab-contents');
        });

        tab.classList.add('active-tab-btn');
        var target = document.getElementById(tab.getAttribute('data-tab'));
        if (target) target.classList.add('active-tab-contents');
      });
    });
  });
})();
</script>

