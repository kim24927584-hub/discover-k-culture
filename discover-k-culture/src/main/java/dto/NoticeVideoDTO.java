package dto;

import java.sql.Timestamp;

public class NoticeVideoDTO {

    private long videoId;
    private long noticeId;
    private String videoName;
    private String videoPath;
    private int videoOrder;
    private Timestamp createdAt;

    public long getVideoId() {
        return videoId;
    }

    public void setVideoId(long videoId) {
        this.videoId = videoId;
    }

    public long getNoticeId() {
        return noticeId;
    }

    public void setNoticeId(long noticeId) {
        this.noticeId = noticeId;
    }

    public String getVideoName() {
        return videoName;
    }

    public void setVideoName(String videoName) {
        this.videoName = videoName;
    }

    public String getVideoPath() {
        return videoPath;
    }

    public void setVideoPath(String videoPath) {
        this.videoPath = videoPath;
    }

    public int getVideoOrder() {
        return videoOrder;
    }

    public void setVideoOrder(int videoOrder) {
        this.videoOrder = videoOrder;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
