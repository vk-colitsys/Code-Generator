<cfcomponent name="Postgresql" extends="dbBase" output="false">
		
	<cffunction name="getTables" access="public" output="false" returntype="query">
		<cfset var qAllTables = "" />
		<cfset objTable = "" />
		
		<cfif not len(getDsn())>
			<cfthrow message="you must provide a dsn" />
		</cfif>
		<cfquery name="qAllTables" datasource="#getDsn()#">
			SELECT table_name
				,CASE WHEN table_type = 'BASE TABLE' 
					THEN 'TABLE' 
					ELSE table_type 
				END 
			FROM information_schema.tables
			WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
			ORDER BY table_name
		</cfquery>
		<cfquery name="qAllTables" dbtype="query">
			SELECT	table_name as tablename,
					table_type as tabletype
			FROM	qAllTables
		</cfquery>
		<cfreturn qAllTables />
	</cffunction>
		
	<!--- these functions are modified from reactor --->
	<cffunction name="translateCfSqlType" access="private" hint="I translate the Postgres data type names into ColdFusion cf_sql_xyz names" output="false" returntype="string">
		<cfargument name="typeName" hint="I am the type name to translate" required="yes" type="string" />
		<cfswitch expression="#lcase(arguments.typeName)#">
			<!--- time --->
			<cfcase value="date">
				<cfreturn "cf_sql_timestamp" />
			</cfcase>
			<cfcase value="timestamp">
				<cfreturn "cf_sql_timestamp" />
			</cfcase>

			<!--- bit / bool --->
			<cfcase value="bit">
				<cfreturn "cf_sql_bit" />
			</cfcase>
			<cfcase value="bool,boolean">
				<cfreturn "cf_sql_varchar" />
			</cfcase>

			<!--- numerics --->
			<cfcase value="oid">
				<cfreturn "cf_sql_integer" />
			</cfcase>
			<cfcase value="smallint">
				<cfreturn "cf_sql_smallint" />
			</cfcase>
			<cfcase value="integer,int,serial">
				<cfreturn "cf_sql_integer" />
			</cfcase>
			<cfcase value="bigint,bigserial">
				<cfreturn "cf_sql_bigint" />
			</cfcase>
			<cfcase value="numeric,smallmoney,money">
				<!--- postgres has deprecated the money type: http://www.postgresql.org/docs/8.1/static/datatype-money.html --->
				<cfreturn "cf_sql_numeric" />
			</cfcase>
			<cfcase value="real">
				<cfreturn "cf_sql_real" />
			</cfcase>
			<cfcase value="decimal,double precision,float">
				<cfreturn "cf_sql_decimal" />
			</cfcase>
			
			<!--- binary --->
			<cfcase value="bytea">
				<cfreturn "cf_sql_binary" />
			</cfcase>

			<!--- strings --->
			<cfcase value="char,character">
				<cfreturn "cf_sql_char" />
			</cfcase>
			<cfcase value="varchar,character varying">
				<cfreturn "cf_sql_varchar" />
			</cfcase>
			<cfcase value="text">
				<cfreturn "cf_sql_longvarchar" />
			</cfcase>
		</cfswitch>
		<cfthrow message="Unsupported (or incorrectly supported) database datatype: #arguments.typeName#." />
	</cffunction>
	
	<cffunction name="translateDataType" access="private" hint="I translate the Postgres data type names into ColdFusion data type names" output="false" returntype="string">
		<cfargument name="typeName" hint="I am the type name to translate" required="yes" type="string" />
		<cfargument name="length" hint="I am the length of the column" required="no" type="numeric" default="0" />
		<cfargument name="isPrimaryKey" hint="I am a flag indicating that the column is a primary key" required="no" type="boolean" default="false" />
		
		<cfswitch expression="#arguments.typeName#">
			<cfcase value="smallint,int,integer,bigint,serial,bigserial">
				<cfreturn "numeric" />
			</cfcase>
			<cfcase value="bytea">
				<cfreturn "string" />
			</cfcase>
			<cfcase value="bit,bool,boolean">
				<cfreturn "boolean" />
			</cfcase>
			<cfcase value="char,character">
				<cfif arguments.length EQ 35 AND arguments.isPrimaryKey>
					<cfreturn "uuid" />
				</cfif>
				<cfreturn "string" />
			</cfcase>
			<cfcase value="char,character">
				<cfreturn "string" />
			</cfcase>
			<cfcase value="date,time,timestamp">
				<cfreturn "date" />
			</cfcase>
			<cfcase value="decimal,double,float,money,numeric,real">
				<cfreturn "numeric" />
			</cfcase>
		</cfswitch>

		<cfthrow message="Unsupported (or incorrectly supported) database datatype: #arguments.typeName#." />

	</cffunction>
	
	<cffunction name="getTableMetadata" access="private" output="false" returntype="query">
		<cfargument name="table" type="string" required="true" />
		
		<cfset var qTable = "" />
		<!--- get table column info --->
		<!--- This is a modified version of the query in sp_columns --->
		<cfquery name="qTable" datasource="#getDsn()#">
			SELECT COLUMN_NAME
				,CASE
					WHEN IS_NULLABLE = 'Yes' AND COLUMN_DEFAULT IS NULL THEN 'true'
					ELSE 'false'
				END AS nullable
				,DATA_TYPE AS type_name
				,CASE
					WHEN CHARACTER_MAXIMUM_LENGTH IS NULL THEN 0
					ELSE CHARACTER_MAXIMUM_LENGTH
				END as length
				,CASE
					WHEN data_type = 'serial' THEN 'true'
					WHEN data_type = 'bigserial' THEN 'true'
					ELSE 'false'
				END AS identity
			FROM information_schema.COLUMNS
			WHERE TABLE_NAME = <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="128" value="#arguments.table#" />
		</cfquery>
		<cfreturn qTable />
	</cffunction>
		
	<cffunction name="getPrimaryKeyList" access="private" output="false" returntype="string">
		<cfargument name="table" type="string" required="true" />
		
		<cfset var qPrimaryKeys = "" />

		<cfquery name="qPrimaryKeys" datasource="#getDsn()#">
			SELECT column_name 
			FROM information_schema.table_constraints a
				,information_schema.key_column_usage b
			WHERE a.table_name = b.table_name
			AND a.constraint_name = b.constraint_name
			AND a.constraint_type = <cfqueryparam cfsqltype="cf_sql_varchar" value="PRIMARY KEY" />
			AND a.table_name = <cfqueryparam cfsqltype="cf_sql_varchar" scale="128" value="#arguments.table#" />
		</cfquery>

		<cfreturn lstPrimaryKeys />
	</cffunction>

</cfcomponent>