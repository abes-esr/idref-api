package fr.idref.api.derivationviaf.model.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

public class ViafResponse {
    @JsonProperty("ns1:VIAFCluster")
    private ViafCluster viafCluster;

    public ViafCluster getViafCluster() {
        return viafCluster;
    }

    public void setViafCluster(ViafCluster viafCluster) {
        this.viafCluster = viafCluster;
    }
}
