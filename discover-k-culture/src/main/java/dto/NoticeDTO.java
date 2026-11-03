package dto;

import java.sql.Timestamp;

public class NoticeDTO {
    private long noticeId;
    private long memberId;
    private String title;
    private String content;
    private int viewCount;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private String writerNickname;

    public long getNoticeId() { return noticeId; }
    public void setNoticeId(long noticeId) { this.noticeId = noticeId; }
    public long getMemberId() { return memberId; }
    public void setMemberId(long memberId) { this.memberId = memberId; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public int getViewCount() { return viewCount; }
    public void setViewCount(int viewCount) { this.viewCount = viewCount; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
    public String getWriterNickname() { return writerNickname; }
    public void setWriterNickname(String writerNickname) { this.writerNickname = writerNickname; }
}
