<!-- css 세팅 -->
<% request.setAttribute("pageCss", "home.css"); %>
<%@ include file="/include/header.jsp"%>


<div class="layout">
    <div class="search-bar">
        <form>
            <input
                type="text"
                name="search"
                value=""
                placeholder="Search" />
            <button
                class="search-btn"
                type="search">
                <img
                    src="assets/icon-search-6328608.png"
                    alt="" />
            </button>
        </form>
    </div>
    <div class="content-wrapper">
        <main>
            <section class="main-s1">
                <table class="board-notice">
                    <caption>
                        <div class="notice-caption">
                            <strong>Notice</strong> <a href="#"> <img
                                src="assets/icon-arrow-right-6423875.png"
                                alt="" />
                            </a>
                        </div>
                    </caption>
                    <tr>
                        <td class="notice-symbol must-read">MUST-READ</td>
                        <td class="notice-title"><a href="#">Community Guidelines</a></td>
                        <td class="notice-hits">3</td>
                    </tr>

                    <tr>
                        <td class="notice-symbol notice">NOTICE</td>
                        <td class="notice-title"><a href="#">Welcome to K-culture !</a></td>
                        <td class="notice-hits">11</td>
                    </tr>

                    <tr>
                        <td class="notice-symbol must-read">MUST-READ</td>
                        <td class="notice-title"><a href="#">Community Guidelines</a></td>
                        <td class="notice-hits">3</td>
                    </tr>
                </table>
                <div class="festival-api"></div>
            </section>
            <section class="main-s2">
                <div class="picture-posts">
                    <div class="p-post">
                        <a href="#"><img
                            src="imgs/cat1.jpg"
                            alt="" /></a> <a href="#"><p class="picture-title">공양이</p></a>
                        <p class="picture-writer">여니</p>
                        <p class="picture-hits">
                            <img
                                src=""
                                alt="" />13
                        </p>
                    </div>
                </div>
            </section>
            <section class="main-s3">
                <div class="view-allposts"></div>
            </section>
        </main>

        <%@ include file="/include/sidebar.jsp"%>
        <%@include file="/include/footer.jsp"%>