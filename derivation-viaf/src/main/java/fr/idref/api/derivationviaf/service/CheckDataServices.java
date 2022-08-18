package fr.idref.api.derivationviaf.service;

import fr.idref.api.derivationviaf.model.Props;
import fr.idref.api.derivationviaf.model.solr.Doc;
import fr.idref.api.derivationviaf.model.solr.SolrDoublon;
import java.util.Base64;

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

    @Value("${spring.urlClusterViaf}")
    private String urlClusterViaf;

    @Value("${spring.urlChe}")
    private String urlChe;



    private static final Logger log = LoggerFactory.getLogger(CheckDataServices.class);


    public boolean isViafExist(String notice, String idSourceViaf)        {return notice.contains("<mx:controlfield tag=\"001\">"+idSourceViaf+"</mx:controlfield>");}
    public boolean isSruSuccess(String notice)      {return notice.contains("<operationStatus>success</operationStatus>");}
    public boolean isSruCheSuccess(String xml)      {return xml.contains("numberOfRecords>1</numberOfRecords>");}

    // TODO get value numfound in json solr
    public boolean isSolrExist(SolrDoublon solr)    {return (solr.getAdditionalProperties().containsKey("result"));}

    public boolean isSolrDoublon(SolrDoublon solr)  {return (solr.getResponse() != null && solr.getResponse().getNumFound() > 0);}

    private String formatMessageSru (String message)
    {
        try {
            message = java.net.URLDecoder.decode(message, "UTF-8");
        }
        catch (Exception e){
            log.error("formatMessageSru : "+e.getMessage());
        }
        finally {
            return message;
        }
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

    public String getLogin(String token)
    {
        String[] tmp = token.split("/");
        String loginClear = "";

        try {

            if (tmp.length == 2) {
                byte[] decodedBytes = Base64.getDecoder().decode(java.net.URLDecoder.decode(tmp[0], "UTF-8"));
                loginClear = new String(decodedBytes);
            }
            else if (tmp.length == 3) {
                byte[] decodedBytes = Base64.getDecoder().decode(java.net.URLDecoder.decode(tmp[1], "UTF-8"));
                loginClear = new String(decodedBytes);
            }

        } catch (UnsupportedEncodingException e) {
            log.error("Decode login from token failed" + token);
            e.printStackTrace();
        }

     return loginClear;
    }


    public boolean isUriSourceViaf(String uriSourceViaf) {
        boolean isUriSourceViaf = false;

        // https://viaf.org/processed/LC|n  80032817
        String find = "(http|https)://(viaf.org/processed)/(.*)";

        Pattern p = Pattern.compile(find);
        Matcher m = p.matcher(uriSourceViaf);

        if (m.matches() ) {
            isUriSourceViaf = true;
        }
        return isUriSourceViaf;
    }



    public String getIdClusterViaf(String uriClusterViaf)
    {
        // TODO get redirect info
        //  http://www.viaf.org/viaf/sourceID/LC%7Cn%20%2080032817
        // =>
        // https://viaf.org/viaf/12341457/

        return "12341457";

    }

    public String getIdSourceViaf(String uriSourceViaf)
    {
        String idSourceViaf = "";

       // https://viaf.org/processed/LC|n  80032817
        String find = "(http|https)://(viaf.org/processed)/(.*)";

        Pattern p = Pattern.compile(find);
        Matcher m = p.matcher(uriSourceViaf);

        if (m.matches()) {
            idSourceViaf = m.group(3);
        }

        return idSourceViaf;
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


    public String getUrlSolr(String recordId) {
        return urlSolr.replaceAll("\\*", recordId);
    }

    public String getUrlClusterViaf(String idSourceViaf) {

        return urlClusterViaf.replaceAll("\\*",idSourceViaf);
    }


/*
    public Props populateParam(String uriSourceViaf, String token)
    {
        Props p =  new Props();
        p.setToken(token);
        p.setStatus("KO");
        p.setReponse("vide");
        p.setLogin(getLogin(token));

        if (isUriSourceViaf(uriSourceViaf))
        {
            //  get info from source viaf : uri et id
            String idSourceViaf = getIdSourceViaf(uriSourceViaf);
            p.setUriSourceViaf(uriSourceViaf);
            p.setIdSourceViaf(idSourceViaf);
            p.setUriSourceViafXml(uriSourceViaf + "?httpAccept=text/xml");

            //  get info from cluster viaf : uri et id
            p.setUriClusterViaf(getUrlClusterViaf(idSourceViaf));
            // TODO test not null getUrlClusterViaf(idSourceViaf)
            String idClusterViaf = getIdClusterViaf(p.getUriClusterViaf());
            p.setIdClusterViaf(idClusterViaf);

            p.setUrlSolr(getUrlSolr(idClusterViaf));
            p.setValide(true);

        }
        else
        {
            p.setValide(false);
            p.setMessage("step 1 STOP format invalide uri source viaf");
        }

        return p;
    }
*/


}


