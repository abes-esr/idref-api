package fr.idref.api.derivationviaf.model.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

public class ViafCluster {
    @JsonProperty("ns1:viafID")
    private String viafID;

    public String getViafID() {
        return viafID;
    }

    public void setViafID(String viafID) {
        this.viafID = viafID;
    }
}
