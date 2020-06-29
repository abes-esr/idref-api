<?xml version="1.0" encoding="UTF-8"?>
<!--     XSL de transformation du marcXml Bnf en marcXml Sudoc. (ERM créé 2020)
    Objectifs : rendre conforme au marcXml Sudoc : 
    v 20200625
  -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:srw="http://www.loc.gov/zing/srw/"
    xmlns:mxc="info:lc/xmlns/marcxchange-v2" version="2.0" exclude-result-prefixes="srw mxc xsi xs">
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    <xsl:param name="token"/>
    <xsl:strip-space elements="*"/>
    <xsl:variable name="g_carNonTri"
        >de De des Des du Du l' L' le Le la La [la] [La] les Les un Un une Une
        die Die (die) (Die) das Das
        the The [the] [The]
        los Los las Las el El uno Uno una Una
        il Il gli Gli
    </xsl:variable>
    <xsl:template match="/">
        <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xmlns:xsd="http://www.w3.org/2001/XMLSchema"
            xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
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
                <srw:extraRequestData><srw:authenticationToken> <xsl:value-of select="$token" /></srw:authenticationToken></srw:extraRequestData>
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
                    <datafield tag="010" ind1="#" ind2="#">
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
                            <xsl:sort select="string(@code)" order="ascending"/>
                            <xsl:apply-templates select="."/>
                        </xsl:for-each>
                    </datafield>
                </xsl:for-each>
                <xsl:call-template name="z033"/>
                <xsl:call-template name="z035"/>
                <xsl:apply-templates
                    select="mxc:record/mxc:controlfield[not(@tag = '001' or @tag = '003' or @tag = '005')]"/>
                <xsl:for-each select="//mxc:datafield[@tag = '101']">
                    <datafield tag="101" ind1="#" ind2="#">
                        <xsl:apply-templates/>
                    </datafield>
                </xsl:for-each>
                <!--ERM le 24/06/20 -->
                <!--devenu inutile avec le tri pos-traitement 
             <xsl:apply-templates select="//mxc:datafield[@tag = '102']"/>-->
                <xsl:call-template name="z103"/>
                <xsl:call-template name="z106">
                    <xsl:with-param name="leader09_008" select="$leader09_008"/>
                </xsl:call-template>
                <xsl:for-each select="//mxc:datafield[@tag = '123']">
                    <datafield tag="123" ind1="#" ind2="#">
                        <xsl:for-each select="mxc:subfield">
                            <subfield>
                                <xsl:attribute name="code" select="@code"/>
                                <xsl:value-of select="lower-case(text())"/>
                            </subfield>
                        </xsl:for-each>
                    </datafield>
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
                <!--ERM le 24/06/20 -->
                <!-- pour les zones qui commencent par : 30X / 34X / 35X / 36X
                    - celles qui n'ont que des $a, génèrent autant de zones 300$a (pour les 30X) ou 340$a (pour les 34X / 35X / 36X) que de chaines séparées par '. -'
                    - celles qui ont d'autre sous-zones concatènent les sous-zones Bnf dans : 300$a (pour les 30X) ou 340$a (pour les 34X / 35X / 36X) 
                    -->
                <!--Pour les zones qui commencent par : 30X / 34X / 35X / 36X  -->
                <xsl:for-each
                    select="//mxc:datafield[starts-with(@tag, '30') and @tag != '305'] | //mxc:datafield[starts-with(@tag, '34')] | //mxc:datafield[starts-with(@tag, '35')] | //mxc:datafield[starts-with(@tag, '36')]">
                    <xsl:variable name="tagSource" select="@tag"/>
                    <xsl:variable name="tagDest">
                        <xsl:choose>
                            <xsl:when test="starts-with(@tag, '30')">300</xsl:when>
                            <xsl:otherwise>340</xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="not(mxc:subfield[@code > 'a'])">
                            <!--SI pas d'autre sous-zone qu'un $a
                            ALORS pour chaque sous-zone $a, on découpe (séparateur '. -') pour faire une zone : 
		- (si zone de départ 30X ->) 300$a   
		- (si zone de départ 34X / 35X / 36X   ->) 340$a   -->
                            <xsl:for-each select="mxc:subfield[@code = 'a']">
                                <xsl:for-each select="tokenize(text(), '. -')">
                                    <xsl:call-template name="z3XX">
                                        <xsl:with-param name="tagSource" select="$tagSource"/>
                                        <xsl:with-param name="tagDest" select="$tagDest"/>
                                        <xsl:with-param name="mode" select="'tokenize'"/>
                                    </xsl:call-template>
                                </xsl:for-each>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <!--SINON (ie s'il y a au moins une sous-zone autre que $a) on concatène dans :
                            - (si zone de départ 30X ->) 300$a   
		- (si zone de départ 34X / 35X / 36X   ->) 340$a   
		ex : Lieu de naissance : $a Bnf. Lieu de mort : $b Bnf -->
                            <xsl:call-template name="z3XX">
                                <xsl:with-param name="tagSource" select="$tagSource"/>
                                <xsl:with-param name="tagDest" select="$tagDest"/>
                                <xsl:with-param name="mode" select="'concat'"/>
                            </xsl:call-template>
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
                <!--ERM le 24/06/20 -->
                <!--ancienne version des petits poissions qu'on ne laisse pas passer :
                    or @tag = '300' or @tag = '301' or @tag = '302' or @tag = '303' or @tag = '304' or @tag = '307' 
                    or  @tag = '340' or @tag = '341' or @tag = '342' or @tag = '343' or @tag = '344' or @tag = '345' or @tag = '346' or @tag = '347' or @tag = '349' 
                    or @tag = '351' or @tag = '352' or @tag = '353' or @tag = '354' 
                    or @tag = '360' or @tag = '361' -->
                <xsl:apply-templates
                    select="mxc:record/mxc:datafield[not(@tag = '010' or @tag = '039' or @tag = '100' or @tag = '101' or @tag = '103' or @tag = '105' or @tag = '106' or @tag = '123' or @tag = '150' or @tag = '152' or @tag = '154' or @tag = '160' or @tag = '210' or @tag = '230' or @tag = '240' 
                    or (starts-with(@tag, '30') and @tag != '305') or starts-with(@tag, '34') or starts-with(@tag, '35') or starts-with(@tag, '36') 
                    or @tag = '410' or @tag = '430' or @tag = '440' 
                    or @tag = '500' or @tag = '510' or @tag = '515' or @tag = '520' or @tag = '530' or @tag = '540' or @tag = '550' or @tag = '580' 
                    or @tag = '710' or @tag = '730' or @tag = '740' or @tag = '810')] | @*"
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
        <datafield tag="{$zone}" ind1="{$ind1}" ind2="{$ind2}">
            <xsl:call-template name="zX10_zXXX">
                <xsl:with-param name="zone" select="@tag"/>
            </xsl:call-template>
        </datafield>
    </xsl:template>
    <xsl:template name="z033">
        <xsl:variable name="date" select="current-date()"/>
        <datafield tag="033" ind1="#" ind2="#">
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
        <datafield tag="035" ind1="#" ind2="#">
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
            <xsl:variable name="z103_aFin">
                <xsl:value-of select="substring($z103a, 11, 10)"/>
            </xsl:variable>
            <xsl:variable name="z103_bDebut">
                <xsl:value-of select="substring($z103b, 1, 6)"/>
            </xsl:variable>
            <xsl:variable name="z103_bFin">
                <xsl:value-of select="substring($z103b, 7, 6)"/>
            </xsl:variable>
            <datafield tag="103" ind1="#" ind2="#">
                <xsl:analyze-string select="$z103_aDebut" regex="\d+">
                    <xsl:matching-substring>
                        <subfield code="a">
                            <xsl:value-of select="normalize-space($z103_aDebut)"/>
                        </subfield>
                    </xsl:matching-substring>
                </xsl:analyze-string>
                <xsl:analyze-string select="$z103_aFin" regex="\d+">
                    <xsl:matching-substring>
                        <subfield code="b">
                            <xsl:value-of select="normalize-space($z103_aFin)"/>
                        </subfield>
                    </xsl:matching-substring>
                </xsl:analyze-string>
                <xsl:analyze-string select="$z103_bDebut" regex="\d+">
                    <xsl:matching-substring>
                        <subfield code="c">
                            <xsl:value-of select="normalize-space($z103_bDebut)"/>
                        </subfield>
                    </xsl:matching-substring>
                </xsl:analyze-string>
                <xsl:analyze-string select="$z103_bFin" regex="\d+">
                    <xsl:matching-substring>
                        <subfield code="d">
                            <xsl:value-of select="normalize-space($z103_bFin)"/>
                        </subfield>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </datafield>
        </xsl:if>
    </xsl:template>
    <xsl:template name="z150">
        <xsl:if
            test="string-length(normalize-space(//mxc:datafield[@tag = '150']/mxc:subfield[@code = 'a'])) = 1 or string-length(normalize-space(//mxc:datafield[@tag = '150']/mxc:subfield[@code = 'b'])) = 1">
            <datafield tag="150" ind1="#" ind2="#">
                <xsl:if
                    test="string-length(normalize-space(//mxc:datafield[@tag = '150']/mxc:subfield[@code = 'a'])) = 1">
                    <subfield code="a">
                        <xsl:value-of
                            select="(//mxc:datafield[@tag = '150']/mxc:subfield[@code = 'a'])"/>
                    </subfield>
                </xsl:if>
                <xsl:if
                    test="string-length(normalize-space(//mxc:datafield[@tag = '150']/mxc:subfield[@code = 'b'])) = 1">
                    <subfield code="b">
                        <xsl:value-of
                            select="(//mxc:datafield[@tag = '150']/mxc:subfield[@code = 'b'])"/>
                    </subfield>
                </xsl:if>
            </datafield>
        </xsl:if>
    </xsl:template>
    <xsl:template name="z106">
        <xsl:param name="leader09_008"/>
        <datafield tag="106" ind1="#" ind2="#">
            <xsl:variable name="z200szx"
                select="normalize-space(//mxc:datafield[@tag = '200']/mxc:subfield[@code = 'x'])"/>
            <xsl:variable name="z200szy"
                select="normalize-space(//mxc:datafield[@tag = '200']/mxc:subfield[@code = 'y'])"/>
            <xsl:variable name="z200szz"
                select="normalize-space(//mxc:datafield[@tag = '200']/mxc:subfield[@code = 'z'])"/>
            <xsl:choose>
                <!--               <!-\-ceinture-\->
                <xsl:when
                    test="(substring(normalize-space(//mxc:datafield[@tag = '106']/mxc:subfield[@code = 'a']), 1, 1) != '') 
                    and ($leader09_008 = 'p' and $z200szx=''  and $z200szy='' and $z200szz='')">
                    
                    <subfield code="a">0</subfield>
                    <subfield code="b">1</subfield>
                    <subfield code="c">0</subfield>
                </xsl:when>
                <!-\-bretelles-\->
                <xsl:when
                    test="(substring(normalize-space(//mxc:datafield[@tag = '106']/mxc:subfield[@code = 'a']), 1, 1) != '') 
                    and $leader09_008 = 'p' 
                    and  (not(//mxc:datafield[@tag = '200']/mxc:subfield[@code = 'x'])
                   and not(//mxc:datafield[@tag = '200']/mxc:subfield[@code = 'y']) 
                   and  not(//mxc:datafield[@tag = '200']/mxc:subfield[@code = 'z']))">
                    <subfield code="a">0</subfield>
                    <subfield code="b">1</subfield>
                    <subfield code="c">0</subfield>
                </xsl:when>-->
                <!--ceinture et bretelles-->
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
        <xsl:comment>
            $tagSource : <xsl:value-of select="$tagSource"/>
            $tagDest : <xsl:value-of select="$tagDest"/>
            $mode : <xsl:value-of select="$mode"/>
        </xsl:comment>
        <!--ERM le 24/06/20 -->
        <datafield tag="{$tagDest}" ind1="#" ind2="#">
            <!-- passage du paramètre mode pour réaliser les 2 types de traitement tokenize ou concat-->
            <xsl:choose>
                <xsl:when test="$mode = 'tokenize'">
                    <subfield code="a">
                        <xsl:value-of select="normalize-space(.)"/>
                    </subfield>
                </xsl:when>
                <xsl:when test="$mode = 'concat'">
                    <xsl:variable name="sza"
                        select="concat('Lieu de naissance : ', mxc:subfield[@code = 'a'])"/>
                    <xsl:variable name="szb"
                        select="concat('Lieu de mort : ', mxc:subfield[@code = 'b'])"/>
                    <subfield code="a">
                        <xsl:value-of select="$sza"/>
                        <xsl:if test="$szb != ''">
                            <xsl:text>. </xsl:text>
                        </xsl:if>
                        <xsl:value-of select="$szb"/>
                    </subfield>
                </xsl:when>
            </xsl:choose>
        </datafield>
    </xsl:template>
    <xsl:template name="zXXX">
        <xsl:param name="zone"/>
        <datafield tag="{$zone}" ind1="#" ind2="#">
            <xsl:call-template name="zX10_zXXX">
                <xsl:with-param name="zone" select="@tag"/>
            </xsl:call-template>
        </datafield>
    </xsl:template>
    <xsl:template name="zX10_zXXX">
        <xsl:param name="zone"/>
        <xsl:for-each select="mxc:subfield[(string(@code) &lt; 'a') and (@code != '3')]">
            <xsl:sort select="number(@code)" order="ascending"/>
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
            <xsl:sort select="string(@code)" order="ascending"/>
            <xsl:choose>
                <xsl:when test="ends-with($zone, '40')">
                    <xsl:choose>
                        <xsl:when test=".[@code = 'a'] != ''">
                            <subfield code="a">
                                <xsl:value-of select="normalize-space(text())"/>
                                <xsl:if
                                    test="./parent::mxc:datafield/mxc:subfield[(@code) = 'b'] != ''">
                                    <xsl:value-of
                                        select="concat(', ', ./parent::mxc:datafield/mxc:subfield[(@code) = 'b'])"
                                    />
                                </xsl:if>
                                <xsl:if
                                    test="./parent::mxc:datafield/mxc:subfield[(@code) = 'f'] != ''">
                                    <xsl:value-of
                                        select="concat(' (', ./parent::mxc:datafield/mxc:subfield[(@code) = 'f'], ')')"
                                    />
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
                            </subfield>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select=".[not(@code = 'b' or @code = 'f')]"/>
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
        <datafield tag="810" ind1="#" ind2="#">
            <subfield code="a">
                <xsl:value-of select="."/>
            </subfield>
        </datafield>
    </xsl:template>
    <xsl:template match="mxc:subfield[@code = '7']">
        <xsl:choose>
            <xsl:when test="text() = 'ba0yba0y'"/>
            <xsl:otherwise>
                <subfield code="7">
                    <xsl:value-of select="substring(., 1, 2)"/>
                </subfield>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="mxc:subfield[@code = '8']">
        <xsl:choose>
            <xsl:when test="text() = 'frefre'"/>
            <xsl:when test="text() = 'fre   '"/>
            <xsl:when test="text() = 'fre '"/>
            <xsl:otherwise>
                <subfield code="8">
                    <xsl:value-of select="."/>
                </subfield>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="mxc:subfield[@code = '9']">
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
