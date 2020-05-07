package fr.idref.idrefapi.model.solr;

import com.fasterxml.jackson.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonPropertyOrder({
        "A001_AS",
        "A033.A033Sa_AS"
})
public class Doc {

    @JsonProperty("A001_AS")
    private List<String> a001AS = null;
    @JsonProperty("A033.A033Sa_AS")
    private List<String> a033A033SaAS = null;
    @JsonIgnore
    private Map<String, Object> additionalProperties = new HashMap<String, Object>();

    @JsonProperty("A001_AS")
    public List<String> getA001AS() {
        return a001AS;
    }

    @JsonProperty("A001_AS")
    public void setA001AS(List<String> a001AS) {
        this.a001AS = a001AS;
    }

    @JsonProperty("A033.A033Sa_AS")
    public List<String> getA033A033SaAS() {
        return a033A033SaAS;
    }

    @JsonProperty("A033.A033Sa_AS")
    public void setA033A033SaAS(List<String> a033A033SaAS) {
        this.a033A033SaAS = a033A033SaAS;
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
        return "Doc{" +
                "a001AS=" + a001AS +
                ", a033A033SaAS=" + a033A033SaAS +
                ", additionalProperties=" + additionalProperties +
                '}';
    }
}