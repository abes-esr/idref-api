package fr.idref.api.derivationviaf.service;

import com.fasterxml.jackson.databind.JsonNode;
import fr.idref.api.derivationviaf.handler.RestTemplateHandler;
import fr.idref.api.derivationviaf.model.Props;
import fr.idref.api.derivationviaf.model.dto.ViafResponse;
import fr.idref.api.derivationviaf.model.solr.SolrDoublon;
import net.sf.saxon.TransformerFactoryImpl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.core.io.*;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import javax.xml.transform.*;
import javax.xml.transform.stream.StreamResult;
import java.io.IOException;
import java.io.StringReader;
import java.io.StringWriter;
import java.net.URI;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.Map;

import static org.json.XMLTokener.entity;
import org.springframework.core.io.Resource;

@Service
public class GetDataServices {

    private static final Logger log = LoggerFactory.getLogger(GetDataServices.class);

    @Value("${spring.url.sru}")
    private String urlSru;

    @Value("${spring.urlOracle}")
    private String urlOracle;

    private RestTemplate restTemplate;
    private final ResourceLoader resourceLoader;


    @Autowired
    public GetDataServices(RestTemplateBuilder restTemplateBuilder) {
        restTemplate = restTemplateBuilder
                .errorHandler(new RestTemplateHandler())
                .build();

        resourceLoader = new DefaultResourceLoader();
    }

    public String getIdClusterViaf(String url) {

        HttpHeaders headers = new HttpHeaders();
        headers.setAccept(Collections.singletonList(MediaType.APPLICATION_XML));
        HttpEntity<String> entity = new HttpEntity<>(headers);

        ResponseEntity<ViafResponse> response = restTemplate.exchange(
                url,
                HttpMethod.GET,
                entity,
                ViafResponse.class
        );

        ViafResponse body = response.getBody();
        if (body == null || body.getViafID() == null) {
            return null;
        }
        return body.getViafID();
    }


    public SolrDoublon getXmlSolr(String url) { return  restTemplate.getForObject(url, SolrDoublon.class); }
    public String getXmlViaf(String url) {

        HttpHeaders headers = new HttpHeaders();
        headers.setAccept(Collections.singletonList(MediaType.APPLICATION_XML));
        HttpEntity<String> entity = new HttpEntity<>(headers);

        ResponseEntity<String> response = restTemplate.exchange(
                url,
                HttpMethod.GET,
                entity,
                String.class
        );

        return response.getBody();
    }

  //public SruChe getXmlSruChe(String url) {return restTemplate.getForObject(url, SruChe.class); }
    public String getXmlSruChe(String url) {return restTemplate.getForObject(url, String.class); }

    public String getXmlUpdateOracle(String xml) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_XML);

        HttpEntity<String> request = new HttpEntity<>(xml, headers);
        return restTemplate.postForObject(urlOracle, request, String.class);
    }


    public String getXmlSru(String xml)
    {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_XML);

        HttpEntity<String> request = new HttpEntity<>(xml, headers);
        return restTemplate.postForObject(urlSru, request, String.class);
    }



     public String transformXsl(String xml,String token, Props p) throws IOException{

         StringWriter writer = new StringWriter();
         StreamResult result = new StreamResult(writer);

         Resource  resource = resourceLoader.getResource(p.getUrlXslt());


         Source xsltSource = new javax.xml.transform.stream.StreamSource(resource.getInputStream());
         Source xmlSource = new javax.xml.transform.stream.StreamSource(new StringReader(xml));

         TransformerFactory transFact = new TransformerFactoryImpl();
         try {
             Transformer trans = transFact.newTransformer(xsltSource);
             trans.setParameter("token", token);
             trans.setParameter("idviaf", p.getIdClusterViaf());
             trans.transform(xmlSource, result);
         } catch (TransformerConfigurationException e) {
             e.printStackTrace();
             log.error("Step 3.1  ERROR xsl transfo : " + e.getMessage());
         } catch (TransformerException e) {
             e.printStackTrace();
             log.error("Step 3.2  ERROR xsl transfo : " + e.getMessage());
         }

         return writer.toString();
     }
}


