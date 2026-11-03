package dto;

public class TourDTO {

    private String contentId;
    private String title;
    private String address;
    private String imageUrl;
    private String startDate;
    private String endDate;


    public String getContentId() {
        return contentId;
    }

    public void setContentId(String contentId) {
        this.contentId = contentId;
    }


    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }


    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }


    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }


    public String getStartDate() {
        return startDate;
    }

    public void setStartDate(String startDate) {
        this.startDate = startDate;
    }


    public String getEndDate() {
        return endDate;
    }

    public void setEndDate(String endDate) {
        this.endDate = endDate;
    }


    public String getDisplayPeriod() {

        String start =
            formatDate(startDate);

        String end =
            formatDate(endDate);

        if (
            start.isEmpty()
            && end.isEmpty()
        ) {
            return "";
        }

        if (end.isEmpty()) {
            return start;
        }

        return start + " ~ " + end;
    }


    private String formatDate(
        String value
    ) {

        if (
            value == null
            || value.length() != 8
        ) {
            return value == null
                ? ""
                : value;
        }

        return value.substring(0, 4)
            + "."
            + value.substring(4, 6)
            + "."
            + value.substring(6, 8);
    }
}
