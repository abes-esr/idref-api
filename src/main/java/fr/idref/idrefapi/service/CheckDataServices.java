package fr.idref.idrefapi.service;

import fr.idref.idrefapi.model.Props;
import fr.idref.idrefapi.model.solr.Doc;
import fr.idref.idrefapi.model.solr.SolrDoublon;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
public class CheckDataServices {

    @Value("${spring.urlSolr}")
    private String urlSolr;

    @Value("${spring.urlBnf}")
    private String urlBnf;

    public boolean isBnfExist(String notice) {return notice.contains("<srw:numberOfRecords>1</srw:numberOfRecords>");}
    public boolean isSruSuccess(String notice) {return notice.contains("<operationStatus>success</operationStatus>");}
    public boolean isSolrExist(SolrDoublon solr) {return (solr.getResponse().getNumFound() == 0);}
    public boolean isSolrDoublon(SolrDoublon solr) {return (solr.getResponse() != null && solr.getResponse().getNumFound() > 0);}

    private String formatMessageSru (String message)
    {
        return message.replaceAll("%27+","'").replaceAll("\\+"," ").replace("%24","$").replace("%3B",";");
    }

    public List<String> getPpnFromSolr (SolrDoublon solr)
    {
        List<String> ppn = new ArrayList<>();
        List<Doc> l = solr.getResponse().getDocs();

        for ( Doc d : l) {
            ppn.add(d.getA001AS().toString().replace("[","").replace("]",""));
        }

        return ppn;
    }



public String getMessage(String xml)
{
    String res = "";
    String target = "<message>";
    String targetend = "</message>";
    int index = xml.indexOf(target);
    int subindex = xml.indexOf(targetend);
    res = xml.substring(index+9,subindex);
    res = formatMessageSru(res);
    return res;
}


    public String getPpn(String xml) {
        {
            String ppn = "";
            String target = "<recordIdentifier>";
            int index = xml.indexOf(target);
            int subIndex = index + 27;
            ppn = xml.substring(index+18,subIndex);
            return ppn;
        }
    }


    private boolean isArk(String ark) {
        boolean isArk = false;
        String find = "(http|https)://catalogue.bnf.fr/ark:/12148/cb\\d{8,9}[0-9bcdfghjkmnpqrstvwxz]";

        Pattern p = Pattern.compile(find);
        Matcher m = p.matcher(ark);

        if (m.matches() ) {
            isArk = true;
        }

        return isArk;
    }


    private String getRecordId(String ark)
    {
        String recordId = "";

        String find = "(http|https)://catalogue.bnf.fr/ark:/12148/cb(\\d{8,9})[0-9bcdfghjkmnpqrstvwxz]";

        Pattern p = Pattern.compile(find);
        Matcher m = p.matcher(ark);

        if (m.matches()) {
            recordId = m.group(2);
        }
        return recordId;
    }

    private String getUrlSolr(String recordId) {
        return urlSolr.replaceAll("\\?\\*", recordId + "*");
    }

    private String getUrlBnf(String recordId) {
        return urlBnf.replaceAll("\\*\\?\\*",recordId);
    }

    public Props populateParam(String ark, String token)
    {
        Props p =  new Props();

        p.setArk(ark);
        p.setToken(token);
        p.setStatus("KO");
        p.setReponse("vide");

        if (isArk(ark))
        {
            p.setIsArk(isArk(ark));

            String  recordId = getRecordId(ark);

            p.setRecordId(recordId);
            p.setUrlBnf(getUrlBnf(recordId));
            p.setUrlSolr(getUrlSolr(recordId));
            p.setValide(true);
        }
        else
        {
            p.setValide(false);
            p.setMessage("L'ark a un format invalide");
        }

        return p;
    }

}


