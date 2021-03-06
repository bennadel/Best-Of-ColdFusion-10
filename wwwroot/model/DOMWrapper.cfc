
component
	output="false"
	hint="I wrap the jSoup document in order to provide easier access to the underlying Java methods; I also provide utility methods for the DOM."
	{

	
	// I parse the given HTML and return an initialized DOM wrapper.
	function init( String html, Any cssParser ){
		
		// Create and cache our JSoup class. The class mostly has static methods for parsing 
		// so we don't need to initialize it; but, let's cache it so we don't have to create
		// it over and over again. 
		variables.jSoupClass = createObject( "java", "org.jsoup.Jsoup" );
		
		// Store our CSS parser (which will be used for merging style tags).
		variables.cssParser = cssParser;
		
		// Create an cache the jSoup DOM.
		variables.dom = variables.jSoupClass.parse( javaCast( "string", html ) );
		
		// Return this object reference.
		return( this );
		
	}
	
	
	// I add a selector error to the document. This injects a Comment node in the Body tag in
	// order to indicate that the given selector is not supported by jSoup and its use resulted
	// in a caught exception.
	function addSelectorError( String selector, Any error ){
		
		// Add to the beginning of the BODY tag.
		variables.dom.body().prependChild(
			this.createComment( "ERROR: Selector not supported [ #selector# ][ #error.message# ]" )
		);
		
		// Return this object for method chaining.
		return( this );
		
	}
	
	
	// I add a selector warning to the document. This injects a Comment node in the Body tag in
	// order to indicate that the given selector did not match any elements.
	function addSelectorWarning( String selector ){
		
		// Add to the beginning of the BODY tag.
		variables.dom.body().prependChild(
			this.createComment( "WARNING: No element match for selector [ #selector# ]" )
		);
		
		// Return this object for method chaining.
		return( this );
		
	}
	
	
	// I append the given value to the end of the existing attribute value of the given node.
	function appendAttribute( Any node, String name, String value ){
		
		// Append the value to any existing value of the attribute.
		node.attr(
			javaCast( "string", name ),
			javaCast( 
				"string", 
				(node.attr( javaCast( "string", name ) ) & value)
			)
		);
		
		// Return this object for method chaining.
		return( this );
		
	}
	
	
	// I apply the given CSS rules to the underlying jSoup DOM. This updates the [style] attribute
	// of all elements that match the CSS rule selectors. It does this in a top-document manner, 
	// attempting to uphold the rules of CSS selector specificity.
	function applyCSSRules( Array cssRules ){
		
		// Loop over each rule to apply it to the Document. On our first pass, all we're going to
		// do is build up specificity-based data attributes. Then, once those are applied, we'll 
		// execute a second pass on the document to build up the Style attributes.
		for (var rule in cssRules){
			
			// Select all the nodes that match the given selector. This is really the only step
			// that can raise an exception. If the selector is not supported, we'll need to catch
			// the error and skip this selector.
			try {
			
				// Get the matching DOM nodes.
				var selectedNodes = this.select( rule.selector );
			
			} catch( Any error ){
				
				// The given selector is not supported by the jSoup parser. Let's add a WARNING 
				// to the output to let them know they may want to use a different syntax.
				this.addSelectorError( rule.selector, error );
				
				// The selector is not supported. Skip to the next rule.
				continue;
				
			}
			
			// Make sure we have nodes. If we don't bypass the node processing.
			if (!selectedNodes.size()){
				
				// Let's add a NOTICE to the output to let them know that they have styles that 
				// are not actually being used in the HTML generation. 
				this.addSelectorWarning( rule.selector );
				
				// Continue on to the next rule.
				continue;
				
			}
			
			// Now that we know we have nodes to augment with inline CSS properties, let's create
			// the CSS properties collection as a single string. This way, we don't have to flatten
			// it for each node.
			var propertiesList = rule.style;
			
			// Loop over each selected node and inject the specificity-based data attribute.
			for (var node in selectedNodes){
				
				// In case this node has been selected by a previous selector, make sure to append
				// the CSS to the end of the specificity-based attribute. This way, we can keep 
				// CSS rules with the same specificy added in-order of the document, top-to-bottom.
				this.appendAttribute( node, "data-selector-#rule.specificity#", propertiesList );
				
			}
			
		}
		
		// Now that we've created all of our specificity-based data attributes, we have to go back
		// over the document to aggregate those into a single Style attribute. Let's gather all of
		// the nodes that have data attributes.
		var selectedNodes = this.select( "*[^data-selector-]" );
		
		// Loop over the selected nodes to compile the Style attribute.
		for (var node in selectedNodes){
			
			// Merge the selector attributes into the style attribute.
			this.compileSelectorAttributes( node );
			
		}
		
		// Get any nodes that have Class attributes - these can be stripped as they will no longer
		// server any purpose with the styles being inlined.
		for (var node in this.select( "*[class]" )){
			
			// Strip out any Class attribute.
			node.removeAttr( javaCast( "string", "class" ) );			
			
		}
		
		// Return this object for method chaining.
		return( this );
		
	}
	
	
	// I compile the temporarily-cached style values in the selector attributes into the Style
	// attribute of the given node.
	function compileSelectorAttributes( Any node ){
		
		// As the CSS rules were applied to the document, they were stored in temporary attributes
		// so that the selector specificity could be taken into account once we had all the known
		// rules for any given node. Now, let's extract those temporary attributes so that we can
		// compile them and apply them to the Style attribute.
		var selectorAttributes = this.extractSelectorAttributes( node );
		
		// By default, the selector attributes collection is return in specificity-first order. 
		// As such, we'll be prepending the values to the Style attribute so that the style portions
		// read in ASC order of specificity going from left-to-right; this also allows the existing
		// style value to have the highest precedence. delete the temp attributes.
		for (var selectorAttribute in selectorAttributes){
			
			// Prepend each value to the style attribute to keep existing Style values as the
			// most important.
			this.prependAttribute( node, "style", selectorAttribute.style );
			
		}
		
	} 
	
	
	// I create a comment node with the given content.
	function createComment( String comment ){
		
		// Initialize and return the comment.
		return(
			createObject( "java", "org.jsoup.nodes.Comment" ).init(
				javaCast( "string", comment ),
				javaCast( "string", "" )
			)
		);
		
	}
	
	
	// I extract the temporary Selector attributes that are storing unmerged Style data for the
	// given node.
	function extractSelectorAttributes( Any node ){
		
		// We're going to build up an array of the selector attributes so that we can then
		// subsequently apply them to the Style attribute.
		var selectorAttributes = [];
		
		// Get the HTML5 "data-" attributes from the node. Since we don't know what the 
		// specificity of the various rules have been, we don't know what attributes to look
		// for. We'll have to get all the HTML5 attributes and then look for the ones that match
		// our naming convension.
		// 
		// NOTE: dataset() returns the attributes values WITHOUT the "data-" prefix.
		//
		// NOTE: We have duplicate() the return value from dataset() because ColdFusion will throw
		// an error. If we use an intermediary variable, it works; but it doesn't work if we inline
		// the request. Must be some funky compilation error??
		structEach(
			duplicate( node.dataset() ),
			function( key, value ){
				
				// Make sure this pair is one of our selectors.
				if (reFindNoCase( "^selector-\d+$", key )){
					
					// Add this to the selectors collection for this node.
					arrayAppend(
						selectorAttributes,
						{
							specificity: fix( listLast( key, "-" ) ),
							style: value
						}
					);
					
					// Delete the temporary selector attribute - it is no longer valuable.
					node.removeAttr( javaCast( "string", ("data-" & key) ) );
					
				}
				
			}
		);
		
		// Now, let's sort the selector array based on specificity. We're going to order the higher
		// specificities first since we'll be adding them in reverse order to the style attribute.
		arraySort(
			selectorAttributes,
			function( attribute1, attribute2 ){
				
				// Sort Descending by specificity.
				if (attribute1.specificity <= attribute2.specificity){
					
					return( 1 );
					
				} else {
					
					return( -1 );
					
				}
				
			}
		);
		
		// Return the extracted and sorted attributes.
		return( selectorAttributes );
		
	}
	
	
	// I return the document as an HTML string.
	function html( Boolean prettyPrint = true, Numeric indent = 4 ){
		
		// Get the output settings so we can control how to conversion to string works. Be default, 
		// we want to enable pretty printing (formatting) with a 4-space indent.
		variables.dom.outputSettings()
			.prettyPrint( javaCast( "boolean", prettyPrint ) )
			.indentAmount( javaCast( "int", indent ) )
		;
		
		// Return the body element of the updated DOM content. Pretty much everything else (ie. 
		// head, title) will be stripped out by the email client (probably). 
		return( variables.dom.body().toString() );
		
	}
	
	
	// I find any embedded Style tags and then merge them into the document, creating or appending
	// Style attributes where necessary. Any selector values in the CSS that raise an error or do
	// not match any tags will result in a cautionary comment being added to the HTML.
	function mergeStyles(){
		
		// Locate all the style nodes.
		var styleNodes = dom.select( javaCast( "string", "style" ) );
		
		// Remove the style nodes from the document. Once we inline the CSS, we'll no longer
		// have a need for the Style nodes.
		styleNodes.remove();
		
		// Concatenate all of the CSS content so that we can parse it. The html() will concat
		// all of the inner HTML values of the various Style nodes.
		var cssContent = styleNodes.html();
		
		// Parse the CSS rules.
		var cssRules = variables.cssParser.parseCSS( cssContent );
		
		// Apply the CSS rules to the DOM. This will populate the [style] attributes.
		this.applyCSSRules( cssRules );
		
		// Return this object reference for method chaining.
		return( this );
		
	}
	
	
	// I prepend the given value to the beginning of the existing attribute value of the given node.
	function prependAttribute( Any node, String name, String value ){
		
		// Prepend the value to any existing value of the attribute.
		node.attr(
			javaCast( "string", name ),
			javaCast( 
				"string", 
				(value & node.attr( javaCast( "string", name ) ))
			)
		);
		
		// Return this object for method chaining.
		return( this );
		
	}
	
	
	// I select nodes from the document using the given selector.
	function select( String selector ){
		
		// Locate and return the underyling jSoup nodes.
		return(
			variables.dom.select( javaCast( "string", selector ) )
		);
		
	}
	
		
}














