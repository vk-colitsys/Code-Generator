<cfcomponent output="false">

	<cffunction name="init" access="public" returntype="templateService" output="false">
		<cfargument name="xslBasePath" type="string" required="true" />
		
		<cfscript>
			if(DirectoryExists(arguments.xslBasePath)){
				variables.templateBasePath = arguments.xslBasePath;
			} else {
				variables.templateBasePath = ExpandPath( arguments.xslBasePath );
			}
			
			variables.osSeparator = getOSFileSeparator();
			variables.projectsBasePath = CleanPath( ListAppend(templateBasePath, 'projects', osSeparator));
			
			return this;
		</cfscript>

		<cfreturn this />
	</cffunction>

	<cffunction name="getProjectTemplates" access="public" returntype="array" output="false">
		<cfset var qryTemplateFolders = "" />
		<cfset var arrTemplateFolders = arrayNew(1) />

		<cfdirectory name="qryTemplateFolders" action="list" directory="#variables.projectsBasePath#" />
		<cfloop query="qryTemplateFolders">
			<!--- only directories and not the .svn dir if it exists --->
			<cfif qryTemplateFolders.type eq "Dir" and qryTemplateFolders.name neq ".svn">
				<cfset arrayAppend(arrTemplateFolders,qryTemplateFolders.name) />
			</cfif>
		</cfloop>
		<cfreturn arrTemplateFolders />
	</cffunction>

	<cffunction name="applyTemplate" access="public" returntype="query" output="false">
		<cfargument name="tableName" type="string" required="true" />
		<cfargument name="tableXml" type="xml" required="true" />
		<cfargument name="template" type="string" required="false" default="default" />
		<cfargument name="writeToPath" type="string" required="false" />
		
		<cfset var templateFiles = getTemplateFiles( arguments.template ) />
		<cfset var finalQuery = QueryNew('filename,content') />
		
		<cfloop query="templateFiles">
			<cfset QueryAddRow(finalQuery) />
			<cfset QuerySetCell(finalQuery, 'filename', ListAppend(directory, "#prependage##tableName##appendage#.#filetype#", osSeparator))>

			<cfif templateType EQ "cfm">
				<cfset QuerySetCell(finalQuery, 'content', processCFMTemplate(arguments.tableXml, content)) />
			<cfelse>
				<cfset QuerySetCell(finalQuery, 'content', XmlTransform(arguments.tableXml, content))>
			</cfif>
		</cfloop>
		
		<!--- write files if path supplied --->
		<cfif StructKeyExists(arguments, 'writeToPath')>
			<cfloop query="finalQuery">
				<cfset writeFile( arguments.writeToPath & osSeparator & filename, content ) />
			</cfloop>
		</cfif>

		<cfreturn finalQuery />
	</cffunction>

	<cffunction name="getTemplateFiles" access="private" returntype="query" output="false" hint="Gets the details of all the files that a template is to generate">
		<cfargument name="templateName" type="string" required="false" default="default" />

		<cfscript>
			var projectPath = CleanPath( ListAppend(projectsBasePath, arguments.templateName, osSeparator) );
			var config = "";
			var files = QueryNew('name,directory,filetype,appendage,prependage,templatetype,content');
			var i = 0;
			var thisFile = "";
			var templateType = "";
			var thisConfig = "";
			var includes = "";
			
			if(DirectoryExists(projectPath)){
				config = readConfig(projectPath);
				if(StructKeyExists(config.generator, 'file')){
					for(i=1; i LTE ArrayLen(config.generator.file); i=i+1){
						thisFile = config.generator.file[i];
						
						QueryAddRow(files);
						QuerySetCell(files, 'name', thisFile.xmlAttributes.name);
						
						if(StructKeyExists(thisFile.xmlAttributes, 'templatetype')){
							templateType = thisFile.xmlAttributes.templatetype;
						} else {
							templateType = 'xsl';
						}
						QuerySetCell(files, 'templatetype', templatetype);
						
						if(StructKeyExists(thisFile.xmlAttributes, 'filetype')){
							QuerySetCell(files, 'filetype', thisFile.xmlAttributes.fileType);
						} else {
							QuerySetCell(files, 'filetype', 'cfc');
						}
						if(StructKeyExists(thisFile.xmlAttributes, 'filenameAppend')){
							QuerySetCell(files, 'appendage', thisFile.xmlAttributes.filenameAppend);
						} else {
							QuerySetCell(files, 'appendage', '');
						}
						if(StructKeyExists(thisFile.xmlAttributes, 'filenamePrepend')){
							QuerySetCell(files, 'prependage', thisFile.xmlAttributes.filenamePrepend);
						} else {
							QuerySetCell(files, 'prependage', '');
						}
						if(StructKeyExists(thisFile.xmlAttributes, 'directory')){
							QuerySetCell(files, 'directory', thisFile.xmlAttributes.directory);
						} else {
							QuerySetCell(files, 'directory', thisFile.xmlAttributes.name);
						}
						
						includes = XmlSearch(thisFile, '//file[@name="#thisFile.xmlAttributes.name#"]/include');
						
						if(StructKeyExists(thisFile.xmlAttributes, 'transformer')){
							thisConfig = thisFile.xmlAttributes.transformer;
						} else {
							thisConfig = thisFile.xmlAttributes.name & '.' & templateType;
						}
						
						QuerySetCell(files, 'content', buildTemplate(includes, projectPath, thisConfig, templateType) );
					}				
				}
			}
			
			return files;
		</cfscript>
	</cffunction>

	<cffunction name="buildTemplate" access="private" output="false" returntype="string">
		<cfargument name="includes" type="array" required="true" />
		<cfargument name="projectPath" type="string" required="true" />
		<cfargument name="rootConfig" type="string" required="true" />
		<cfargument name="templateType" type="string" required="true" />

		<cfset var innerTemplate = "" />
		<cfset var fileContent = "" />
		<cfset var i = 0 />
		<cfset var incTemplate = "" />
		<cfset var baseTemplate = ListAppend(arguments.projectPath, arguments.rootConfig, osSeparator) />

		<!--- loop through each include and append it to the inner XSL/CFML --->
		<cfloop from="1" to="#arrayLen(arguments.includes)#" index="i">
			<cfset incTemplate = ListAppend(arguments.projectPath, arguments.includes[i].xmlAttributes.file, osSeparator)>

			<cffile action="read" file="#cleanPath(incTemplate)#" variable="fileContent" charset="utf-8" />
			<cfset innerTemplate = innerTemplate & chr(13) & chr(13) & fileContent />
		</cfloop>

		<!--- read the base template and wrap it round the includes --->
		<cffile action="read" file="#cleanPath(baseTemplate)#" variable="fileContent" charset="utf-8" />

		<cfreturn ReplaceNoCase(trim(fileContent),"<!-- custom code -->",trim(innerTemplate)) />
	</cffunction>

	<cffunction name="processCFMTemplate" access="private" output="false" returntype="string">
		<cfargument name="xmlTable" required="true" type="xml" />
		<cfargument name="template" type="string" required="true" />		
		
		<cfset var content = "" />
		<cfset var root = arguments.xmlTable.root />
		<cfset var tempFileName = '#createUUID()#.cfm' />
		<cfset var tempDirPath = getDirectoryFromPath(getCurrentTemplatePath()) & 'temp' />
		
		<cfif not directoryExists(tempDirPath)>
			<cfdirectory action="create" directory="#tempDirPath#">
		</cfif>
		
		<!--- write the cfm to a hard file so it can be dynamically evaluated --->
		<cffile action="write" file="#cleanPath(tempDirPath & osSeparator & tempFileName)#" output="#arguments.template#" />
		<cfsavecontent variable="content">
			<cfinclude template="temp/#tempFileName#" />
		</cfsavecontent>
		<cfset content =  replaceList(content,"<%,%>,%","<,>,##") />
		<cffile action="delete" file="#cleanPath(tempDirPath & osSeparator & tempFileName)#" />
		
		<cfreturn content />
	</cffunction>
	
	<cffunction name="readConfig" access="private" output="false" returntype="xml">		
		<cfargument name="projectPath" type="string" required="true" />
		
		<cfset var configXML = "" />
		<cfset var configPath = cleanPath( ListAppend(arguments.projectPath, "yac.xml", osSeparator)) />

		<cfif fileExists( configPath )>
			<cffile action="read" file="#configPath#" variable="configXML" charset="utf-8" />
		</cfif>

		<cfreturn XmlParse(Trim(configXML)) />
	</cffunction>
	
	<cffunction name="getOSFileSeparator" access="private" returntype="any" output="false" hint="Get the operating system's file separator character. Code supplied by Luis Majano">
        <cfreturn createObject("java","java.lang.System").getProperty("file.separator") />
    </cffunction>
	
	<cffunction name="cleanPath" access="private" returntype="string" output="false">
		<cfargument name="path" type="string" required="true" />
		
		<cfscript>
			var rtn = Trim(arguments.path);

			
			rtn = Replace(rtn, '\', osSeparator, 'all');
			rtn = Replace(rtn, '/', osSeparator, 'all');
			
			while(find(osSeparator & osSeparator, rtn)){
				rtn = Replace(rtn, osSeparator & osSeparator, osSeparator, 'all');
			}
			
			return rtn;		
		</cfscript>
	</cffunction>

	<cffunction name="writeFile" access="private" returntype="boolean" output="false">
		<cfargument name="path" type="string" required="true" />
		<cfargument name="content" type="any" required="true" />
		
		<cfset var cleanedpath = cleanPath(arguments.path) />
		<cfset var directory = GetDirectoryFromPath(cleanedpath) />
		<cfset var collector = ArrayNew(1) />
		<cfset var osSeparator = getOSFileSeparator() />
		<cfset var firstCharIsSeparator = (Left(cleanedpath, 1) EQ osSeparator) />
		<cfset var i = 0 />
		
		
		<!--- figure out how many directories we must write --->
		<cfloop condition="not DirectoryExists(directory) and ListLen(directory,osSeparator)">
			<cfset ArrayAppend(collector, ListLast(directory, osSeparator)) />
			<cfset directory = ListDeleteAt(directory, ListLen(directory, osSeparator), osSeparator) />
		</cfloop>
					
		<cfif directory EQ "" AND firstCharIsSeparator>
			<cfset directory = osSeparator />
		</cfif>		
	
		<!--- write any directories that we must --->
		<cfloop from="#ArrayLen(collector)#" to="1" index="i" step="-1">
			<cfset directory = CleanPath( ListAppend(directory, collector[i], osSeparator) ) />
			<cfdirectory action="create" directory="#directory#" />
		</cfloop>

		
		<!--- finally write the file --->
		<cffile action="write" file="#cleanedpath#" output="#content#" />
		
		<cfreturn true />
	</cffunction>
</cfcomponent>