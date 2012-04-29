
component
	output="false"
	accessors="true"
	hint="I model a CSS rule as a selector and a collection of properties."
	{
	
	
	// While the list of properties is not used with implicit accessors (only synthesized getters
	// and setters), I'm using it to document which properties can be accessed via implicit notation.
	property name="properties" type="array" getter="true" setter="false";
	property name="selector" type="string" getter="true" setter="false";
	property name="specificity" type="numeric" getter="true" setter="false";
	property name="style" type="string" getter="true" setter="false";
	
	
	// I initialize the component.
	function init( String selector, Array properties ){
		
		// Store the internal properties.
		variables.selector = selector;
		variables.properties = properties;
		
		// Don't calculate the specificy yet - lazy load it upon first use.
		variables.specificity = "";
		
		// Return this object reference.
		return( this );
		
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
	function flatten(){
		
		// Create our style string container.
		var style = "";
		
		// Flatten the collection of properties into a single string.
		for (var property in variables.properties){
			
			style &= "#property.name#:#property.value#;";
			
		}
		
		// Return the flattened style value.
		return( style );
		
	}
	
	
	// I return a copy of the properties collection.
	function getProperties(){
		
		// Duplicate the properties so we can maintain encapsulation.
		return( duplicate( variables.propreties ) ); 
		
	}
	
	
	// I get the selector property.
	function getSelector(){
		
		// Return the selector.
		return( variables.selector );
		
	}
	
	
	// I get the calculated specificity.
	function getSpecificity(){
		
		// Now that the specificity is being accessed, possibly for the first time, let's check
		// to see if we've calculated the value yet.
		if (!isNumeric( variables.specificity )){
			
			// Now is the time to calculate!
			variables.specificity = this.calculateSelectorSpecificity( variables.selector );
			
		}
		
		// Return the calculated specificity.
		return( variables.specificity );
		
	}
	
	
	// Getting the style is the same thing as flattening the properties list. This is just a short-
	// hand to that method via an implicit property.
	function getStyle(){
		
		// Return the flattened properties.
		return( this.flatten() );
		
	}
	
	
}