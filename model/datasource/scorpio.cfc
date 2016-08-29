<cfcomponent name="scorpio" extends="dbBase" output="false">
	
	<cffunction name="getTables" access="public" output="false" returntype="query">
		<cfset var qAllTables = "" />
		<cfset objTable = "" />
		
		<cfif not len(getDsn())>
			<cfthrow message="you must provide a dsn" />
		</cfif>
		<cfdbinfo datasource="#getDsn()#" name="qAllTables" type="tables" />
		<cfquery name="qAllTables" dbtype="query">
			SELECT	table_name as tablename,
					table_type as tabletype
			FROM	qAllTables
		</cfquery>
		<cfreturn qAllTables />
	</cffunction>
	
	<cffunction name="getTableXML" access="public" output="false" returntype="xml">
		<cfargument name="table" type="string" required="true" />
		<cfargument name="componentPath" type="string" required="true" />
		
		<cfset var xmlTable = "" />
		<cfset var tableMetadata = getTableMetaData( arguments.table ) />
		<cfset var primaryKeyList = getPrimaryKeyList( arguments.table ) />
		
		<!--- convert the table data into an xml format --->
		<!--- added listfirst to the sql_type because identity is sometimes appended --->
		<cfxml variable="xmlTable">
		<!--- NOTE: no way to get identity as of RC1 --->
		<cfoutput>
		<root>
			<bean name="#listLast(arguments.componentPath,'.')#" path="#arguments.componentPath#">
				<dbtable name="#arguments.table#">
				<cfloop query="tableMetadata">
					<column name="#column_name#"
							type="#translateDataType(listFirst(type_name," "), column_size, is_primarykey )#"
							cfSqlType="#translateCfSqlType(listFirst(type_name," "))#"
							required="#is_nullable#"
							length="#column_size#"
							primaryKey="#is_primarykey#"
							identity="false" />
				</cfloop>
				</dbtable>
			</bean>
		</root>
		</cfoutput>
		</cfxml>
		<cfreturn xmlTable />
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
			<!--- oracle specific --->
			<cfcase value="rowid">
				<cfreturn "cf_sql_varchar" />
			</cfcase>
			<cfcase value="date">
				<cfreturn "cf_sql_timestamp" />
			</cfcase>
			<cfcase value="timestamp(6)">
				<cfreturn "cf_sql_date" />
			</cfcase>
			<cfcase value="varchar2">
				<cfreturn "cf_sql_varchar" />
			</cfcase>
			<cfcase value="nvarchar2">
				<cfreturn "cf_sql_varchar" />
			</cfcase>
			<cfcase value="blob">
				<cfreturn "cf_sql_blob" />
			</cfcase>
			<cfcase value="clob">
				<cfreturn "cf_sql_clob" />
			</cfcase>
			<cfcase value="nclob">
				<cfreturn "cf_sql_clob" />
			</cfcase>
			<cfcase value="long">
				<cfreturn "cf_sql_longvarchar" />
			</cfcase>
			<cfcase value="long raw">
				<!--- @@Note: may need "tobinary(ToBase64(x))" when updating --->
				<cfreturn "cf_sql_longvarbinary" />
			</cfcase>
			<cfcase value="raw">
			   <!--- @@Note: may need "tobinary(ToBase64(x))" when updating --->
				<cfreturn "cf_sql_varbinary" />
			</cfcase>
			<cfcase value="number">
				<cfreturn "cf_sql_numeric" />
			</cfcase>
			<cfdefaultcase>
				<!--- 
					this is required because of a bug in cfdbinfo as of RC1 regarding
					and because this function may be missing some types for previously unsupported db types
				  --->
				<cfreturn "cf_sql_varchar" />
			</cfdefaultcase>
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
			<!--- oracle specific --->
			<cfcase value="rowid">
				<cfreturn "string" />
			</cfcase>
			<cfcase value="date">
				<cfreturn "date" />
			</cfcase>
			<cfcase value="timestamp(6)">
				<cfreturn "date" />
			</cfcase>
			<cfcase value="varchar2">
				<cfreturn "string" />
			</cfcase>
			<cfcase value="nvarchar2">
				<cfreturn "string" />
			</cfcase>
			<cfcase value="blob">
				<cfreturn "binary" />
			</cfcase>
			<cfcase value="clob">
				<cfreturn "string" />
			</cfcase>
			<cfcase value="nclob">
				<cfreturn "string" />
			</cfcase>
			<cfcase value="long">
				<cfreturn "string" />
			</cfcase>
		   <cfcase value="long raw">
				<cfreturn "binary" />
			</cfcase>
			<cfcase value="raw">
				<cfreturn "binary" />
			</cfcase>
			<cfcase value="number">
				<cfreturn "numeric" />
			</cfcase>
			<cfdefaultcase>
				<!--- 
					this is required because of a bug in cfdbinfo as of RC1 regarding
					and because this function may be missing some types for previously unsupported db types
				  --->
				<cfreturn "string" />
			</cfdefaultcase>
		</cfswitch>
	</cffunction>
	
	<cffunction name="getTableMetadata" access="private" output="false" returntype="query">
		<cfargument name="table" type="string" required="true" />
		
		<cfset var qTable = "" />
		<!--- get table column info --->
		<cfdbinfo datasource="#getDsn()#" name="qTable" type="columns" table="#arguments.table#" />
		<cfreturn qTable />
	</cffunction>

</cfcomponent>