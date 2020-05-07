package fr.idref.idrefapi.model.solr;

import com.fasterxml.jackson.annotation.*;

import java.util.HashMap;
import java.util.Map;


/** TODO from http://www.jsonschema2pojo.org/ **/


@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonPropertyOrder({
        "responseHeader",
        "response"
})
public class SolrDoublon {

    @JsonProperty("responseHeader")
    private ResponseHeader responseHeader;
    @JsonProperty("response")
    private Response response;
    @JsonIgnore
    private Map<String, Object> additionalProperties = new HashMap<String, Object>();

    @JsonProperty("responseHeader")
    public ResponseHeader getResponseHeader() {
        return responseHeader;
    }

    @JsonProperty("responseHeader")
    public void setResponseHeader(ResponseHeader responseHeader) {
        this.responseHeader = responseHeader;
    }

    @JsonProperty("response")
    public Response getResponse() {
        return response;
    }

    @JsonProperty("response")
    public void setResponse(Response response) {
        this.response = response;
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
        return "SolrDoublon{" +
                "responseHeader=" + responseHeader +
                ", response=" + response +
                ", additionalProperties=" + additionalProperties +
                '}';
    }
}
