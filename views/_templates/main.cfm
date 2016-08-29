<cfset variables.thisEvent = event.getValue("event")>

<cfcontent reset="true" /><cfoutput><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="content-type" content="text/html; charset=utf-8" />
		<title>next-generator, ColdFusion Code Generator</title>
		<meta name="keywords" content="" />
		<meta name="author" content="Dominic Watson" />
		
		<link rel="stylesheet" type="text/css" media="screen" href="views/_css/default.css"  />		
		
		<script type="text/javascript" src="views/_js/jquery-1.3.2/jquery-1.3.2.min.js"></script>
		<script type="text/javascript" src="views/_js/jquery-1.3.2/jquery-selectboxes.min.js"></script>
		<script type="text/javascript" src="views/_js/jquery-1.3.2/jquery-nextgenerator-form.js"></script>
	</head>
	<body>
		<div id="wrapper">
			<div id="logo">
				<h1><a href="?event=page.home">next-generator</a></h1>
				<h2> an old-skool code generator by dominic watson,<br /> Based on the <em>Illudium PU-36 Code Generator</em> by Brian Rinaldi</h2>
			</div>
			<div id="header">
				<div id="menu">
					<ul>
						<li<cfif thisEvent EQ 'page.home'> class="current_page_item"</cfif>><a href="?event=page.home">Generator</a></li>
						<li<cfif thisEvent EQ 'page.about'> class="current_page_item"</cfif>><a href="?event=page.about">About</a></li>
						<li class="last<cfif thisEvent EQ 'page.help'> current_page_item</cfif>"><a href="?event=page.help">Help</a></li>
					</ul>
				</div>
			</div>
		</div>
		
		<div id="page">
			<div id="content">
				<div class="post">
					#viewcollection.getView('body')#
				</div>
			</div>

			<div id="sidebar">
				<ul>
					<li>
						<h2>Related Links</h2>
						<ul>
							<li><a href="http://frankfusion.dominicwatson.co.uk">Frank Fusion Blog</a></li>
							<li><a href="http://code.google.com/p/cfcgenerator/source ">Illudium PU-36 Code Generator</a></li>
							<li><a href="http://riaforge.org">Riaforge</a></li>
							<li><a href="http://www.model-glue.com/">Model Glue</a></li>
							<li><a href="http://www.coldspringframework.org/">ColdSpring</a></li>
						</ul>
					</li>
				</ul>
			</div>

			<div style="clear: both;">&nbsp;</div>
		</div>

		<div id="footer">
			<p id="legal">( c ) 2009 <a href="http://fusion.dominicwatson.co.uk/">Dominic Watson</a>. All Rights Reserved. Designed by <a href="http://www.freecsstemplates.org/">Free CSS Templates</a>.</p>
		</div>
	</body>
</html></cfoutput>