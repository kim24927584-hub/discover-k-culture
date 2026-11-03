package dto;

import java.sql.Timestamp;

public class CommentLikeDTO {
    private long commentLikeId;
    private long memberId;
    private long commentId;
    private Timestamp createdAt;

    public long getCommentLikeId() { return commentLikeId; }
    public void setCommentLikeId(long commentLikeId) { this.commentLikeId = commentLikeId; }
    public long getMemberId() { return memberId; }
    public void setMemberId(long memberId) { this.memberId = memberId; }
    public long getCommentId() { return commentId; }
    public void setCommentId(long commentId) { this.commentId = commentId; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
