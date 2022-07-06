package fr.idref.api.derivationviaf.model.solr;

import com.fasterxml.jackson.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonPropertyOrder({
        "numFound",
        "start",
        "docs"
})
public class Response {

    @JsonProperty("numFound")
    private Integer numFound;
    @JsonProperty("start")
    private Integer start;
    @JsonProperty("docs")
    private List<Doc> docs = null;
    @JsonIgnore
    private Map<String, Object> additionalProperties = new HashMap<String, Object>();

    @JsonProperty("numFound")
    public Integer getNumFound() {
        return numFound;
    }

    @JsonProperty("numFound")
    public void setNumFound(Integer numFound) {
        this.numFound = numFound;
    }

    @JsonProperty("start")
    public Integer getStart() {
        return start;
    }

    @JsonProperty("start")
    public void setStart(Integer start) {
        this.start = start;
    }

    @JsonProperty("docs")
    public List<Doc> getDocs() {
        return docs;
    }

    @JsonProperty("docs")
    public void setDocs(List<Doc> docs) {
        this.docs = docs;
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
        return "Response{" +
                "numFound=" + numFound +
                ", start=" + start +
                ", docs=" + docs +
                ", additionalProperties=" + additionalProperties +
                '}';
    }
}