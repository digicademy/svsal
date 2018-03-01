<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:math="http://www.w3.org/2005/xpath-functions/math"
	xmlns:sal="http://salamanca.adwmainz.de"
	exclude-result-prefixes="xs math"
	version="3.0">
    <xsl:template match="*">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="sal:lemma[@type='term']">
<xsl:value-of select="./text()"/>
    </xsl:template>
</xsl:stylesheet>