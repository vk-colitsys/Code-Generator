<cfoutput>
	<h1 class="title">About this code</h1>
	<p> One rainy day, I sat down to auto generate a bunch of CFCs using 
		<a href="http://www.remotesynthesis.com/" title="Brian Rinaldi's Blog">Brian Rinaldi's</a>
		marvellous <a href="http://code.google.com/p/cfcgenerator/source/checkout">Illudium PU-36 Code Generator</a>.
		
		The trouble was, I was using Railo, and the blessed thing didn't work first time. Having zero patience, 
		I decided to rewrite the generator using HTML and js only, and adding functionality that I had always
		wanted to see. </p>
	
	<h2>How is it different from the original?</h2>
	<p> This code is at least 50% Illudium PU-36. However, I have:
	<ul>
		<li>extensively reorganised the model;</li>
		<li>made the project xml schema less implicit;</li>
		<li>added the ability to generate code for multiple tables at once;</li>
		<li>added the ability to serve the code as a zip file;</li>
		<li>added support for Railo 3.1;</li>
		<li><em>removed</em> the option for viewing the generated code in the page;</li>
		<li><em>removed</em> Flex from the equation; the application front end is html with a little javascript.</li>
	</ul>	
	
	<h2>Why Model-Glue?</h2>
	<p> I love coding with MG and hadn't had a chance to raodtest any of the new features in Gesture;
		so I used it here. It may seem a little overkill for an app this simple, but I wanted to make 
		the generator easily extensible and MG does that for me.</p>
		
	<h2>Contact</h2>
	<p> If you have any suggestions, criticisms or contributions, you can contact me here:</p>
	<ul>
		<li><a href="http://www.amazon.co.uk/gp/registry/wishlist/3SCP07J95IABF" target="_blank">Amazon Wishlist</a></li>
		<li><a href="http://fusion.dominicwatson.co.uk" target="_blank">My Blog</a></li>
	</ul>
</cfoutput>