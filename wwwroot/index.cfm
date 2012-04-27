
<!--- Turn off any debugging output. --->
<cfsetting showdebugoutput="false" />

<!--- Reset the content buffer. --->
<cfcontent type="text/html; charset=utf-8" />

<!DOCTYPE html>
<html>
<head>
	<title>HTML Email Utility - Best of ColdFusion 10 by Ben Nadel</title>
	
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
	
	
	<!-- Load scripts. -->
	<script type="text/javascript" src="http://code.jquery.com/jquery-1.7.2.min.js"></script>
	<script type="text/javascript" src="./linked/js/generator.js"></script>
	
</body>
</html>









