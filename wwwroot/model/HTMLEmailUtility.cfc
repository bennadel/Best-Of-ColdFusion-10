
component
	output="false"
	hint="I provide utility methods for parsing HTML markup and preparing it for use within HTML emails (which have much less support for CSS)."
	{
		
		
	// I initialize the component.
	function init(){
		
		// Return this object reference.
		return( this );
		
	}
	
	
	// I take HTML with embedded STYLE tags and I pares the CSS and inline it within the DOM
	// so that the email clients will be able to render it [more] properly.
	function prepareForEmail( String html ){
	
		// Parse the incoming HTML into a jSoup DOM (Document Object Model) so that we can 
		// extract and then integrate the CSS properties.
		var dom = new DOMWrapper( 
			html,
			new CSSParser()
		); 
		
		// Ask the document to inline and Style tags.
		dom.mergeStyles();
		
		// Return the resultant document HTML with embedded Style attributes.
		return( dom.html() );
		
	}
	
		
}



















