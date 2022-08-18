package fr.idref.api.derivationviaf.model;


import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

@JsonIgnoreProperties(ignoreUnknown=true)
public class Entry {


        @JsonProperty("viafId")
        private String viafId;


}
