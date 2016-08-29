<cfcomponent output="false">
	<cfscript>
		this.name = "nextgenerator";
		this.sessionManagement = true;
		this.sessionTimeout = createTimeSpan(0,0,30,0);
	</cfscript>

	<cffunction name="onSessionStart"  output="false">
		<cfset request._modelglue.bootstrap.sessionStart = true />
	</cffunction>

	<cffunction name="onRequest">
		<cfsetting enablecfoutputonly="true" />
		<cfinclude template="/ModelGlue/gesture/ModelGlue.cfm" />
	</cffunction>

	<cffunction name="onSessionEnd" output="false">
		<cfargument name="sessionScope" type="struct" required="true">
		<cfargument name="appScope" 	type="struct" required="false">
	
		<cfset invokeSessionEvent("modelglue.onSessionEnd", arguments.sessionScope, appScope) />
	</cffunction>

	<cffunction name="invokeSessionEvent" output="false" access="private">
		<cfargument name="eventName" />
		<cfargument name="sessionScope" />
		<cfargument name="appScope" />
	
		<cfset var mgInstances = createObject("component", "ModelGlue.Util.ModelGlueFrameworkLocator").findInScope(appScope) />
		<cfset var values = structNew() />
		<cfset var i = "" />
	
		<cfset values.sessionScope = arguments.sessionScope />
	
		<cfloop from="1" to="#arrayLen(mgInstances)#" index="i">
			<cfset mgInstances[i].executeEvent(arguments.eventName, values) />
		</cfloop>
	</cffunction>
</cfcomponent>