package fr.idref.idrefapi.service;

import fr.idref.idrefapi.model.Props;
import fr.idref.idrefapi.model.solr.Doc;
import fr.idref.idrefapi.model.solr.SolrDoublon;
import it.sauronsoftware.base64.Base64;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.UnsupportedEncodingException;
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

    @Value("${spring.urlChe}")
    private String urlChe;

    private static final Logger log = LoggerFactory.getLogger(CheckDataServices.class);


    public boolean isBnfExist(String notice)        {return notice.contains("<srw:numberOfRecords>1</srw:numberOfRecords>");}
    public boolean isSruSuccess(String notice)      {return notice.contains("<operationStatus>success</operationStatus>");}
    public boolean isSruCheSuccess(String xml)      {return xml.contains("numberOfRecords>1</numberOfRecords>");}

    public boolean isSolrExist(SolrDoublon solr)    {return (solr.getResponse().getNumFound() == 0);}
    public boolean isSolrDoublon(SolrDoublon solr)  {return (solr.getResponse() != null && solr.getResponse().getNumFound() > 0);}

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
    String targetEnd = "</message>";
    int index = xml.indexOf(target);
    int subIndex = xml.indexOf(targetEnd);
    res = xml.substring(index+9,subIndex);
    res = formatMessageSru(res);
    return res;
}


public String getRecord(String xml)
{
    final Pattern pattern = Pattern.compile("<record>(.+?)</record>", Pattern.DOTALL);
    final Matcher matcher = pattern.matcher(xml);
    matcher.find();
    return matcher.group(1);
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

    public String getLinkPpn(String ppn)
    {
        StringBuffer sb = new StringBuffer();

        sb.append("<a href=\"javascript:goToPpn('");
        sb.append(ppn);
        sb.append("');\">");
        sb.append(ppn);
        sb.append("</a>)");

         return sb.toString();

    }

    private String getLogin(String token)
    {
        String[] tmp = token.split("/");
        String loginClear = "";

        try {

        if (tmp.length == 2) {
            loginClear = Base64.decode(java.net.URLDecoder.decode(tmp[0], "UTF-8"));
        }
        else if (tmp.length == 3) {
            loginClear = Base64.decode(java.net.URLDecoder.decode(tmp[1], "UTF-8"));
        }

        } catch (UnsupportedEncodingException e) {
            log.error("Decode login from token failed" + token);
            e.printStackTrace();
        }

     return loginClear;
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

    public String formatUrlChe(String ppn, String token)
    {
        return urlChe.replace("xxx", token).replace("yyy", ppn);

    }

    public String formatXmlCheToXmlOracle(String record, String ppn, String login)
    {
        StringBuffer sb = new StringBuffer();

        String begin = "<?xml version='1.0' encoding='utf-8'?>\n" +
                "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\n" +
                "    xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"\n" +
                "    xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n" +
                "    <soap:Body>\n" +
                "        <ucp:updateRequest xmlns:srw=\"http://www.loc.gov/zing/srw/\"\n" +
                "            xmlns:ucp=\"http://www.loc.gov/zing/srw/update/\">\n" +
                "            <srw:version>1.0</srw:version>\n" +
                "            <ucp:action>info:srw/action/1/replace</ucp:action>\n" +
                "            <srw:recordIdentifier>"+
                ppn +
                "</srw:recordIdentifier>\n" +
                "            <ucp:recordVersions>\n" +
                "                <ucp:recordVersion>\n" +
                "                    <ucp:versionType>timestamp</ucp:versionType>\n" +
                "                    <ucp:versionValue>124578</ucp:versionValue>\n" +
                "                </ucp:recordVersion>\n" +
                "            </ucp:recordVersions>\n" +
                "            <srw:record>\n" +
                "                <srw:recordPacking>xml</srw:recordPacking>\n" +
                "                <srw:recordSchema>info:srw/schema/1/marcxml-v1.1</srw:recordSchema>\n" +
                "<srw:recordData>" ;




String end = "</srw:recordData>\n" +
        "            </srw:record>\n" +
        "<srw:extraRequestData>\n"+
        "   <srw:creatorid>\n"+
              login+
        "</srw:creatorid>\n"+
                "<srw:creatorappid>Aucune</srw:creatorappid>\n"+
            "</srw:extraRequestData>\n"+
        "</ucp:updateRequest>\n"+
        "</soap:Body>\n"+
        "</soap:Envelope>";

        sb.append(begin);
        sb.append(record);
        sb.append(end);

        return sb.toString();
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
        p.setLogin(getLogin(token));

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


