<cfcomponent name="railoAdminAPIFacade" output="false" hint="Railo version of the wrapper for admiapi functions">
	<cffunction name="init" access="public" output="false" returntype="adminAPIFacadeRailo">
		<cfargument name="administratorPassword" type="string" required="true" />
		
		<cfset variables.arrDSNs = arrayNew(1) />
		<cfset setDatasources(arguments.administratorPassword) />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="setDatasources" access="public" output="false" returntype="void">
		<cfargument name="administratorPassword" type="string" required="true" />
		
		<cfset var dsns = "" />
		<cfset var objDatasource = "" />
		<cfset var thisType = "" />

		<cfadmin action="getDatasources" returnVariable="dsns" password="#arguments.administratorPassword#" type="web" />

		<cfloop query="dsns">
			<cfset thisType = classToType(classname) />
			<cfif len(thisType)>
				<cfset objDatasource = createObject("component","datasource.datasource").init(name,thisType) />
				<cfset arrayAppend(variables.arrDSNs, objDatasource) />
			</cfif>
		</cfloop>
	</cffunction>
	
	<cffunction name="getDatasources" access="public" output="false" returntype="array">
		<cfreturn variables.arrDSNs />
	</cffunction>
	
	<cffunction name="getDatasource" access="public" output="false" returntype="datasource.datasource">
		<cfargument name="datasource" type="string" required="true" />
		<cfset var returnDSN = "" />
		<cfset var i = 0 />
		<cfloop from="1" to="#arrayLen(variables.arrDSNs)#" index="i">
			<cfif variables.arrDSNs[i].getDsnName() EQ arguments.datasource>
				<cfset returnDSN = variables.arrDSNs[i] />
			</cfif>
		</cfloop>
		<cfreturn returnDSN />
	</cffunction>
	
	<cffunction name="classToType" access="private" output="false" returntype="string">
		<cfargument name="classname" required="true" type="string" />
		
		<cfif arguments.classname contains "mySQL">
			<cfreturn "mysql" />
		<cfelseif arguments.classname contains "Oracle">
			<cfreturn "oracle" />
		<cfelseif arguments.classname contains "Informix">
			<cfreturn "informix" />
		<cfelseif arguments.classname contains "postgresql">
			<cfreturn "postgresql" />
		<cfelseif arguments.classname contains "MSSQLServer" or arguments.classname contains "sqlserver" or arguments.classname contains "jtds">
			<cfreturn "mssql" />
		<cfelse><!--- not a supported type --->
			<cfreturn "" />
		</cfif>
	</cffunction>
	
</cfcomponent>