package dto;

import java.sql.Timestamp;

public class UnifiedBoardDTO {

    private long id;
    private String sourceType;
    private String boardType;
    private String title;
    private String writerNickname;
    private int viewCount;
    private int likeCount;
    private int dislikeCount;
    private Timestamp createdAt;
    private String imagePath;
    private String videoPath;
    private String videoThumbnailPath;


    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public String getSourceType() {
        return sourceType;
    }

    public void setSourceType(String sourceType) {
        this.sourceType = sourceType;
    }

    public String getBoardType() {
        return boardType;
    }

    public void setBoardType(String boardType) {
        this.boardType = boardType;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getWriterNickname() {
        return writerNickname;
    }

    public void setWriterNickname(String writerNickname) {
        this.writerNickname = writerNickname;
    }

    public int getViewCount() {
        return viewCount;
    }

    public void setViewCount(int viewCount) {
        this.viewCount = viewCount;
    }

    public int getLikeCount() {
        return likeCount;
    }

    public void setLikeCount(int likeCount) {
        this.likeCount = likeCount;
    }

    public int getDislikeCount() {
        return dislikeCount;
    }

    public void setDislikeCount(int dislikeCount) {
        this.dislikeCount = dislikeCount;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getImagePath() {
        return imagePath;
    }

    public void setImagePath(String imagePath) {
        this.imagePath = imagePath;
    }



    public String getVideoPath() {
        return videoPath;
    }

    public void setVideoPath(String videoPath) {
        this.videoPath = videoPath;
    }

    public String getVideoThumbnailPath() {
        return videoThumbnailPath;
    }

    public void setVideoThumbnailPath(String videoThumbnailPath) {
        this.videoThumbnailPath = videoThumbnailPath;
    }

    public String getBoardName() {

        if ("NOTICE".equals(boardType)) {
            return "공지";
        }

        if ("KCULTURE".equals(boardType)) {
            return "K-컬쳐";
        }

        if ("FREE".equals(boardType)) {
            return "일반";
        }

        if ("QUESTION".equals(boardType)) {
            return "질문";
        }

        return boardType;
    }


    public String getViewUrl() {

        if ("NOTICE".equals(sourceType) || "NOTICE".equals(boardType)) {
            return "/board/noticeView.jsp?id=" + id;
        }

        if ("KCULTURE".equals(boardType)) {
            return "/board/category-view.jsp?postId=" + id;
        }

        if ("QUESTION".equals(boardType)) {
            return "/board/qnaView.jsp?id=" + id;
        }

        return "/board/allView.jsp?id=" + id;
    }
}
