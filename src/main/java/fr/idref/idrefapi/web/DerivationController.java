package fr.idref.idrefapi.web;

import fr.idref.idrefapi.model.Props;
import fr.idref.idrefapi.model.solr.SolrDoublon;
import fr.idref.idrefapi.service.CheckDataServices;
import fr.idref.idrefapi.service.GetDataServices;
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
import java.util.List;

import static org.apache.commons.lang3.StringUtils.join;

@RestController
public class DerivationController {

    @Autowired
    CheckDataServices checkDataServices;

    @Autowired
    GetDataServices getDataServices;

    @Value("${spring.urlBnf}")
    private String urlBnf;


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
    @CrossOrigin(origins = "*")
    @RequestMapping(value = "/derivation", produces = MediaType.APPLICATION_JSON_VALUE)
    public String derivationLot(@RequestParam(required = true) String ark, @RequestParam(required = true) String token) throws IOException {

        Props p = checkDataServices.populateParam(ark, token);
        log.info("Step 0 param : " + p.toString());

        if (Boolean.TRUE.equals(p.getValide())) {
            SolrDoublon solrObj = getDataServices.getXmlSolr(p.getUrlSolr());
            log.info("Step 1  Solr objet : " + solrObj.toString());

            if (checkDataServices.isSolrExist(solrObj)) {

                derivationControle(token, p);

            } else {
                p.setMessage("step 2 ERROR  ws solr error ");
            }
        } else {
            log.info("step 1 ERROR : param non valide" + p.getMessage());

         //  p.setMessage("step 1 ERROR : param non valide ");
        }

        JSONObject jo = new JSONObject();
        jo.put("statut", p.getStatus());
        jo.put("reponse", p.getReponse());
        jo.put("message", p.getMessage());


         return jo.toString();

    }


    /**
     * WS derivation idref verification ppn en doublon:
     * check ark , doublon ppn
     */

    @CrossOrigin(origins = "*")
    @RequestMapping(value = "/derivationdoublon", produces = MediaType.APPLICATION_JSON_VALUE)
    public String derivationDoublon(@RequestParam(required = true) String ark, @RequestParam(required = true) String token, @RequestParam(required = false) String next) throws IOException {

            Props p = checkDataServices.populateParam(ark, token);
            log.info("Step 0 param : " + p.toString());

            if (Boolean.TRUE.equals(p.getValide())) {
                SolrDoublon solrObj = getDataServices.getXmlSolr(p.getUrlSolr());
                log.info("Step 1  Solr objet : " + solrObj.toString());


                 if (checkDataServices.isSolrExist(solrObj) || next.equals("true")) {
                        derivationControle(token, p);
                 }
                  else if (checkDataServices.isSolrDoublon(solrObj)) {

                         List<String> ppn = checkDataServices.getPpnFromSolr(solrObj);
                         p.setStatus("doublon");
                         p.setMessage(join(ppn, "-"));
                         p.setReponse(ppn.toString());

                } else {
                    p.setMessage("step 2 ERROR  ws solr error ");
                }

        } else {
            log.info("step 1 ERROR : param non valide" + p.getMessage());
        }

        JSONObject jo = new JSONObject();
        jo.put("statut", p.getStatus());
        jo.put("reponse", p.getReponse());
        jo.put("message", p.getMessage());

        return jo.toString();
    }

    private void derivationControle(@RequestParam(required = true) String token, Props p) throws IOException {

        String xmlBnf = getDataServices.getXmlBnf(p.getUrlBnf());
        log.info("Step 2 xml Bnf : " + xmlBnf);

        if (checkDataServices.isBnfExist(xmlBnf)) {

            String xmlMarc = getDataServices.transformXsl(xmlBnf, token);
            log.info("Step 3 xml Marc : " + xmlMarc);

            String xmlSru = getDataServices.getXmlSru(xmlMarc);
            log.info("Step 4 xml Sru  : " + xmlSru);

            if (checkDataServices.isSruSuccess(xmlSru)) {
                p.setStatus("OK");
                p.setMessage("ppn crée : " + checkDataServices.getPpn(xmlSru) + "     " + xmlSru);
                p.setReponse(xmlSru);
            } else {
                p.setMessage("Message : " +   checkDataServices.getMessage(xmlSru));
                p.setReponse(xmlSru);
            }
        } else {
            p.setMessage("step 3  ERROR  ws bnf error ");
        }
    }
}



