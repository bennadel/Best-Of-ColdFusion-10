
<!--- We're expecting a single HTML field to convert. --->
<cfparam name="form.html" type="string" default="" />
	
<!--- Create an instance of our HTML Email utility. --->
<cfset htmlEmailUtility = new model.HTMLEmailUtility() /> 
	
<!--- 
	Convert the standard HTML into an HTML that is [more] suitable for email. This works
	by inlining the CSS classes into the elements that match the CSS selectors. This also
	attempts to inline CSS properties that are inherited by parent classes. 
--->
<cfset emailMarkup = htmlEmailUtility.prepareHtmlForEmail( form.html ) />
	
<!--- Reset the output buffer and stream the HTML content back to the client. --->
<cfcontent
	type="text/html; charset=utf-8"
	variable="#toBinary( toBase64( emailMarkup ) )#"
	/>
	
	