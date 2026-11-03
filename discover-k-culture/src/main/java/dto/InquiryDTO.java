package dto;

import java.sql.Timestamp;

public class InquiryDTO {

	private long inquiryId;
	private long memberId;

	/*
	 * 문의가 아직 답변되지 않은 경우 inquiry.answered_by는 NULL일 수 있으므로 primitive long이 아니라 Long을
	 * 사용합니다.
	 */
	private Long answeredBy;

	private String title;
	private String content;
	private String status;
	private String answer;
	private String memberNickname;
	private String adminNickname;

	private Timestamp createdAt;
	private Timestamp answeredAt;

	public long getInquiryId() {
		return inquiryId;
	}

	public void setInquiryId(long inquiryId) {
		this.inquiryId = inquiryId;
	}

	public long getMemberId() {
		return memberId;
	}

	public void setMemberId(long memberId) {
		this.memberId = memberId;
	}

	public Long getAnsweredBy() {
		return answeredBy;
	}

	public void setAnsweredBy(Long answeredBy) {
		this.answeredBy = answeredBy;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public String getContent() {
		return content;
	}

	public void setContent(String content) {
		this.content = content;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public String getAnswer() {
		return answer;
	}

	public void setAnswer(String answer) {
		this.answer = answer;
	}

	public String getMemberNickname() {
		return memberNickname;
	}

	public void setMemberNickname(String memberNickname) {
		this.memberNickname = memberNickname;
	}

	public String getAdminNickname() {
		return adminNickname;
	}

	public void setAdminNickname(String adminNickname) {
		this.adminNickname = adminNickname;
	}

	public Timestamp getCreatedAt() {
		return createdAt;
	}

	public void setCreatedAt(Timestamp createdAt) {
		this.createdAt = createdAt;
	}

	public Timestamp getAnsweredAt() {
		return answeredAt;
	}

	public void setAnsweredAt(Timestamp answeredAt) {
		this.answeredAt = answeredAt;
	}
}
