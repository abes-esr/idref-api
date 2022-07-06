package fr.idref.api.derivationbnf.service;

import fr.idref.api.derivationbnf.handler.RestTemplateHandler;
import fr.idref.api.derivationbnf.model.solr.SolrDoublon;
import net.sf.saxon.TransformerFactoryImpl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import javax.xml.transform.*;
import javax.xml.transform.stream.StreamResult;
import java.io.File;
import java.io.IOException;
import java.io.StringReader;
import java.io.StringWriter;


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

    public SolrDoublon getXmlSolr(String url) { return  restTemplate.getForObject(url, SolrDoublon.class); }
    public String getXmlBnf(String url) {return restTemplate.getForObject(url, String.class); }

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
         File xslFile = resource.getFile();

         Source xsltSource = new javax.xml.transform.stream.StreamSource(xslFile);
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


