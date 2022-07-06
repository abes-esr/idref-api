package fr.idref.api.derivationviaf.handler;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.client.ClientHttpResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.ResponseErrorHandler;

import java.io.IOException;

@Component
public class RestTemplateHandler implements ResponseErrorHandler {

 private static final Logger log = LoggerFactory.getLogger(RestTemplateHandler.class);

    @Override
        public boolean hasError(ClientHttpResponse httpResponse)
                throws IOException {

        return (httpResponse
                    .getStatusCode()
                    .series() == HttpStatus.Series.CLIENT_ERROR || httpResponse
                    .getStatusCode()
                    .series() == HttpStatus.Series.SERVER_ERROR);
        }

        @Override
        public void handleError(ClientHttpResponse httpResponse)
                throws IOException {

            log.error("ERROR 2 : " + HttpStatus.Series.SERVER_ERROR);


            if (httpResponse
                    .getStatusCode()
                    .series() == HttpStatus.Series.SERVER_ERROR) {
                //Handle SERVER_ERROR
                throw new HttpClientErrorException(httpResponse.getStatusCode());
            } else if (httpResponse
                    .getStatusCode()
                    .series() == HttpStatus.Series.CLIENT_ERROR) {

                log.error("ERROR 3 :" + HttpStatus.Series.SERVER_ERROR);

                //Handle CLIENT_ERROR
                if (httpResponse.getStatusCode() == HttpStatus.NOT_FOUND) {
                    throw new UnknownException();
                }
            }
        }
    }
