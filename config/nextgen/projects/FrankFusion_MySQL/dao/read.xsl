	&lt;cffunction name="Read" access="public" output="false" returntype="query" hint="Not strict to the dao concept, can select more than one record here"&gt;
		<xsl:for-each select="root/bean/dbtable/column">&lt;cfargument name="<xsl:value-of select="@name" />" type="<xsl:value-of select="@type" />" required="false" /&gt;
		</xsl:for-each>&lt;cfargument name="orderby" type="string" required="false" /&gt;
		&lt;cfargument name="maxRows" type="numeric" required="false" default="-1" /&gt;
		
		&lt;cfset var qRead = "" /&gt;		
		&lt;cfquery name="qRead" datasource="#_GetDSN()#" maxrows="#arguments.maxRows#"&gt;
			SELECT	<xsl:for-each select="root/bean/dbtable/column">`<xsl:value-of select="@name" />`<xsl:if test="position() != last()">,</xsl:if>
					</xsl:for-each>
			FROM	`<xsl:value-of select="//dbtable/@name" />`
			WHERE	0=0
		
			<xsl:for-each select="root/bean/dbtable/column">&lt;cfif StructKeyExists(arguments,"<xsl:value-of select="@name" />")&gt;
				AND	`<xsl:value-of select="@name" />` = &lt;cfqueryparam value="#arguments.<xsl:value-of select="@name" />#" cfsqltype="<xsl:value-of select="@cfSqlType" />" /&gt;
			&lt;/cfif&gt;
			</xsl:for-each>
			
			&lt;cfif structKeyExists(arguments, "orderby") and len(arguments.orderBy)&gt;
				ORDER BY #arguments.orderby#
			&lt;/cfif&gt;
		&lt;/cfquery&gt;
		
		&lt;cfreturn qRead /&gt;
	&lt;/cffunction&gt;