package fr.idref.api.derivationviaf.model.dto;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

@XmlRootElement(name = "VIAFCluster", namespace = "http://viaf.org/viaf/terms#")
@XmlAccessorType(XmlAccessType.FIELD)
public class ViafResponse {

    @XmlElement(name = "viafID", namespace = "http://viaf.org/viaf/terms#")
    private String viafID;

    public String getViafID() {
        return viafID;
    }

}
