package fr.idref.api.derivationbnf.model;

public class Props {

    private String ark;
    private String token;
    private String recordId;
    private String urlBnf;
    private String urlSolr;
    private Boolean isArk;
    private String message;
    private Boolean isValide;
    private String status;
    private String reponse;
    private String urlChe;
    private String login;
    private String ppnSru;


    public String getIsArk() {
        return ark;
    }

    public void setIsArk(Boolean ark) {
        isArk = ark;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public Boolean getValide() {
        return isValide;
    }

    public void setValide(Boolean valide) {
        isValide = valide;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public void setArk(String ark) {
        this.ark = ark;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public String getRecordId() {
        return recordId;
    }

    public void setRecordId(String recordId) {
        this.recordId = recordId;
    }

    public String getUrlBnf() {
        return urlBnf;
    }

    public void setUrlBnf(String urlBnf) {
        this.urlBnf = urlBnf;
    }

    public String getUrlSolr() {
        return urlSolr;
    }

    public String getReponse() {
        return reponse;
    }

    public void setReponse(String reponse) {
        this.reponse = reponse;
    }

    public void setUrlSolr(String urlSolr) {
        this.urlSolr = urlSolr;
    }

    public String getUrlChe() {
        return urlChe;
    }

    public void setUrlChe(String urlChe) {
        this.urlChe = urlChe;
    }

    public String getLogin() {
        return login;
    }

    public void setLogin(String login) {
        this.login = login;
    }

    public String getPpnSru() {
        return ppnSru;
    }

    public void setPpnSru(String ppnSru) {
        this.ppnSru = ppnSru;
    }

    @Override
    public String toString() {
        return "Props{" +
                "ark='" + ark + '\'' +
                ", token='" + token + '\'' +
                ", recordId='" + recordId + '\'' +
                ", urlBnf='" + urlBnf + '\'' +
                ", urlSolr='" + urlSolr + '\'' +
                ", isArk=" + isArk +
                ", message='" + message + '\'' +
                ", isValide=" + isValide +
                ", status='" + status + '\'' +
                ", reponse='" + reponse + '\'' +
                ", urlChe='" + urlChe + '\'' +
                ", login='" + login + '\'' +
                ", ppnSru='" + ppnSru + '\'' +
                '}';
    }
}
