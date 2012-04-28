
(function( $ ){
	
	
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
	
	// Disable the default TAB key on the input to make typing a bit more natural. This plugin
	// will enable intuitive tabbing in the textarea (ie. actually applying the tab character).
	dom.inputHtml.tabby();
	
	// On keyup, let's pass the updated HTML to the server and get the email-ready HTML.
	dom.inputHtml.keyup(
		function( event ){
			
			// Get the new HTML value.
			var html = dom.inputHtml.val();
			
			// Check to see if the new HTML value is exactly the same as the previous HTML value.
			// This will happen if the user is simply navigating around the HTML without changing it.
			if (lastHtml === html){
				
				// Don't make an unnecessary AJAX request (or normalization requests).
				return;
				
			}
			
			// The new HTML is not exactly the same; but, there's a chance that it is "roughtly"
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
			
			// Convert the input HTML to email-ready HTML.
			var generateHtml = $.ajax({
				type: "post",
				url: "./generate.cfm",
				data: {
					html: html
				},
				dataType: "html"
			});
		
			// If the HTML comes back successfully, put it in the output panel.
			generateHtml.done(
				function( html ){
					
					// Show the resultant HTML.
					dom.outputHtml.val( html );
					
					// Preview the resultant HTML.
					writeHtmlToIFrame( dom.outputPreview, html );
					
				}
			);
			
		}
	);
	
	
})( jQuery );





