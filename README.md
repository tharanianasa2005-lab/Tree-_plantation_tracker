# tree_plantation_tracker

Flutter client for the Tree Plantation Tracker MySQL-backed REST API.

## Configure the API

The app sends authentication, tree, and admin requests to the REST API. Set its
base URL at build/run time:

```shell
flutter run --dart-define=API_BASE_URL=https://your-api-host
```

For Android emulators, use the host machine's emulator-accessible address
(commonly `http://10.0.2.2:3000`) rather than `localhost`. Physical devices
must use a server address reachable from the device. The API must provide
`/api/register`, `/api/login`, `/api/trees`, `/api/users`, and `/api/reports`.

Firebase configuration files containing project API keys are excluded from
version control. Configure Firebase locally with FlutterFire CLI and obtain
`android/app/google-services.json` from the Firebase console before building
the Android app.

Tree ownership is enforced by the API using the logged-in user's token. Before
starting the updated API, run `migrations/add_tree_owner.sql` from the backend
project against its MySQL database. Existing tree records will have no owner
until an administrator assigns them; new records are automatically saved to
the logged-in user.

Admin user management displays account profile details returned by the API;
passwords must remain hashed on the server and are never displayed by the app.

Tree photos selected while adding a tree are stored by the API. In **My Trees**,
tap the camera icon on a tree's image to replace its photo. Photos must be under
500 KB; restart the API after updating its server code.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
