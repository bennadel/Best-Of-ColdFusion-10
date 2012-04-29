
component
	output="false"
	hint="I define the application settings and event handlers."
	{
		
		
	// Define the application settings.
	this.name = hash( getCurrentTemplatePath() );
	this.applicationTimeout = createTimeSpan( 0, 1, 0, 0 );
	this.sessionManagement = false;
	
	// Turn on implicit notation so that properties can be accessed without the use of their
	// underyling getter/setter methods. This requires configuring the "accessor" properties on
	// and CFCs that support this approach.
	this.invokeImplicitAccessor = true;
	
	// Define our per-application Java library settings. Here, we are telling it to load JAR and 
	// CLASS files in the lib directory that is located in our application root. In this case, we
	// are loading the JSoup 1.6.2 Class for parsing, traversing, and mutating HTML Documents.
	this.javaSettings = {
		loadPaths: [
			"./lib/"
		],
		loadColdFusionClassPath: true
	};
	
	
}