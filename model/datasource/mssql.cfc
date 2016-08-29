<cfcomponent name="mssql" extends="dbBase" output="false">
	
	<cffunction name="getTables" access="public" output="false" returntype="query">
		<cfset var qAllTables = "" />
		<cfset objTable = "" />
		
		<cfif not len(getDsn())>
			<cfthrow message="you must provide a dsn" />
		</cfif>
		<cfquery name="qAllTables" datasource="#getDsn()#">
			exec sp_tables @table_type="'Table'"
		</cfquery>
		
		<cfquery name="qAllTables" dbtype="query">
			SELECT	table_name as tablename,
					table_type as tabletype
			FROM	qAllTables
		</cfquery>
		<cfreturn qAllTables />
	</cffunction>
	
	<!--- these functions are modified from reactor v0.1 --->
	<cffunction name="translateCfSqlType" access="private" hint="I translate the MSSQL data type names into ColdFusion cf_sql_xyz names" output="false" returntype="string">
		<cfargument name="typeName" hint="I am the type name to translate" required="yes" type="string" />
		
		<cfswitch expression="#arguments.typeName#">
			<cfcase value="bigint">
				<cfreturn "cf_sql_bigint" />
			</cfcase>
			<cfcase value="binary">
				<cfreturn "cf_sql_binary" />
			</cfcase>
			<cfcase value="bit">
				<cfreturn "cf_sql_bit" />
			</cfcase>
			<cfcase value="char">
				<cfreturn "cf_sql_char" />
			</cfcase>
			<cfcase value="datetime">
				<cfreturn "cf_sql_timestamp" />
			</cfcase>
			<cfcase value="decimal">
				<cfreturn "cf_sql_decimal" />
			</cfcase>
			<cfcase value="float">
				<cfreturn "cf_sql_float" />
			</cfcase>
			<cfcase value="image">
				<cfreturn "cf_sql_longvarbinary" />
			</cfcase>
			<cfcase value="int">
				<cfreturn "cf_sql_integer" />
			</cfcase>
			<cfcase value="money">
				<cfreturn "cf_sql_money" />
			</cfcase>
			<cfcase value="nchar">
				<cfreturn "cf_sql_char" />
			</cfcase>
			<cfcase value="ntext">
				<cfreturn "cf_sql_longvarchar" />
			</cfcase>
			<cfcase value="numeric">
				<cfreturn "cf_sql_varchar" />
			</cfcase>
			<cfcase value="nvarchar">
				<cfreturn "cf_sql_varchar" />
			</cfcase>
			<cfcase value="real">
				<cfreturn "cf_sql_real" />
			</cfcase>
			<cfcase value="smalldatetime">
				<cfreturn "cf_sql_date" />
			</cfcase>
			<cfcase value="smallint">
				<cfreturn "cf_sql_smallint" />
			</cfcase>
			<cfcase value="smallmoney">
				<cfreturn "cf_sql_decimal" />
			</cfcase>
			<cfcase value="text">
				<cfreturn "cf_sql_longvarchar" />
			</cfcase>
			<cfcase value="timestamp">
				<cfreturn "cf_sql_timestamp" />
			</cfcase>
			<cfcase value="tinyint">
				<cfreturn "cf_sql_tinyint" />
			</cfcase>
			<cfcase value="uniqueidentifier">
				<cfreturn "cf_sql_idstamp" />
			</cfcase>
			<cfcase value="varbinary">
				<cfreturn "cf_sql_varbinary" />
			</cfcase>
			<cfcase value="varchar">
				<cfreturn "cf_sql_varchar" />
			</cfcase>
		</cfswitch>
	</cffunction>
	
	<cffunction name="translateDataType" access="private" hint="I translate the MSSQL data type names into ColdFusion data type names" output="false" returntype="string">
		<cfargument name="typeName" hint="I am the type name to translate" required="yes" type="string" />
		<cfargument name="length" hint="I am the length of the column" required="no" type="numeric" default="0" />
		<cfargument name="isPrimaryKey" hint="I am a flag indicating that the column is a primary key" required="no" type="boolean" default="false" />
		
		<cfswitch expression="#arguments.typeName#">
			<cfcase value="bigint">
				<cfreturn "numeric" />
			</cfcase>
			<cfcase value="binary">
				<cfreturn "binary" />
			</cfcase>
			<cfcase value="bit">
				<cfreturn "boolean" />
			</cfcase>
			<cfcase value="char">
				<cfif arguments.length EQ 35 AND arguments.isPrimaryKey>
					<cfreturn "uuid" />
				</cfif>
				<cfreturn "string" />
			</cfcase>
			<cfcase value="datetime">
				<cfreturn "date" />
			</cfcase>
			<cfcase value="decimal">
				<cfreturn "numeric" />
			</cfcase>
			<cfcase value="float">
				<cfreturn "numeric" />
			</cfcase>
			<cfcase value="image">
				<cfreturn "binary" />
			</cfcase>
			<cfcase value="int">
				<cfreturn "numeric" />
			</cfcase>
			<cfcase value="money">
				<cfreturn "numeric" />
			</cfcase>
			<cfcase value="nchar">
				<cfreturn "string" />
			</cfcase>
			<cfcase value="ntext">
				<cfreturn "string" />
			</cfcase>
			<cfcase value="numeric">
				<cfreturn "numeric" />
			</cfcase>
			<cfcase value="nvarchar">
				<cfreturn "string" />
			</cfcase>
			<cfcase value="real">
				<cfreturn "numeric" />
			</cfcase>
			<cfcase value="smalldatetime">
				<cfreturn "date" />
			</cfcase>
			<cfcase value="smallint">
				<cfreturn "numeric" />
			</cfcase>
			<cfcase value="smallmoney">
				<cfreturn "numeric" />
			</cfcase>
			<cfcase value="text">
				<cfreturn "string" />
			</cfcase>
			<cfcase value="timestamp">
				<cfreturn "numeric" />
			</cfcase>
			<cfcase value="tinyint">
				<cfreturn "numeric" />
			</cfcase>
			<cfcase value="uniqueidentifier">
				<cfreturn "string" />
			</cfcase>
			<cfcase value="varbinary">
				<cfreturn "binary" />
			</cfcase>
			<cfcase value="varchar">
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
			SELECT	c.COLUMN_NAME,
				c.DATA_TYPE as TYPE_NAME,
				CASE
					WHEN ISNUMERIC(c.CHARACTER_MAXIMUM_LENGTH) = 1 THEN c.CHARACTER_MAXIMUM_LENGTH
					ELSE 0
					END as LENGTH,
				CASE
					WHEN c.IS_NULLABLE = 'No' AND c.Column_Default IS NULL THEN 0 /* a column is defined as nullable only if it doesn't have a default */
					ELSE 1
				END as NULLABLE,
				CASE
					WHEN columnProperty(object_id(c.TABLE_NAME), c.COLUMN_NAME, 'IsIdentity') > 0 THEN 'true'
					ELSE 'false'
				END AS [IDENTITY]
			FROM INFORMATION_SCHEMA.COLUMNS as c
			WHERE c.TABLE_NAME = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.table#" />
		</cfquery>
		<cfreturn qTable />
	</cffunction>
		
	<cffunction name="getPrimaryKeyList" access="private" output="false" returntype="string">
		<cfargument name="table" type="string" required="true" />
		
		<cfset var qPrimaryKeys = "" />

		<cfquery name="qPrimaryKeys" datasource="#getDsn()#">
			SELECT ccu.COLUMN_NAME,ccu.CONSTRAINT_NAME AS PK_NAME
			FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu
				INNER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
				ON ccu.CONSTRAINT_NAME = tc.CONSTRAINT_NAME
			AND 	ccu.TABLE_NAME = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.table#" />
			AND	tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		</cfquery>
		<cfreturn valueList(qPrimaryKeys.column_name) />
	</cffunction>
</cfcomponent>