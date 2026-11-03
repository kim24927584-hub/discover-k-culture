package dto;

import java.sql.Timestamp;

public class LanguageDTO {
    private int languageId;
    private String code;
    private String nameKo;
    private String nameNative;
    private boolean active;
    private Timestamp createdAt;

    public int getLanguageId() { return languageId; }
    public void setLanguageId(int languageId) { this.languageId = languageId; }
    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public String getNameKo() { return nameKo; }
    public void setNameKo(String nameKo) { this.nameKo = nameKo; }
    public String getNameNative() { return nameNative; }
    public void setNameNative(String nameNative) { this.nameNative = nameNative; }
    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
