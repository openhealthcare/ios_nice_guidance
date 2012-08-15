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

- Use NSPredicate to remove "duplicate" PDFs from list, technically they have a different category so they aren't duplicate but on A-Z they are
- Favourite button that saves an array of titles into user_info.plist
- Share button that sends URL and title to Twitter and Email
- Settings page with details for app
- Tabbed Master view with a-z, category and favourite options
- General UI sprucing up
- Proper memory management review