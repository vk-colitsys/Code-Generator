	&lt;cffunction name="Exists" access="public" output="false" returntype="boolean" hint="Not strict to the dao concept, can pass more than one filter here"&gt;
		<xsl:for-each select="root/bean/dbtable/column">&lt;cfargument name="<xsl:value-of select="@name" />" type="<xsl:value-of select="@type" />" required="false" /&gt;
		</xsl:for-each>
		
		&lt;cfset var qRead = "" /&gt;		
		&lt;cfquery name="qRead" datasource="#_GetDSN()#"&gt;
			SELECT	Count(*) as nRows
			FROM	`<xsl:value-of select="//dbtable/@name" />`
			WHERE	0=0
		
			<xsl:for-each select="root/bean/dbtable/column">&lt;cfif StructKeyExists(arguments,"<xsl:value-of select="@name" />")&gt;
				AND	`<xsl:value-of select="@name" />` = &lt;cfqueryparam value="#arguments.<xsl:value-of select="@name" />#" cfsqltype="<xsl:value-of select="@cfSqlType" />" /&gt;
			&lt;/cfif&gt;
			</xsl:for-each>
		&lt;/cfquery&gt;
		
		&lt;cfreturn (qRead.nRows GT 0) /&gt;
	&lt;/cffunction&gt;