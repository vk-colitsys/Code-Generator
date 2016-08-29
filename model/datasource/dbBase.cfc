<cfcomponent output="false" hint="Base component for database implementations">
	
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="dsn" type="string" required="true" />
		
		<cfset setDSN(arguments.dsn) />
		<cfreturn this />
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
		<cfoutput>
		<root>
			<bean name="#listLast(arguments.componentPath,'.')#" path="#arguments.componentPath#">
				<dbtable name="#arguments.table#">
				<cfloop query="tableMetadata">
					<column name="#column_name#"
							type="#translateDataType(listFirst(type_name," "), length, listFind(primaryKeyList,column_name))#"
							cfSqlType="#translateCfSqlType(listFirst(type_name," "))#"
							required="#yesNoFormat(nullable-1)#"
							length="#length#"
							primaryKey="#yesNoFormat(listFind(primaryKeyList,column_name))#"
							identity="#identity#" />
				</cfloop>
				</dbtable>
			</bean>
		</root>
		</cfoutput>
		</cfxml>
		<cfreturn xmlTable />
	</cffunction>

	<cffunction name="setDSN" access="private" output="false" returntype="void">
		<cfargument name="dsn" type="string" required="true" />
		<cfset variables.dsn = arguments.dsn />
	</cffunction>
	
	<cffunction name="getDSN" access="private" output="false" returntype="string">
		<cfreturn variables.dsn />
	</cffunction>

</cfcomponent>