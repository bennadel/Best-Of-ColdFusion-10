
<!--- Turn off any debugging output. --->
<cfsetting showdebugoutput="false" />

<!--- Reset the content buffer. --->
<cfcontent type="text/html; charset=utf-8" />

<!DOCTYPE html>
<html>
<head>
	<title>HTML Email Utility - Best of ColdFusion 10 by Ben Nadel</title>
	
	<!-- Load styles and Fonts. -->
	<link rel="stylesheet" type="text/css" href="http://fonts.googleapis.com/css?family=Exo:400,200,700"></link>
	<link rel="stylesheet" type="text/css" href="./linked/css/generator.css"></link>
</head>
<body>
	
	<!-- BEGIN: Header Panel. -->
	<div class="headerPanel">
		
		<h1>
			HTML Email Utility - Best of ColdFusion 10
		</h1>
		
		<div class="subtitle">
			Designed and Developed by <a href="http://www.bennadel.com" target="_blank">Ben Nadel</a>
		</div>
		
	</div>
	<!-- END: Header Panel. -->
	
	<!-- BEGIN: Input Panel. -->
	<div class="inputPanel">
		
		<h2>
			Enter Your HTML With &lt;STYLE&gt; Tags:
		</h2>
		
		<form>
			<textarea class="html"></textarea>
		</form>
		
	</div>
	<!-- END: Input Panel. -->
	
	<!-- BEGIN: Output Panel. -->
	<div class="outputPanel">
		
		<!-- BEGIN: Html Panel. -->
		<div class="htmlPanel">
			
			<h2>
				Your HTML Result With Inlined CSS Styles:
			</h2>
			
			<form>
				<textarea class="html"></textarea>
			</form>
			
		</div>
		<!-- END: Html Panel. -->
		
		<!-- BEGIN: Preview Panel. -->
		<div class="previewPanel">
				
			<h3>
				HTML Preview:
			</h3>
			
			<form>
				<iframe src="about:blank" class="render"></iframe>
			</form>
			
		</div>
		<!-- END: Preview Panel. -->
		
	</div>
	<!-- END: Output Panel. -->
	
	
	<!-- --------------------------------------------------- -->
	<!-- --------------------------------------------------- -->
	
	<!-- For sample data and demo. This value will be injected into the form. -->
	<script type="text/demo-data" class="demoData">
		
		<style type="text/css">
			
			div.container {
				background-color: #F0F0F0 ;
				color: #333333 ;
				font-family: georgia ;
				font-size 16px ;
				line-height: 22px ;
				padding: 10px 10px 10px ;
				}
				
			a {
				color: #333333 ;
				}
				
			em {
				background-color: gold ;			
				}
				
			div.header {
				font-family: helvetica, arial, verdana ;			
				}
			
			div.header h1 { 
				font-size: 24px ;
				line-height: 29px ;
				margin-bottom: 8px ;
				}
				
			div.header h2 {
				color: #999999 ;
				font-size: 18px ;
				line-height: 24px ;
				margin-top: 8px ;
				}
				
			div.header h2 a {
				color: #999999 ;
				text-decoration: none ;
				}
			
			/* 
			 * Notice that this selector is not useful. It will be inserted into 
			 * the output HTML as a WARNING comment within the body tag.
			 */
			div.footer {
				font-size: 11px ;
				}
			
		</style>
		
		<div class="container">
			
			<div class="header">
				
				<h1>
					Best of ColdFusion 10
				</h1>
				
				<h2>
					By <a href="http://www.bennadel.com">Ben Nadel</a>
				</h2>
				
			</div>
			
			<p>
				This is my Best of ColdFusion 10 contest entry. The point of this entry is to
				build a utility that will take HTML that uses Style blocks and generate HTML
				with inlined style attributes. This is done to make the HTML more email-friendly
				since many 
				<a href="http://www.campaignmonitor.com/css/">email clients don't like Style blocks</a>.
			</p>
			
			<p>
				<em>Heck yeah!!!</em>
			</p>
			
		</div>
		
	</script>
	
	<!-- --------------------------------------------------- -->
	<!-- --------------------------------------------------- -->

	
	<!-- Load scripts. -->
	<script type="text/javascript" src="./linked/js/jquery-1.7.2.min.js"></script>
	<script type="text/javascript" src="./linked/js/jquery.textarea.js"></script>
	<script type="text/javascript" src="./linked/js/generator.js"></script>
	
</body>
</html>









