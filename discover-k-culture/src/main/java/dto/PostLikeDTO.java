package dto;

import java.sql.Timestamp;

public class PostLikeDTO {
    private long likeId;
    private long memberId;
    private long postId;
    private Timestamp createdAt;

    public long getLikeId() { return likeId; }
    public void setLikeId(long likeId) { this.likeId = likeId; }
    public long getMemberId() { return memberId; }
    public void setMemberId(long memberId) { this.memberId = memberId; }
    public long getPostId() { return postId; }
    public void setPostId(long postId) { this.postId = postId; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
