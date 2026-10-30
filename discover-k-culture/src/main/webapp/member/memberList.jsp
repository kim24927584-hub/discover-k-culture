<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<%
request.setAttribute("pageCss", "memberList.css");
%>

<%@ include file="/include/header.jsp"%>

<main class="member-admin">

	<div class="member-admin-heading">
		<div>
			<h1>회원 관리</h1>
			<p>회원 상태, 정지 정보, 권한을 확인하고 관리할 수 있습니다.</p>
		</div>

		<div class="member-admin-links">
			<a href="${ctx}/admin/noticeList.jsp">공지 관리</a> <a
				href="${ctx}/admin/inquiryList.jsp">문의 관리</a>
		</div>
	</div>

	<!-- 검색 및 회원 수 -->
	<div class="member-toolbar">

		<div class="member-search">
			<input type="text" aria-label="회원 검색"
				placeholder="로그인 ID, 닉네임, 이메일 검색">

			<button type="button" class="member-btn member-btn-primary">
				검색</button>

			<button type="button" class="member-btn member-btn-reset">
				초기화</button>
		</div>

		<div class="member-count">
			<span>전체 회원</span> <strong>3명</strong>
		</div>

		<div class="member-page-size">
			<label for="memberPageSize">페이지당</label> <select id="memberPageSize">
				<option value="10">10명</option>
				<option value="20">20명</option>
				<option value="30">30명</option>
			</select>
		</div>

	</div>

	<!-- 회원 목록 -->
	<div class="member-table-container">
		<table class="member-table">
			<thead>
				<tr>
					<th scope="col">ID</th>
					<th scope="col">프로필</th>
					<th scope="col">회원</th>
					<th scope="col">국가</th>
					<th scope="col">권한</th>
					<th scope="col">상태</th>
					<th scope="col">정지 정보</th>
					<th scope="col">관리</th>
				</tr>
			</thead>

			<tbody>
				<!-- 관리자 예시 -->
				<tr>
					<td class="member-number">#1</td>

					<td><span class="member-avatar">👤</span></td>

					<td class="member-name-cell"><span class="member-login">admin</span>
						<span class="member-nickname">관리자</span></td>

					<td>대한민국</td>

					<td><span class="member-badge member-role-admin"> ADMIN
					</span></td>

					<td><span class="member-badge member-status-active"> 활동
					</span></td>

					<td>
						<div class="member-suspension">
							<span class="member-date">-</span> <span class="member-reason">
								정지 사유 없음 </span>
						</div>
					</td>

					<td><span class="member-protected"> 관리자 계정 보호 </span></td>
				</tr>

				<!-- 일반 회원 예시 -->
				<tr>
					<td class="member-number">#2</td>

					<td><span class="member-avatar">👤</span></td>

					<td class="member-name-cell"><span class="member-login">user01</span>
						<span class="member-nickname">일반회원</span></td>

					<td>대한민국</td>

					<td><span class="member-badge member-role-user"> USER </span>
					</td>

					<td><span class="member-badge member-status-active"> 활동
					</span></td>

					<td>
						<div class="member-suspension">
							<span class="member-date">-</span> <span class="member-reason">
								정지 사유 없음 </span>
						</div>
					</td>

					<td>
						<div class="member-actions">
							<select aria-label="일반회원 상태">
								<option value="ACTIVE" selected>활동</option>
								<option value="SUSPENDED">정지</option>
							</select>

							<button type="button" class="member-btn member-btn-primary">
								변경</button>

							<button type="button" class="member-btn member-btn-delete">
								회원 삭제</button>
						</div>
					</td>
				</tr>

				<!-- 정지 회원 예시 -->
				<tr>
					<td class="member-number">#3</td>

					<td><span class="member-avatar">👤</span></td>

					<td class="member-name-cell"><span class="member-login">user02</span>
						<span class="member-nickname">정지회원</span></td>

					<td>일본</td>

					<td><span class="member-badge member-role-user"> USER </span>
					</td>

					<td><span class="member-badge member-status-suspended">
							정지 </span></td>

					<td>
						<div class="member-suspension">
							<span class="member-date">2026-12-31</span> <span
								class="member-reason" title="게시판 이용 규칙 위반"> 게시판 이용 규칙 위반
							</span>
						</div>
					</td>

					<td>
						<div class="member-actions">
							<select aria-label="정지회원 상태">
								<option value="ACTIVE">활동</option>
								<option value="SUSPENDED" selected>정지</option>
							</select> <input type="date" aria-label="정지 종료일" value="2026-12-31">

							<input type="text" class="member-reason-input" aria-label="정지 사유"
								placeholder="정지 사유 입력" value="게시판 이용 규칙 위반">

							<button type="button" class="member-btn member-btn-primary">
								변경</button>

							<button type="button" class="member-btn member-btn-delete">
								회원 삭제</button>
						</div>
					</td>
				</tr>
				<!-- 일반 회원 -->
				<tr>
					<td class="member-number">#4</td>
					<td><span class="member-avatar">👤</span></td>

					<td class="member-name-cell"><span class="member-login">minseong04</span>
						<span class="member-nickname">한국문화좋아</span></td>

					<td>대한민국</td>
					<td><span class="member-badge member-role-user">USER</span></td>
					<td><span class="member-badge member-status-active">활동</span></td>

					<td>
						<div class="member-suspension">
							<span class="member-date">-</span> <span class="member-reason">정지
								사유 없음</span>
						</div>
					</td>

					<td>
						<div class="member-actions">
							<select aria-label="한국문화좋아 상태">
								<option value="ACTIVE" selected>활동</option>
								<option value="SUSPENDED">정지</option>
							</select>
							<button type="button" class="member-btn member-btn-primary">변경</button>
							<button type="button" class="member-btn member-btn-delete">회원
								삭제</button>
						</div>
					</td>
				</tr>

				<!-- 일반 회원 -->
				<tr>
					<td class="member-number">#5</td>
					<td><span class="member-avatar">👤</span></td>

					<td class="member-name-cell"><span class="member-login">sakura05</span>
						<span class="member-nickname">사쿠라</span></td>

					<td>일본</td>
					<td><span class="member-badge member-role-user">USER</span></td>
					<td><span class="member-badge member-status-active">활동</span></td>

					<td>
						<div class="member-suspension">
							<span class="member-date">-</span> <span class="member-reason">정지
								사유 없음</span>
						</div>
					</td>

					<td>
						<div class="member-actions">
							<select aria-label="사쿠라 상태">
								<option value="ACTIVE" selected>활동</option>
								<option value="SUSPENDED">정지</option>
							</select>
							<button type="button" class="member-btn member-btn-primary">변경</button>
							<button type="button" class="member-btn member-btn-delete">회원
								삭제</button>
						</div>
					</td>
				</tr>

				<!-- 정지 회원 -->
				<tr>
					<td class="member-number">#6</td>
					<td><span class="member-avatar">👤</span></td>

					<td class="member-name-cell"><span class="member-login">alex06</span>
						<span class="member-nickname">Alex</span></td>

					<td>미국</td>
					<td><span class="member-badge member-role-user">USER</span></td>
					<td><span class="member-badge member-status-suspended">정지</span></td>

					<td>
						<div class="member-suspension">
							<span class="member-date">2026-12-15</span> <span
								class="member-reason" title="광고성 게시글 반복 등록"> 광고성 게시글 반복
								등록 </span>
						</div>
					</td>

					<td>
						<div class="member-actions">
							<select aria-label="Alex 상태">
								<option value="ACTIVE">활동</option>
								<option value="SUSPENDED" selected>정지</option>
							</select> <input type="date" aria-label="Alex 정지 종료일" value="2026-12-15">

							<input type="text" class="member-reason-input"
								aria-label="Alex 정지 사유" value="광고성 게시글 반복 등록">

							<button type="button" class="member-btn member-btn-primary">변경</button>
							<button type="button" class="member-btn member-btn-delete">회원
								삭제</button>
						</div>
					</td>
				</tr>

				<!-- 일반 회원 -->
				<tr>
					<td class="member-number">#7</td>
					<td><span class="member-avatar">👤</span></td>

					<td class="member-name-cell"><span class="member-login">emma07</span>
						<span class="member-nickname">서울여행중</span></td>

					<td>영국</td>
					<td><span class="member-badge member-role-user">USER</span></td>
					<td><span class="member-badge member-status-active">활동</span></td>

					<td>
						<div class="member-suspension">
							<span class="member-date">-</span> <span class="member-reason">정지
								사유 없음</span>
						</div>
					</td>

					<td>
						<div class="member-actions">
							<select aria-label="서울여행중 상태">
								<option value="ACTIVE" selected>활동</option>
								<option value="SUSPENDED">정지</option>
							</select>
							<button type="button" class="member-btn member-btn-primary">변경</button>
							<button type="button" class="member-btn member-btn-delete">회원
								삭제</button>
						</div>
					</td>
				</tr>

				<!-- 일반 회원 -->
				<tr>
					<td class="member-number">#8</td>
					<td><span class="member-avatar">👤</span></td>

					<td class="member-name-cell"><span class="member-login">lin08</span>
						<span class="member-nickname">한식탐험가</span></td>

					<td>대만</td>
					<td><span class="member-badge member-role-user">USER</span></td>
					<td><span class="member-badge member-status-active">활동</span></td>

					<td>
						<div class="member-suspension">
							<span class="member-date">-</span> <span class="member-reason">정지
								사유 없음</span>
						</div>
					</td>

					<td>
						<div class="member-actions">
							<select aria-label="한식탐험가 상태">
								<option value="ACTIVE" selected>활동</option>
								<option value="SUSPENDED">정지</option>
							</select>
							<button type="button" class="member-btn member-btn-primary">변경</button>
							<button type="button" class="member-btn member-btn-delete">회원
								삭제</button>
						</div>
					</td>
				</tr>
				<tr>
					<td class="member-number">#9</td>
					<td><span class="member-avatar">👤</span></td>
					<td class="member-name-cell"><span class="member-login">jiyoon09</span>
						<span class="member-nickname">한강산책</span></td>
					<td>대한민국</td>
					<td><span class="member-badge member-role-user">USER</span></td>
					<td><span class="member-badge member-status-active">활동</span></td>
					<td>
						<div class="member-suspension">
							<span class="member-date">-</span> <span class="member-reason">정지
								사유 없음</span>
						</div>
					</td>
					<td>
						<div class="member-actions">
							<select aria-label="한강산책 상태">
								<option value="ACTIVE" selected>활동</option>
								<option value="SUSPENDED">정지</option>
							</select>
							<button type="button" class="member-btn member-btn-primary">변경</button>
							<button type="button" class="member-btn member-btn-delete">회원
								삭제</button>
						</div>
					</td>
				</tr>

				<tr>
					<td class="member-number">#10</td>
					<td><span class="member-avatar">👤</span></td>
					<td class="member-name-cell"><span class="member-login">yuki10</span>
						<span class="member-nickname">유키</span></td>
					<td>일본</td>
					<td><span class="member-badge member-role-user">USER</span></td>
					<td><span class="member-badge member-status-active">활동</span></td>
					<td>
						<div class="member-suspension">
							<span class="member-date">-</span> <span class="member-reason">정지
								사유 없음</span>
						</div>
					</td>
					<td>
						<div class="member-actions">
							<select aria-label="유키 상태">
								<option value="ACTIVE" selected>활동</option>
								<option value="SUSPENDED">정지</option>
							</select>
							<button type="button" class="member-btn member-btn-primary">변경</button>
							<button type="button" class="member-btn member-btn-delete">회원
								삭제</button>
						</div>
					</td>
				</tr>

				<tr>
					<td class="member-number">#11</td>
					<td><span class="member-avatar">👤</span></td>
					<td class="member-name-cell"><span class="member-login">daniel11</span>
						<span class="member-nickname">김치러버</span></td>
					<td>캐나다</td>
					<td><span class="member-badge member-role-user">USER</span></td>
					<td><span class="member-badge member-status-active">활동</span></td>
					<td>
						<div class="member-suspension">
							<span class="member-date">-</span> <span class="member-reason">정지
								사유 없음</span>
						</div>
					</td>
					<td>
						<div class="member-actions">
							<select aria-label="김치러버 상태">
								<option value="ACTIVE" selected>활동</option>
								<option value="SUSPENDED">정지</option>
							</select>
							<button type="button" class="member-btn member-btn-primary">변경</button>
							<button type="button" class="member-btn member-btn-delete">회원
								삭제</button>
						</div>
					</td>
				</tr>

				<tr>
					<td class="member-number">#12</td>
					<td><span class="member-avatar">👤</span></td>
					<td class="member-name-cell"><span class="member-login">mei12</span>
						<span class="member-nickname">드라마정주행</span></td>
					<td>중국</td>
					<td><span class="member-badge member-role-user">USER</span></td>
					<td><span class="member-badge member-status-suspended">정지</span></td>
					<td>
						<div class="member-suspension">
							<span class="member-date">2026-11-30</span> <span
								class="member-reason" title="동일 게시글 반복 등록"> 동일 게시글 반복 등록
							</span>
						</div>
					</td>
					<td>
						<div class="member-actions">
							<select aria-label="드라마정주행 상태">
								<option value="ACTIVE">활동</option>
								<option value="SUSPENDED" selected>정지</option>
							</select> <input type="date" aria-label="드라마정주행 정지 종료일" value="2026-11-30">
							<input type="text" class="member-reason-input"
								aria-label="드라마정주행 정지 사유" value="동일 게시글 반복 등록">
							<button type="button" class="member-btn member-btn-primary">변경</button>
							<button type="button" class="member-btn member-btn-delete">회원
								삭제</button>
						</div>
					</td>
				</tr>

				<tr>
					<td class="member-number">#13</td>
					<td><span class="member-avatar">👤</span></td>
					<td class="member-name-cell"><span class="member-login">sophie13</span>
						<span class="member-nickname">부산바다</span></td>
					<td>프랑스</td>
					<td><span class="member-badge member-role-user">USER</span></td>
					<td><span class="member-badge member-status-active">활동</span></td>
					<td>
						<div class="member-suspension">
							<span class="member-date">-</span> <span class="member-reason">정지
								사유 없음</span>
						</div>
					</td>
					<td>
						<div class="member-actions">
							<select aria-label="부산바다 상태">
								<option value="ACTIVE" selected>활동</option>
								<option value="SUSPENDED">정지</option>
							</select>
							<button type="button" class="member-btn member-btn-primary">변경</button>
							<button type="button" class="member-btn member-btn-delete">회원
								삭제</button>
						</div>
					</td>
				</tr>

				<tr>
					<td class="member-number">#14</td>
					<td><span class="member-avatar">👤</span></td>
					<td class="member-name-cell"><span class="member-login">lucas14</span>
						<span class="member-nickname">케이팝팬</span></td>
					<td>독일</td>
					<td><span class="member-badge member-role-user">USER</span></td>
					<td><span class="member-badge member-status-active">활동</span></td>
					<td>
						<div class="member-suspension">
							<span class="member-date">-</span> <span class="member-reason">정지
								사유 없음</span>
						</div>
					</td>
					<td>
						<div class="member-actions">
							<select aria-label="케이팝팬 상태">
								<option value="ACTIVE" selected>활동</option>
								<option value="SUSPENDED">정지</option>
							</select>
							<button type="button" class="member-btn member-btn-primary">변경</button>
							<button type="button" class="member-btn member-btn-delete">회원
								삭제</button>
						</div>
					</td>
				</tr>

				<tr>
					<td class="member-number">#15</td>
					<td><span class="member-avatar">👤</span></td>
					<td class="member-name-cell"><span class="member-login">nana15</span>
						<span class="member-nickname">떡볶이최고</span></td>
					<td>태국</td>
					<td><span class="member-badge member-role-user">USER</span></td>
					<td><span class="member-badge member-status-active">활동</span></td>
					<td>
						<div class="member-suspension">
							<span class="member-date">-</span> <span class="member-reason">정지
								사유 없음</span>
						</div>
					</td>
					<td>
						<div class="member-actions">
							<select aria-label="떡볶이최고 상태">
								<option value="ACTIVE" selected>활동</option>
								<option value="SUSPENDED">정지</option>
							</select>
							<button type="button" class="member-btn member-btn-primary">변경</button>
							<button type="button" class="member-btn member-btn-delete">회원
								삭제</button>
						</div>
					</td>
				</tr>

				<tr>
					<td class="member-number">#16</td>
					<td><span class="member-avatar">👤</span></td>
					<td class="member-name-cell"><span class="member-login">oliver16</span>
						<span class="member-nickname">여행하는올리버</span></td>
					<td>호주</td>
					<td><span class="member-badge member-role-user">USER</span></td>
					<td><span class="member-badge member-status-suspended">정지</span></td>
					<td>
						<div class="member-suspension">
							<span class="member-date">2026-12-10</span> <span
								class="member-reason" title="부적절한 댓글 작성"> 부적절한 댓글 작성 </span>
						</div>
					</td>
					<td>
						<div class="member-actions">
							<select aria-label="여행하는올리버 상태">
								<option value="ACTIVE">활동</option>
								<option value="SUSPENDED" selected>정지</option>
							</select> <input type="date" aria-label="여행하는올리버 정지 종료일"
								value="2026-12-10"> <input type="text"
								class="member-reason-input" aria-label="여행하는올리버 정지 사유"
								value="부적절한 댓글 작성">
							<button type="button" class="member-btn member-btn-primary">변경</button>
							<button type="button" class="member-btn member-btn-delete">회원
								삭제</button>
						</div>
					</td>
				</tr>

				<tr>
					<td class="member-number">#17</td>
					<td><span class="member-avatar">👤</span></td>
					<td class="member-name-cell"><span class="member-login">hana17</span>
						<span class="member-nickname">제주살이</span></td>
					<td>대한민국</td>
					<td><span class="member-badge member-role-user">USER</span></td>
					<td><span class="member-badge member-status-active">활동</span></td>
					<td>
						<div class="member-suspension">
							<span class="member-date">-</span> <span class="member-reason">정지
								사유 없음</span>
						</div>
					</td>
					<td>
						<div class="member-actions">
							<select aria-label="제주살이 상태">
								<option value="ACTIVE" selected>활동</option>
								<option value="SUSPENDED">정지</option>
							</select>
							<button type="button" class="member-btn member-btn-primary">변경</button>
							<button type="button" class="member-btn member-btn-delete">회원
								삭제</button>
						</div>
					</td>
				</tr>

				<tr>
					<td class="member-number">#18</td>
					<td><span class="member-avatar">👤</span></td>
					<td class="member-name-cell"><span class="member-login">sofia18</span>
						<span class="member-nickname">한복체험</span></td>
					<td>스페인</td>
					<td><span class="member-badge member-role-user">USER</span></td>
					<td><span class="member-badge member-status-active">활동</span></td>
					<td>
						<div class="member-suspension">
							<span class="member-date">-</span> <span class="member-reason">정지
								사유 없음</span>
						</div>
					</td>
					<td>
						<div class="member-actions">
							<select aria-label="한복체험 상태">
								<option value="ACTIVE" selected>활동</option>
								<option value="SUSPENDED">정지</option>
							</select>
							<button type="button" class="member-btn member-btn-primary">변경</button>
							<button type="button" class="member-btn member-btn-delete">회원
								삭제</button>
						</div>
					</td>
				</tr>
			</tbody>
		</table>
	</div>

	<!-- 페이지 번호 -->
	<div class="member-pagination" aria-label="회원 목록 페이지">
		<span class="is-disabled">«</span> <span class="is-disabled">‹
			이전</span> <span class="is-current" aria-current="page">1</span> <span
			class="is-disabled">다음 ›</span> <span class="is-disabled">»</span>
	</div>

	<p class="member-page-summary">1 / 1 페이지 · 전체 3명</p>

</main>

<%@ include file="/include/footer.jsp"%>