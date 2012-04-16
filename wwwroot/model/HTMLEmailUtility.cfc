
component
	output="false"
	hint="I provide utility methods for parsing HTML markup and preparing it for use within HTML emails (which have much less support for CSS)."
	{
		
		
	// I initialize the component.
	function init(){
		
		// Create and cache our JSoup class. The class mostly has static methods for parsing 
		// so we don't need to initialize it; but, let's cache it so we don't have to create
		// it over and over again. 
		variables.jSoupClass = createObject( "java", "org.jsoup.Jsoup" );
		
		// Return this object reference.
		return( this );
		
	}
	
	
	// I apply the given CSS rules to the given jSoup DOM. This updates the [style] attribute
	// of all elements that match the CSS rule selectors.
	function applyCSSToDOM( Any dom, Array cssRules ){
		
		// Before we apply the CSS rules, we want to quarantine any existing inline CSS. This
		// is an important step because the existing inline CSS should always come last (for
		// important); however, the CSS rules should be applied in-order.
		var nodesWithStyle = dom.select( javaCast( "string", "*[style]" ) );
		
		// Loop over existing line-style nodes to move into a temp attribute.
		for (var node in nodesWithStyle){
			
			// Move style to a data attribute.
			node.attr( "data-temp-style", node.attr( "style" ) );
			
			// Reset the style attribute.
			node.attr( "style", "" );
			
		}
		
		// Loop over each rule to apply it in turn.
		for (var rule in cssRules){
			
			// Select all the nodes that match the given selector.
			var selectedNodes = dom.select( javaCast( "string", rule.selector ) );
			
			// Make sure we have nodes. If we don't bypass the node processing.
			if (!selectedNodes.size()){
				
				// Continue on to the next rule.
				continue;
				
			}
			
			// Now that we know we have nodes to augment with inline CSS properties, let's create
			// the CSS properties collection as a single string.
			var propertiesList = "";
			
			// Flatten the collection of properties into a single string.
			arrayEach(
				rule.properties,
				function( property ){
					
					// Flatten the property.
					propertiesList &= "#property.name#:#property.value#;";
					
				}
			);
			
			// Loop over each selected node and inject the CSS inline.
			for (var node in selectedNodes){
				
				// When injecting the CSS remember to keep the ............
				node.attr(
					"style",
					(propertiesList & node.attr( "style" ))
				);
				
			}
			
		}
		
		// Now that we've applied the CSS rules, we need to re-apply the original inline CSS 
		// after the CSS that we've injected (in order to maintain presendence).
		for (var node in nodesWithStyle){
			
			// Move temp stlye back into place.
			node.attr(
				"style",
				(node.attr( "style" ) & node.attr( "data-temp-style" ) )
			);

			// Delete the temp attribute.
			node.removeAttr( "data-temp-style" );
			
		}
		
		// Return the augmented jSoup document node.
		return( dom );
		
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
		cssMarkup = stripCSSComments( cssMarkup );
		
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
		// Properties key. 
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
		
		// For each selector, let's create a new rule.
		arrayEach(
			selectors,
			function( selector ){
				
				// Append the rule.
				arrayAppend(
					rules,
					{
						selector: selector,
						properties: properties
					}
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
	
	
	// I take HTML with embedded STYLE tags and I pares the CSS and inline it within the DOM
	// so that the email clients will be able to render it [more] properly.
	function prepareHtmlForEmail( String html ){
	
		// Parse the incoming HTML into a jSoup DOM (Document Object Model) so that we can 
		// extract and then integrate the CSS properties.
		var dom = jSoupClass.parse( javaCast( "string", form.html ) );
		
		// Locate all the style nodes.
		var styleNodes = dom.select( "style" );
		
		// Remove the style nodes from the document. Once we inline the CSS, we'll no longer
		// have a need for the Style nodes.
		styleNodes.remove();
		
		// Concatenate all of the CSS content so that we can parse it. The html() will concat
		// all of the inner HTML values of the various Style nodes.
		var cssContent = styleNodes.html();
		
		// Parse the CSS rules.
		var cssRules = this.parseCSS( cssContent );
		
		// Apply the CSS rules to the DOM. This will populate the [style] attributes.
		this.applyCSSToDOM( dom, cssRules );
		
		// Return the body element of the updated DOM content. Pretty much everything else 
		// will be stripped out by the email client (probably). 
		return( dom.select( "body" ).toString() );

	}
	
	
	// I strip comments from the given CSS markup.
	function stripCSSComments( String cssMarkup ){
		
		// Remove anything between /* ... */ notation.
		cssMarkup = reReplace( cssMarkup, "/\*[\w\W]*?\*/", "", "all" );
		
		// Return the cleaned CSS.
		return( cssMarkup );
		
	}
	
		
}



















