package dto;

import java.sql.Timestamp;

public class PostVideoDTO {
    private long videoId;
    private long postId;
    private String videoName;
    private String videoPath;
    private String thumbnailPath;
    private int videoOrder;
    private Timestamp createdAt;

    public long getVideoId() { return videoId; }
    public void setVideoId(long videoId) { this.videoId = videoId; }
    public long getPostId() { return postId; }
    public void setPostId(long postId) { this.postId = postId; }
    public String getVideoName() { return videoName; }
    public void setVideoName(String videoName) { this.videoName = videoName; }
    public String getVideoPath() { return videoPath; }
    public void setVideoPath(String videoPath) { this.videoPath = videoPath; }
    public String getThumbnailPath() { return thumbnailPath; }
    public void setThumbnailPath(String thumbnailPath) { this.thumbnailPath = thumbnailPath; }
    public int getVideoOrder() { return videoOrder; }
    public void setVideoOrder(int videoOrder) { this.videoOrder = videoOrder; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
