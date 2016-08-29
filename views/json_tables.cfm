<cfset variables.tables = event.getValue('tables', '#QueryNew("")#') />
<cfsetting showdebugoutput="false">
<cfcontent type="text/plain" reset="true"/><cfoutput>{<cfloop query="tables">"#JsStringFormat(tablename)#":"#JsStringFormat(tablename)#"<cfif currentRow LT tables.recordcount>,</cfif></cfloop>}</cfoutput>