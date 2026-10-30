<%@ page
    language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<!-- css 세팅 -->
<% request.setAttribute("pageCss", "home.css"); %>
<%@ include file="/include/header.jsp"%>
<!-- 메인 -->

          <main>
            <div class="wrapper">
            <section class="main-s1">
              <table class="board board-notice">
                <caption>
                  <div class="main-caption">
                    <a href="#">Notice</a>
                    <a href="#">
                      <img src="${ctx}/resources/assets/icon-arrow-right-6423875.png" alt="" />
                    </a>
                  </div>
                </caption>
                <tr>
                  <td class="notice-symbol must-read">MUST-READ</td>
                  <td class="notice-title">
                    <a href="#">Community Guidelines</a>
                  </td>
                  <td class="notice-hits">3</td>
                </tr>
                <tr>
                  <td class="notice-symbol notice">NOTICE</td>
                  <td class="notice-title">
                    <a href="#">Welcome to K-culture !</a>
                  </td>
                  <td class="notice-hits">11</td>
                </tr>
                <tr>
                  <td class="notice-symbol must-read">MUST-READ</td>
                  <td class="notice-title">
                    <a href="#">Community Guidelines</a>
                  </td>
                  <td class="notice-hits">3</td>
                </tr>
                <tr>
                  <td class="notice-symbol must-read">MUST-READ</td>
                  <td class="notice-title">
                    <a href="#">Community Guidelines</a>
                  </td>
                  <td class="notice-hits">3</td>
                </tr>
                <tr>
                  <td class="notice-symbol must-read">MUST-READ</td>
                  <td class="notice-title">
                    <a href="#">Community Guidelines</a>
                  </td>
                  <td class="notice-hits">3</td>
                </tr>
              </table>
            </section>
            <section class="main-s2">
              <div class="festival-api"></div>
            </section></div>
            <div class="wrapper">
            <section class="main-s3">
              <ul>
                <li class="picture-posts">
                  <dl class="p-post">
                    <dt class="p-img">
                      <a href="#"><img src="${ctx}/resources/img/cat1.jpg" alt="" /></a>
                    </dt>
                    <dd class="p-title">
                      <a href="#">공양이</a>
                    </dd>
                    <dd class="p-writer">여니</dd>
                    <dd class="p-info">
                      <span>26.10.29</span>
                      <span class="p-view">
                        <img src="${ctx}/resources/assets/icon-open-eye-829117.png" alt="" />
                        <span class="p-hits">13</span>
                      </span>
                    </dd>
                  </dl>
                  <dl class="p-post">
                    <dt class="p-img">
                      <a href="#"><img src="${ctx}/resources/img/cat2.jpg" alt="" /></a>
                    </dt>
                    <dd class="p-title">
                      <a href="#">공양이</a>
                    </dd>
                    <dd class="p-writer">여니</dd>
                    <dd class="p-info">
                      <span>26.10.29</span>
                      <span class="p-view">
                        <img src="${ctx}/resources/assets/icon-open-eye-829117.png" alt="" />
                        <span class="p-hits">13</span>
                      </span>
                    </dd>
                  </dl>
                  <dl class="p-post">
                    <dt class="p-img">
                      <a href="#"><img src="${ctx}/resources/img/cat3.jpg" alt="" /></a>
                    </dt>
                    <dd class="p-title">
                      <a href="#">공양이</a>
                    </dd>
                    <dd class="p-writer">여니</dd>
                    <dd class="p-info">
                      <span>26.10.29</span>
                      <span class="p-view">
                        <img src="${ctx}/resources/assets/icon-open-eye-829117.png" alt="" />
                        <span class="p-hits">13</span>
                      </span>
                    </dd>
                  </dl>

                </li>
                <li class="picture-posts">
                  <dl class="p-post">
                    <dt class="p-img">
                      <a href="#"><img src="${ctx}/resources/img/cat1.jpg" alt="" /></a>
                    </dt>
                    <dd class="p-title">
                      <a href="#">공양이</a>
                    </dd>
                    <dd class="p-writer">여니</dd>
                    <dd class="p-info">
                      <span>26.10.29</span>
                      <span class="p-view">
                        <img src="${ctx}/resources/assets/icon-open-eye-829117.png" alt="" />
                        <span class="p-hits">13</span>
                      </span>
                    </dd>
                  </dl>
                  <dl class="p-post">
                    <dt class="p-img">
                      <a href="#"><img src="${ctx}/resources/img/cat2.jpg" alt="" /></a>
                    </dt>
                    <dd class="p-title">
                      <a href="#">공양이</a>
                    </dd>
                    <dd class="p-writer">여니</dd>
                    <dd class="p-info">
                      <span>26.10.29</span>
                      <span class="p-view">
                        <img src="${ctx}/resources/assets/icon-open-eye-829117.png" alt="" />
                        <span class="p-hits">13</span>
                      </span>
                    </dd>
                  </dl>
                  <dl class="p-post">
                    <dt class="p-img">
                      <a href="#"><img src="${ctx}/resources/img/cat3.jpg" alt="" /></a>
                    </dt>
                    <dd class="p-title">
                      <a href="#">공양이</a>
                    </dd>
                    <dd class="p-writer">여니</dd>
                    <dd class="p-info">
                      <span>26.10.29</span>
                      <span class="p-view">
                        <img src="${ctx}/resources/assets/icon-open-eye-829117.png" alt="" />
                        <span class="p-hits">13</span>
                      </span>
                    </dd>
                  </dl>
                  </dl>
                </li>
              </ul>
            </section>
            <section class="main-s4">
              <caption>
                <div class="main-caption">
                  All Posts
                  <a href="#">
                      <img src="${ctx}/resources/assets/icon-arrow-right-6423875.png" alt="" />
                    </a>
                </div>
              </caption>
              <table class="board">
                <tr class="board-line">
                  <td class="notice-hits">
                    5
                  </td>
                  <td class="notice-title"><a href="#">자려고 누웠는데 갑자기</a></td>
                  <td class="notice-hits">3</td>
                </tr>
              </table>
            </section></div>
          </main>
          
          
<%@ include file="/include/sidebar.jsp"%>

<%@ include file="/include/footer.jsp"%>