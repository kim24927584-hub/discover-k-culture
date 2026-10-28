<%@ page
    language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>


<% request.setAttribute("pageCss", "footer.css"); %>


<%@ taglib
    prefix="c"
    uri="http://java.sun.com/jsp/jstl/core"%>
<c:set
    var="ctx"
    value="${pageContext.request.contextPath}" />

<link
    rel="stylesheet"
    href="${ctx}/resources/css/reset.css" />
<link
    rel="stylesheet"
    href="${ctx}/resources/css/common.css" />

<c:if test="${not empty pageCss}">
    <link
        rel="stylesheet"
        href="${ctx}/resources/css/${pageCss}" />
</c:if>


<!-- 푸터 -->
<footer>
    <div class="f-section">
        <div class="f-logo">
            <img
                src="${ctx}/resources/assets/logo.png"
                alt="" />
        </div>
        <div class="copy">
            <p class="copyright">&copy; 2026, All Rights Reserved</p>
            <p class="copydesc">
                <span>김민성</span><span>이우민</span><span>양영준</span><span>송연희</span>
            </p>
            <p class="copyinfo">
                <span>이용약관</span> <span>개인정보처리방침</span> <span>개인 정보 설정</span> <span>위치정보이용약관</span>
            </p>
        </div>
    </div>
</footer>
</div>
</div>

</body>
</html>