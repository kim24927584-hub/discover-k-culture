package dto;
import java.sql.Timestamp;
public class PostDTO {
    private long postId, memberId;
    private int categoryId, viewCount, likeCount, dislikeCount, commentCount;
    private String boardType, title, content, memberNickname, categoryName;
    private Timestamp createdAt, updatedAt;
    public long getPostId(){return postId;} public void setPostId(long v){postId=v;}
    public long getMemberId(){return memberId;} public void setMemberId(long v){memberId=v;}
    public int getCategoryId(){return categoryId;} public void setCategoryId(int v){categoryId=v;}
    public String getBoardType(){return boardType;} public void setBoardType(String v){boardType=v;}
    public String getTitle(){return title;} public void setTitle(String v){title=v;}
    public String getContent(){return content;} public void setContent(String v){content=v;}
    public int getViewCount(){return viewCount;} public void setViewCount(int v){viewCount=v;}
    public int getLikeCount(){return likeCount;} public void setLikeCount(int v){likeCount=v;}
    public int getDislikeCount(){return dislikeCount;} public void setDislikeCount(int v){dislikeCount=v;}
    public int getCommentCount(){return commentCount;} public void setCommentCount(int v){commentCount=v;}
    public Timestamp getCreatedAt(){return createdAt;} public void setCreatedAt(Timestamp v){createdAt=v;}
    public Timestamp getUpdatedAt(){return updatedAt;} public void setUpdatedAt(Timestamp v){updatedAt=v;}
    public String getMemberNickname(){return memberNickname;} public void setMemberNickname(String v){memberNickname=v;}
    public String getCategoryName(){return categoryName;} public void setCategoryName(String v){categoryName=v;}
}
