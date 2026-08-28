# Roan Justine B. Baluyut
## INF231
## CTADMOBL Advance Mobile Programming
## Long Exam 1
The application uses a Model-Service-Screen structure to separate the different parts of the application.

Models handle the data of the app. The User, Post, and Comment models define the structure of the data and use fromJson() to convert the JSON data from the API into Dart objects.

Services handle the communication between the app and the API. UserService, PostService, and CommentService handle the API requests, while LocalStorageService handles the saved data using shared_preferences. The Services return the data as Models instead of making the Screens handle raw JSON.

Screens are responsible for displaying the data and handling the UI. For example, the NewsFeedScreen calls PostService to get the posts, receives a List<Post>, and uses it to display the posts.

The interaction is basically:

Screen - Service - API - Model - Screen

This structure makes the code easier to manage because each part has its own job. If the API changes, the Service can be updated without changing the Screen. It also makes the Models and Services reusable in different Screens.

