
<cfscript>
	
	param name="form.html" type="string" default="";
	
	// Create our JSoup class. The class mostly has static methods for parsing so we
	// don't need to initialize it. 
	jSoupClass = createObject( "java", "org.jsoup.Jsoup" );

	// Parse the incoming HTML into a jSoup DOM (Document Object Model).
	dom = jSoupClass.parse( javaCast( "string", form.html ) );
	
	
	// Get the STYLE attributes.
	styleNodes = dom.select( "style" );
	
	styleNodes.remove();
	
	
	styleContent = "";
	
	for ( styleNode in styleNodes ){
		
		styleContent &= styleNode.html();
		
	}
	
	cssRules = reMatch( "[^{]+\{[^}]*\}", styleContent );
	
	writeDump(cssRules);
	abort;
	
	
	
</cfscript>

<cfcontent
	type="text/html; charset=utf-8"
	variable="#toBinary( toBase64( dom.toString() ) )#"
	/>
	