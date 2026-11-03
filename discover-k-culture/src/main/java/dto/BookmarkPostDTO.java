package dto;

import java.sql.Timestamp;

/**
 * 북마크 목록 화면에 필요한 게시글 정보 DTO
 *
 * 기존 post 테이블 + bookmark 테이블 + member 테이블의 정보를
 * 한 번에 담기 위해 별도로 만든 DTO입니다.
 *
 * 기존 PostDTO를 수정하지 않기 때문에
 * 기존 게시판 기능에 영향을 주지 않습니다.
 */
public class BookmarkPostDTO {

    // 게시글 번호
    private long postId;

    // 게시판 종류: KCULTURE / FREE / QUESTION
    private String boardType;

    // 게시글 제목
    private String title;

    // 작성자 닉네임
    private String memberNickname;

    // K-컬처 게시글의 카테고리명
    private String categoryName;

    // 조회수
    private int viewCount;

    // 추천수
    private int likeCount;

    // 게시글 작성일
    private Timestamp createdAt;

    // 북마크 등록일
    private Timestamp bookmarkedAt;


    public long getPostId() {
        return postId;
    }

    public void setPostId(long postId) {
        this.postId = postId;
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

    public String getMemberNickname() {
        return memberNickname;
    }

    public void setMemberNickname(String memberNickname) {
        this.memberNickname = memberNickname;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
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

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getBookmarkedAt() {
        return bookmarkedAt;
    }

    public void setBookmarkedAt(Timestamp bookmarkedAt) {
        this.bookmarkedAt = bookmarkedAt;
    }
}
