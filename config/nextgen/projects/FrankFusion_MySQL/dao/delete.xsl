	&lt;cffunction name="Delete" access="public" output="false" returntype="boolean"&gt;
		<xsl:for-each select="root/bean/dbtable/column[@primaryKey='Yes']">&lt;cfargument name="<xsl:value-of select="@name" />" type="<xsl:value-of select="@type" />" required="true" /&gt;
		</xsl:for-each>
		&lt;cfset var qDelete = ""&gt;
		
		&lt;cfquery datasource="#_GetDSN()#"&gt;
			DELETE FROM	`<xsl:value-of select="//dbtable/@name" />` 
			WHERE		<xsl:for-each select="root/bean/dbtable/column[@primaryKey='Yes']">`<xsl:value-of select="@name" />` =  &lt;cfqueryparam value="#arguments.<xsl:value-of select="@name" />#" cfsqltype="<xsl:value-of select="@cfSqlType" />" /&gt;
			<xsl:if test="position() != last()">AND		</xsl:if></xsl:for-each>
		&lt;/cfquery&gt;
		
		&lt;cfquery name="qDelete" datasource="#_GetDSN()#"&gt;	
			SELECT ROW_COUNT() as rowsDeleted
		&lt;/cfquery&gt;

		&lt;cfreturn qDelete.rowsDeleted /&gt;
	&lt;/cffunction&gt;