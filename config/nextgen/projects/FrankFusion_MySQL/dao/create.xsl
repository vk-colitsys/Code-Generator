
	&lt;cffunction name="create" access="public" returntype="numeric" output="false" hint="Returns the id of the newly created record"&gt;
		<xsl:for-each select="root/bean/dbtable/column[@primaryKey='No']">&lt;cfargument name="<xsl:value-of select="@name" />" type="<xsl:value-of select="@type" />" required="<xsl:value-of select="@required" />" /&gt;
		</xsl:for-each>

		&lt;cfset var qCreate = "" /&gt;

		&lt;cfquery datasource="#_GetDSN()#"&gt;	
			INSERT INTO `<xsl:value-of select="//dbtable/@name" />` (	<xsl:for-each select="root/bean/dbtable/column[@primaryKey='No']">`<xsl:value-of select="@name" />`<xsl:if test="position() != last()">,</xsl:if></xsl:for-each>)
			VALUES (	<xsl:for-each select="root/bean/dbtable/column[@primaryKey='No']">
						<xsl:if test="@required='No'">&lt;cfif StructKeyExists(arguments,"<xsl:value-of select="@name" />")&gt; </xsl:if>&lt;cfqueryparam value="#arguments.<xsl:value-of select="@name" />#" cfsqltype="<xsl:value-of select="@cfSqlType" />" /&gt;<xsl:if test="@required='No'"> &lt;cfelse&gt; NULL &lt;/cfif&gt;</xsl:if><xsl:if test="position() != last()">,
						</xsl:if>
						</xsl:for-each>	);
		&lt;/cfquery&gt;
		
		&lt;cfquery name="qCreate" datasource="#_GetDSN()#"&gt;		
			SELECT IfNull(LAST_INSERT_ID(), 0) as newId
		&lt;/cfquery&gt;
		
		&lt;cfreturn qCreate.newId /&gt;
	&lt;/cffunction&gt;