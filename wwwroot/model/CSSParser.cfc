
component
	output="false"
	hint="I provide simple parsing utlities for CSS content. This does not actually validate CSS rules - it simply parses CSS string content based on common character delimiters."
	{


	// I initialize the component.
	function init(){
		
		return( this );
		
	}
	
	
	// I parse the given CSS string into a collection of rules. Each rule will have a selector
	// and a collection of properties to apply to the selected elements.
	function parseCSS( String cssMarkup ){
		
		// Create our collection of rules. The rules will be parsed and collected in a top-down
		// manner, according to their position in the CSS content.
		var rules = [];
		
		// Strip out any CSS comments. Since our parsing of the CSS is going to use a really
		// loose approach splitting, we want to remove anything that will possibly give us
		// false matches.
		cssMarkup = this.stripCSSComments( cssMarkup );
		
		// Loop over the rules blocks based on the trailing "}" delimiter.
		for (var ruleBlock in cssMarkup.split( "}" )){
			
			// Parse the block and append it to the rules collection. If the rules block returns
			// multiple rules (based on multiple selectors), add each independently to the rules
			// collection.
			arrayAppend(
				rules,
				this.parseRuleBlock( ruleBlock ),
				true
			);
			
		}
		
		// Return the parsed rules.
		return( rules );
		
	}
	
	
	// I parse the given propreties (name-value pairs) block into an array of structs. Each struct
	// with have a Name and Value property; we need to use an array since the order of CSS in the
	// original document is import to the rendering. 
	function parsePropertiesBlock( String propertiesBlock ){
		
		// Define the properties collection. Each property will have a name and value key.
		var properties = [];
		
		// Each property in the block is delimited by a semi-colon. Therefore, we can access the 
		// name-value pairs by splitting on the semi-colon.
		for (var propertyBlock in propertiesBlock.split( ";" )){
			
			// Extrac the name and value pairs.
			var name = trim( listFirst( propertyBlock, ":" ) );
			var value = trim( listRest( propertyBlock, ":" ) );
			
			// Check to make sure the property is valid before we add it to our collection. In 
			// this case, we are checking to make sure the name and value are different in case
			// the list-wise extraction grabbed the same value.
			if (
				len( name ) &&
				len( value ) &&
				compare( name, value )
				){
				
				// Create and append the property as a struct with Name/Value.
				arrayAppend(
					properties,
					{
						name: name,
						value: value
					}
				);
				
			}
			
		}
		
		// Return the propreties collection.
		return( properties );
		
	}
	
	
	// I parse the given rule block. Each rule block may result in zero or more rules depending on
	// whether or not there were multiple selectors. If multiple selectors are provided, each 
	// selector / property set is returned as a different rule.
	function parseRuleBlock( String ruleBlock ){
		
		// Create our collection of rules. Each rule will be a struct with a Selector and a
		// Properties key with a "lose" specificity calculation.
		var rules = [];
		
		// For each rule block, let's separate the selectors from the properties. Remember, there
		// might be multiple selectors for each rule block.
		var selectorsBlock = listFirst( ruleBlock, "{" );
		var propertiesBlock = listRest( ruleBlock, "{" );
		
		// Parse the selectors.
		var selectors = this.parseSelectorsBlock( selectorsBlock );
		
		// Parse the properties.
		var properties = this.parsePropertiesBlock( propertiesBlock );	
		
		// Make sure we have propeties - if we don't we don't want to bother creating rules.
		if (!arrayLen( properties )){
			
			// Return the empty rules collection - we have not valid properties.
			return( rules );
			
		}
		
		// For each selector, let's create a new rule (since multiple selectors can be applied to
		// the same list of properties).
		arrayEach(
			selectors,
			function( selector ){
				
				// Append the new rule.
				arrayAppend(
					rules,
					new CSSRule( selector, properties )
				);
				
			}
		);
		
		// Return the parsed rule.
		return( rules );
				
	}
	
	
	// I parse the given selector block. Each selector is a string of DOM traversal directives. 
	function parseSelectorsBlock( String selectorsBlock ){
		
		// Create our selector collection. Each selector will be a string.
		var selectors = [];
		
		// Each selector for a given rule is delimited by the comma. As such, we should be able
		// to split on comma (although it's possible that a selector can have an embedded comma
		// for attribute-based selection -- which we'll ignore for now).
		for (var selectorBlock in selectorsBlock.split( "," )){
			
			// Simply trim the selector.
			arrayAppend(
				selectors,
				trim( selectorBlock )
			);
			
		}
		
		// Return our selectors collection.
		return( selectors );
		
	}
	
	
	// I strip comments from the given CSS markup.
	function stripCSSComments( String cssMarkup ){
		
		// Remove anything between /* ... */ notation.
		cssMarkup = reReplace( cssMarkup, "/\*[\w\W]*?\*/", "", "all" );
		
		// Return the cleaned CSS.
		return( cssMarkup );
		
	}
	

}




