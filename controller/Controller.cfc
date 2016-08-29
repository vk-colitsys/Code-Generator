<cfcomponent output="false" hint="I am a Model-Glue controller." extends="ModelGlue.gesture.controller.Controller">

	<cffunction name="init" access="public" output="false" hint="Constructor">
		<cfargument name="framework" />
		
		<cfset super.init(framework) />
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getDSNs" access="public" returntype="void" output="false">
		<cfargument name="event" />
		
		<cfscript>
			event.setValue('datasources', beans.dsnService.getDatasources());
			return;
		</cfscript>
	</cffunction>
	
	<cffunction name="getDSN" access="public" returntype="void" output="false">
		<cfargument name="event" />
		
		<cfscript>
			var dsn = event.getValue('dsn');
			event.setValue('datasource', beans.dsnService.getDatasource(dsn));
			return;
		</cfscript>
	</cffunction>
	
	<cffunction name="getTables" access="public" returntype="void" output="false">
		<cfargument name="event" />
		
		<cfscript>
			if(not event.exists('datasource')){
				getDsn(event);
			}			
			event.setValue("tables", event.getValue('datasource').getDbms().getTables());
			return;
		</cfscript>
	</cffunction>
	
	<cffunction name="getProjectTemplates" access="public" returntype="void" output="false">
		<cfargument name="event" />
		
		<cfscript>
			event.setValue('templates', beans.templateService.getProjectTemplates());
			return;
		</cfscript>
	</cffunction>
	
	<cffunction name="applyTemplate" access="public" returntype="void" output="false">
		<cfargument name="event" />
		
		<cfscript>
			var tableXml = "";
			var template = event.getValue('template', 'default');
			var tables = event.getValue('tables');
			var table = "";
			var files = "";
			var i = 0;
			var n = 0;
			var rootpath = event.getValue('rootpath', GetTempDirectory() & Hash(Now()) );

			event.setValue('rootpath', rootpath); // should it have been defaulted
			
			if(not event.exists('datasource')){
				getDsn(event);
			}

			for(i=1; i LTE ListLen(tables); i=i+1){
				table = ListGetAt(tables, i);
				tableXml = event.getValue('datasource').getDbms().getTableXml(table, "");
				beans.templateService.applyTemplate(table, tableXml, template, rootpath);
			}
		</cfscript>
	</cffunction>	
	
	<cffunction name="zipFiles" access="public" returntype="void" output="false">
		<cfargument name="event" />
		
		<cfset var filename = Hash(Now()) & '.zip' />
		<cfset var rootpath = event.getValue('rootpath') />
		<cfset var filecontent = "" />

		<cfzip action="zip" file="#GetTempDirectory()#/#filename#" source="#rootpath#" />

		<cffile action="readBinary" file="#GetTempDirectory()#/#filename#" variable="filecontent"  />
		
		<cfdirectory action="delete" directory="#rootpath#" recurse="true" />
		<cffile action="delete" file="#GetTempDirectory()#/#filename#" />
		
		<cfset event.setValue("zipFileContent", filecontent) />
	</cffunction>

</cfcomponent>
	
