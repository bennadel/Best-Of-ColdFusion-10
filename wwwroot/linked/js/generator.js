
(function( $ ){
	
	
	// I check the input html for changes in content (that need to be reflected in the output /
	// results panel.
	function checkForHtmlUpdates(){
		
		// Get the new HTML value.
		var html = dom.inputHtml.val();
		
		// Check to see if the new HTML value is exactly the same as the previous HTML value.
		// This will happen if the user is simply navigating around the HTML without changing it.
		if (lastHtml === html){
			
			// Don't make an unnecessary AJAX request (or normalization requests).
			return;
			
		}
		
		// The new HTML is not exactly the same; but, there's a chance that it is "roughly"
		// the same. Let's normalize the html so that we can see if the HTML has changed in a 
		// meaningful way since the last update.
		var normalizedHtml = normalizeHtml( html );
		
		// Check to see if the HTML was updated in a meaningful way. That is, where
		// there characters added that actually affect the style and structure of the
		// HTML vs. the last known state.
		if (lastNormalizedHtml === normalizedHtml){
				
			// Don't make an unnecessary AJAX request.
			return;
				
		}
		
		// Store the standard and normalized values for our next keypress-based update check.
		lastHtml = html;
		lastNormalizedHtml = normalizedHtml;
		
		// If there is an outstanding request for previously modified content, kill that one and
		// use this one as the most recent on.
		if (generateHtmlRequest !== null){
			
			// Abort the previous request.
			generateHtmlRequest.abort();
			
		}
		
		// Convert the input HTML to email-ready HTML on the server.
		generateHtmlRequest = $.ajax({
			type: "post",
			url: "./generate.cfm",
			data: {
				html: html
			},
			dataType: "html"
		});
		
		// If the HTML comes back successfully, put it in the output panel.
		generateHtmlRequest.done(
			function( emailHtml ){
				
				// Show the resultant HTML.
				dom.outputHtml.val( emailHtml );
				
				// Preview the resultant HTML.
				writeHtmlToIFrame( dom.outputPreview, emailHtml );
				
			}
		);
		
		// No matter what happens, clear the AJAX request when this one is done.
		generateHtmlRequest.always(
			function(){
				
				// Clear the outstanding request reference.
				generateHtmlRequest = null;
				
			}
		);
		
	}
	
	// I limit the number of times that an method can be called in a given amount of time.
	function debounce( method, timePeriod ){
		
		// I am a timer to keep track of the period between a string of method invocations.
		var timer = null;
		
		// I am the debouncer that invokes the given method only after a period of pause between
		// successive (attempted) method invocations.
		var debouncedMethod = function(){
			
			// Clear any existing timeout.
			clearTimeout( timer );
			
			// Keep track of the current invoke arguments in case we need to pass these off to
			// the eventual method invocation.
			var invokeArguments = arguments;
			
			// Create a new timer that will invoke the target method IF there has been a period of
			// inactivity after its original invocation.
			timer = setTimeout(
				function(){
					method.apply( window, invokeArguments );
				},
				timePeriod
			);
			
		};
		
		// Return the debounced wrapper for our method.
		return( debouncedMethod );
		
	} 
	
	// I create a normalized string of HTML (minimizing white-space) as a way to allow two
	// technically different snippets of HTML to be considered the "same."
	function normalizeHtml( html ){
		
		// Trim the value and convert all white-space into a space.
		return(
			html
				.replace( /^\s+|\s+$/g, "" )
				.replace( /\s+/g, " " )
		);
		
	}
		
	// I write the given HTML to the given iframe (jquery reference).
	function writeHtmlToIFrame( iframe, html ){
		
		// Get the Document object form within the content window. jQuery doesn't expose
		// this property; as such, we'll have to get it from the raw DOM node. 
		var doc =iframe.get( 0 ).contentWindow.document;
		
		// Open the doc, write the HTML, and then close the doc. Closing the document will
		// prevent subsequent write() calls to the same document from appending unexpected
		// output source.
		doc.open();
		doc.write( html );
		doc.close();
		
	}


	// ------------------------------------------------------ //
	// ------------------------------------------------------ //

	
	// Get and cache relevant DOM elements (as jQuery references).
	var dom = {
		inputHtml: $( "div.inputPanel textarea.html" ),
		outputHtml: $( "div.htmlPanel textarea.html" ),
		outputPreview: $( "div.previewPanel iframe.render" )
	};
	
	// In order to minimize the number of AJAX we have to make (which is already too many),
	// we're going to keep track of the normalized HTML values.
	var lastHtml = "";
	var lastNormalizedHtml = "";
	
	// Keep track of the most recent AJAX request so we can cancel the last one if a new one
	// is triggered by content changes.
	var generateHtmlRequest = null;
	
	// Disable the default TAB key on the input to make typing a bit more natural. This plugin
	// will enable intuitive tabbing in the textarea (ie. actually applying the tab character).
	dom.inputHtml.tabby();
	
	// On keyup, let's pass the updated HTML to the server and get the email-ready HTML. Let's 
	// debounce the response to key events so that we're not making tooooo many requests to the
	// server to translate HTML documents.
	dom.inputHtml.keyup(
		debounce( 
			function( event ){
				
				// For every key-up, check to see if the html has been modified.
				checkForHtmlUpdates();
					
			},
			250
		)
	);
	
	// Update the output panel when the page loads - this will kick off the first check for
	// html if there is content stored in the textarea.
	checkForHtmlUpdates(); 
	
	
})( jQuery );





