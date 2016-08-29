<cfset variables.datasources = event.getValue('datasources') />
<cfset variables.templates = event.getValue('templates') />

<cfoutput>
	<cfif not ArrayLen(datasources)>
		<h1 class="title">Oops, no datasources have been found!</h1>
		<p> This is usually caused by 1 of 2 problems:</p>
		<ol>
			<li>You have not configured the application correctly. You
				must set your Coldfusion / Railo administrator password in 
				<strong>/config/coldspring.xml</strong>.</li>
			
			<li>There are no datasources setup for your ColdFusion / Railo instance. We can't do
				much without datasources!</li>
		</ol>
	<cfelse>
		<h1 class="title">next-gen cf code generator</h1>
		<p>	Generating code has never been so simple, simply choose a datasource then pick how you'd like
			your code output:</p>
			
		<form id="generatorform" action="" method="post">
			<fieldset>
				<h2 class="title first">1. Choose datasource &amp; tables</h2>
	
				<dl>
					<dt><label for="dsn">Datasource:</label></dt>
					<dd>
						<select name="dsn" id="dsn" size="1">
							<option value="">Please choose...</option>
							<cfloop from="1" to="#ArrayLen(datasources)#" index="variables.i">
								<option value="#datasources[i].getDsnName()#">#datasources[i].getDsnName()#</option>
							</cfloop>
						</select>
					</dd>
					 <dd class="clear"/>
				</dl>
				
				<dl>
					<dt><label for="tables">Tables:</label></dt>
					<dd>
						<select name="tables" id="tables" size="5" multiple="true">
						</select>
					</dd>
					 <dd class="clear"/>
				</dl>

			</fieldset>
			
			<fieldset>
				<h2 class="title">2. Configure code output</h2>
	
				<dl>
					<dt><label for="template">Project template:</label></dt>
					<dd>
						<select name="template" id="template" size="1">
							<option value="">Please choose...</option>
							<cfloop from="1" to="#ArrayLen(templates)#" index="variables.i">
								<option value="#templates[i]#">#templates[i]#</option>
							</cfloop>
						</select>
					</dd>
					 <dd class="clear"/>
				</dl>
				
				<dl>
		        	<dt><label for="event">Format:</label></dt>
		            <dd id="formats">
		            	<input type="radio" value="action.zip" id="formatZip" name="event" checked="checked" /><label class="opt" for="formatZip">Zip file</label>
		                <input type="radio" value="action.writetoserver" id="formatServer" name="event" /><label class="opt" for="formatServer">Direct to server</label>
		            </dd>
		            <dd class="clear"/>
		        </dl>
		        
		        <dl>
		        	<dt><label for="rootpath">Path:</label></dt>
		            <dd>
		            	<input type="select" class="text" name="rootpath" id="rootpath" value="#GetDirectoryFromPath(GetBaseTemplatePath())#generated-files" />
		            </dd>
		             <dd class="clear"/>
		        </dl>

			</fieldset>
			
			<fieldset class="action">
				<input id="submit" class="submit" type="submit" value="Generate!" name="submit"/>				
				<br class="clear" />
			</fieldset>
		</form>
	</cfif>
</cfoutput>
