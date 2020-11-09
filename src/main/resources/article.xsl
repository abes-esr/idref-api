<?xml version="1.0" encoding="UTF-8"?>
<!--     XSL de transformation du marcXml Bnf en marcXml Sudoc. (ERM créé 2020)
    Objectifs : rendre conforme au marcXml Sudoc :
    v 20201008
  -->
<xsl:stylesheet exclude-result-prefixes="srw mxc xsi xs" version="2.0"
                xmlns:mxc="info:lc/xmlns/marcxchange-v2" xmlns:srw="http://www.loc.gov/zing/srw/"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output encoding="UTF-8" indent="yes" method="xml"/>
    <xsl:param name="token"/>
    <xsl:strip-space elements="*"/>
    <xsl:variable name="dateJour">
        <xsl:value-of select="format-date(current-date(), '[Y0001][M01][D01]')"/>
    </xsl:variable>
    <xsl:variable name="g_carNonTri"
    >de De des Des du Du l' L' le Le la La [la] [La] les Les un Un une Une
        die Die (die) (Die) das Das
        the The [the] [The]
        los Los las Las el El uno Uno una Una
        il Il gli Gli
    </xsl:variable>
    <xsl:template match="/">
        <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
                       xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <soap:Body>
                <ucp:updateRequest xmlns:srw="http://www.loc.gov/zing/srw/"
                                   xmlns:ucp="http://www.loc.gov/zing/srw/update/">
                    <srw:version>1.0</srw:version>
                    <ucp:action>info:srw/action/1/creaute</ucp:action>
                    <srw:recordIdentifier/>
                    <ucp:recordVersions>
                        <ucp:recordVersion>
                            <ucp:versionType>timestamp</ucp:versionType>
                            <ucp:versionValue>124578</ucp:versionValue>
                        </ucp:recordVersion>
                    </ucp:recordVersions>
                    <srw:record>
                        <srw:recordPacking>xml</srw:recordPacking>
                        <srw:recordSchema>info:srw/schema/1/marcxml-v1.1</srw:recordSchema>
                        <srw:recordData>
                            <xsl:apply-templates select="//srw:recordData"/>
                        </srw:recordData>
                    </srw:record>
                </ucp:updateRequest>
                <srw:extraRequestData>
                    <srw:authenticationToken>
                        <xsl:value-of select="$token"/>
                    </srw:authenticationToken>
                </srw:extraRequestData>
            </soap:Body>
        </soap:Envelope>
    </xsl:template>
    <xsl:template match="srw:recordData">
        <!--ERM le 24/06/20 -->
        <!--arbre1 : variable qui contient les zones non ordonnées-->
        <xsl:variable name="arbre1">
            <record>
                <!--ERM le 24/06/20 -->
                <!--devenu inutile -->
                <xsl:variable name="leaderDeb">
                    <xsl:value-of select="substring(mxc:record/mxc:leader, 1, 17)"/>
                </xsl:variable>
                <xsl:variable name="leaderFin">
                    <xsl:value-of select="substring(mxc:record/mxc:leader, 19)"/>
                </xsl:variable>
                <!--   <xsl:choose>
                    <xsl:when
                        test="mxc:record/mxc:datafield[substring(@tag, 1, 1) = '7'][mxc:subfield[@code = '3'][normalize-space(text()) != '']]">
                        <xsl:element name="leader">
                            <xsl:value-of select="concat($leaderDeb, '#', $leaderFin)"/>
                        </xsl:element>
                    </xsl:when>
                </xsl:choose>-->
                <xsl:variable name="leader09_008">
                    <xsl:call-template name="typeAut">
                        <xsl:with-param name="code" select="substring($leaderDeb, 10, 1)"/>
                    </xsl:call-template>
                </xsl:variable>
                <datafield tag="008">
                    <!--ind1=" " ind2=" "-->
                    <subfield code="a">
                        <xsl:value-of select="concat('T', $leader09_008, '5')"/>
                    </subfield>
                </datafield>
                <xsl:for-each select="//mxc:datafield[@tag = '010']">
                    <datafield ind1="#" ind2="#" tag="010">
                        <xsl:apply-templates select="mxc:subfield[@code = 'a']"/>
                        <xsl:choose>
                            <xsl:when test="mxc:subfield[@code = '2'] != 'ISNI'">
                                <subfield code="2">ISNI</subfield>
                                <subfield code="C">
                                    <xsl:value-of select="mxc:subfield[@code = '2']"/>
                                </subfield>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="mxc:subfield[@code = '2']"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:for-each select="mxc:subfield[string(@code) &gt; 'a']">
                            <xsl:sort order="ascending" select="string(@code)"/>
                            <xsl:apply-templates select="."/>
                        </xsl:for-each>
                    </datafield>
                </xsl:for-each>
                <xsl:call-template name="z033"/>
                <xsl:call-template name="z035"/>
                <xsl:apply-templates
                        select="mxc:record/mxc:controlfield[not(@tag = '001' or @tag = '003' or @tag = '005')]"/>
                <xsl:for-each select="//mxc:datafield[@tag = '101']">
                    <xsl:if test="string-length(normalize-space(mxc:subfield[@code = 'a'])) = 3">
                        <datafield ind1="#" ind2="#" tag="101">
                            <xsl:for-each select="mxc:subfield[@code = 'a']">
                                <xsl:variable name="z101a" select="normalize-space(.)"/>
                                <xsl:if test="string-length($z101a) = 3">
                                    <subfield code="a">
                                        <xsl:value-of select="$z101a"/>
                                    </subfield>
                                </xsl:if>
                            </xsl:for-each>
                        </datafield>
                    </xsl:if>
                </xsl:for-each>
                <!--ERM le 24/06/20 -->
                <!--devenu inutile avec le tri pos-traitement
             <xsl:apply-templates select="//mxc:datafield[@tag = '102']"/>-->
                <xsl:call-template name="z103"/>
                <xsl:call-template name="z106">
                    <xsl:with-param name="leader09_008" select="$leader09_008"/>
                </xsl:call-template>
                <xsl:for-each select="//mxc:datafield[@tag = '123']">
                    <datafield ind1="#" ind2="#" tag="123">
                        <xsl:for-each select="mxc:subfield">
                            <subfield>
                                <xsl:attribute name="code" select="@code"/>
                                <xsl:value-of select="lower-case(text())"/>
                            </subfield>
                        </xsl:for-each>
                    </datafield>
                </xsl:for-each>
                <xsl:for-each select="//mxc:datafield[@tag = '128']">
                    <xsl:choose>
                        <xsl:when
                                test="//mxc:datafield[@tag = '210']/mxc:subfield[@code = 'a'][text() != '']"/>
                        <xsl:when test="$leader09_008 = 'b'"/>
                        <xsl:otherwise>
                            <xsl:call-template name="z128"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
                <xsl:call-template name="z150"/>
                <xsl:for-each select="//mxc:datafield[@tag = '210']">
                    <xsl:call-template name="zX10">
                        <xsl:with-param name="zone" select="@tag"/>
                    </xsl:call-template>
                </xsl:for-each>
                <xsl:for-each select="//mxc:datafield[@tag = '230'] | //mxc:datafield[@tag = '240']">
                    <xsl:call-template name="zXXX">
                        <xsl:with-param name="zone" select="@tag"/>
                    </xsl:call-template>
                </xsl:for-each>
                <xsl:for-each select="//mxc:datafield[@tag = '330']">
                    <datafield ind1="0" ind2="#" tag="330">
                        <xsl:for-each select="mxc:subfield[@code = 'a']/tokenize(text(), '. -')">
                            <subfield code="a">
                                <xsl:value-of select="normalize-space(.)"/>
                            </subfield>
                        </xsl:for-each>
                    </datafield>
                </xsl:for-each>
                <!--ERM le 24/06/20 -->
                <!-- pour les zones qui commencent par : 30X / 34X / 35X / 36X
                    - celles qui n'ont que des $a, génèrent autant de zones 300$a (pour les 30X) ou 340$a (pour les 34X / 35X / 36X) que de chaines séparées par '. -'
                    - celles qui ont d'autre sous-zones concatènent les sous-zones Bnf dans : 300$a (pour les 30X) ou 340$a (pour les 34X / 35X / 36X)
                    -->
                <!--Pour les zones qui commencent par : 30X / 34X / 35X / 36X  -->
                <xsl:for-each
                        select="//mxc:datafield[starts-with(@tag, '30') and @tag != '305'] | //mxc:datafield[starts-with(@tag, '34')] | //mxc:datafield[starts-with(@tag, '35') and @tag != '356'] | //mxc:datafield[starts-with(@tag, '36')]">
                    <xsl:variable name="tagSource" select="@tag"/>
                    <xsl:variable name="tagDest">
                        <xsl:choose>
                            <xsl:when
                                    test="@tag = '300' or @tag = '303' or @tag = '349' or @tag = '353'"
                            >300</xsl:when>
                            <xsl:otherwise>340</xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when
                                test="@tag = '301' or @tag = '304' or @tag = '341' or @tag = '342' or @tag = '346' or @tag = '349' or @tag = '352' or @tag = '360' or @tag = '361'">
                            <!--diffrentes sous-zones à concatener dans 300$a  ou  340$a-->
                            <xsl:call-template name="z3XX">
                                <xsl:with-param name="tagSource" select="$tagSource"/>
                                <xsl:with-param name="tagDest" select="$tagDest"/>
                                <xsl:with-param name="mode" select="'concat'"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <!--seulement un ou plusieurs $a
                            ALORS pour chaque sous-zone $a, on découpe (séparateur '. -') pour faire une zone  300$a   ou  340$a-->
                            <xsl:for-each select="mxc:subfield[@code = 'a']">
                                <xsl:for-each select="tokenize(text(), '. -')">
                                    <xsl:call-template name="z3XX">
                                        <xsl:with-param name="tagSource" select="$tagSource"/>
                                        <xsl:with-param name="tagDest" select="$tagDest"/>
                                        <xsl:with-param name="mode" select="'tokenize'"/>
                                        <xsl:with-param name="libelle">
                                            <xsl:choose>
                                                <xsl:when test="$tagSource = '302'">
                                                    <xsl:text>Nationalité : </xsl:text>
                                                </xsl:when>
                                                <xsl:when test="$tagSource = '303'">
                                                    <xsl:text>Adresse : </xsl:text>
                                                </xsl:when>
                                                <xsl:when test="$tagSource = '307'">
                                                    <xsl:text>Composition du groupe : </xsl:text>
                                                </xsl:when>
                                                <xsl:when test="$tagSource = '343'">
                                                    <xsl:text>Profession annexe : </xsl:text>
                                                </xsl:when>
                                                <xsl:when test="$tagSource = '344'">
                                                    <xsl:text>Gamme des produits et services de la marque : </xsl:text>
                                                </xsl:when>
                                                <xsl:when test="$tagSource = '345'">
                                                    <xsl:text>Interventions : </xsl:text>
                                                </xsl:when>
                                                <xsl:when test="$tagSource = '347'">
                                                    <xsl:text>Titulature : </xsl:text>
                                                </xsl:when>
                                                <xsl:when test="$tagSource = '350'">
                                                    <xsl:text>Activité liée à la production artistique : </xsl:text>
                                                </xsl:when>
                                                <xsl:when test="$tagSource = '351'">
                                                    <xsl:text>Technique : </xsl:text>
                                                </xsl:when>
                                                <xsl:when test="$tagSource = '353'">
                                                    <xsl:text>Influence : </xsl:text>
                                                </xsl:when>
                                                <xsl:when test="$tagSource = '354'">
                                                    <xsl:text>Devise(s) : </xsl:text>
                                                </xsl:when>
                                                <xsl:otherwise/>
                                            </xsl:choose>
                                        </xsl:with-param>
                                    </xsl:call-template>
                                </xsl:for-each>
                            </xsl:for-each>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
                <xsl:for-each select="//mxc:datafield[@tag = '410']">
                    <xsl:call-template name="zX10">
                        <xsl:with-param name="zone" select="@tag"/>
                    </xsl:call-template>
                </xsl:for-each>
                <xsl:for-each select="//mxc:datafield[@tag = '430'] | //mxc:datafield[@tag = '440']">
                    <xsl:call-template name="zXXX">
                        <xsl:with-param name="zone" select="@tag"/>
                    </xsl:call-template>
                </xsl:for-each>
                <xsl:for-each select="//mxc:datafield[@tag = '510']">
                    <xsl:call-template name="zX10">
                        <xsl:with-param name="zone" select="@tag"/>
                    </xsl:call-template>
                </xsl:for-each>
                <xsl:for-each
                        select="//mxc:datafield[starts-with(@tag, '5') and (not(@tag = '510'))]">
                    <xsl:call-template name="zXXX">
                        <xsl:with-param name="zone" select="@tag"/>
                    </xsl:call-template>
                </xsl:for-each>
                <xsl:for-each select="//mxc:datafield[@tag = '710']">
                    <xsl:call-template name="zX10">
                        <xsl:with-param name="zone" select="@tag"/>
                    </xsl:call-template>
                </xsl:for-each>
                <xsl:for-each select="//mxc:datafield[@tag = '730'] | //mxc:datafield[@tag = '740']">
                    <xsl:call-template name="zXXX">
                        <xsl:with-param name="zone" select="@tag"/>
                    </xsl:call-template>
                </xsl:for-each>
                <xsl:for-each select="//mxc:datafield[@tag = '810']/mxc:subfield[@code = 'a']">
                    <xsl:call-template name="z810"/>
                </xsl:for-each>
                <datafield ind1="#" ind2="#" tag="899">
                    <xsl:variable name="dateJour2">
                        <xsl:value-of select="format-date(current-date(), '[D01]/[M01]/[Y0001]')"/>
                    </xsl:variable>
                    <subfield code="a">
                        <xsl:value-of
                                select="concat('Notice BnF dérivée via IdRef, le ', $dateJour2)"/>
                    </subfield>
                </datafield>
                <!--ERM le 24/06/20 -->
                <!--ancienne version des petits poissions qu'on ne laisse pas passer :
                    or @tag = '300' or @tag = '301' or @tag = '302' or @tag = '303' or @tag = '304' or @tag = '307'
                    or  @tag = '340' or @tag = '341' or @tag = '342' or @tag = '343' or @tag = '344' or @tag = '345' or @tag = '346' or @tag = '347' or @tag = '349'
                    or @tag = '351' or @tag = '352' or @tag = '353' or @tag = '354'
                    or @tag = '360' or @tag = '361' -->
                <xsl:apply-templates
                        select="mxc:record/mxc:datafield[not(@tag = '010' or @tag = '039' or @tag = '100' or @tag = '101' or @tag = '103' or @tag = '105' or @tag = '106' or @tag = '123' or @tag = '128' or @tag = '150' or @tag = '152' or @tag = '154' or @tag = '160' or @tag = '210' or @tag = '230' or @tag = '240' or (starts-with(@tag, '30') and @tag != '305') or @tag = '330' or starts-with(@tag, '34') or (starts-with(@tag, '35') and @tag != '356') or starts-with(@tag, '36') or @tag = '410' or @tag = '430' or @tag = '440' or @tag = '500' or @tag = '510' or @tag = '515' or @tag = '520' or @tag = '530' or @tag = '540' or @tag = '550' or @tag = '580' or @tag = '652' or @tag = '710' or @tag = '730' or @tag = '740' or @tag = '810')] | @*"
                />
            </record>
        </xsl:variable>
        <!--ERM le 24/06/20 -->
        <!-- arbre2 : variable qui contient la copie ordonnée des zones de arbre1-->
        <xsl:variable name="arbre2">
            <xsl:for-each select="$arbre1">
                <xsl:sort select="//datafield/@tag"/>
                <xsl:copy-of select="."/>
            </xsl:for-each>
        </xsl:variable>
        <!--ERM le 24/06/20 -->
        <!-- permet d'écrire le résultat-->
        <xsl:copy-of select="$arbre2"/>
    </xsl:template>
    <xsl:template name="zX10">
        <xsl:param name="zone"/>
        <xsl:variable name="ind1">
            <xsl:choose>
                <xsl:when
                        test="string-length(normalize-space(//mxc:datafield[@tag = '150']/mxc:subfield[@code = 'a'])) = 1">
                    <xsl:text>0</xsl:text>
                </xsl:when>
                <xsl:when
                        test="string-length(normalize-space(//mxc:datafield[@tag = '150']/mxc:subfield[@code = 'b'])) = 1">
                    <xsl:choose>
                        <xsl:when
                                test="normalize-space(//mxc:datafield[@tag = '150']/mxc:subfield[@code = 'b']) = '0'">
                            <xsl:text>0</xsl:text>
                        </xsl:when>
                        <xsl:when
                                test="normalize-space(//mxc:datafield[@tag = '150']/mxc:subfield[@code = 'b']) = '1'">
                            <xsl:text>1</xsl:text>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:when
                        test="mxc:subfield[@code = 'd'] != '' or mxc:subfield[@code = 'e'] != '' or mxc:subfield[@code = 'f'] != ''">
                    <xsl:text>1</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="0"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="ind2">
            <xsl:choose>
                <xsl:when test="@ind2 = ' ' or @ind2 = '|'">#</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@ind2"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <datafield ind1="{$ind1}" ind2="{$ind2}" tag="{$zone}">
            <xsl:call-template name="zX10_zXXX">
                <xsl:with-param name="zone" select="@tag"/>
            </xsl:call-template>
        </datafield>
    </xsl:template>
    <xsl:template name="z033">
        <xsl:variable name="date" select="current-date()"/>
        <datafield ind1="#" ind2="#" tag="033">
            <subfield code="a">
                <xsl:value-of select="normalize-space(//mxc:controlfield[@tag = '003'])"/>
            </subfield>
            <subfield code="2">BNF</subfield>
            <subfield code="d">
                <xsl:value-of select="format-date($date, '[Y0001][M01][D01]')"/>
            </subfield>
        </datafield>
    </xsl:template>
    <xsl:template name="z035">
        <datafield ind1="#" ind2="#" tag="035">
            <subfield code="a">
                <xsl:value-of select="normalize-space(//mxc:controlfield[@tag = '001'])"/>
            </subfield>
        </datafield>
    </xsl:template>
    <xsl:template name="typeAut">
        <xsl:param name="code"/>
        <xsl:variable name="rolemap">;a=p;b=b;c=g;d=m;e=a;f=u;h=q;j=d;l=f;j=z</xsl:variable>
        <xsl:value-of
                select="substring-before(substring-after($rolemap, concat(';', $code, '=')), ';')"/>
    </xsl:template>
    <xsl:template name="z103">
        <xsl:if test="//mxc:datafield[@tag = '103']">
            <xsl:variable name="z103a">
                <xsl:value-of select="//mxc:datafield[@tag = '103']/mxc:subfield[@code = 'a']"/>
            </xsl:variable>
            <xsl:variable name="z103b">
                <xsl:value-of select="//mxc:datafield[@tag = '103']/mxc:subfield[@code = 'b']"/>
            </xsl:variable>
            <xsl:variable name="z103_aDebut">
                <xsl:value-of select="substring($z103a, 1, 10)"/>
            </xsl:variable>
            <xsl:variable name="z103_aDebutDate">
                <xsl:analyze-string regex="[?Xx.]*[0-9]{{2,8}}[?Xx.]*"
                                    select="substring($z103a, 2, 8)">
                    <xsl:matching-substring>
                        <xsl:value-of select="substring($z103a, 2, 8)"/>
                    </xsl:matching-substring>
                    <!--<xsl:non-matching-substring>KO</xsl:non-matching-substring>-->
                </xsl:analyze-string>
            </xsl:variable>
            <xsl:variable name="z103_aFin">
                <xsl:value-of select="substring($z103a, 11, 10)"/>
            </xsl:variable>
            <xsl:variable name="z103_aFinDate">
                <xsl:analyze-string regex="[?Xx.]*[0-9]{{2,8}}[?Xx.]*"
                                    select="substring($z103a, 12, 8)">
                    <xsl:matching-substring>
                        <xsl:value-of select="substring($z103a, 12, 8)"/>
                    </xsl:matching-substring>
                    <!-- <xsl:non-matching-substring>KO</xsl:non-matching-substring>-->
                </xsl:analyze-string>
            </xsl:variable>
            <xsl:variable name="z103_bDebut">
                <xsl:value-of select="substring($z103b, 1, 6)"/>
            </xsl:variable>
            <xsl:variable name="z103_bDebutDate">
                <xsl:analyze-string regex="[?Xx.]*[0-9]{{2,8}}[?Xx.]*"
                                    select="substring($z103b, 2, 4)">
                    <xsl:matching-substring>
                        <xsl:value-of select="substring($z103b, 2, 4)"/>
                    </xsl:matching-substring>
                    <!--   <xsl:non-matching-substring>KO</xsl:non-matching-substring>-->
                </xsl:analyze-string>
            </xsl:variable>
            <xsl:variable name="z103_bFin">
                <xsl:value-of select="substring($z103b, 7, 6)"/>
            </xsl:variable>
            <xsl:variable name="z103_bFinDate">
                <xsl:analyze-string regex="[?Xx.]*[0-9]{{2,8}}[?Xx.]*"
                                    select="substring($z103b, 8, 4)">
                    <xsl:matching-substring>
                        <xsl:value-of select="substring($z103b, 8, 4)"/>
                    </xsl:matching-substring>
                    <!--<xsl:non-matching-substring>KO</xsl:non-matching-substring>-->
                </xsl:analyze-string>
            </xsl:variable>
            <!--  <xsl:comment>
           103$a : <xsl:value-of select="$z103a"/>
           103$b : <xsl:value-of select="$z103b"/>
           $z103_aDebutDate : <xsl:value-of select="$z103_aDebutDate"/>
           $z103_aFinDate : <xsl:value-of select="$z103_aFinDate"/>
           $z103_bDebutDate : <xsl:value-of select="$z103_bDebutDate"/>
           $z103_bFinDate  : <xsl:value-of select="$z103_bFinDate"/>
       </xsl:comment>-->
            <xsl:if
                    test="$z103_aDebutDate != '' or $z103_aFinDate != '' or $z103_bDebutDate != '' or $z103_bFinDate != ''">
                <datafield ind1="#" ind2="#" tag="103">
                    <!-- ERM  pour chaque sous zone ne pas laisser passer si contient espace -->
                    <xsl:analyze-string regex="[?Xx.]*[0-9]{{2,8}}[?Xx.]*" select="$z103_aDebutDate">
                        <xsl:matching-substring>
                            <subfield code="a">
                                <xsl:value-of select="normalize-space($z103_aDebut)"/>
                            </subfield>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                    <xsl:analyze-string regex="[?Xx.]*[0-9]{{2,8}}[?Xx.]*" select="$z103_aFinDate">
                        <xsl:matching-substring>
                            <subfield code="b">
                                <xsl:value-of select="normalize-space($z103_aFin)"/>
                            </subfield>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                    <xsl:analyze-string regex="[?Xx.]*[0-9]{{2,8}}[?Xx.]*" select="$z103_bDebutDate">
                        <xsl:matching-substring>
                            <subfield code="c">
                                <xsl:value-of select="normalize-space($z103_bDebut)"/>
                            </subfield>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                    <xsl:analyze-string regex="[?Xx.]*[0-9]{{2,8}}[?Xx.]*" select="$z103_bFinDate">
                        <xsl:matching-substring>
                            <subfield code="d">
                                <xsl:value-of select="normalize-space($z103_bFin)"/>
                            </subfield>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                </datafield>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <xsl:template name="z128">
        <xsl:variable name="z128a"
                      select="normalize-space(//mxc:datafield[@tag = '128']/mxc:subfield[@code = 'a'])"/>
        <xsl:variable name="z128b" select="//mxc:datafield[@tag = '128']/mxc:subfield[@code = 'b']"/>
        <xsl:variable name="z128c" select="//mxc:datafield[@tag = '128']/mxc:subfield[@code = 'c']"/>
        <xsl:if test="string-length($z128a) = 2">
            <datafield ind1="#" ind2="#" tag="128">
                <subfield code="a">
                    <xsl:value-of select="$z128a"/>
                </subfield>
                <xsl:if test="string-length($z128b) = 4">
                    <subfield code="b">
                        <xsl:value-of select="$z128b"/>
                    </subfield>
                </xsl:if>
                <xsl:if test="string-length($z128c) = 4">
                    <subfield code="c">
                        <xsl:value-of select="$z128c"/>
                    </subfield>
                </xsl:if>
            </datafield>
        </xsl:if>
    </xsl:template>
    <xsl:template name="z150">
        <xsl:variable name="z150a"
                      select="normalize-space(//mxc:datafield[@tag = '150']/mxc:subfield[@code = 'a'])"/>
        <xsl:variable name="z150b"
                      select="normalize-space(//mxc:datafield[@tag = '150']/mxc:subfield[@code = 'b'])"/>
        <xsl:if test="string-length($z150a) = 1 or string-length($z150b) = 1">
            <xsl:variable name="valeur150a" select="'abcdefghuyz'"/>
            <xsl:variable name="valeur150b" select="'01'"/>
            <datafield ind1="#" ind2="#" tag="150">
                <xsl:if test="string-length($z150a) = 1 and contains($valeur150a, $z150a)">
                    <subfield code="a">
                        <xsl:value-of select="$z150a"/>
                    </subfield>
                </xsl:if>
                <xsl:if test="string-length($z150b) = 1 and contains($valeur150b, $z150b)">
                    <subfield code="b">
                        <xsl:value-of select="$z150b"/>
                    </subfield>
                </xsl:if>
            </datafield>
        </xsl:if>
    </xsl:template>
    <xsl:template name="z106">
        <xsl:param name="leader09_008"/>
        <datafield ind1="#" ind2="#" tag="106">
            <xsl:variable name="z200szx"
                          select="normalize-space(//mxc:datafield[@tag = '200']/mxc:subfield[@code = 'x'])"/>
            <xsl:variable name="z200szy"
                          select="normalize-space(//mxc:datafield[@tag = '200']/mxc:subfield[@code = 'y'])"/>
            <xsl:variable name="z200szz"
                          select="normalize-space(//mxc:datafield[@tag = '200']/mxc:subfield[@code = 'z'])"/>
            <xsl:choose>
                <xsl:when
                        test="(substring(normalize-space(//mxc:datafield[@tag = '106']/mxc:subfield[@code = 'a']), 1, 1) != '') and $leader09_008 = 'p' and ((not(//mxc:datafield[@tag = '200']/mxc:subfield[@code = 'x']) or //mxc:datafield[@tag = '200']/mxc:subfield[@code = 'x'] = '') and (not(//mxc:datafield[@tag = '200']/mxc:subfield[@code = 'y']) or //mxc:datafield[@tag = '200']/mxc:subfield[@code = 'y'] = '') and (not(//mxc:datafield[@tag = '200']/mxc:subfield[@code = 'z']) or //mxc:datafield[@tag = '200']/mxc:subfield[@code = 'z'] = ''))">
                    <subfield code="a">0</subfield>
                    <subfield code="b">1</subfield>
                    <subfield code="c">0</subfield>
                </xsl:when>
                <xsl:otherwise>
                    <subfield code="a">
                        <xsl:choose>
                            <xsl:when
                                    test="substring(normalize-space(//mxc:datafield[@tag = '106']/mxc:subfield[@code = 'a']), 1, 1) != ''">
                                <xsl:value-of
                                        select="(substring(normalize-space(//mxc:datafield[@tag = '106']/mxc:subfield[@code = 'a']), 1, 1))"
                                />
                            </xsl:when>
                            <xsl:otherwise>#</xsl:otherwise>
                        </xsl:choose>
                    </subfield>
                    <subfield code="b">
                        <xsl:choose>
                            <xsl:when
                                    test="substring(normalize-space(//mxc:datafield[@tag = '106']/mxc:subfield[@code = 'a']), 2, 1) != ''">
                                <xsl:value-of
                                        select="substring(normalize-space(//mxc:datafield[@tag = '106']/mxc:subfield[@code = 'a']), 2, 1)"
                                />
                            </xsl:when>
                            <xsl:otherwise>#</xsl:otherwise>
                        </xsl:choose>
                    </subfield>
                    <subfield code="c">
                        <xsl:choose>
                            <xsl:when
                                    test="substring(normalize-space(//mxc:datafield[@tag = '106']/mxc:subfield[@code = 'a']), 3, 1) != ''">
                                <xsl:value-of
                                        select="substring(normalize-space(//mxc:datafield[@tag = '106']/mxc:subfield[@code = 'a']), 3, 1)"
                                />
                            </xsl:when>
                            <xsl:otherwise>#</xsl:otherwise>
                        </xsl:choose>
                    </subfield>
                </xsl:otherwise>
            </xsl:choose>
        </datafield>
    </xsl:template>
    <xsl:template name="z3XX">
        <xsl:param name="tagSource"/>
        <xsl:param name="tagDest"/>
        <xsl:param name="mode"/>
        <xsl:param name="libelle"/>
        <xsl:variable name="sza">
            <xsl:choose>
                <xsl:when test="$mode = 'tokenize'">
                    <xsl:value-of select="$libelle"/>
                    <xsl:value-of select="normalize-space(.)"/>
                </xsl:when>
                <xsl:when test="$mode = 'concat'">
                    <xsl:choose>
                        <xsl:when test="$tagSource = '301'">
                            <xsl:if test="mxc:subfield[@code = 'a'] != ''">
                                <xsl:text>Lieu de naissance : </xsl:text>
                                <xsl:call-template name="concatZ3XX">
                                    <xsl:with-param name="sousZone" select="'a'"/>
                                </xsl:call-template>
                            </xsl:if>
                            <xsl:if test="mxc:subfield[@code = 'b'] != ''">
                                <xsl:text>Lieu de décès : </xsl:text>
                                <xsl:call-template name="concatZ3XX">
                                    <xsl:with-param name="sousZone" select="'b'"/>
                                </xsl:call-template>
                            </xsl:if>
                        </xsl:when>
                        <xsl:when test="$tagSource = '304'">
                            <xsl:text>Note d'adresse des imprimeurs-libraires. </xsl:text>
                            <xsl:if test="mxc:subfield[@code = 'a'] != ''">
                                <xsl:text>Lieu d’activité : </xsl:text>
                                <xsl:call-template name="concatZ3XX">
                                    <xsl:with-param name="sousZone" select="'a'"/>
                                </xsl:call-template>
                            </xsl:if>
                            <xsl:if test="mxc:subfield[@code = 'd'] != ''">
                                <xsl:text>Dates d’activité : </xsl:text>
                                <xsl:call-template name="concatZ3XX">
                                    <xsl:with-param name="sousZone" select="'d'"/>
                                </xsl:call-template>
                            </xsl:if>
                            <xsl:if test="mxc:subfield[@code = 'l'] != ''">
                                <xsl:text>Adresse : </xsl:text>
                                <xsl:call-template name="concatZ3XX">
                                    <xsl:with-param name="sousZone" select="'l'"/>
                                </xsl:call-template>
                            </xsl:if>
                            <xsl:if test="mxc:subfield[@code = 'e'] != ''">
                                <xsl:text>Enseigne : </xsl:text>
                                <xsl:call-template name="concatZ3XX">
                                    <xsl:with-param name="sousZone" select="'e'"/>
                                </xsl:call-template>
                            </xsl:if>
                        </xsl:when>
                        <xsl:when test="$tagSource = '341'">
                            <xsl:text>Note d'activité des imprimeurs-libraires, marchands d'estampes ou relieurs. </xsl:text>
                            <xsl:if test="mxc:subfield[@code = 'a'] != ''">
                                <xsl:text>Ville d’activité : </xsl:text>
                                <xsl:call-template name="concatZ3XX">
                                    <xsl:with-param name="sousZone" select="'a'"/>
                                </xsl:call-template>
                            </xsl:if>
                            <xsl:if test="mxc:subfield[@code = 'b'] != ''">
                                <xsl:text>Dates d’activité : </xsl:text>
                                <xsl:call-template name="concatZ3XX">
                                    <xsl:with-param name="sousZone" select="'b'"/>
                                </xsl:call-template>
                            </xsl:if>
                            <xsl:if test="mxc:subfield[@code = 'c'] != ''">
                                <xsl:text>Adresse : </xsl:text>
                                <xsl:call-template name="concatZ3XX">
                                    <xsl:with-param name="sousZone" select="'c'"/>
                                </xsl:call-template>
                            </xsl:if>
                            <xsl:if test="mxc:subfield[@code = 'd'] != ''">
                                <xsl:text>Enseigne : </xsl:text>
                                <xsl:call-template name="concatZ3XX">
                                    <xsl:with-param name="sousZone" select="'d'"/>
                                </xsl:call-template>
                            </xsl:if>
                        </xsl:when>
                        <xsl:when test="$tagSource = '342'">
                            <xsl:if test="mxc:subfield[@code = 'a'] != ''">
                                <xsl:text>Voyages : </xsl:text>
                                <xsl:call-template name="concatZ3XX">
                                    <xsl:with-param name="sousZone" select="'a'"/>
                                </xsl:call-template>
                            </xsl:if>
                            <xsl:if test="mxc:subfield[@code = 'b'] != ''">
                                <xsl:text>Date : </xsl:text>
                                <xsl:call-template name="concatZ3XX">
                                    <xsl:with-param name="sousZone" select="'b'"/>
                                </xsl:call-template>
                            </xsl:if>
                        </xsl:when>
                        <xsl:when test="$tagSource = '346'">
                            <xsl:if test="mxc:subfield[@code = 'a'] != ''">
                                <xsl:text>Distinctions : </xsl:text>
                                <xsl:call-template name="concatZ3XX">
                                    <xsl:with-param name="sousZone" select="'a'"/>
                                </xsl:call-template>
                            </xsl:if>
                            <xsl:if test="mxc:subfield[@code = 'b'] != ''">
                                <xsl:text>Date : </xsl:text>
                                <xsl:call-template name="concatZ3XX">
                                    <xsl:with-param name="sousZone" select="'b'"/>
                                </xsl:call-template>
                            </xsl:if>
                        </xsl:when>
                        <xsl:when test="$tagSource = '349'">
                            <xsl:if test="mxc:subfield[@code = 'r'] != ''">
                                <xsl:text>Nature de la date ou des dates : </xsl:text>
                                <xsl:call-template name="concatZ3XX">
                                    <xsl:with-param name="sousZone" select="'r'"/>
                                </xsl:call-template>
                            </xsl:if>
                            <xsl:if test="mxc:subfield[@code = 'p'] != ''">
                                <xsl:text>Pays : </xsl:text>
                                <xsl:call-template name="concatZ3XX">
                                    <xsl:with-param name="sousZone" select="'p'"/>
                                </xsl:call-template>
                            </xsl:if>
                            <xsl:if test="mxc:subfield[@code = 'a'] != ''">
                                <xsl:text>Ville : </xsl:text>
                                <xsl:call-template name="concatZ3XX">
                                    <xsl:with-param name="sousZone" select="'a'"/>
                                </xsl:call-template>
                            </xsl:if>
                            <xsl:if test="mxc:subfield[@code = 'c'] != ''">
                                <xsl:text>Lieu : </xsl:text>
                                <xsl:call-template name="concatZ3XX">
                                    <xsl:with-param name="sousZone" select="'c'"/>
                                </xsl:call-template>
                            </xsl:if>
                            <xsl:if test="mxc:subfield[@code = 'd'] != ''">
                                <xsl:text>Date ou date de début : </xsl:text>
                                <xsl:call-template name="concatZ3XX">
                                    <xsl:with-param name="sousZone" select="'d'"/>
                                </xsl:call-template>
                            </xsl:if>
                            <xsl:if test="mxc:subfield[@code = 'e'] != ''">
                                <xsl:text>Date de fin : </xsl:text>
                                <xsl:call-template name="concatZ3XX">
                                    <xsl:with-param name="sousZone" select="'e'"/>
                                </xsl:call-template>
                            </xsl:if>
                            <xsl:if test="mxc:subfield[@code = 't'] != ''">
                                <xsl:text>Complément d’information : </xsl:text>
                                <xsl:call-template name="concatZ3XX">
                                    <xsl:with-param name="sousZone" select="'t'"/>
                                </xsl:call-template>
                            </xsl:if>
                        </xsl:when>
                        <xsl:when test="$tagSource = '352'">
                            <xsl:if test="mxc:subfield[@code = 'a'] != ''">
                                <xsl:text>Typologie de production : </xsl:text>
                                <xsl:call-template name="concatZ3XX">
                                    <xsl:with-param name="sousZone" select="'a'"/>
                                </xsl:call-template>
                            </xsl:if>
                            <xsl:if test="mxc:subfield[@code = 'g'] != ''">
                                <xsl:text>Genre de production : </xsl:text>
                                <xsl:call-template name="concatZ3XX">
                                    <xsl:with-param name="sousZone" select="'g'"/>
                                </xsl:call-template>
                            </xsl:if>
                        </xsl:when>
                        <xsl:when test="$tagSource = '360'">
                            <xsl:if test="mxc:subfield[@code = 'a'] != ''">
                                <xsl:text>Salon : </xsl:text>
                                <xsl:call-template name="concatZ3XX">
                                    <xsl:with-param name="sousZone" select="'a'"/>
                                </xsl:call-template>
                            </xsl:if>
                            <xsl:if test="mxc:subfield[@code = 'b'] != ''">
                                <!--  <xsl:text>Sous-vedette : </xsl:text>-->
                                <xsl:call-template name="concatZ3XX">
                                    <xsl:with-param name="sousZone" select="'b'"/>
                                </xsl:call-template>
                            </xsl:if>
                            <xsl:if test="mxc:subfield[@code = 'c'] != ''">
                                <xsl:text>Lieu : </xsl:text>
                                <xsl:call-template name="concatZ3XX">
                                    <xsl:with-param name="sousZone" select="'c'"/>
                                </xsl:call-template>
                            </xsl:if>
                            <xsl:if test="mxc:subfield[@code = 'd'] != ''">
                                <xsl:text>Numéro du salon : </xsl:text>
                                <xsl:call-template name="concatZ3XX">
                                    <xsl:with-param name="sousZone" select="'d'"/>
                                </xsl:call-template>
                            </xsl:if>
                            <xsl:if test="mxc:subfield[@code = 'e'] != ''">
                                <xsl:text>Lieu du salon : </xsl:text>
                                <xsl:call-template name="concatZ3XX">
                                    <xsl:with-param name="sousZone" select="'e'"/>
                                </xsl:call-template>
                            </xsl:if>
                            <xsl:if test="mxc:subfield[@code = 'f'] != ''">
                                <xsl:text>Dates du salon : </xsl:text>
                                <xsl:call-template name="concatZ3XX">
                                    <xsl:with-param name="sousZone" select="'f'"/>
                                </xsl:call-template>
                            </xsl:if>
                            <xsl:if test="mxc:subfield[@code = 't'] != ''">
                                <xsl:text>Titre : </xsl:text>
                                <xsl:call-template name="concatZ3XX">
                                    <xsl:with-param name="sousZone" select="'t'"/>
                                </xsl:call-template>
                            </xsl:if>
                        </xsl:when>
                        <xsl:when test="$tagSource = '361'">
                            <xsl:if test="mxc:subfield[@code = 'a'] != ''">
                                <xsl:text>Lieu d’exposition : </xsl:text>
                                <xsl:call-template name="concatZ3XX">
                                    <xsl:with-param name="sousZone" select="'a'"/>
                                </xsl:call-template>
                            </xsl:if>
                            <xsl:if test="mxc:subfield[@code = 'n'] != ''">
                                <xsl:text>Établissement précisant le lieu : </xsl:text>
                                <xsl:call-template name="concatZ3XX">
                                    <xsl:with-param name="sousZone" select="'n'"/>
                                </xsl:call-template>
                            </xsl:if>
                            <xsl:if test="mxc:subfield[@code = 'f'] != ''">
                                <xsl:text>Année de l’exposition : </xsl:text>
                                <xsl:call-template name="concatZ3XX">
                                    <xsl:with-param name="sousZone" select="'f'"/>
                                </xsl:call-template>
                            </xsl:if>
                            <xsl:if test="mxc:subfield[@code = 't'] != ''">
                                <xsl:text>Titre : </xsl:text>
                                <xsl:call-template name="concatZ3XX">
                                    <xsl:with-param name="sousZone" select="'t'"/>
                                </xsl:call-template>
                            </xsl:if>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <datafield ind1="#" ind2="#" tag="{$tagDest}">
            <subfield code="a">
                <xsl:value-of select="normalize-space($sza)"/>
            </subfield>
        </datafield>
    </xsl:template>
    <xsl:template name="concatZ3XX">
        <xsl:param name="sousZone"/>
        <xsl:for-each select="mxc:subfield[@code = $sousZone][text() != '']">
            <xsl:variable name="posSsz" select="position()"/>
            <xsl:variable name="posSsz_last" select="last()"/>
            <xsl:for-each select="tokenize(text(), '. -')">
                <xsl:value-of select="normalize-space(.)"/>
                <xsl:variable name="posMorceau" select="position()"/>
                <xsl:variable name="posMorceau_last" select="last()"/>
                <xsl:choose>
                    <xsl:when test="$posMorceau != $posMorceau_last or $posSsz != $posSsz_last">
                        <xsl:text> / </xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>. </xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="zXXX">
        <xsl:param name="zone"/>
        <datafield ind1="#" ind2="#" tag="{$zone}">
            <xsl:call-template name="zX10_zXXX">
                <xsl:with-param name="zone" select="@tag"/>
            </xsl:call-template>
        </datafield>
    </xsl:template>
    <xsl:template name="zX10_zXXX">
        <xsl:param name="zone"/>
        <xsl:for-each select="mxc:subfield[(string(@code) &lt; 'a') and (@code != '3')]">
            <xsl:sort order="ascending" select="number(@code)"/>
            <xsl:choose>
                <xsl:when test="starts-with($zone, '5')">
                    <xsl:apply-templates select=".[not(@code = '9')]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        <xsl:for-each select="mxc:subfield[@code = '3']">
            <subfield code="Q">
                <xsl:value-of select="."/>
            </subfield>
        </xsl:for-each>
        <xsl:for-each select="mxc:subfield[string(@code) &gt;= 'a']">
            <xsl:sort order="ascending" select="string(@code)"/>
            <xsl:choose>
                <xsl:when test="ends-with($zone, '40')">
                    <xsl:choose>
                        <xsl:when test=".[@code = 'a'] != ''">
                            <subfield code="a">
                                <xsl:value-of select="normalize-space(text())"/>
                                <xsl:if
                                        test="./parent::mxc:datafield/mxc:subfield[@code = 'b'] != ''">
                                    <xsl:value-of
                                            select="concat(', ', ./parent::mxc:datafield/mxc:subfield[@code = 'b'])"
                                    />
                                </xsl:if>
                                <xsl:variable name="ssz240a" select="'c, d, e, f'"/>
                                <xsl:if
                                        test="./parent::mxc:datafield/mxc:subfield[contains($ssz240a, @code)][text() != '']">
                                    <xsl:text> (</xsl:text>
                                </xsl:if>
                                <xsl:for-each
                                        select="./parent::mxc:datafield/mxc:subfield[contains($ssz240a, @code)][text() != '']">
                                    <xsl:choose>
                                        <xsl:when test="position() != 1">
                                            <xsl:text>, </xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise/>
                                    </xsl:choose>
                                    <xsl:value-of select="."/>
                                </xsl:for-each>
                                <xsl:if
                                        test="./parent::mxc:datafield/mxc:subfield[contains($ssz240a, @code)][text() != '']">
                                    <xsl:text>)</xsl:text>
                                </xsl:if>
                            </subfield>
                        </xsl:when>
                        <xsl:when test=".[@code = 't'] != ''">
                            <xsl:variable name="zoneATrier"
                                          select="translate(.[@code = 't'], '[]', '')"/>
                            <subfield code="t">
                                <xsl:call-template name="nonTri">
                                    <xsl:with-param name="in_ZoneATrier" select="$zoneATrier"/>
                                </xsl:call-template>
                                <xsl:variable name="ssz240t" select="'h, i, n, k, l m, q, r, s, u'"/>
                                <xsl:for-each
                                        select="./parent::mxc:datafield/mxc:subfield[contains($ssz240t, @code)][text() != '']">
                                    <xsl:text>. </xsl:text>
                                    <xsl:value-of select="."/>
                                </xsl:for-each>
                            </subfield>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates
                                    select=".[@code = 'x' or @code = 'y' or @code = 'z']"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when
                        test="(ends-with($zone, '10') or ends-with($zone, '30')) and .[@code = 'a'] != ''">
                    <subfield code="a">
                        <xsl:call-template name="nonTri">
                            <xsl:with-param name="in_ZoneATrier" select="normalize-space(text())"/>
                        </xsl:call-template>
                    </subfield>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="z810">
        <datafield ind1="#" ind2="#" tag="810">
            <subfield code="a">
                <xsl:value-of select="."/>
            </subfield>
        </datafield>
    </xsl:template>
    <xsl:template match="mxc:subfield[@code = '5']">
        <xsl:variable name="zoneTableau">200;400;500;510;516;520;700</xsl:variable>
        <xsl:variable name="zoneTableauXX">4XX;5XX</xsl:variable>
        <xsl:variable name="sz5">
            <xsl:choose>
                <xsl:when test="lower-case(normalize-space(.)) = 'xxz'">z</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="lower-case(normalize-space(.))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="nbCaraInitial" select="string-length($sz5)"/>
        <xsl:variable name="sz5_ssX" select="replace($sz5, 'x', '')"/>
        <xsl:variable name="nbCara_ssX" select="string-length($sz5_ssX)"/>
        <xsl:variable name="zone">
            <xsl:value-of select="./parent::mxc:datafield/@tag"/>
        </xsl:variable>
        <xsl:variable name="zoneXX" select="concat(substring($zone, 1, 1), 'XX')"/>
        <!--    <xsl:comment>
        template match
    sz5 =  <xsl:value-of select="$sz5"/>
    zone = <xsl:value-of select="$zone"/>
    nb cara <xsl:value-of select="$nbCaraInitial"/>
    nb cara sans X <xsl:value-of select="$nbCara_ssX"/>
    </xsl:comment>-->
        <xsl:choose>
            <xsl:when test="$nbCara_ssX = 1">
                <!-- <xsl:comment>
                     1 cara signifiant OK
                 </xsl:comment>-->
                <xsl:variable name="code1cara">
                    <xsl:choose>
                        <xsl:when test="$nbCaraInitial = 1">
                            <xsl:value-of select="$sz5"/>
                        </xsl:when>
                        <xsl:otherwise/>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="code3cara">
                    <xsl:choose>
                        <xsl:when test="$nbCaraInitial != 1">
                            <xsl:value-of select="concat('xx', $sz5_ssX)"/>
                        </xsl:when>
                        <xsl:otherwise/>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="code1erTour">
                    <xsl:choose>
                        <xsl:when test="$code1cara != ''">
                            <xsl:value-of select="$code1cara"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$code3cara"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="contains($zoneTableau, $zone)">
                        <!--<xsl:comment>
                            la zone <xsl:value-of select="$zone"/> est dans le tableau
                        </xsl:comment>-->
                        <xsl:call-template name="tableau">
                            <xsl:with-param name="zone" select="$zone"/>
                            <xsl:with-param name="sz5" select="$code1erTour"/>
                            <xsl:with-param name="sz5Initial" select="$sz5"/>
                            <xsl:with-param name="nbCaraInitial" select="$nbCaraInitial"/>
                            <xsl:with-param name="generique" select="'non'"/>
                            <xsl:with-param name="fin" select="'non'"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="contains($zoneTableauXX, $zoneXX)">
                        <!-- <xsl:comment>
                             la zone <xsl:value-of select="$zone"/> n'est pas dans le tableau
                             on passe au générique zoneXX
                         </xsl:comment>-->
                        <xsl:call-template name="tableau">
                            <xsl:with-param name="zone" select="$zoneXX"/>
                            <xsl:with-param name="sz5" select="$code1erTour"/>
                            <xsl:with-param name="sz5Initial" select="$sz5"/>
                            <xsl:with-param name="nbCaraInitial" select="$nbCaraInitial"/>
                            <xsl:with-param name="generique" select="'oui'"/>
                            <xsl:with-param name="fin" select="'non'"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <!--  <xsl:comment> plus d'1 cara diff de x == retoqué  </xsl:comment>-->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="tableau">
        <xsl:param name="sz5"/>
        <xsl:param name="sz5Initial"/>
        <xsl:param name="nbCaraInitial"/>
        <xsl:param name="zone"/>
        <xsl:param name="generique"/>
        <xsl:param name="fin"/>
        <!--<xsl:comment>
            template tableau
        sz5 =  <xsl:value-of select="$sz5"/>
        zone = <xsl:value-of select="$zone"/>
        sz5Initial  <xsl:value-of select="$sz5Initial"/>
        nb cara initial<xsl:value-of select="$nbCaraInitial"/>
       generique  <xsl:value-of select="$generique"/>
        fin <xsl:value-of select="$fin"/>
        </xsl:comment>-->
        <xsl:choose>
            <xsl:when
                    test="($zone = '200' and ($sz5 = 'e' or $sz5 = 'f' or $sz5 = 'i' or $sz5 = 'j' or $sz5 = 'k' or $sz5 = 'l')) or ($zone = '400' and ($sz5 = 'e' or $sz5 = 'f' or $sz5 = 'i' or $sz5 = 'j' or $sz5 = 'k' or $sz5 = 'l')) or ($zone = '500' and ($sz5 = 'xxc' or $sz5 = 'xxd' or $sz5 = 'e' or $sz5 = 'xxe' or $sz5 = 'f' or $sz5 = 'xxg' or $sz5 = 'xxh' or $sz5 = 'i' or $sz5 = 'j' or $sz5 = 'xxj' or $sz5 = 'k' or $sz5 = 'l' or $sz5 = 'xxl' or $sz5 = 'n' or $sz5 = 'xxt')) or ($zone = '510' and ($sz5 = 'xxk' or $sz5 = 'xxl' or $sz5 = 'xxm' or $sz5 = 'xxn' or $sz5 = 'xxp' or $sz5 = 'xxq' or $sz5 = 'r' or $sz5 = 's' or $sz5 = 'xxs' or $sz5 = 'xxt')) or ($zone = '516' and ($sz5 = 'xxm' or $sz5 = 'xxs')) or ($zone = '520' and ($sz5 = 'xxm' or $sz5 = 'xxn' or $sz5 = 'xxt')) or ($zone = '4XX' and ($sz5 = 'a' or $sz5 = 'b' or $sz5 = 'u' or $sz5 = 'z')) or ($zone = '5XX' and ($sz5 = 'a' or $sz5 = 'b' or $sz5 = 'g' or $sz5 = 'h' or $sz5 = 'u' or $sz5 = 'z'))">
                <subfield code="5">
                    <xsl:value-of select="$sz5"/>
                </subfield>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$nbCaraInitial = 1 and $fin = 'non'">
                        <!--<xsl:comment>
                            code 1 cara KO , on refait un tour en ajoutant des XX
                          </xsl:comment>-->
                        <xsl:call-template name="tableau">
                            <xsl:with-param name="zone" select="$zone"/>
                            <xsl:with-param name="sz5" select="concat('xx', $sz5)"/>
                            <xsl:with-param name="sz5Initial" select="$sz5Initial"></xsl:with-param>
                            <xsl:with-param name="nbCaraInitial" select="$nbCaraInitial"/>
                            <xsl:with-param name="fin" select="'oui'"/>
                            <xsl:with-param name="generique" select="$generique"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$nbCaraInitial != 1 and $fin = 'non'">
                        <!-- <xsl:comment>
                             code 3 cara KO on refait un tour en ajoutant supprimant ne prenant que le cara signifiant
                         </xsl:comment>-->
                        <xsl:call-template name="tableau">
                            <xsl:with-param name="zone" select="$zone"/>
                            <xsl:with-param name="sz5" select="replace($sz5, 'x', '')"/>
                            <xsl:with-param name="sz5Initial" select="$sz5Initial"></xsl:with-param>
                            <xsl:with-param name="nbCaraInitial" select="$nbCaraInitial"/>
                            <xsl:with-param name="fin" select="'oui'"/>
                            <xsl:with-param name="generique" select="$generique"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$fin = 'oui' and $generique = 'non'">
                        <!--<xsl:comment>
                            2 tour sur zone initiale on passe à la zone générique
                        </xsl:comment>-->
                        <xsl:call-template name="tableau">
                            <xsl:with-param name="zone"
                                            select="concat(substring($zone, 1, 1), 'XX')"/>
                            <xsl:with-param name="sz5">
                                <xsl:choose>
                                    <xsl:when test="$nbCaraInitial = 1"><xsl:value-of select="$sz5Initial"/></xsl:when>
                                    <xsl:otherwise><xsl:value-of select="concat('xx',replace($sz5, 'x', ''))"></xsl:value-of></xsl:otherwise>
                                </xsl:choose>
                            </xsl:with-param>
                            <xsl:with-param name="sz5Initial" select="$sz5Initial"></xsl:with-param>
                            <xsl:with-param name="nbCaraInitial" select="$nbCaraInitial"/>
                            <xsl:with-param name="fin" select="'non'"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="mxc:subfield[@code = '7']">
        <!-- ERM le 11/09/20 on tue la $7 faute de $6-->
        <!-- <xsl:choose>
            <xsl:when test="text() = 'ba0yba0y'"/>
            <xsl:otherwise>
                <subfield code="7">
                    <xsl:value-of select="substring(., 1, 2)"/>
                </subfield>
            </xsl:otherwise>
        </xsl:choose>-->
    </xsl:template>
    <xsl:template match="mxc:subfield[@code = '8']">
        <xsl:choose>
            <xsl:when test="./parent::mxc:datafield[starts-with(@tag, '5')] or text() = 'frefre' or text() = 'fre   ' or text() = 'fre ' or contains(.,'|||')"/>
            <xsl:otherwise>
                <subfield code="8">
                    <xsl:value-of select="."/>
                </subfield>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="mxc:subfield[@code = '9']">
        <xsl:choose>
            <xsl:when test="./parent::mxc:datafield[starts-with(@tag, '5')]"/>
            <xsl:otherwise>
                <xsl:variable name="sz9pos1">
                    <xsl:choose>
                        <xsl:when test="normalize-space(substring(text(), 2, 1)) != ''">
                            <xsl:value-of select="substring(text(), 2, 1)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>#</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="sz9pos2"
                              select="substring(preceding-sibling::mxc:subfield[@code = '7'], 8, 1)"/>
                <xsl:variable name="sz9">
                    <xsl:value-of select="concat($sz9pos1, $sz9pos2)"/>
                </xsl:variable>
                <xsl:if test="string-length($sz9) = 2">
                    <subfield code="9">
                        <xsl:value-of select="concat($sz9pos1, $sz9pos2)"/>
                    </subfield>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="nonTri">
        <xsl:param name="in_ZoneATrier"/>
        <!-- Recherche du premier mot in_ZoneATrier
     et identification de ce mot avec un article
     rappel : séparateur de l'article dans un groupe nominal = espace ou apostrophe
     algorithme :
       1 ) séparation par l'espace de
            "Raison", "Une brève ..." , "l'archiduc ...", "l'archiduchesse"
            doit retourner respectivement
            "Raison", "Une" , "l'archiduc" et "l'archiduchesse".
       2 ) séparation par l'apostrophe de
            "Raison", "Une" , "l'archiduc" et "l'archiduchesse"
            doit retourner respectivement
            "Raison", "Une" , "l'" et "l'".
       3 ) identification du premier mot avec un article
   -->
        <xsl:variable name="SepareParEspace">
            <xsl:choose>
                <xsl:when test="contains($in_ZoneATrier, ' ')">
                    <xsl:value-of select="substring-before($in_ZoneATrier, ' ')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$in_ZoneATrier"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="SepareParEspaceEtApostrophe">
            <xsl:choose>
                <xsl:when test="contains($SepareParEspace, &quot;'&quot;)">
                    <!-- je réattache l'apostrophe -->
                    <xsl:value-of
                            select="concat(substring-before($SepareParEspace, &quot;'&quot;), &quot;'&quot;)"
                    />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$SepareParEspace"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="contains($g_carNonTri, $SepareParEspaceEtApostrophe)">
                <!--<xsl:text disable-output-escaping="yes">@</xsl:text>-->
                <xsl:value-of select="$SepareParEspaceEtApostrophe"/>
                <!-- <xsl:text> </xsl:text> -->
                <xsl:choose>
                    <xsl:when
                            test="substring(substring-after($in_ZoneATrier, $SepareParEspaceEtApostrophe), 1, 1) = ' '">
                        <xsl:text> </xsl:text>
                        <xsl:text>@</xsl:text>
                        <xsl:value-of
                                select="substring-after(substring-after($in_ZoneATrier, $SepareParEspaceEtApostrophe), ' ')"
                        />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>@</xsl:text>
                        <xsl:value-of
                                select="substring-after($in_ZoneATrier, $SepareParEspaceEtApostrophe)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text disable-output-escaping="yes">@</xsl:text>
                <xsl:value-of select="$in_ZoneATrier"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- tester les différentes methodes dans Oracle pour voir-->
    <!-- méthode 0-->
    <xsl:template match="*">
        <!-- retire xmlns des éléments -->
        <xsl:element name="{local-name()}">
            <!-- attributs -->
            <xsl:for-each select="@*">
                <!-- retire xmlns des attributs -->
                <xsl:attribute name="{local-name()}">
                    <xsl:choose>
                        <xsl:when test="name() = 'ind1' or name() = 'ind2'">
                            <xsl:choose>
                                <xsl:when test=". = ' ' or . = '|'">#</xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="."/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="."/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </xsl:for-each>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <!--
    <!-\- méthode 1-\->
    <xsl:template match="*">
        <!-\- retire xmlns des éléments -\->
        <xsl:element name="{local-name()}">
            <!-\- attributs -\->
            <xsl:for-each select="@*">
                <!-\- retire xmlns des attributs -\->
                <xsl:attribute name="{local-name()}">
                    <xsl:value-of select="."/>
                </xsl:attribute>
            </xsl:for-each>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <!-\- <!-\\- méthode 2-\\->
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>

    <!-\\- Copie de l'élément sans xmlns = local-name() -\\->
    <xsl:template match="*">
        <xsl:element name="{local-name()}">
            <xsl:apply-templates select="node() | @*"/>
        </xsl:element>
    </xsl:template>-\->
    -->
</xsl:stylesheet>
