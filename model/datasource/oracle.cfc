<cfcomponent name="Oracle" extends="dbBase" output="false">
	
	<cffunction name="getTables" access="public" output="false" returntype="array">
		<cfset var qAllTables = "" />
		<cfset objTable = "" />
		
		<cfif not len(getDsn())>
			<cfthrow message="you must provide a dsn" />
		</cfif>
		<cfquery name="qAllTables" datasource="#getDsn()#">
			SELECT owner
        ,  TABLE_NAME
        , 'TABLE'   TABLE_TYPE
			FROM all_tables
		</cfquery>
		
		<cfquery name="qAllTables" dbtype="query">
			SELECT	TABLE_NAME as tablename,
					TABLE_TYPE as tabletype
			FROM	qAllTables
		</cfquery>
		<cfreturn qAllTables />
	</cffunction>
	
	<!--- these functions are modified from reactor --->
	<cffunction name="translateCfSqlType" access="private" hint="I translate the Oracle data type names into ColdFusion cf_sql_xyz names" output="false" returntype="string">
		<cfargument name="typeName" hint="I am the type name to translate" required="yes" type="string" />
		<cfswitch expression="#lcase(arguments.typeName)#">
        <!--- misc --->
			<cfcase value="rowid">
				<cfreturn "cf_sql_varchar" />
			</cfcase>
			<!--- time --->
			<cfcase value="date">
				<cfreturn "cf_sql_timestamp" />
			</cfcase>
			<cfcase value="timestamp(6)">
				<cfreturn "cf_sql_date" />
			</cfcase>
         <!--- strings --->
			<cfcase value="char">
				<cfreturn "cf_sql_char" />
			</cfcase>
			<cfcase value="nchar">
				<cfreturn "cf_sql_char" />
			</cfcase>
			<cfcase value="varchar">
				<cfreturn "cf_sql_varchar" />
			</cfcase>
			<cfcase value="varchar2">
				<cfreturn "cf_sql_varchar" />
			</cfcase>
			<cfcase value="nvarchar2">
				<cfreturn "cf_sql_varchar" />
			</cfcase>
			<!--- long types --->
			<!---   @@Note: bfile  not supported --->
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
			   <!--- @@Note: may need "tobinary(ToBase64(x))" when updating --->
			<cfcase value="long raw">
				<cfreturn "cf_sql_longvarbinary" />
			</cfcase>
			<cfcase value="raw">
			   <!--- @@Note: may need "tobinary(ToBase64(x))" when updating --->
				<cfreturn "cf_sql_varbinary" />
			</cfcase>
			<!--- numerics --->
			<cfcase value="float">
				<cfreturn "cf_sql_float" />
			</cfcase>
			<cfcase value="integer">
				<cfreturn "cf_sql_numeric" />
			</cfcase>
			<cfcase value="number">
				<cfreturn "cf_sql_numeric" />
			</cfcase>
			<cfcase value="real">
				<cfreturn "cf_sql_numeric" />
			</cfcase>
		</cfswitch>
		<cfthrow message="Unsupported (or incorrectly supported) database datatype: #arguments.typeName#." />
	</cffunction>
	
	<cffunction name="translateDataType" access="private" hint="I translate the Oracle data type names into ColdFusion data type names" output="false" returntype="string">
		<cfargument name="typeName" hint="I am the type name to translate" required="yes" type="string" />
		<cfargument name="length" hint="I am the length of the column" required="no" type="numeric" default="0" />
		<cfargument name="isPrimaryKey" hint="I am a flag indicating that the column is a primary key" required="no" type="boolean" default="false" />

		<cfswitch expression="#arguments.typeName#">
        <!--- misc --->
			<cfcase value="rowid">
				<cfreturn "string" />
			</cfcase>
			<!--- time --->
			<cfcase value="date">
				<cfreturn "date" />
			</cfcase>
			<cfcase value="timestamp(6)">
				<cfreturn "date" />
			</cfcase>
            <!--- strings --->
			<cfcase value="char">
				<cfreturn "string" />
			</cfcase>
			<cfcase value="nchar">
				<cfreturn "string" />
			</cfcase>
			<cfcase value="varchar">
				<cfreturn "string" />
			</cfcase>
			<cfcase value="varchar2">
				<cfif arguments.length EQ 35 AND arguments.isPrimaryKey>
					<cfreturn "uuid" />
				</cfif>
				<cfreturn "string" />
			</cfcase>
			<cfcase value="nvarchar2">
				<cfreturn "string" />
			</cfcase>
			<!--- long --->
			<!---   @@Note: bfile  not supported --->
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
			<!--- numerics --->
			<cfcase value="float">
				<cfreturn "numeric" />
			</cfcase>
			<cfcase value="integer">
				<cfreturn "numeric" />
			</cfcase>
			<cfcase value="number">
				<cfreturn "numeric" />
			</cfcase>
			<cfcase value="real">
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
			 SELECT
             	    col.COLUMN_NAME       as COLUMN_NAME,
                  /* Oracle has no equivalent to autoincrement or  identity */
                  'false'                     AS "IDENTITY",                    
                  CASE
                        WHEN col.NULLABLE = 'Y' AND col.DATA_DEFAULT IS NULL THEN 1 /* a column is defined as nullable only if it doesn't have a default */
                        ELSE 0
                  END                  as NULLABLE,
                 col.DATA_TYPE         as TYPE_NAME,
                  case
                    /* 26 is the length of now() in ColdFusion (i.e. {ts '2006-06-26 13:10:14'})*/
                    when col.data_type = 'DATE'   then 26
                    else col.data_length
                  end                 as length,
                  col.DATA_DEFAULT      as "DEFAULT"
            FROM  all_tab_columns   col,
                  ( select  colCon.column_name,
                 			  colcon.table_name
                  from    all_cons_columns  colCon,
                         all_constraints   tabCon
                  where tabCon.table_name = <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="128" value="#arguments.table#" />
                       AND colCon.CONSTRAINT_NAME = tabCon.CONSTRAINT_NAME
                       AND colCon.TABLE_NAME      = tabCon.TABLE_NAME
                       AND 'P'                    = tabCon.CONSTRAINT_TYPE
                 ) primaryConstraints
            where col.table_name = <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="128" value="#arguments.table#" />
            		and col.COLUMN_NAME        = primaryConstraints.COLUMN_NAME (+)
                  AND col.TABLE_NAME       = primaryConstraints.TABLE_NAME (+)
        order by col.column_id
		</cfquery>
		<cfreturn qTable />
	</cffunction>
	
	<cffunction name="getPrimaryKeyList" access="private" output="false" returntype="string">
		<cfargument name="table" type="string" required="true" />
		
		<cfset var qPrimaryKeys = "" />

		<cfquery name="qPrimaryKeys" datasource="#getDsn()#">
      	select    colCon.column_name,
           		  colcon.CONSTRAINT_NAME  AS PK_NAME
        from    user_cons_columns  colCon,
                user_constraints   tabCon
        where tabCon.table_name = <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="128" value="#arguments.table#" />
        AND colCon.CONSTRAINT_NAME = tabCon.CONSTRAINT_NAME
        AND colCon.TABLE_NAME      = tabCon.TABLE_NAME
        AND 'P'                    = tabCon.CONSTRAINT_TYPE
        order by colcon.POSITION
		</cfquery>
		<cfreturn valueList(qPrimaryKeys.column_name) />
	</cffunction>

</cfcomponent>