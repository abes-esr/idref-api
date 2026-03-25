package fr.idref.api.derivationviaf.service;

import fr.idref.api.derivationviaf.model.Props;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.stereotype.Service;

import java.net.URI;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;

@Service
public class PopulateServices {


    @Autowired
    CheckDataServices checkServices;

    @Autowired
    GetDataServices getServices;


    public Props populateParam(String uriSourceViaf, String token)
    {
        Props p =  new Props();
        p.setToken(token);
        p.setStatus("KO");
        p.setReponse("vide");
        p.setLogin(checkServices.getLogin(token));
        p.setValide(false);

        //Si encodé 2 fois : c'est possible en copiant l'url depuis l'interface VIAF.
        //https://stp.abes.fr/node/98756/edit?origine=idref et https://stp.abes.fr/node/98758/edit?origine=idref
        if (uriSourceViaf.contains("%")){
            uriSourceViaf = URLDecoder.decode(uriSourceViaf, StandardCharsets.UTF_8);
        }
        if (checkServices.isUriSourceViaf(uriSourceViaf))
        {
            //  get info from source viaf : uri et id
            String idSourceViaf = checkServices.getIdSourceViaf(uriSourceViaf);
            p.setUriSourceViaf(uriSourceViaf);
            p.setIdSourceViaf(idSourceViaf);

            p.setUrlXslt(checkServices.getUrlXslt(uriSourceViaf));

            //  get info from cluster viaf : uri et id
            p.setUriClusterViaf(checkServices.getUrlClusterViaf(idSourceViaf));

            p.setUriViaf(checkServices.getUrlViaf(idSourceViaf));

            String idClusterViaf = getServices.getIdClusterViaf(p.getUriClusterViaf());
            if (idClusterViaf != null) {

                p.setIdClusterViaf(idClusterViaf);
                p.setUrlSolr(checkServices.getUrlSolr(idClusterViaf));
                p.setValide(true);
            }else {
                p.setMessage("step 1 STOP format invalide uri cluster viaf en erreur");
            }
        }
        else
    {
        p.setMessage("step 1 STOP format invalide uri source viaf");
    }

        return p;
}


}
