package fr.idref.api.derivationviaf.service;

import com.fasterxml.jackson.databind.JsonNode;
import fr.idref.api.derivationviaf.handler.RestTemplateHandler;
import fr.idref.api.derivationviaf.model.Entries;
import fr.idref.api.derivationviaf.model.solr.SolrDoublon;
import net.sf.saxon.TransformerFactoryImpl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import javax.xml.transform.*;
import javax.xml.transform.stream.StreamResult;
import java.io.IOException;
import java.io.StringReader;
import java.io.StringWriter;
import java.net.URI;
import java.util.LinkedHashMap;
import java.util.Map;

import static org.json.XMLTokener.entity;


@Service
public class GetDataServices {

    private static final Logger log = LoggerFactory.getLogger(GetDataServices.class);

    @Value("${spring.url.sru}")
    private String urlSru;

    @Value("${spring.urlOracle}")
    private String urlOracle;


    private RestTemplate restTemplate;

    @Autowired
    public GetDataServices(RestTemplateBuilder restTemplateBuilder) {
        restTemplate = restTemplateBuilder
                .errorHandler(new RestTemplateHandler())
                .build();
    }

    // https://www.wranto.com/2018/03/Spring-RestTemplate-AutoRedirect.html
    //https://stackoverflow.com/questions/45118609/how-to-map-getbody-array-list-response-of-resttemplate-into-class-in-spring-boot
    public String getIdClusterViaf(String url) {
        Map<String,String> response = restTemplate.getForObject(url, Map.class);
        return response.get("viafID");
    }


    public SolrDoublon getXmlSolr(String url) { return  restTemplate.getForObject(url, SolrDoublon.class); }
    public String getXmlViaf(String url) {return restTemplate.getForObject(url, String.class); }

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



     public String transformXsl(String xml,String token) throws IOException{

         StringWriter writer = new StringWriter();
         StreamResult result = new StreamResult(writer);

         Resource resource = new ClassPathResource("article.xsl");

         Source xsltSource = new javax.xml.transform.stream.StreamSource(resource.getInputStream());
         Source xmlSource = new javax.xml.transform.stream.StreamSource(new StringReader(xml));

         TransformerFactory transFact = new TransformerFactoryImpl();
         try {
             Transformer trans = transFact.newTransformer(xsltSource);
             trans.setParameter("token", token);
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


