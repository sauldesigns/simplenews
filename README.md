# Le News

<!-- [![Build Status](https://travis-ci.org/{sauldesigns}/{simplenews}.png?branch=master)](https://travis-ci.org/{sauldesigns}/{simplenews}) -->

Le News is a cross-platform cloud-enabled mobile application powered by Flutter Framework.

The application was built with simplicity in mind by using tags to filter news articles.

| Demo |
| ------ |
| <img src="http://sauldesigns.me/img/le_news.gif"> |

| Tags | Articles |
| ------ | ------ |
|<img src="http://sauldesigns.me/img/IMG_2370.PNG" width="400" height="760">| <img src="http://sauldesigns.me/img/IMG_2372.PNG" width="400" height="760">|


### How To Use Application
  - Initial page will be tags list. By default Top will be first option
  - You can create tags by inputing in text field.
  - You can then scroll over to news articles by swiping left
  - Single tap will launch the article you are trying to read
  - Double tap will bring user back to initial page with a sliding animation.

### Database
  - Powered By Firebase:
    - Authenticaion
    - Image Storage
    - Data Storage

You can also:
  - Change profile picture
  - Reset password
  - Add Custom filter tags

### API
  - Powered by News API

>Le News uses News API in order to get the top news and pass in the tags so that the api can filter news articles based on tag title. The News API then sends JSON data over to app and then pushes it to function that creates pages containing Title, Description, and Image.

### Open Source Projects
Le News uses a number of open source projects to work properly:

  - [Firebase Core] - Enables connecting to multiple Firebase apps.
  - [Firebase Auth] - Enables Android and iOS authentication using passwords, phone numbers and identity providers like google, facebook, and twitter
  - [Firebase Storage] - Enables the use of Cloud Storage API.
  - [Firebase Cloud Firestore] - Enables the use of the Cloud Firestore API.
  - [http] - Future based library for making HTTP requests
  - [URL Launcher] - Flutter plugin for launching a URL in the mobile platform
  - [Image Picker] - Flutter plugin for iOS and Android for picking images from the image library, and taking new pictures with the camera
  - [Connectivity] - Allows app to discover network connectivity and configure themseleves accordingly.

### Mobile Application Installation

| Android | iOS |
| ------ | ------ |
| In-progress | In-progress |

Application in progress of being uploaded to both the iOS and Android App store.

### Todos
  - Write MORE Tests
  - Add Night Mode
  - Add bookmarks
  - Add search function within a tag
  - Add ability to jump to certain page
  - Add last tag and page location in cloud so that when user closes app it goes to page they were at on any device.

  [firebase core]: <https://pub.dev/packages/firebase_core>
  [firebase auth]: <https://pub.dev/packages/firebase_auth>
  [firebase storage]: <https://pub.dev/packages/firebase_storage>
  [firebase cloud firestore]: <https://pub.dev/packages/cloud_firestore>
  [http]: <https://pub.dev/packages/http>
  [url launcher]: <https://pub.dev/packages/url_launcher>
  [image picker]: <https://pub.dev/packages/image_picker>
  [connectivity]: <https://pub.dev/packages/connectivity>
  
  
  
  
