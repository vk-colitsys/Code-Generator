<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="text" indent="no"  />
		<xsl:template match="/">
&lt;cfcomponent extends="org.FrankFusion.dataObjects.dao" output="false"&gt;

&lt;!--- CONSTRUCTOR ---&gt;
	&lt;cffunction name="init" access="public" output="false" returntype="any"&gt;
		&lt;cfargument name="datasource" type="any" required="true" hint="Generic datasource object"&gt;
		
		&lt;cfscript&gt;
			var tableName = "<xsl:value-of select="//dbtable/@name" />";
			var primaryKey = "<xsl:for-each select="root/bean/dbtable/column[@primaryKey='Yes']"><xsl:value-of select="@name" /><xsl:if test="position() != last()">,</xsl:if></xsl:for-each>";
			var fieldlist = "<xsl:for-each select="root/bean/dbtable/column"><xsl:value-of select="@name" /><xsl:if test="position() != last()">,</xsl:if></xsl:for-each>";
			var relatedFieldlist = "";
			
			return super.init(arguments.datasource, tableName, primaryKey, fieldlist, relatedFieldlist);
		&lt;/cfscript&gt;
	&lt;/cffunction&gt;
	
	<!-- custom code -->

&lt;/cfcomponent&gt;</xsl:template>
</xsl:stylesheet>