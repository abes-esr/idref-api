package fr.idref.api.derivationviaf.model;

public class Props {

    private String uriSourceViaf;
    private String uriClusterViaf;
    private String uriSourceViafXml;
    private String idSourceViaf;
    private String idClusterViaf;


    private String token;
    private String recordId;

    private String urlSolr;

    private String message;
    private Boolean isValide;
    private String status;
    private String reponse;
    private String urlChe;
    private String login;
    private String ppnSru;

    @Override
    public String toString() {
        return "Props{" +
                "uriSourceViaf='" + uriSourceViaf  + '\'' +
                ",\n uriClusterViaf='" + uriClusterViaf + '\'' +
                ",\n uriSourceViafXml='" + uriSourceViafXml + '\'' +
                ",\n idSourceViaf='" + idSourceViaf + '\'' +
                ",\n idClusterViaf='" + idClusterViaf + '\'' +
                ",\n token='" + token + '\'' +
                ",\n recordId='" + recordId + '\'' +
                ",\n urlSolr='" + urlSolr + '\'' +
                ",\n message='" + message + '\'' +
                ",\n isValide=" + isValide +
                ",\n status='" + status + '\'' +
                ",\n reponse='" + reponse + '\'' +
                ",\n urlChe='" + urlChe + '\'' +
                ",\n login='" + login + '\'' +
                ",\n ppnSru='" + ppnSru + '\'' +
                '}';
    }

    public String getUriSourceViafXml() {
        return uriSourceViafXml;
    }

    public void setUriSourceViafXml(String uriSourceViafXml) {
        this.uriSourceViafXml = uriSourceViafXml;
    }

    public String getUriSourceViaf() {
        return uriSourceViaf;
    }

    public void setUriSourceViaf(String uriSourceViaf) {
        this.uriSourceViaf = uriSourceViaf;
    }

    public String getUriClusterViaf() {
        return uriClusterViaf;
    }

    public void setUriClusterViaf(String uriClusterViaf) {
        this.uriClusterViaf = uriClusterViaf;
    }

    public String getIdSourceViaf() {
        return idSourceViaf;
    }

    public void setIdSourceViaf(String idSourceViaf) {
        this.idSourceViaf = idSourceViaf;
    }

    public String getIdClusterViaf() {
        return idClusterViaf;
    }

    public void setIdClusterViaf(String idClusterViaf) {
        this.idClusterViaf = idClusterViaf;
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

    public String getUrlSolr() {
        return urlSolr;
    }

    public void setUrlSolr(String urlSolr) {
        this.urlSolr = urlSolr;
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

    public String getReponse() {
        return reponse;
    }

    public void setReponse(String reponse) {
        this.reponse = reponse;
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

}
