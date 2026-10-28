<%@ page
    language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ include file="/include/header.jsp"%>

<body>
 <div class="layout">
            <div class="search-bar">
                <form>
                    <input
                        type="text"
                        name="search"
                        value=""
                        placeholder="Search" />
                    <button
                        class="btn search-btn"
                        type="search">
                        <img
                            src="assets/icon-search-6328608.png"
                            alt="" />
                    </button>
                </form>
            </div>
            <div class="content-wrapper">
                <main>
                    <section class="s1">
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
                                <td class="title"><a href="#">Community Guidelines</a></td>
                                <td class="hits">3</td>
                            </tr>

                            <tr>
                                <td class="notice-symbol notice">NOTICE</td>
                                <td class="title"><a href="#">Welcome to K-culture !</a></td>
                                <td class="hits">11</td>
                            </tr>

                            <tr>
                                <td class="notice-symbol must-read">MUST-READ</td>
                                <td class="title"><a href="#">Community Guidelines</a></td>
                                <td class="hits">3</td>
                            </tr>
                        </table>
                    </section>
                </main>
                
<%@ include file = "/include/sidebar.jsp" %>
    <%@include file = "/include/footer.jsp" %>