package fr.idref.idrefapi.model.solr;

import com.fasterxml.jackson.annotation.*;

import java.util.HashMap;
import java.util.Map;

@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonPropertyOrder({
        "q",
        "indent",
        "fl",
        "solrService",
        "start",
        "rows",
        "version",
        "wt"
})
public class Params {

    @JsonProperty("q")
    private String q;
    @JsonProperty("indent")
    private String indent;
    @JsonProperty("fl")
    private String fl;
    @JsonProperty("solrService")
    private String solrService;
    @JsonProperty("start")
    private String start;
    @JsonProperty("rows")
    private String rows;
    @JsonProperty("version")
    private String version;
    @JsonProperty("wt")
    private String wt;
    @JsonIgnore
    private Map<String, Object> additionalProperties = new HashMap<String, Object>();

    @JsonProperty("q")
    public String getQ() {
        return q;
    }

    @JsonProperty("q")
    public void setQ(String q) {
        this.q = q;
    }

    @JsonProperty("indent")
    public String getIndent() {
        return indent;
    }

    @JsonProperty("indent")
    public void setIndent(String indent) {
        this.indent = indent;
    }

    @JsonProperty("fl")
    public String getFl() {
        return fl;
    }

    @JsonProperty("fl")
    public void setFl(String fl) {
        this.fl = fl;
    }

    @JsonProperty("solrService")
    public String getSolrService() {
        return solrService;
    }

    @JsonProperty("solrService")
    public void setSolrService(String solrService) {
        this.solrService = solrService;
    }

    @JsonProperty("start")
    public String getStart() {
        return start;
    }

    @JsonProperty("start")
    public void setStart(String start) {
        this.start = start;
    }

    @JsonProperty("rows")
    public String getRows() {
        return rows;
    }

    @JsonProperty("rows")
    public void setRows(String rows) {
        this.rows = rows;
    }

    @JsonProperty("version")
    public String getVersion() {
        return version;
    }

    @JsonProperty("version")
    public void setVersion(String version) {
        this.version = version;
    }

    @JsonProperty("wt")
    public String getWt() {
        return wt;
    }

    @JsonProperty("wt")
    public void setWt(String wt) {
        this.wt = wt;
    }

    @JsonAnyGetter
    public Map<String, Object> getAdditionalProperties() {
        return this.additionalProperties;
    }

    @JsonAnySetter
    public void setAdditionalProperty(String name, Object value) {
        this.additionalProperties.put(name, value);
    }

    @Override
    public String toString() {
        return "Params{" +
                "q='" + q + '\'' +
                ", indent='" + indent + '\'' +
                ", fl='" + fl + '\'' +
                ", solrService='" + solrService + '\'' +
                ", start='" + start + '\'' +
                ", rows='" + rows + '\'' +
                ", version='" + version + '\'' +
                ", wt='" + wt + '\'' +
                ", additionalProperties=" + additionalProperties +
                '}';
    }
}