<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    version="3.0"
    xmlns:XSLT="http://csrc.nist.gov/ns/oscal/metaschema/xslt-alias">
    
<!-- Purpose: Produce an XSLT supporting bidirectional XML-JSON syntax negotiation based on constraints declared in a netaschema -->
<!-- Input:   A Metaschema -->
<!-- Output:  An XSLT, supporting bidirectional transformation. -->

<!-- nb A schema and Schematron for the metaschema format should be found nearby. -->

    <xsl:output indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:namespace-alias stylesheet-prefix="XSLT" result-prefix="xsl"/>
    
    <xsl:variable name="string-value-label">STRVALUE</xsl:variable>
    <xsl:variable name="markdown-value-label">RICHTEXT</xsl:variable>
    <xsl:variable name="target-namespace" select="string(/METASCHEMA/namespace)"/>
    <xsl:variable name="root-name" select="/METASCHEMA/@root/string(.)"/>
    
    <xsl:key name="definition-by-name" match="define-flag | define-field | define-assembly" use="@name"/>
    <xsl:key name="callers-by-flags" match="define-field | define-assembly" use="flag/@name"/>
    
    <!-- Produces composed metaschema (imports resolved) -->
    <xsl:import href="../lib/metaschema-compose.xsl"/>
    
    <xsl:template match="/">
        <xsl:apply-templates select="$composed-metaschema/METASCHEMA"/>
    </xsl:template>
    
    <xsl:template match="METASCHEMA">
        <XSLT:stylesheet version="3.0"
            xpath-default-namespace="http://www.w3.org/2005/xpath-functions"
            exclude-result-prefixes="#all">
            
            <XSLT:output indent="yes" method="xml"/>
            
            <xsl:comment> METASCHEMA conversion stylesheet supports JSON->XML conversion </xsl:comment>
            
            <xsl:comment> 00000000000000000000000000000000000000000000000000000000000000 </xsl:comment>
            <xsl:call-template  name="furniture"/>
            <xsl:comment> 00000000000000000000000000000000000000000000000000000000000000 </xsl:comment>
            <xsl:apply-templates select="$composed-metaschema/METASCHEMA/*"/>
            
        </XSLT:stylesheet>
    </xsl:template>
    
    <xsl:template match="title"/>
    
    <xsl:template match="/METASCHEMA/*" priority="-0.2"/>
    
    <xsl:template match="define-flag" expand-text="true">
        <!-- Flags won't be producing elements in the regular traversal -->
        <xsl:comment> 000 Handling flag "{ @name }" 000 </xsl:comment>
        
        <XSLT:template match="*[@key='{@name}']" mode="json2xml"/>
        <xsl:variable name="match-step" expand-text="yes" as="xs:string">*[@key='{@name}']</xsl:variable>
        <xsl:variable name="match-patterns" as="xs:string*">
            <xsl:for-each select="key('callers-by-flags',@name)">
                <xsl:value-of>
                    <xsl:text>*[@key='{@name}']/{$match-step}</xsl:text>
                    <xsl:if test="matches(@group-as, '\i\c*')">
                        <xsl:text> | *[@key='{@group-as}']/*/{$match-step}</xsl:text>
                    </xsl:if>
                </xsl:value-of>
            </xsl:for-each>
        </xsl:variable>
        <XSLT:template match="{string-join($match-patterns,' | ')}" mode="as-attribute">
            <XSLT:attribute name="{@name}">
                <XSLT:apply-templates mode="#current"/>
            </XSLT:attribute>
        </XSLT:template>
    </xsl:template>
        
    <xsl:template match="define-flag/* | define-field/* | define-assembly/*"/>
            
        
    <xsl:template match="model | choice" priority="2">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="model//*">
        <xsl:variable name="definition" select="key('definition-by-name',@named)"/>
        <XSLT:apply-templates mode="#current" select="*[@key=({string-join((@named/('''' ||. || ''''),$definition/@group-as/('''' || . || '''')),', ')})]"/>    
    </xsl:template>
    
    <xsl:template match="model/prose" priority="2">
        <XSLT:apply-templates mode="#current" select="*[@key='prose']"/>    
    </xsl:template>
    
    <xsl:template match="define-field" expand-text="true">
        <xsl:variable name="field-match" as="xs:string">*[@key='{@name}']{ @group-as/(' | *[@key=''' || . || ''']/*') }{ if (@name=../@root) then ' | /map[empty(@key)]' else ''}</xsl:variable>
        <xsl:comment> 000 Handling field "{ @name }" 000 </xsl:comment>
        <XSLT:template match="{$field-match}" priority="2" mode="json2xml">
            <XSLT:element name="{@name}" namespace="{$target-namespace}">
                <xsl:for-each select="@address">
                    <XSLT:attribute name="{.}" select="../@key"/>
                </xsl:for-each>
                <XSLT:apply-templates mode="as-attribute"/>
                <xsl:apply-templates/>
                <XSLT:apply-templates mode="json2xml" select="*[@key={ if (@as='mixed') then $markdown-value-label else $string-value-label }]"/>
            </XSLT:element>
        </XSLT:template>
        <xsl:call-template name="drop-address"/>
    </xsl:template>
    
    <xsl:template match="define-assembly" expand-text="true">
        <xsl:variable name="assembly-match" as="xs:string">*[@key='{@name}']{ @group-as/(' | *[@key=''' || . || ''']/*') }</xsl:variable>
        <xsl:comment> 000 Handling assembly "{ @name }" 000 </xsl:comment>
        <XSLT:template match="{$assembly-match}" priority="2" mode="json2xml">
            <XSLT:element name="{@name}" namespace="{$target-namespace}">
                <xsl:for-each select="@address">
                    <XSLT:attribute name="{.}" select="../@key"/>
                </xsl:for-each>
                <XSLT:apply-templates mode="as-attribute"/>
                <xsl:apply-templates/>
            </XSLT:element>
        </XSLT:template>
        <xsl:call-template name="drop-address"/>
    </xsl:template>
    
    <xsl:template name="drop-address">
        <!-- When a flag is promoted as an address, it appears in the JSON as a label, so no attribute should be made in the regular traversal. -->
        <xsl:if test="matches(@address, '\i\c*')">
            <XSLT:template mode="as-attribute" priority="2"
                match="*[@key='{@name}']/string[@key='{@address}']{ @group-as/(' | ' || '*[@key=''' || . || ''']/*/string[@key=''{@address}'']') }"
            />
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="furniture">
        
        <XSLT:output indent="yes"/>
        
        <XSLT:strip-space elements="*"/>
        <XSLT:preserve-space elements="string"/>
        
        <XSLT:param name="json-file" as="xs:string"/>
        
        <XSLT:variable name="json-xml" select="unparsed-text($json-file) ! json-to-xml(.)"/>
        
        <XSLT:template match="/">
            <XSLT:choose>
                <XSLT:when test="exists($json-xml/map)">
                    <XSLT:apply-templates select="$json-xml" mode="json2xml"/>
                </XSLT:when>
                <XSLT:otherwise>
                    <XSLT:apply-templates mode="json2xml"/>
                </XSLT:otherwise>
            </XSLT:choose>
        </XSLT:template>
        
        <XSLT:template match="/map[empty(@key)]"
            priority="10"
            mode="json2xml">
            <XSLT:apply-templates mode="#current" select="*[@key=('{@root}')]"/>
        </XSLT:template>
        
        <XSLT:template match="array" mode="json2xml">
            <XSLT:apply-templates mode="#current"/>
        </XSLT:template>
        
        <XSLT:template match="array[@key='prose']/*" priority="5" mode="json2xml">
            <xsl:comment> This will have to be post-processed to render markdown into markup </xsl:comment>
            <XSLT:element name="p" namespace="{$target-namespace}">
                <XSLT:apply-templates mode="#current"/>
            </XSLT:element>
        </XSLT:template>
        
        <XSLT:template match="string[@key='{$markdown-value-label}']" mode="json2xml">
            <XSLT:comment> Not yet handling markdown </XSLT:comment>
            <XSLT:apply-templates mode="#current"/>
        </XSLT:template>
        
        <XSLT:template match="string[@key='{$string-value-label}']" mode="json2xml">
            <XSLT:apply-templates mode="#current"/>
        </XSLT:template>
        
        
        <XSLT:template mode="as-attribute" match="*"/>
        
        <XSLT:template mode="as-attribute" match="map">
            <XSLT:apply-templates mode="#current"/>
        </XSLT:template>
        
        <XSLT:template mode="as-attribute"  match="string[@key='id']" priority="0.4">
            <XSLT:attribute name="id">
                <XSLT:apply-templates mode="#current"/>
            </XSLT:attribute>
        </XSLT:template>
        
    </xsl:template>
    
</xsl:stylesheet>