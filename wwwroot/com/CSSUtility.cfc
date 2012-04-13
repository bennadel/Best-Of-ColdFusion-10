
component
	output="false"
	hint="I provide utility methods for parsing CSS markup."
	{
		
		
	// I initialize the component.
	function init(){
		
		// Return this object reference.
		return( this );
		
	}
	
	
	// I parse the given CSS string into a collection of selectors and the rules that need
	// to be applied to those selectors.
	function parseCSS( string cssMarkup ){
		
		// Create our selector collection. Each selector will have a Path and Properites.
		// These will be presented in a top-down manner (as they appeared in the original)
		// CSS block.
		var selectors = [];
		
		// Strip out any CSS comments. Since our parsing of the CSS is going to use a really
		// loose approach splitting, we want to remove anything that will possibly give us
		// false matches.
		cssMarkup = stripComments( cssMarkup );
		
		// Now, let's split the CSS using the closing brace, since each CSS rule ends with a
		// closing brace, this should generally break up the CSS block into rules.
		var ruleBlocks = listToArray( cssMarkup, "}" );
		
		// Loop over each rule part to parse further.
		for (var ruleBlock in ruleBlocks){
			
			// Now that we have our rule block, we can split it on the opening brace. Since 
			// the selector is seperated from the properties by the opening brace, this will
			// generally give us the two related parts of the rule.
			var ruleParts = listToArray( ruleBlock, "{" );
			
			
			
		}
		

		
	}
	
	
	// I parse the given propreties (name-value pairs) markup into a struct. 
	function parseProperties( string propertiesMarkup ){
		
		// Define the propreties collection. Each property will have a single value. We're not
		// going to worry about translating short-hand rules into full rules.
		var properties = {};
		
		// Each property is seperated by a semi-colon, so we should be able to split on the
		// semi-colon to get the different proprety parts.
		var declarations = listToArray( propertiesMarkup, ";" ); 
		
		// Loop over the declarations to parse out the names and values.
		for (var declaration in declarations){
			
			// Each property declaration in the form of "name: value". As such, we can parse
			// the name and the value using a list delimited by ":".
			properties[ trim( listFirst( declaration, ":" ) ) ] = trim( listRest( declaration, ":" ) );
			
		}
		
		// Return the propreties collection.
		return( properties );
		
	}
	
	
	// I strip comments from the given CSS markup.
	function stripComments( string cssMarkup ){
		
		// Remove anything between /* ... */ notation.
		cssMarkup = reReplace( cssMarkup, "/\*[\w\W]*?\*/", "", "all" );
		
		// Return the cleaned CSS.
		return( cssMarkup );
		
	}
	
		
}



















