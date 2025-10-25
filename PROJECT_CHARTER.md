# PROJECT_CHARTER

Project: Smart Task Manager

Goal
- Learn and demonstrate HTTP POST/GET/PUT/DELETE using Dio.
- Implement local caching (Hive), pagination, search, and retry logic.

Architecture
- Feature-first structure under `lib/features/tasks`.
- Core networking under `lib/core/network` (DioClient, NetworkException).
- Repositories hide data source details (remote/local).
- Riverpod for state management in presentation layer.

Learning Objectives
- Understand request lifecycle and error handling with Dio.
- Implement offline caching with Hive.
- Add retry logic and pagination.
- Write unit and widget tests for networking and local cache.

Success Criteria
- All features implemented: CRUD, caching, retry, pagination, search.
- Tests pass locally (`flutter test`).
- App runs on a mobile device via `flutter run`.
