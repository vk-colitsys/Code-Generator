----------------------------------------------------------
-- 	next-generator, a coldfusion code generator 
--	by dominic watson
----------------------------------------------------------

REQUIREMENTS
----------------------------------------------------------
* ColdFusion MX 7.0.2 or above. 
	- NOTE: This application utlizes the adminAPI, so you must have access to the local ColdFusion server administrator password.

* Railo 3.1 or above
* Currently supports MySQL 4.1 and 5 and MSSQL 2000/2005 and Oracle (contributed by Beth Bowden)
* Running ColdFusion 8 Beta adds limited support for any type of database supported by ColdFusion
	- Access is supported in Unicode mode only
	- Identity field support is not available
	- Unknown data types (due to a bug in the beta) will default to string
	
	
INSTALLATION
----------------------------------------------------------
* Deploy the application to your web server
* Create a mapping, '/nextgenerator', to the application root folder
* Ensure that you have Model-Glue 3+ installed and mapped to '/ModelGlue'
* Ensure that you have ColdSpring 1.2+ installed and mapped to '/coldspring'
* Either:
	- Run the build.xml ant file (in Eclipse, select the file, hold down alt-shift-X then hit Q)
	- Or, edit the application's coldSpring config xml file so that:
		. the dsnService bean takes  your admin api password as its constructor arg (defaults to '[password]'). 
		. the dsnService bean class is set correctly for your server, 
		  ie. for Railo you need nextgenerator.model.adminAPIFacadeRailo and for 
		  ColdFusion you need nextgenerator.model.adminAPIFacade

	
  The ColdSpring config xml file can be found at [installpath]/config/coldspring.xml
  
HELP, CONTACT, ETC
-----------------------------------------------------------
Once the application is installed, help and further details can be 
found from within the application.

Enjoy, Dominic.