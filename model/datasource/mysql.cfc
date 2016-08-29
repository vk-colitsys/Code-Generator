<cfcomponent name="mysql" extends="dbBase" output="false">>
		
	<cffunction name="isMySQL5plus" access="private" output="false" returntype="boolean">
		<!--- a simple test to see if the information_schema exists --->
		
		<cfif not isDefined("variables.isMySQL5plusVar")>
			<cftry>
				<cfquery datasource="#getDsn()#">
					SELECT 0 FROM INFORMATION_SCHEMA.columns LIMIT 1
				</cfquery>
				<cfset variables.isMySQL5plusVar = true />
				
				<cfcatch type="database">
					<cfset variables.isMySQL5plusVar = false />
				</cfcatch>
			</cftry>
		</cfif>

		<cfreturn variables.isMySQL5plusVar />
	</cffunction>
	
	<cffunction name="getTables" access="public" output="false" returntype="query">
		<cfif isMySQL5Plus()>
			<cfreturn getTables_5() />
		<cfelse>
			<cfreturn getTables_41() />
		</cfif>
	</cffunction>
	<cffunction name="getTables_5" access="private" output="false" returntype="query">
		<cfset var qAllTables = "" />
		<cfset objTable = "" />
		
		<cfif not len(getDsn())>
			<cfthrow errorcode="you must provide a dsn" />
		</cfif>
		<cfquery name="qAllTables" datasource="#getDsn()#">
			SELECT TABLE_NAME as tablename, TABLE_TYPE as tabletype
			FROM information_schema.TABLES
			WHERE TABLE_SCHEMA = database()
		</cfquery>
		
		<cfreturn qAllTables />
	</cffunction>
	<!--- MySQL 4.1 support thanks to Josh Nathanson --->
	<cffunction name="getTables_41" access="private" output="false" returntype="query">
		<cfset var qStatus = "" />
		<cfset var qDB = "" />
		<cfset var getDBname = "" />
		<cfset var qAllTables = "" />
		<cfset objTable = "" />
		
		<cfif not len(getDsn())>
			<cfthrow errorcode="you must provide a dsn" />
		</cfif>
		
		<cfquery name="qStatus" datasource="#getDsn()#">
		SHOW TABLE STATUS
		</cfquery>

		<cfquery name="qDB" datasource="#getDsn()#">
		SHOW OPEN TABLES
		</cfquery>

		<cfquery name="getDBname" dbtype="query">
		SELECT Database AS db FROM qDB
		GROUP BY Database
		</cfquery>

		<cfquery name="qAllTables" dbtype="query">
			SELECT Name AS tablename, Engine AS tabletype
			FROM qStatus
		</cfquery>

		<cfreturn qAllTables>
	</cffunction>
	
	
	<!--- these functions are modified from reactor v0.1 --->
	<cffunction name="translateCfSqlType" access="private" hint="I translate the MySQL data type names into ColdFusion cf_sql_xyz names" output="false" returntype="string">
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
			<cfcase value="double">
				<cfreturn "cf_sql_numeric" />
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
			<cfcase value="longtext">
				<cfreturn "cf_sql_longvarchar" />
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
			<cfcase value="mediumint">
				<cfreturn "cf_sql_integer" />
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
			<cfcase value="bigint,int,mediumint,smallint,tinyint">
				<cfreturn "Numeric" />
			</cfcase>
			<cfcase value="binary">
				<cfreturn "String" />
			</cfcase>
			<cfcase value="bit">
				<cfreturn "Boolean" />
			</cfcase>
			<cfcase value="char">
				<cfif arguments.length EQ 35 AND arguments.isPrimaryKey>
					<cfreturn "uuid" />
				</cfif>
				<cfreturn "string" />
			</cfcase>
			<cfcase value="datetime">
				<cfreturn "Date" />
			</cfcase>
			<cfcase value="decimal">
				<cfreturn "Numeric" />
			</cfcase>
			<cfcase value="double">
				<cfreturn "Numeric" />
			</cfcase>
			<cfcase value="float">
				<cfreturn "Numeric" />
			</cfcase>
			<cfcase value="image">
				<cfreturn "Numeric" />
			</cfcase>
			<cfcase value="money">
				<cfreturn "Numeric" />
			</cfcase>
			<cfcase value="nchar">
				<cfreturn "String" />
			</cfcase>
			<cfcase value="ntext">
				<cfreturn "String" />
			</cfcase>
			<cfcase value="numeric">
				<cfreturn "Numeric" />
			</cfcase>
			<cfcase value="nvarchar">
				<cfreturn "String" />
			</cfcase>
			<cfcase value="longtext">
				<cfreturn "String" />
			</cfcase>
			<cfcase value="real">
				<cfreturn "Numeric" />
			</cfcase>
			<cfcase value="smalldatetime">
				<cfreturn "Date" />
			</cfcase>
			<cfcase value="smallmoney">
				<cfreturn "Numeric" />
			</cfcase>
			<cfcase value="text">
				<cfreturn "String" />
			</cfcase>
			<cfcase value="timestamp">
				<cfreturn "Date" />
			</cfcase>
			<cfcase value="uniqueidentifier">
				<cfreturn "String" />
			</cfcase>
			<cfcase value="varbinary">
				<cfreturn "String" />
			</cfcase>
			<cfcase value="varchar">
				<cfreturn "String" />
			</cfcase>
		</cfswitch>
	</cffunction>
	
	<cffunction name="getTableMetadata" access="private" output="false" returntype="query">
		<cfargument name="table" type="string" required="true" />
		
		<cfif isMySQL5plus()>
			<cfreturn getTableMetadata_5( arguments.table ) />
		<cfelse>
			<cfreturn getTableMetadata_41( arguments.table ) />
		</cfif>
	</cffunction>
	<cffunction name="getTableMetadata_5" access="private" output="false" returntype="query">
		<cfargument name="table" type="string" required="true" />
		
		<cfset var qTable = "" />
		<!--- get table column info, borrowed from Reactor --->
		<cfquery name="qTable" datasource="#getDsn()#">
			SELECT COLUMN_NAME,
			CASE
				WHEN IS_NULLABLE = 'Yes' AND COLUMN_DEFAULT IS NULL THEN 'true'
				ELSE 'false'
			END as nullable,
			DATA_TYPE as type_name,
			CASE
				WHEN CHARACTER_MAXIMUM_LENGTH IS NULL THEN 0
				ELSE CHARACTER_MAXIMUM_LENGTH
			END as length,
			CASE
				WHEN EXTRA = 'auto_increment' THEN 'true'
				ELSE 'false'
			END as identity
			FROM information_schema.COLUMNS
			WHERE TABLE_SCHEMA = Database() AND TABLE_NAME = <cfqueryparam cfsqltype="cf_sql_varchar" scale="128" value="#arguments.table#" />
		</cfquery>
		<cfreturn qTable />
	</cffunction>
	<!--- MySQL 4.1 support thanks to Josh Nathanson --->
	<cffunction name="getTableMetadata_41" access="private" output="false" returntype="query">
		<cfargument name="table" type="string" required="true" />
		
		<cfset var qTable_pre = "" />
		<cfset var qTable = "" />
		<cfset var lgth = "" />
		<cfset var typ = "" />
		<cfset var lgth_str = "" />

		<cfquery name="qTable_pre" datasource= "#getDsn()#">
			DESCRIBE #arguments.table#
		</cfquery>

		<cfset qTable = QueryNew("COLUMN_NAME, nullable, type_name, length, identity")>

		<cfoutput query="qTable_pre">
			<!--- set type and length --->
			<cfset lgth = REFind("[0-9]+",Type,1,true)>
			<cfset typ = REFind("[a-zA-Z]+",Type,1,true)>
			<cfif lgth.len[1]> 
			<!--- if lgth is found by REFind, return struct - lgth.len[1] will be nonzero --->
				<cfset lgth_str = Mid(Type,lgth.pos[1],lgth.len[1])>
			<cfelse>
				<cfset lgth_str = "0">
			</cfif>
			<cfset typ_str = Mid(Type,typ.pos[1],typ.len[1])> <!--- there will always be a type --->
		
			<cfset QueryAddRow(qTable)>
			<cfset QuerySetCell(qTable,"COLUMN_NAME",Field)>
			<cfif Null is "Yes">
				<cfset QuerySetCell(qTable, "nullable", "true")>
			<cfelse>
				<cfset QuerySetCell(qTable, "nullable", "false")>
			</cfif>
			<cfset QuerySetCell(qTable, "type_name", typ_str)>
			<cfset QuerySetCell(qTable, "length", lgth_str)>
			<cfif Extra is "auto_increment">
				<cfset QuerySetCell(qTable, "identity", "true")>
			<cfelse>
				<cfset QuerySetCell(qTable, "identity", "false")>
			</cfif>
	
		</cfoutput>

		<cfreturn qTable />
	</cffunction>

	
	<cffunction name="getPrimaryKeyList" access="private" output="false" returntype="string">
		<cfargument name="table" type="string" required="true" />
		
		<cfif isMySQL5plus()>
			<cfreturn getPrimaryKeyList_5( arguments.table ) />
		<cfelse>
			<cfreturn getPrimaryKeyList_41( arguments.table ) />
		</cfif>
	</cffunction>
	<cffunction name="getPrimaryKeyList_5" access="private" output="false" returntype="string">
		<cfargument name="table" type="string" required="true" />
		
		<cfset var qPrimaryKeys = "" />
		<cfset var lstPrimaryKeys = "" />
		<cfquery name="qPrimaryKeys" datasource="#getDsn()#">
			SELECT COLUMN_NAME
			FROM information_schema.COLUMNS
			WHERE TABLE_SCHEMA = Database()
			AND TABLE_NAME = <cfqueryparam cfsqltype="cf_sql_varchar" scale="128" value="#arguments.table#" />
			AND	COLUMN_KEY = <cfqueryparam cfsqltype="cf_sql_varchar" value="PRI" />
		</cfquery>
		<cfreturn valueList(qPrimaryKeys.column_name) />
	</cffunction>
	<!--- MySQL 4.1 support thanks to Josh Nathanson --->
	<cffunction name="getPrimaryKeyList_41" access="private" output="false" returntype="string">
		<cfargument name="table" type="string" required="true" />
		
		<cfset var qPrimaryKeys_pre = "" />
		<cfset var qPrimaryKeys = "" />
		<cfset var lstPrimaryKeys = "" />
		
		<cfquery name="qPrimaryKeys_pre" datasource= "#getDsn()#">
		DESCRIBE #arguments.table#
		</cfquery>
		
		<cfquery name="qPrimaryKeys" dbtype="query">
		SELECT Field AS COLUMN_NAME FROM qPrimaryKeys_pre
		WHERE [Key] = <cfqueryparam cfsqltype="cf_sql_varchar" value="PRI" />
		</cfquery>

		<cfreturn valueList(qPrimaryKeys.column_name) />
	</cffunction>

</cfcomponent>