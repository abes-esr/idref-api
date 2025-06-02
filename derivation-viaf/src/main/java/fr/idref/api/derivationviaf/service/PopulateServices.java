package fr.idref.api.derivationviaf.service;

import fr.idref.api.derivationviaf.model.Props;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.stereotype.Service;

import java.net.URI;

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
