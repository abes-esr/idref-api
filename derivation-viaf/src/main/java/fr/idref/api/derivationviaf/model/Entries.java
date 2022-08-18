package fr.idref.api.derivationviaf.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@JsonIgnoreProperties(ignoreUnknown=true)
public class Entries {

    @JsonProperty("Entries")
    private LinkedHashMap<String,String> Entries;

}