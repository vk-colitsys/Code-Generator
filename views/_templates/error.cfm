<cfset variables.exception = event.getValue('exception') />
<cfparam name="exception.message" default="Unknown error" />

<cfheader statuscode="500" />
<cfoutput><h1 class="title">Oops, an error occurred</h1>
	<h2>#exception.message#</h2>
	<cfif StructKeyExists(exception, 'detail')>
		<p> #exception.detail#</p>
	</cfif>
	<cfif StructKeyExists(exception, 'tagcontext')>
		<p>
			<cfloop from="1" to="#ArrayLen(exception.tagContext)#" index="variables.i">
				#exception.tagContext[i].template#, Line #exception.tagContext[i].line#	<br />
			</cfloop>
		</p>	
	</cfif>
</cfoutput>