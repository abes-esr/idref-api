<?xml version="1.0" encoding="UTF-8"?>
<!--     XSL de transformation du marcXml Bnf en marcXml Sudoc. (ERM créé 2020)
    Objectifs : rendre conforme au marcXml Sudoc :
  -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:srw="http://www.loc.gov/zing/srw/"
                xmlns:mxc="info:lc/xmlns/marcxchange-v2" version="2.0" exclude-result-prefixes="srw mxc xsi xs">
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    <xsl:param name="token"/>
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
                    <srw:extraRequestData><srw:authenticationToken> <xsl:value-of select="$token" /></srw:authenticationToken></srw:extraRequestData>
                </ucp:updateRequest>
            </soap:Body>
        </soap:Envelope>
    </xsl:template>
    <xsl:template match="srw:recordData">
        <record>
            <xsl:variable name="leaderDeb">
                <xsl:value-of select="substring(mxc:record/mxc:leader, 1, 17)"/>
            </xsl:variable>
            <xsl:variable name="leaderFin">
                <xsl:value-of select="substring(mxc:record/mxc:leader, 19)"/>
            </xsl:variable>
            <xsl:choose>
                <xsl:when
                        test="mxc:record/mxc:datafield[substring(@tag, 1, 1) = '7'][mxc:subfield[@code = '3'][normalize-space(text()) != '']]">
                    <xsl:element name="leader">
                        <xsl:value-of select="concat($leaderDeb, '#', $leaderFin)"/>
                    </xsl:element>
                </xsl:when>
            </xsl:choose>
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
            <xsl:apply-templates select="mxc:record/mxc:datafield[@tag = '101']"/>
            <xsl:apply-templates select="mxc:record/mxc:datafield[@tag = '102']"/>
            <xsl:call-template name="z103"/>
            <xsl:call-template name="z106"/>
            <!-- les zones 300 / 301 / 302 ... /309 sauf 305 $a  génèrent autant de zones 300$a que de chaines séparées par '.-'-->
            <xsl:for-each select="//mxc:datafield[@tag='240']">
                <xsl:call-template name="zXXX">
                    <xsl:with-param name="zone" select="@tag"/>
                </xsl:call-template>
            </xsl:for-each>
            <xsl:for-each
                    select="//mxc:datafield[starts-with(@tag, '30') and @tag != '305']/mxc:subfield[@code = 'a']">
                <xsl:for-each select="tokenize(text(), '.-')">
                    <xsl:call-template name="z3XX">
                        <xsl:with-param name="tag" select="'300'"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:for-each>
            <!-- les zones 340 / 341 / 342 ... /349  génèrent autant de zones 340$a que de chaines séparées par '.-'-->
            <xsl:for-each
                    select="//mxc:datafield[starts-with(@tag, '34')]/mxc:subfield[@code = 'a']">
                <xsl:for-each select="tokenize(text(), '.-')">
                    <xsl:call-template name="z3XX">
                        <xsl:with-param name="tag" select="'340'"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:for-each>
            <!-- les zones 360 / 361   génèrent autant de zones 300$a que de chaines séparées par '.-'-->
            <xsl:for-each
                    select="//mxc:datafield[@tag = '360' or @tag = '361']/mxc:subfield[@code = 'a']">
                <xsl:for-each select="tokenize(text(), '.-')">
                    <xsl:call-template name="z3XX">
                        <xsl:with-param name="tag" select="'300'"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:for-each>
            <xsl:for-each select="//mxc:datafield[@tag='440']">
                <xsl:call-template name="zXXX">
                    <xsl:with-param name="zone" select="@tag"/>
                </xsl:call-template>
            </xsl:for-each>
            <xsl:for-each select="//mxc:datafield[starts-with(@tag, '5')]">
                <xsl:call-template name="zXXX">
                    <xsl:with-param name="zone" select="@tag"/>
                </xsl:call-template>
            </xsl:for-each>
            <xsl:for-each select="//mxc:datafield[@tag = '810']/mxc:subfield[@code = 'a']">
                <xsl:call-template name="z810"/>
            </xsl:for-each>
            <xsl:apply-templates
                    select="mxc:record/mxc:datafield[not(@tag = '010' or @tag = '039' or @tag = '100' or @tag = '101' or @tag = '102' or @tag = '103' or @tag = '105' or @tag = '106' or @tag = '150' or @tag = '152' or @tag = '160' or @tag = '240' or @tag = '300' or @tag = '301' or @tag = '302' or @tag = '303' or @tag = '304' or @tag = '307' or @tag = '340' or @tag = '341' or @tag = '342' or @tag = '343' or @tag = '344' or @tag = '345' or @tag = '346' or @tag = '347' or @tag = '349' or @tag = '351' or @tag = '352' or @tag = '353' or @tag = '354' or @tag = '360' or @tag = '361' or @tag = '440'  or @tag = '500' or @tag = '510' or @tag = '515' or @tag = '520' or @tag = '530' or @tag = '540' or @tag = '550' or @tag = '580' or @tag = '810')] | @*"
            />
        </record>
    </xsl:template>
    <xsl:template name="z033">
        <datafield tag="033" ind1="#" ind2="#">
            <subfield code="a">
                <xsl:value-of select="normalize-space(//mxc:controlfield[@tag = '003'])"/>
            </subfield>
            <subfield code="2">BNF</subfield>
            <subfield code="d">
                <xsl:value-of select="//mxc:controlfield[@tag = '005']/text()"/>
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
                <xsl:value-of select="substring($z103a, 1, 9)"/>
            </xsl:variable>
            <xsl:variable name="z103_aFin">
                <xsl:value-of select="substring($z103a, 10, 9)"/>
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
                            <xsl:value-of select="$z103_aDebut"/>
                        </subfield>
                    </xsl:matching-substring>
                </xsl:analyze-string>
                <xsl:analyze-string select="$z103_aFin" regex="\d+">
                    <xsl:matching-substring>
                        <subfield code="b">
                            <xsl:value-of select="$z103_aFin"/>
                        </subfield>
                    </xsl:matching-substring>
                </xsl:analyze-string>
                <xsl:analyze-string select="$z103_bDebut" regex="\d+">
                    <xsl:matching-substring>
                        <subfield code="c">
                            <xsl:value-of select="$z103_bDebut"/>
                        </subfield>
                    </xsl:matching-substring>
                </xsl:analyze-string>
                <xsl:analyze-string select="$z103_bFin" regex="\d+">
                    <xsl:matching-substring>
                        <subfield code="d">
                            <xsl:value-of select="$z103_bFin"/>
                        </subfield>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </datafield>
        </xsl:if>
    </xsl:template>
    <xsl:template name="z106">
        <datafield tag="106" ind1="#" ind2="#">
            <subfield code="a">
                <xsl:choose>
                    <xsl:when
                            test="normalize-space(substring(//mxc:datafield[@tag = '106']/mxc:subfield[@code = 'a'], 1, 1)) != ''">
                        <xsl:value-of
                                select="substring(//mxc:datafield[@tag = '106']/mxc:subfield[@code = 'a'], 1, 1)"
                        />
                    </xsl:when>
                    <xsl:otherwise>#</xsl:otherwise>
                </xsl:choose>
            </subfield>
            <subfield code="b">
                <xsl:choose>
                    <xsl:when
                            test="normalize-space(substring(//mxc:datafield[@tag = '106']/mxc:subfield[@code = 'a'], 2, 1)) != ''">
                        <xsl:value-of
                                select="substring(//mxc:datafield[@tag = '106']/mxc:subfield[@code = 'a'], 2, 1)"
                        />
                    </xsl:when>
                    <xsl:otherwise>#</xsl:otherwise>
                </xsl:choose>
            </subfield>
            <subfield code="c">
                <xsl:choose>
                    <xsl:when
                            test="normalize-space(substring(//mxc:datafield[@tag = '106']/mxc:subfield[@code = 'a'], 3, 1)) != ''">
                        <xsl:value-of
                                select="substring(//mxc:datafield[@tag = '106']/mxc:subfield[@code = 'a'], 3, 1)"
                        />
                    </xsl:when>
                    <xsl:otherwise>#</xsl:otherwise>
                </xsl:choose>
            </subfield>
        </datafield>
    </xsl:template>
    <xsl:template name="z3XX">
        <xsl:param name="tag"/>
        <datafield tag="{$tag}" ind1="#" ind2="#">
            <subfield code="a">
                <xsl:value-of select="normalize-space(.)"/>
            </subfield>
        </datafield>
    </xsl:template>
    <xsl:template name="zXXX">
        <xsl:param name="zone"/>
        <datafield tag="{$zone}" ind1="#" ind2="#">
            <xsl:for-each select="mxc:subfield[(string(@code) &lt; 'a') and (@code != '3')]">
                <xsl:sort select="number(@code)" order="ascending"/>
                <xsl:apply-templates select="."/>
            </xsl:for-each>
            <xsl:for-each select="mxc:subfield[@code = '3']">
                <subfield code="Q">
                    <xsl:value-of select="."/>
                </subfield>
            </xsl:for-each>
            <xsl:choose>
                <xsl:when test="ends-with($zone, '40')">
                    <subfield code="a">
                        <xsl:value-of select="mxc:subfield[(@code) = 'a']"/>
                        <xsl:if test="mxc:subfield[(@code) = 'b']!=''">
                            <xsl:value-of select="concat(', ',mxc:subfield[(@code) = 'b'])"/></xsl:if>
                        <xsl:if test="mxc:subfield[(@code) = 'f']!=''">
                            <xsl:value-of select="concat(' (',mxc:subfield[(@code) = 'f'],')')"/></xsl:if>
                        <xsl:if test="mxc:subfield[(@code) = 't']!=''">
                            <xsl:value-of select="concat('. ',translate(translate(mxc:subfield[(@code) = 't'],'[',''),']',''))"/>
                        </xsl:if>
                    </subfield>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:for-each select="mxc:subfield[string(@code) &gt;= 'a']">
                        <xsl:sort select="string(@code)" order="ascending"/>
                        <xsl:apply-templates select="."/>
                    </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
        </datafield>
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
        <subfield code="9">
            <xsl:value-of select="concat($sz9pos1, $sz9pos2)"/>
        </subfield>
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

</xsl:stylesheet>
