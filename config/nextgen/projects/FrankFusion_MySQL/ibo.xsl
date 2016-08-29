<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="text" indent="no"  />
		<xsl:template match="/">
&lt;cfcomponent extends="org.FrankFusion.dataObjects.ibo" output="false"&gt;

&lt;!--- CONSTRUCTOR ---&gt;
	&lt;cffunction name="init" access="public" output="false" returntype="any"&gt;
		&lt;cfargument name="<xsl:value-of select="//dbtable/@name" />Dao" type="any" required="true" hint="<xsl:value-of select="//dbtable/@name" /> dao object"&gt;
		
		&lt;cfscript&gt;
			super.init(arguments.<xsl:value-of select="//dbtable/@name" />Dao);
			variables._relatedDaos = StructNew();
			return this;
		&lt;/cfscript&gt;
	&lt;/cffunction&gt;

&lt;!--- ODD BUSINESS LOGIC ---&gt;

&lt;!--- RELATIONSHIPS ---&gt;
	&lt;cffunction name="GetRelatedObject" access="private" returntype="any" hint="Gets a related object pre-initialised with dao and datasource"&gt;
		&lt;cfargument name="name" type="string" required="true"&gt;
		
		&lt;cfreturn CreateObject('component', "#arguments.name#IBO").init(_relatedDaos[arguments.name])&gt;
	&lt;/cffunction&gt;

&lt;!--- ACCESSORS ---&gt;
<xsl:for-each select="root/bean/dbtable/column">
	&lt;cffunction name="Set<xsl:value-of select="@name" />" access="public" output="false" returntype="void"&gt;
		&lt;cfargument name="<xsl:value-of select="@name" />" type="<xsl:value-of select="@type" />" required="true" /&gt;
		&lt;cfscript&gt;
			SetField("<xsl:value-of select="@name" />", arguments.<xsl:value-of select="@name" />);
		&lt;/cfscript&gt;	
	&lt;/cffunction&gt;
	&lt;cffunction name="Get<xsl:value-of select="@name" />" returntype="<xsl:value-of select="@type" />" access="public" output="false"&gt;
	<xsl:choose><xsl:when test="@type='Numeric'">	&lt;cfreturn Val(GetField("<xsl:value-of select="@name" />",0))&gt;</xsl:when>
		<xsl:when test="@type='Date'">	&lt;cfreturn GetField("<xsl:value-of select="@name" />",Now())&gt;</xsl:when>
		<xsl:when test="@type='Boolean'">	&lt;cfreturn GetField("<xsl:value-of select="@name" />",false)&gt;</xsl:when>
		<xsl:otherwise>	&lt;cfreturn GetField("<xsl:value-of select="@name" />","")&gt;</xsl:otherwise></xsl:choose>
	&lt;/cffunction&gt;
</xsl:for-each>

&lt;/cfcomponent&gt;</xsl:template>
</xsl:stylesheet>