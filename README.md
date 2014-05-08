SSXcodeSnippets
===============

This is NOT a complete project YET...needs fixes soon to be resolved.

The main objective of this application is to upload and download customized snippets to your account in Dropbox into XCode Snippets area.
Sure, there are other apps out there using github instead of dropbox which are very cool. But I think I may use my own app to work with snippets. 
You are free to use and change code (probably it will need to be changed xD)

HOW DOES IT WORK
===============
Press Login button
A new window page will be prompted in your web browser
Login with your dropbox account (for now only works wtih my account) ** change this for release next upgrade **
Allow access to the application

In the application window, press "Download Snippets"


BUGS:
===============
Apparently there is a bug with dropbox. When downloading snippets Dropboxs puts a text at the end of the code, so XCode reads as a duplicate and closes. *Something to fix soon.*


TO DO:
===============
- Release for production (is only for development)
- UPLOAD to Dropbox (when Dropbox release the option ;] )
- Separate classes. Taking out classes from appDelegate ¬¬ 
- Logo 
- Hide api client (oops)
