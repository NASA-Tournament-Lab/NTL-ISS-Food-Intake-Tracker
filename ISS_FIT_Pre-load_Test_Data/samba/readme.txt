samba.tar.gz
-> The samba data to be deployed to samba sever.

application_data
-> The folder contains pre-loaded data. The app is compiled and built with pre-loaded data (images, food details, user profiles, etc.).
To generate the pre-load data, please follow the steps:
a.	Reset the iOS 5.1 simulator in Xcode.
b.	Delete all folders in samba server, and extract “samba/samba.tar.gz” file to samba server.
c.	Replace the content in “data_sync/OTHER_DEVICE_ID/1376993248/” folder in samba server with the latest files if necessary. Note that “data_sync/OTHER_DEVICE_ID/1376993248/” is the default device sync folder that is used for generating pre-load data.
d.	Replace the content in “control_files” folder in samba server with the latest files if necessary. 
e.	Set “CreatePreloadApplicationData” in Configuration.plist in the Xcode project to “YES”.
f.	Run the project in iOS 5.1 simulator, and wait until the sync completes. 
g.	Copy the content in ~/Library/Application Support/iPhone Simulator/5.1/Applications/{FoodIntakeTracker App UDID}/Documents in Mac to “samba/application_data” in the source code repository.
h.	Set Set “CreatePreloadApplicationData” in Configuration.plist in the Xcode project to “NO”.


