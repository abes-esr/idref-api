package fr.idref.api.derivationviaf.web;

import fr.idref.api.derivationviaf.model.solr.SolrDoublon;
import fr.idref.api.derivationviaf.service.CheckDataServices;
import fr.idref.api.derivationviaf.service.GetDataServices;
import fr.idref.api.derivationviaf.model.Props;
import fr.idref.api.derivationviaf.service.PopulateServices;
import org.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;
import java.util.Date;
import java.util.List;

import static org.apache.commons.lang3.StringUtils.join;

@RestController
public class DerivationController {

    @Autowired
    CheckDataServices checkDataServices;

    @Autowired
    GetDataServices getDataServices;

    @Autowired
    PopulateServices populateServices;


    @Value("${spring.url.sru}")
    private String urlSru;

    private static final Logger log = LoggerFactory.getLogger(DerivationController.class);


    /**
     * WS derivation idref :
     * check data : format ark is valid , id from ark is unique
     * retrieve xml from bnf by ws bnf
     * transfo xsl
     * insert xml in cbs by ws sru update
     *
     * @param ark   : url
     * @param token : key from authentification
     * @return
     * @throws IOException
     */
    /*
    @CrossOrigin(origins = "*")
    @RequestMapping(value = "/derivation", produces = MediaType.APPLICATION_JSON_VALUE)
    public String derivationLot(@RequestParam String ark, @RequestParam String token) throws IOException {

        Props p = checkDataServices.populateParam(ark, token);
        log.info("Step 0 param : " + p.toString());

        if (Boolean.TRUE.equals(p.getValide())) {
            SolrDoublon solrObj = getDataServices.getXmlSolr(p.getUrlSolr());
            log.info("Step 1  Solr objet : " + solrObj.toString());

            if (checkDataServices.isSolrExist(solrObj)) {


                String xmlBnf = getDataServices.getXmlBnf(p.getUrlBnf());
                log.info("Step 2 xml Bnf : " + xmlBnf);

                if (checkDataServices.isBnfExist(xmlBnf)) {

                    String xmlMarc = getDataServices.transformXsl(xmlBnf, token);
                    log.info("Step 3 xml Marc : " + xmlMarc);

                    String xmlSru = getDataServices.getXmlSru(xmlMarc);
                    log.info("Step 4 xml Sru  : " + xmlSru);

                    if (checkDataServices.isSruSuccess(xmlSru)) {

                        p.setStatus("OK");
                        p.setMessage("ppn crée : " + checkDataServices.getPpn(xmlSru) + "   <br/>   " + xmlSru);
                        p.setReponse(xmlSru);

                    } else {
                        p.setMessage("Message : " + checkDataServices.getMessage(xmlSru));
                        p.setReponse(xmlSru);
                    }
                } else {
                    p.setMessage("step 3 STOP ws sru bnf no result");
                }
            } else {
                p.setMessage("step 2 STOP ws solrtotal doublon id bnf");
            }
        } else {
            log.info("step 1 ERROR : param non valide" + p.getMessage());

        }

        JSONObject jo = new JSONObject();
        jo.put("statut", p.getStatus());
        jo.put("reponse", p.getReponse());
        jo.put("message", p.getMessage());
        jo.put("ppn", p.getPpnSru());
        jo.put("date lot", "27/08/2020 14:08");

        return jo.toString();

    }

*/

    /**
     * WS derivation idref verification ppn en doublon:
     * check ark , doublon ppn
     */


    @CrossOrigin(origins = "*")
    @RequestMapping(value = "/derivationviafdoublon", produces = MediaType.APPLICATION_JSON_VALUE)
    public String derivationDoublon(@RequestParam String urisourceviaf, @RequestParam String token, @RequestParam(required = false) String next) throws IOException {

        urisourceviaf = "https://viaf.org/processed/LC|n  80032817";
        Props p = populateServices.populateParam(urisourceviaf, token);
        log.info("Step 0 param : " + p.toString());

        if (Boolean.TRUE.equals(p.getValide())) {
            SolrDoublon solrObj = getDataServices.getXmlSolr(p.getUrlSolr());
            log.info("Step 1  Solr objet : " + solrObj.toString());

// TODO check isSolrExist
            if (checkDataServices.isSolrExist(solrObj) || next.equals("true")) {
                String xmlViaf = getDataServices.getXmlViaf(p.getUriSourceViafXml());
                log.info("Step 2 xml Viaf : " + xmlViaf);

                if (checkDataServices.isViafExist(xmlViaf, p.getIdSourceViaf())) {

                    String xmlMarc = getDataServices.transformXsl(xmlViaf, token);
                    log.info("Step 3 xml Marc : " + xmlMarc);

                    String xmlSru = getDataServices.getXmlSru(xmlMarc);
                    log.info("Step 4 xml Sru  : " + xmlSru);


                    if (checkDataServices.isSruSuccess(xmlSru)) {

                        // new step : retrieve notice and write in Xml
                        log.info("Step 5 xml che ppn  : " + xmlSru);

                        String ppn = checkDataServices.getPpn(xmlSru);
                        p.setUrlChe(checkDataServices.formatUrlChe(ppn, token));

                        String xmlChe = getDataServices.getXmlSruChe(p.getUrlChe());

                        if (checkDataServices.isSruCheSuccess(xmlChe)) {

                            String record = checkDataServices.getRecord(xmlChe);
                            String xmlOracle = checkDataServices.formatXmlCheToXmlOracle(record, ppn, p.getLogin());
                            log.info(xmlOracle);
                            // concat


                     //       String res = getDataServices.getXmlUpdateOracle(xmlOracle);
                    //       log.info(res);

                        }


                        p.setPpnSru(ppn);
                        p.setStatus("OK");
                        p.setMessage("ppn crée : " + checkDataServices.getPpn(xmlSru) + "   <br/>   " + checkDataServices.getMessage(xmlSru));
                        p.setReponse(xmlSru);
                    } else {
                        p.setMessage("Message : " + checkDataServices.getMessage(xmlSru));
                        p.setReponse(xmlSru);
                    }

                } else {
                    p.setMessage("step 3 STOP ws sru bnf no result");
                }
            } else if (checkDataServices.isSolrDoublon(solrObj)) {

                List<String> ppn = checkDataServices.getPpnFromSolr(solrObj);
                p.setStatus("doublon");
                p.setMessage(join(ppn, " "));
                p.setReponse(ppn.toString());

            } else {
                p.setMessage("step 2 STOP ws solrtotal doublon id viaf");
            }

        } else {
            log.info("step 1 ERROR : param non valide" + p.getMessage());
        }

        JSONObject jo = new JSONObject();
        jo.put("statut", p.getStatus());
        jo.put("reponse", p.getReponse());
        jo.put("message", p.getMessage());
        jo.put("date doublon", new Date());
        jo.put("ppn", p.getPpnSru());

        log.info("json : "  + jo.toString());
        return jo.toString();
    }

}


