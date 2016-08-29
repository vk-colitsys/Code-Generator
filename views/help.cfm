<cfoutput>
	<h1 class="title">Help me please!</h1>
	<p> <a href="##datasources">I don't see any datasources</a><br />
		<a href="##templates">I want to create my own templates</a><br />
		<a href="##extending">I want to extend the code</a>
	</p>
	
	<h2 id="datasources">I don't see any datasources</h2>
	<p> This is usually caused by 1 of 2 problems:</p>
	<ol>
		<li>You have not configured the application correctly. You
			must set your Coldfusion / Railo administrator password in 
			<strong>/config/coldspring.xml</strong>. This is passed as a constructor argument
			to the <strong>dsnService</strong> bean (the last bean definition, easy to find).
		</li>
		
		<li>There are no datasources setup for your ColdFusion / Railo instance.</li>
	</ol>
	
	<h2 id="templates">I want to create my own templates</h2>

	<p> Custom templates are organised into projects which can be found at: <strong>/config/nextgen/projects</strong>.
		To create a new project, simply drop in a new folder with the name you'd like for your project; this
		will now appear in the 'project template' drop down in the generator form.
	</p>
	<h3>Getting started</h3>
	<p> Probably the best way to get started is to copy and adapt an existing project. With even
		a very basic understanding of xslt, and as a cf developer, you will probably find you can
		get by without the documentation that follows below.</p>
	
	<h3>Configuration</h3>
	<p> Every project must have a configuration xml file named yac.xml (yet another config) that sits in the root of 
		the project folder. This file defines the files that are to be generated for each table, and the 
		transformer includes with which to generate them. The config is made up of the following xml elements:</p>
		
	<div class="domsbox">
		<h4>generator</h4>
		<p>	The root element, no attributes. Can contain <em>file</em> elements.</p>

	
		<h4>file</h4>
		<p> Defines a file that is to be generated for each table, e.g. a DAO cfc. Can contain <em>include</em> elements and 
			has the following attributes: </p>
		<ul>
			<li>name (required): e.g. dao, service, gateway, etc.</li>
			<li>transformer (optional): relative path to the transformer template for this file, defaults to [name].[templatetype]</li>
			<li>filetype (optional): the extension of the generated file, defaults to 'cfc'</li>
			<li>templatetype (optional): either 'xsl' or 'cfm', defaults to 'xsl'</li>
			<li>directory (optional): generated files will be created in this subdirectory, defaults to [name]</li>
			<li>filenameAppend (optional): string to be appended to the generated filename</li>
			<li>filenamePrepend (optional): string to be prepended to the generated filename</li>
		</ul>
		
		<p> Generated files will be named: [directory]/[filenamePrepend][tablename][filenameAppend].[filetype]</p>
	
		<h4>include</h4>
		<p> Defines a transformer to be included in the file generation. Contains no child elements and one attribute:</p>
		<ul>
			<li>file (required): relative path to the include. Must be either an 'xsl' or 'cfm' template, 
				dependant on the parent <em>file</em> element's templatetype attribute.</li>
		</ul>
	</div>
	
	<h3>Transformer templates</h3>
	<p>	Transformer templates can be either cfm or xslt templates (this is defined in yac.xml, <em>file > templatetype</em>).
		Each template will transform a table xml definition that takes the form:</p>
		
	<pre class="prettyprint"><a id="Details"><span class="pun"><</span><span class="tag">root</span><span class="pun">></span><span class="pln"><br/>        </span><span class="pun"><</span><span class="tag">bean</span><span class="pln"> </span><span class="atn">name</span><span class="pun">=</span><span class="atv">"name"</span><span class="pln"> </span><span class="atn">path</span><span class="pun">=</span><span class="atv">"dot.notation.path"</span><span class="pun">></span><span class="pln"><br/>                </span><span class="pun"><</span><span class="tag">dbtable</span><span class="pln"> </span><span class="atn">name</span><span class="pun">=</span><span class="atv">"tableName"</span><span class="pun">></span><span class="pln"><br/>                        </span><span class="pun"><</span><span class="tag">column</span><span class="pln"> </span><span class="atn">name</span><span class="pun">=</span><span class="atv">"columnName"</span><span class="pln"><br/>                                </span><span class="atn">type</span><span class="pun">=</span><span class="atv">"cfDataType"</span><span class="pln"><br/>                                </span><span class="atn">cfSqlType</span><span class="pun">=</span><span class="atv">"cfSQLDataType"</span><span class="pln"><br/>                                </span><span class="atn">required</span><span class="pun">=</span><span class="atv">"yes|no"</span><span class="pln"><br/>                                </span><span class="atn">length</span><span class="pun">=</span><span class="atv">"##"</span><span class="pln"><br/>                                </span><span class="atn">primaryKey</span><span class="pun">=</span><span class="atv">"yes|no"</span><span class="pln"><br/>                                </span><span class="atn">identity</span><span class="pun">=</span><span class="atv">"true|false"</span><span class="pln"> </span><span class="pun">/></span><span class="pln"><br/>                </span><span class="pun"><</span><span class="pun">/</span><span class="tag">dbtable</span><span class="pun">></span><span class="pln"><br/>        </span><span class="pun"><</span><span class="pun">/</span><span class="tag">bean</span><span class="pun">></span><span class="pln"><br/></span><span class="pun"><</span><span class="pun">/</span><span class="tag">root</span><span class="pun">></span></a></pre>
	
	
	<h2 id="extending">I want to extend the code</h2>
	<p> If you're familiary with Model-Glue and ColdSpring, then hopefully the code is transparent. If you're
		not, I suggest reading the tutorials and docs, you'll never turn back!</p>
		
	<ul>
		<li><a href="http://www.model-glue.com/">Model Glue</a></li>
		<li><a href="http://www.coldspringframework.org/">ColdSpring</a></li>
	</ul>
</cfoutput>