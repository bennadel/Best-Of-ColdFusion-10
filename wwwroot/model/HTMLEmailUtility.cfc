
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
	
	
	// I add a selector error to the document. This injects a Comment node in the Body tag in
	// order to indicate that the given selector is not supported by jSoup and its use resulted
	// in a caught exception.
	function addSelectorError( Any dom, String selector, Any error ){
		
		// Add to the beginning of the BODY tag.
		dom.body().prependChild(
			createObject( "java", "org.jsoup.nodes.Comment" ).init(
				javaCast( "string", "ERROR: Selector not supported [ #selector# ][ #error.message# ]" ),
				javaCast( "string", "" )
			)
		);
		
		// Return this object for method chaining.
		return( this );
		
	}
	
	
	// I add a selector warning to the document. This injects a Comment node in the Body tag in
	// order to indicate that the given selector did not match any elements.
	function addSelectorWarning( Any dom, String selector ){
		
		// Add to the beginning of the BODY tag.
		dom.body().prependChild(
			createObject( "java", "org.jsoup.nodes.Comment" ).init(
				javaCast( "string", "WARNING: No element match for selector [ #selector# ]" ),
				javaCast( "string", "" )
			)
		);
		
		// Return this object for method chaining.
		return( this );
		
	}
	
	
	// I apply the given CSS rules to the given jSoup DOM. This updates the [style] attribute
	// of all elements that match the CSS rule selectors.
	function applyCSSToDOM( Any dom, Array cssRules ){
		
		// Loop over each rule to apply it to the Document. On our first pass, all we're going to
		// do is build up specificity-based data attributes. Then, once those are applied, we'll 
		// execute a second pass on the document to build up the Style attributes.
		for (var rule in cssRules){
			
			// Select all the nodes that match the given selector. This is really the only step
			// that can raise an exception. If the selector is not supported, we'll need to catch
			// the error and skip this selector.
			try {
			
				// Get the matching DOM nodes.
				var selectedNodes = dom.select( javaCast( "string", rule.selector ) );
			
			} catch( Any error ){
				
				// The given selector is not supported by the jSoup parser. Let's add a WARNING 
				// to the output to let them know they may want to use a different syntax.
				this.addSelectorError( dom, rule.selector, error );
				
				// The selector is not supported. Skip to the next rule.
				continue;
				
			}
			
			// Make sure we have nodes. If we don't bypass the node processing.
			if (!selectedNodes.size()){
				
				// Let's add a NOTICE to the output to let them know that they have styles that 
				// are not actually being used in the HTML generation. 
				this.addSelectorWarning( dom, rule.selector );
				
				// Continue on to the next rule.
				continue;
				
			}
			
			// Now that we know we have nodes to augment with inline CSS properties, let's create
			// the CSS properties collection as a single string. This way, we don't have to flatten
			// it for each node.
			var propertiesList = this.flattenProperties( rule.properties );
			
			// Loop over each selected node and inject the specificity-based data attribute.
			for (var node in selectedNodes){
				
				// In case this node has been selected by a previous selector, make sure to append
				// the CSS to the end of the specificity-based attribute. This way, we can keep 
				// CSS rules with the same specificy added in-order of the document, top-to-bottom.
				node.attr(
					javaCast( "string", "data-selector-#rule.specificity#" ),
					javaCast( 
						"string", 
						(node.attr( javaCast( "string", "data-selector-#rule.specificity#" ) ) & propertiesList)
					)
				);
				
			}
			
		}
		
		// Now that we've created all of our specificity-based data attributes, we have to go back
		// over the document to aggregate those into a single Style attribute. Let's gather all of
		// the nodes that have data attributes.
		var selectedNodes = dom.select( javaCast( "string", "*[^data-selector-]" ) );
		
		// Loop over the selected nodes to compile the Style attribute.
		for (var node in selectedNodes){
			
			// Get the HTML5 "data-" attributes from the node. 
			// 
			// NOTE: This returns the attributes values WITHOUT the "data-" prefix.
			var dataAttributes = node.dataset();
			
			// We're going to build up an array of the selector attributes so that we can then
			// subsequently apply them to the Style attribute.
			var styleAttributes = [];
			
			// Translate the map of data attributes into an array in which we are only going to 
			// store the relevant selector attributes.
			structEach(
				dataAttributes,
				function( key, value ){
					
					// Make sure this pair is one of our selectors.
					if (reFindNoCase( "^selector-\d+$", key )){
						
						// Add this to the style collection for this node.
						arrayAppend(
							styleAttributes,
							{
								name: ("data-" & key),
								specificity: fix( listLast( key, "-" ) ),
								style: value
							}
						);
						
					}
					
				}
			);
			
			// Now, let's sort the style array based on specificity. We're going to order the higher
			// specificities first since we'll be adding them in reverse order to the style attribute.
			arraySort(
				styleAttributes,
				function( attribute1, attribute2 ){
					
					// Sort Descending.
					if (attribute1.specificity <= attribute2.specificity){
						
						return( 1 );
						
					} else {
						
						return( -1 );
						
					}
					
				}
			);
			
			// Now that we've aggregated and sort our specificity-based attributes, we can apply 
			// them back to Style attribute of the given node. As we do this, we'll apply the 
			// style values in specificity-ascending order and delete the temp attributes.
			for (var styleAttribute in styleAttributes){
				
				// Prepend each value to the style attribute to keep existing Style values as the
				// most important.
				node.attr(
					javaCast( "string", "style" ),
					javaCast( 
						"string", 
						(styleAttribute.style & node.attr( javaCast( "string", "style" ) ))
					)
				);
				
				// Delete our temporary data attribute.
				node.removeAttr( javaCast( "string", styleAttribute.name ) );
				
			}
			
		}
		
		// Return the augmented jSoup document node.
		return( dom );
		
	}
	
	
	// I take the given selector and calculate its generic specificity so that it can be compared
	// to other selectors that match the same DOM nodes. For this, we'll be using the algorithm
	// outlined on : http://www.blooberry.com/indexdot/css/topics/cascade.htm . This asks to count
	// the following values:
	//
	// 1. Count the number if ID attributes in the selector
	// 2. Count the number of attributes and pseudo-classes in the selector.
	// 3. Count the number of element names in the selector
	//
	// ... and then add up the results (character-based, not numerically). Of course, we are not
	// doing the best job - we're just using lose RegularExpression matching.
	function calculateSelectorSpecificity( String selector ){
		
		// Before we start parsing the selector, we're gonna try to strip out characters that will
		// making pattern matching more difficult.

		// Strip out wild-card matches - these don't contribute to a selector specificity.
		selector = replace( selector, "*", "", "all" );

		// Strip out any quoted values - these will only be in the attribute selectors (and don't 
		// contribute to our specificity calculation).
		selector = reReplace( selector, """[^""]*""", "", "all" );
		selector = reReplace( selector, "'[^']*'", "", "all" );

		// Now that we've stripped out the quoted values, let's strip out any content within the 
		// attribute selectors.
		selector = reReplace( selector, "\[[^\]]*\]", "[]", "all" );

		// Strip out any special child and descendant selectors as these don't really contribute
		// to specificity.
		selector = reReplace( selector, "[>+~]+", " ", "all" );

		// Strip out any "function calls"; these will be for complex selectors like :not() and 
		// :eq(). We're gonna do this in a loop so that we can simplify the replace and handle 
		// nested groups of parenthesis.
		while (find( "(", selector )){

			// Strip out the smallest parenthesis.
			selector = reReplace( selector, "\([^)]*\)", "", "all" );

		}

		// Now that we've stripped off any parenthesis, our pseudo-elements and pseudo-classes 
		// should all be in a uniform. However, pseudo-elements and pseudo-classes actually have
		// different specifity than each other. To make things simple, let's convert pseudo-
		// classes (which have high specificity) into mock classes.
		selector = reReplace(
			selector,
			":(first-child|last-child|link|visited|hover|active|focus|lang)",
			".pseudo",
			"all"
		);

		// Now that we've removed the pseudo-classes, the only constructs that start with ":" 
		// should be the pseudo-elements. Let's replace these with mock elements. Notice
		// that we are injecting a space before the element name.
		selector = reReplace( selector, ":[\w-]+", " pseudo", "all" );

		// Now that we've cleaned up the selector, we can count the number of key elements within
		// the selector.

		// Count the number of ID selectors. These are the selectors with the highest specificity.
		var idCount = arrayLen(
			reMatch( "##[\w-]+", selector )
		);

		// Count the number of classes, attributes, and pseudo-classes. Remember, we converted 
		// our pseudo-classes to be mock classes (.pseudo).
		var classCount = arrayLen(
			reMatch( "\.[\w_-]+|\[\]", selector )
		);

		// Count the number of elements and pseudo-elements. Remember, we converted our pseudo-
		// selements to be mock elements (pseudo).
		var elementCount = arrayLen(
			reMatch( "(^|\s)[\w_-]+", selector )
		);

		// Now that we have our count of the various parts of the selector, we can calculate 
		// the specificity by concatenating the parts (as strings), and then converting to a 
		// number - the number will be the specificity of the selector.
		return(
			fix( idCount & classCount & elementCount )
		);
		
	}
	
	
	// I flatten the collection of properties into a single string that can be used in a Style tag.
	// Each property will be formatted in "name:value;" format.
	function flattenProperties( Array properties ){
		
		// Create our style string container.
		var style = "";
		
		// Flatten the collection of properties into a single string.
		for (var property in properties){
			
			style &= "#property.name#:#property.value#;";
			
		}
		
		// Return the flattened style value.
		return( style );
		
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
		
		// For each selector, let's create a new rule.
		arrayEach(
			selectors,
			function( selector ){
				
				// Append the rule.
				arrayAppend(
					rules,
					{
						selector: selector,
						properties: properties,
						specificity: this.calculateSelectorSpecificity( selector )
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
		var dom = jSoupClass.parse( javaCast( "string", html ) );
		
		// Locate all the style nodes.
		var styleNodes = dom.select( javaCast( "string", "style" ) );
		
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
		
		// Get the output settings so we can control how to conversion to string works. We
		// want to indent tags with 4-spaces when we convert to string.
		dom.outputSettings()
			.prettyPrint( javaCast( "boolean", true ) )
			.indentAmount( javaCast( "int", 4 ) )
		;
		
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



















