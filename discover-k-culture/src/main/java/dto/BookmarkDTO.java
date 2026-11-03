package dto;

import java.sql.Timestamp;

public class BookmarkDTO {
    private long bookmarkId;
    private long memberId;
    private long postId;
    private Timestamp createdAt;

    public long getBookmarkId() { return bookmarkId; }
    public void setBookmarkId(long bookmarkId) { this.bookmarkId = bookmarkId; }
    public long getMemberId() { return memberId; }
    public void setMemberId(long memberId) { this.memberId = memberId; }
    public long getPostId() { return postId; }
    public void setPostId(long postId) { this.postId = postId; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
