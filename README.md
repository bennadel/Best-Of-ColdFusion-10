
# Best of ColdFusion 10 Contest

By Ben Nadel (www.bennadel.com)

## HTML Email Utility

I have created a simple, one-page application that takes "normal" HTML - that 
is, HTML with STYLE tags - and creates HTML that is more suitable for all the 
major email clients. It does this by extracting the Style tags and injecting 
the CSS rules into the actual markup of the document. All of the rules that 
apply to a given element will be defined in that element's "style" attribute.

As this transformation takes place, the conversion engine takes into account:

* Specificity of CSS.
* Document order.
* Existing style attributes.

The CSS parsing is done completely with common CSS delimiters (ie. {, }, and ;). 
It does not validate properties; nor, does it omit CSS properties that are not 
supported. It also doen't do any cleanup as far as redundant properties are 
concerned. It simply takes what you have in the Style tags, runs it against the
HTML, and lets the natural "cascading" of CSS do its magic.

## ColdFusion 10 Features

The goal of this contest entry is to demonstrate one or more of the new features 
of ColdFusion 10. My entry primarilyy looks at the use of per-application Java 
loading, using the jSoup library as the means to parse the incoming HTML, 
extract the Style tags, and then apply the CSS selectors.

Overall, however, a number of ColdFusion 10 features were touched:

* **Per-Application Java Loading**: As I stated above, I'm using the 
per-application JAR settings to load the jSoup library.
* **Invoke Implicit Accessors**: This settings allows property access to 
implicitly invoke the associated getters/setters without an explicit method
call. I am not sure how I feel about this one. I used it (CSSRule.cfc) mostly 
because I have never used it before - not because I thought that it was 
necessarily the right too for the job. I am a little confused as to the 
proper use-case for it.
* **arrayAppend( x, y, true )**: I LOVE the new, third property which allows 
the injected value to be flattened into the target array. This is hugely useful.
* **arrayEach()**: Using closures to iterate over an array. Awesome! Though, I 
must say that using For-In on an array feels equally useful at times. But, 
there are times when arrayEach() feels like the better choice.
* **arraySort()**: Using closures to define the comparator for the sort.
* **structEach()**: Using closures to iterate over the key-value pairs.

## Installation Instructions

Runs as-is from anywhere so long as ColdFusion 10 is the underlying engine. All
dependencies are in the source code, including the jSoup JAR file and JavaScript
files. No internet connectivity is required.

That's all - I hope you like it! ColdFusion 10 FTW!!!!