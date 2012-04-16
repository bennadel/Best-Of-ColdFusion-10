
$( "div.editorPanel textarea.html" ).keydown(
	function(event){
	
		// Check to see if the current key is the tab.
		if (event.which === 9) {
		
			// Cancel the default event - we don't want to blur the textarea.
			event.preventDefault();
			
			return;
			
		}
		
	}		
);
		

$( "div.editorPanel textarea.html" ).keyup(
	function( event ){
		
		var generateHtml = $.ajax({
			type: "post",
			url: "./generate.cfm",
			data: {
				html: $( this ).val()
			},
			dataType: "html"
		});
		
		generateHtml.done(
			function( html ){
				
				$( "div.resultsPanel div.htmlPreview textarea.html" ).val( html );
				
				var doc = $( "div.resultsPanel div.renderPreview iframe" ).get( 0 ).contentWindow.document;
				doc.open();
				doc.write( html );
				doc.close();
				
			}
		);
		
	}
);
