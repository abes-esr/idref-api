package fr.idref.idrefapi.model.solr;

import com.fasterxml.jackson.annotation.*;

import java.util.HashMap;
import java.util.Map;

@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonPropertyOrder({
        "status",
        "QTime",
        "params"
})
public class ResponseHeader {

    @JsonProperty("status")
    private Integer status;
    @JsonProperty("QTime")
    private Integer qTime;
    @JsonProperty("params")
    private Params params;
    @JsonIgnore
    private Map<String, Object> additionalProperties = new HashMap<String, Object>();

    @JsonProperty("status")
    public Integer getStatus() {
        return status;
    }

    @JsonProperty("status")
    public void setStatus(Integer status) {
        this.status = status;
    }

    @JsonProperty("QTime")
    public Integer getQTime() {
        return qTime;
    }

    @JsonProperty("QTime")
    public void setQTime(Integer qTime) {
        this.qTime = qTime;
    }

    @JsonProperty("params")
    public Params getParams() {
        return params;
    }

    @JsonProperty("params")
    public void setParams(Params params) {
        this.params = params;
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
        return "ResponseHeader{" +
                "status=" + status +
                ", qTime=" + qTime +
                ", params=" + params +
                ", additionalProperties=" + additionalProperties +
                '}';
    }
}