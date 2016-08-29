	&lt;cffunction name="Update" access="public" output="false" returntype="boolean"&gt;
		<xsl:for-each select="root/bean/dbtable/column">&lt;cfargument name="<xsl:value-of select="@name" />" type="<xsl:value-of select="@type" />" required="<xsl:value-of select="@primaryKey" />" /&gt;
		</xsl:for-each>

		&lt;cfset var qUpdate = "" /&gt;
		&lt;cfset var first = "" /&gt;
		&lt;cfset var subsequent = "," /&gt;
	
		&lt;cfquery datasource="#_GetDSN()#"&gt;
			UPDATE	`<xsl:value-of select="//dbtable/@name" />`
			SET		<xsl:for-each select="root/bean/dbtable/column[@primaryKey='No']">&lt;cfif StructKeyExists(arguments, '<xsl:value-of select="@name" />')&gt;
						#first# `<xsl:value-of select="@name" />` = &lt;cfqueryparam value="#arguments.<xsl:value-of select="@name" />#" cfsqltype="<xsl:value-of select="@cfSqlType" />" /&gt;
						&lt;cfset first = subsequent&gt;
					&lt;/cfif&gt;</xsl:for-each>
			

				
			WHERE	<xsl:for-each select="root/bean/dbtable/column[@primaryKey='Yes']">`<xsl:value-of select="@name" />` =  &lt;cfqueryparam value="#arguments.<xsl:value-of select="@name" />#" cfsqltype="<xsl:value-of select="@cfSqlType" />" /&gt;
			<xsl:if test="position() != last()">AND		</xsl:if></xsl:for-each>
		&lt;/cfquery&gt;
		
		&lt;cfquery name="qUpdate" datasource="#_GetDSN()#"&gt;	
			SELECT	ROW_COUNT() as rowsUpdated
		&lt;/cfquery&gt;

		&lt;cfreturn qUpdate.rowsUpdated /&gt;
	&lt;/cffunction&gt;