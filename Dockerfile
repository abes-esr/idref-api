###
# Image pour la compilation de licencesnationales
FROM maven:3-jdk-11 as build-image
WORKDIR /build/
# Installation et configuration de la locale FR
RUN apt update && DEBIAN_FRONTEND=noninteractive apt -y install locales
RUN sed -i '/fr_FR.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
ENV LANG fr_FR.UTF-8
ENV LANGUAGE fr_FR:fr
ENV LC_ALL fr_FR.UTF-8
# On lance la compilation
# si on a un .m2 local on peut décommenter la ligne suivante pour
# éviter à maven de retélécharger toutes les dépendances
#COPY ./.m2/    /root/.m2/
COPY ./derivation-bnf/   /build/derivation-bnf/
COPY ./derivation-viaf/  /build/derivation-viaf/
RUN mvn --batch-mode \
        -Dmaven.test.skip=false \
        -Duser.timezone=Europe/Paris \
        -Duser.language=fr \
        -f /build/derivation-bnf/pom.xml \
        package \
RUN mvn --batch-mode \
        -Dmaven.test.skip=false \
        -Duser.timezone=Europe/Paris \
        -Duser.language=fr \
        -f /build/derivation-viaf/pom.xml \
        package

###
# Image pour le micro service derivation-bnf
FROM openjdk:11 as derivation-bnf-server
COPY --from=build-image /build/derivation-bnf/target/*.jar /app/derivation-bnf.jar
CMD ["java", "-jar", "/app/derivation-bnf.jar"]

###
# Image pour le micro service derivation-viaf
FROM openjdk:11 as derivation-viaf-server
COPY --from=build-image /build/derivation-viaf/target/*.jar /app/derivation-viaf.jar
CMD ["java", "-jar", "/app/derivation-viaf.jar"]