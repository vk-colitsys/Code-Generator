<cfset variables.zipFileContent = event.getValue('zipFileContent') />
<cfset variables.dsn = event.getValue('dsn') />


<cfheader name="Content-Disposition" value="attachment;filename=#dsn#_generated_cfcs.zip" />
<cfcontent type="application/octet-stream" variable="#zipFileContent#" reset="true" />