<cfcomponent name="informix" extends="dbBase" output="false">
	<cffunction name="getTables" access="public" output="false" returntype="query">
		<cfset var qAllTables = "" />
		<cfset objTable = "" />
		
		<cfif not len(getDsn())>
			<cfthrow message="you must provide a dsn" />
		</cfif>
		
		<cfquery name="qAllTables" datasource="#getDsn()#">
			SELECT 
			tabname
			, owner
			, tabtype
			FROM systables
			WHERE tabid > 99
			AND tabtype IN ('T','V')
			ORDER BY 1
		</cfquery>
		
		<cfquery name="qAllTables" dbtype="query">
			SELECT	tabname as tablename,
					tabtype as tabletype
			FROM	qAllTables
		</cfquery>
		<cfreturn qAllTables />
	</cffunction>

	<!--- these functions are modified from reactor v0.1 --->
	<cffunction name="translateCfSqlType" access="private" hint="I translate the MSSQL data type names into ColdFusion cf_sql_xyz names" output="false" returntype="string">
		<cfargument name="typeName" hint="I am the type name to translate" required="yes" type="string" />
		
		<cfswitch expression="#arguments.typeName#">
			<cfcase value="0">
				<cfreturn "cf_sql_char" />
			</cfcase>
			<cfcase value="1">
				<cfreturn "cf_sql_smallint" />
			</cfcase>
			<cfcase value="2">
				<cfreturn "cf_sql_integer" />
			</cfcase>
			<cfcase value="3">
				<cfreturn "cf_sql_float" />
			</cfcase>
			<cfcase value="4">
				<!--- SMALL FLOAT --->
				<cfreturn "cf_sql_float" />
			</cfcase>
			<cfcase value="5">
				<cfreturn "cf_sql_decimal" />
			</cfcase>
			<cfcase value="6">
				<cfreturn "cf_sql_integer" />
			</cfcase>
			<cfcase value="7">
				<cfreturn "cf_sql_date" />
			</cfcase>
			<cfcase value="8">
				<cfreturn "cf_sql_money" />
			</cfcase>
			<cfcase value="10">
				<cfreturn "cf_sql_timestamp" />
			</cfcase>
			<cfcase value="13">
				<cfreturn "cf_sql_varchar" />
			</cfcase>
			<cfcase value="40">
				<cfreturn "cf_sql_longvarchar" />
			</cfcase>
			<cfcase value="41">
				<cfreturn "cf_sql_longvarchar" />
			</cfcase>
			<cfcase value="262">
				<cfreturn "cf_sql_serial" />
			</cfcase>
		</cfswitch>
	</cffunction>
	
	<cffunction name="translateDataType" access="private" hint="I translate the MSSQL data type names into ColdFusion data type names" output="false" returntype="string">
		<cfargument name="typeName" hint="I am the type name to translate" required="yes" type="string" />
		
		<cfswitch expression="#arguments.typeName#">
			<cfcase value="0">
				<cfreturn "string" />
			</cfcase>
			<cfcase value="1">
				<cfreturn "numeric" />
			</cfcase>
			<cfcase value="2">
				<cfreturn "numeric" />
			</cfcase>
			<cfcase value="3">
				<cfreturn "numeric" />
			</cfcase>
			<cfcase value="4">
				<cfreturn "numeric" />
			</cfcase>
			<cfcase value="5">
				<cfreturn "numeric" />
			</cfcase>
			<cfcase value="6">
				<cfreturn "numeric" />
			</cfcase>
			<cfcase value="7">
				<cfreturn "date" />
			</cfcase>
			<cfcase value="8">
				<cfreturn "numeric" />
			</cfcase>
			<cfcase value="10">
				<cfreturn "date" />
			</cfcase>
			<cfcase value="13">
				<cfreturn "string" />
			</cfcase>
			<cfcase value="40">
				<cfreturn "string" />
			</cfcase>
			<cfcase value="41">
				<cfreturn "string" />
			</cfcase>
			<cfcase value="262">
				<cfreturn "string" />
			</cfcase>
		</cfswitch>
		
	</cffunction>
	
	<cffunction name="getTableMetadata" access="private" output="false" returntype="query">
		<cfargument name="table" type="string" required="true" />
		
		<cfset var qTable = "" />
		<!--- get table column info --->
		<!--- This is a modified version of the query in sp_columns --->
		<cfquery name="qTable" datasource="#getDsn()#">
			SELECT
			c.colname AS COLUMN_NAME
			, CASE
				WHEN c.coltype = 262
				THEN c.coltype
				WHEN c.coltype >= 256
				THEN (c.coltype-256)
				ELSE c.coltype
				END 
				AS TYPE_NAME
			, c.collength AS LENGTH
			, CASE
				WHEN c.coltype >= 256  
				THEN 0
				ELSE 1
				END 
				AS NULLABLE
			, CASE
				WHEN c.coltype = 262  
				THEN 1
				ELSE 0
				END 
				AS IDENTITY
			FROM syscolumns c
			WHERE c.tabid = (	SELECT t.tabid
								FROM systables t
								WHERE t.tabid > 99
								AND t.tabname = <cfqueryparam
													cfsqltype="cf_sql_char"
													null="#not Len(arguments.table)#"
													value="#arguments.table#">
							)
			ORDER BY c.colno, c.colname
		</cfquery>
		
		<cfreturn qTable />
	</cffunction>
	
	<cffunction name="getPrimaryKeyList" access="private" output="false" returntype="string">
		<cfargument name="table" type="string" required="true" />
		
		<cfset var qPrimaryKeys = "" />
		<cfset var i = 0>
		<cfset var qTableId = "">
		<cfset var tableID = 0>
		
		<cfquery name="qTableId" datasource="#getDsn()#">
			SELECT t.tabid
			FROM systables t
			WHERE t.tabid > 99
			AND t.tabname = <cfqueryparam
								cfsqltype="cf_sql_char"
								null="#not Len(arguments.table)#"
								value="#arguments.table#">
		</cfquery>
		
		<cfset tableID = Trim(qTableId.tabid)>
		
		<cfquery name="qPrimaryKeys" datasource="#getDsn()#">
		  	<cfloop from="1" to="16" index="i" step="1">
				<cfif i GT 1>UNION</cfif>
		  		SELECT 
		  		i.idxname AS PK_NAME
		  		, i.idxtype
		  		<cfif i eq 1>
					, i.part#i# AS index_order
		  		<cfelse>
					, i.part#i#
		  		</cfif>
		  		, c.colname AS COLUMN_NAME
		  		FROM sysindexes i
		  		INNER JOIN syscolumns c ON (i.tabid = c.tabid AND c.colno = i.part#i#)
		  		WHERE i.tabid = <cfqueryparam cfsqltype="cf_sql_char" value="#tableID#">
				AND i.idxtype = <cfqueryparam cfsqltype="cf_sql_char" value="U">
				AND i.part#i# != <cfqueryparam cfsqltype="cf_sql_char" value="0">
	  		</cfloop>
		</cfquery>

		<cfreturn valueList(qPrimaryKeys.column_name) />
	</cffunction>
	
</cfcomponent>