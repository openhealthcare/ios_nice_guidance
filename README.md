NICE Guidelines - iOS
=====================

iOS app
-------
The iOS app is contained within the 'NICE Guidelines' folder. Fire up the xCode project to run it. This is a universal app (runs on both iPhone and iPad), the 'master' view displays the table of guidelines (powered by Core Data) and the 'detail' view displays the PDF in a webview.

Mac OS X app
------------
The Mac OS X is used to convert the XML from the webserver into a .sqllite file that can be dropped into the app to pre-populate the core data model. Load the app in Xcode and build and run it. The .sqlite file will be in the ~/Library/XML to SQLLite/ folder of your Mac's boot volume.

What's next?
------------

- Tabbed Master view with a-z, category and favourite options
- General UI sprucing up
- Proper memory management review