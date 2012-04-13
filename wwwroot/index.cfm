
<!--- Turn off any debugging output. --->
<cfsetting showdebugoutput="false" />

<!--- Reset the content buffer. --->
<cfcontent type="text/html; charset=utf-8" />

<!DOCTYPE html>
<html>
<head>
	<title>Email HTML Generator</title>
	
	<link rel="stylesheet" type="text/css" href="./linked/css/generator.css" />
</head>
<body>
	
	<!-- BEGIN: Header Panel. -->
	<div class="headerPanel">
		
		Email HTML Generator
		
	</div>
	<!-- END: Header Panel. -->
	
	<!-- BEGIN: Editor Panel. -->
	<div class="editorPanel">
		
		<h2>
			Enter Your Standard HTML With CSS Classes
		</h2>
		
		<form>
			
			<textarea class="html"></textarea>
			
		</form>
		
	</div>
	<!-- END: Editor Panel. -->
	
	<!-- BEGIN: Results Panel. -->
	<div class="resultsPanel">
		
		<ul class="tabs">
			<li class="tab">
				<a href="#preview">Preview</a>
			</li>
			<li class="tab">
				<a href="#html">HTML</a>
			</li>
		</ul>
		
		<div class="tabViews">
		
			<div class="tabView renderPreview">
				
				<iframe src="about:blank"></iframe>
				
			</div>
			
			<div class="tabView htmlPreview">
				
				<textarea class="html"></textarea>
				
			</div>
						
		</div>
		
	</div>
	<!-- END: Results Panel. -->	
	
	
	<!-- Load scripts. -->
	<script type="text/javascript" src="http://code.jquery.com/jquery-1.7.2.min.js"></script>
	<script type="text/javascript" src="./linked/js/generator.js"></script>
	
</body>
</html>









