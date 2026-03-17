# Raven Messenger - Документация курсовой работы

## 📋 Оглавление
1. [Общее описание](#общее-описание)
2. [Архитектура приложения](#архитектура-приложения)
3. [Структура проекта](#структура-проекта)
4. [Технологический стек](#технологический-стек)
5. [API и endpoints](#api-и-endpoints)
6. [Модели данных](#модели-данных)
7. [Логика работы](#логика-работы)
8. [Функциональность](#функциональность)
9. [Установка и запуск](#установка-и-запуск)
10. [Заключение](#заключение)

---

## Общее описание

### О проекте
**Raven Messenger** — это мобильное приложение-мессенджер для безопасного общения пользователей в реальном времени, разработанное на фреймворке Flutter.

### Цели проекта
- Создание платформы для обмена сообщениями между пользователями
- Поддержка личных и групповых чатов
- Реализация системы аутентификации и авторизации
- Управление профилем пользователя
- Обеспечение безопасности данных с помощью JWT-токенов

### Основные возможности
- 📱 Регистрация и авторизация пользователей
- 💬 Создание личных и групповых чатов
- 🔍 Поиск пользователей и чатов
- 👥 Управление участниками группы
- 🎨 Светлая и тёмная темы оформления
- 📊 Просмотр профиля пользователя
- 🔐 Безопасная аутентификация с токенами
- 📁 Загрузка и отправка файлов

---

## Архитектура приложения

### Паттерн MVC (Model-View-Controller)

Приложение построено на основе паттерна MVC с дополнительным слоем Data Access Layer:

```
┌─────────────────────────────────────────┐
│           Presentation Layer            │
│  (Screens, Widgets, State Management)   │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│        Business Logic Layer             │
│  (Providers, Controllers)               │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│          Data Access Layer              │
│  (API Client, Repositories)             │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│          Server (Backend)               │
│  (C# .NET, SQL Database)                │
└─────────────────────────────────────────┘
```

### Компоненты архитектуры

#### 1. **Presentation Layer (Экран/UI)**
- Flutter Widgets и Pages
- Управление состоянием через Provider
- Обработка пользовательских действий

#### 2. **Data Layer (Данные)**
- ApiClient - класс для работы с HTTP-запросами
- Парсинг JSON-ответов
- Кэширование токенов

#### 3. **Business Logic Layer (Бизнес-логика)**
- ThemeProvider - управление темой приложения
- Валидация данных
- Логика переходов между экранами

---

## Структура проекта

```
raven_messenger/
├── lib/
│   ├── main.dart                          # Точка входа приложения
│   ├── screens/                           # Экраны приложения
│   │   ├── splash_screen.dart             # Заставка при загрузке
│   │   ├── login_screen.dart              # Экран входа
│   │   ├── register_screen.dart           # Экран регистрации
│   │   ├── home_screen.dart               # Главный экран (список чатов)
│   │   ├── chat_screen.dart               # Экран чата
│   │   └── search_screen.dart             # Экран поиска
│   ├── data/
│   │   ├── datasources/
│   │   │   └── remote/
│   │   │       └── api_client.dart        # HTTP-клиент для API
│   │   └── models/
│   │       └── chat_models.dart           # Модели данных
│   ├── theme/
│   │   └── app_theme.dart                 # Цветовая схема и стили
│   └── widgets/
│       └── custom_text_field.dart         # Переиспользуемые компоненты
├── assets/
│   └── images/                            # Изображения и иконки
├── pubspec.yaml                           # Конфигурация зависимостей
└── swagger.json                           # Документация API
```

---

## Технологический стек

### Frontend
| Технология | Версия | Назначение |
|------------|--------|-----------|
| **Flutter** | 3.0+ | Фреймворк для разработки мобильных приложений |
| **Dart** | 3.0+ | Язык программирования |
| **Provider** | ^6.1.0 | Управление состоянием приложения |
| **Dio** | ^5.3.0 | HTTP-клиент для API-запросов |
| **Logger** | ^2.1.0 | Логирование операций |
| **Intl** | ^0.19.0 | Интернационализация и локализация |

### Backend
| Технология | Версия | Назначение |
|------------|--------|-----------|
| **C# .NET** | 7.0+ | Язык и фреймворк backend |
| **SQL Server** | - | База данных |
| **JWT** | - | Аутентификация токенов |

### Платформы
- 📱 **Android** (API 21+)
- 🍎 **iOS** (13.0+)

---

## API и endpoints

### Базовый URL
```
https://ravenapp.ru/api
```

### Аутентификация

#### Регистрация
```http
POST /Auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123",
  "firstName": "John",
  "lastName": "Doe",
  "username": "johndoe"
}

Response 200:
{
  "userId": "uuid",
  "email": "user@example.com",
  "token": "jwt_token",
  "refreshToken": "refresh_token",
  "avatarUrl": "https://..."
}
```

#### Вход в систему
```http
POST /Auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}

Response 200:
{
  "userId": "uuid",
  "token": "jwt_token",
  "refreshToken": "refresh_token",
  "settings": { /* user settings */ }
}
```

#### Обновление токена
```http
POST /Auth/refresh
Content-Type: application/json

{
  "token": "old_token",
  "refreshToken": "refresh_token"
}
```

#### Выход
```http
POST /Auth/logout
Content-Type: application/json
Authorization: Bearer {token}

{
  "refreshToken": "refresh_token"
}
```

### Работа с чатами

#### Создание личного чата
```http
POST /Chats/personal/{targetUserId}
Authorization: Bearer {token}

Response 200:
{
  "chatId": "uuid",
  "name": "John Doe",
  "type": 0,
  "participants": [...]
}
```

#### Создание группового чата
```http
POST /Chats/group
Content-Type: application/json
Authorization: Bearer {token}

{
  "name": "My Group",
  "description": "Group description",
  "type": 1,
  "memberIds": ["uuid1", "uuid2"],
  "isPublic": false
}

Response 200:
{
  "chatId": "uuid",
  "name": "My Group",
  "ownerId": "uuid"
}
```

#### Получение всех чатов
```http
GET /Chats?page=1&pageSize=25
Authorization: Bearer {token}

Response 200:
{
  "chats": [
    {
      "chatId": "uuid",
      "name": "Chat Name",
      "lastMessage": "Last message text",
      "updatedAt": "2024-03-16T08:00:00Z",
      "unreadCount": 5
    }
  ],
  "totalCount": 50
}
```

#### Удаление чата
```http
DELETE /Chats/{chatId}
Authorization: Bearer {token}
```

### Работа с сообщениями

#### Отправка сообщения
```http
POST /Messages/send?targetUserId={uuid}
Content-Type: multipart/form-data
Authorization: Bearer {token}

FormData:
- ChatId: uuid
- Content: "Message text"
- File: (optional)

Response 200:
{
  "messageId": "uuid",
  "content": "Message text",
  "senderId": "uuid",
  "timestamp": "2024-03-16T08:00:00Z"
}
```

#### Получение сообщений чата
```http
GET /Messages/{chatId}?page=1&pageSize=25
Authorization: Bearer {token}

Response 200:
{
  "messages": [
    {
      "messageId": "uuid",
      "content": "Text",
      "senderId": "uuid",
      "timestamp": "2024-03-16T08:00:00Z"
    }
  ],
  "totalCount": 100
}
```

#### Редактирование сообщения
```http
PUT /Messages/edit/{messageId}
Content-Type: application/json
Authorization: Bearer {token}

{
  "content": "Edited message text"
}
```

#### Удаление сообщения
```http
DELETE /Messages/delete/{messageId}
Authorization: Bearer {token}
```

### Работа с профилем

#### Получение профиля текущего пользователя
```http
GET /Users/profile
Authorization: Bearer {token}

Response 200:
{
  "userId": "uuid",
  "email": "user@example.com",
  "firstName": "John",
  "lastName": "Doe",
  "username": "johndoe",
  "avatarUrl": "https://...",
  "description": "User bio",
  "settings": { /* settings */ }
}
```

#### Получение профиля пользователя по ID
```http
GET /Users/{userId}
Authorization: Bearer {token}
```

#### Обновление профиля
```http
PUT /Users
Content-Type: application/json
Authorization: Bearer {token}

{
  "firstName": "John",
  "lastName": "Doe",
  "description": "New bio",
  "gender": 0,
  "phoneNumber": "+7..."
}
```

### Статус пользователя

#### Получение статуса
```http
GET /Activity/status
Authorization: Bearer {token}

Response 200:
{
  "userId": "uuid",
  "status": 1,  // 1: Online, 2: Away, 3: Do Not Disturb
  "lastSeen": "2024-03-16T08:00:00Z"
}
```

#### Ping (обновление активности)
```http
POST /Activity/ping
Authorization: Bearer {token}
```

---

## Модели данных

### User (Пользователь)
```dart
class User {
  final String userId;
  final String email;
  final String firstName;
  final String lastName;
  final String username;
  final String? avatarUrl;
  final String? description;
  final DateTime? dateOfBirth;
  final UserSettings settings;
  
  User({
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.username,
    this.avatarUrl,
    this.description,
    this.dateOfBirth,
    required this.settings,
  });
}
```

### Chat (Чат)
```dart
class Chat {
  final String chatId;
  final String name;
  final ChatType type; // 0: Personal, 1: Group
  final String? description;
  final String? avatarUrl;
  final List<String> memberIds;
  final String ownerId;
  final String lastMessage;
  final DateTime updatedAt;
  final int unreadCount;
  final bool isMuted;
  
  Chat({
    required this.chatId,
    required this.name,
    required this.type,
    this.description,
    this.avatarUrl,
    required this.memberIds,
    required this.ownerId,
    required this.lastMessage,
    required this.updatedAt,
    required this.unreadCount,
    required this.isMuted,
  });
}
```

### Message (Сообщение)
```dart
class Message {
  final String messageId;
  final String chatId;
  final String senderId;
  final String content;
  final List<String>? fileUrls;
  final String? replyToMessageId;
  final DateTime timestamp;
  final DateTime? editedAt;
  final bool isRead;
  final int reactionCount;
  
  Message({
    required this.messageId,
    required this.chatId,
    required this.senderId,
    required this.content,
    this.fileUrls,
    this.replyToMessageId,
    required this.timestamp,
    this.editedAt,
    required this.isRead,
    required this.reactionCount,
  });
}
```

### UserSettings (Настройки пользователя)
```dart
class UserSettings {
  final String theme; // 'light' или 'dark'
  final String fontSize; // 'small', 'medium', 'large'
  final String language; // 'ru', 'en'
  final bool pushNotifications;
  final PhoneVisibility phoneVisibility;
  final bool findByPhoneEnabled;
  final bool findByFriendsEnabled;
  final FriendRequestPolicy friendRequestPolicy;
  final ReadReceipts readReceipts;
  
  UserSettings({
    required this.theme,
    required this.fontSize,
    required this.language,
    required this.pushNotifications,
    required this.phoneVisibility,
    required this.findByPhoneEnabled,
    required this.findByFriendsEnabled,
    required this.friendRequestPolicy,
    required this.readReceipts,
  });
}
```

---

## Логика работы

### 1. Процесс аутентификации

```
┌─────────────────────────────────────────────┐
│  Пользователь открывает приложение          │
└────────────────┬────────────────────────────┘
                 │
                 ▼
        ┌────────────────────┐
        │  SplashScreen      │ ← Анимированная заставка
        │  (3 сек)           │   с логотипом
        └────────────┬───────┘
                     │
                     ▼
        ┌────────────────────────────┐
        │  Проверка сохранённого     │
        │  токена в памяти           │
        └────────┬──────────────┬────┘
                 │              │
            ЕСТЬ │              │ НЕТ ТОКЕНА
                 │              │
        ┌────────▼─┐    ┌───────▼────────┐
        │HomeScreen│    │LoginScreen     │
        │(Чаты)    │    │Регистрация     │
        └──────────┘    │или Вход        │
                        └─────┬──────────┘
                              │
                    ┌─────────▼────────┐
                    │RegisterScreen    │
                    │(если нет аккаунта)│
                    └────────┬────────┘
                             │
              ┌──────────────┴──────────────┐
              │ POST /Auth/register         │
              │ или POST /Auth/login        │
              └────────────┬────────────────┘
                           │
                  ┌────────▼────────┐
                  │Сохранение токена│
                  │в ApiClient      │
                  └────────┬────────┘
                           │
                    ┌──────▼──────┐
                    │HomeScreen   │
                    │(Чаты)       │
                    └─────────────┘
```

### 2. Процесс работы с чатами

```
┌─────────────────────────────────┐
│ HomeScreen - Список чатов       │
│ - GET /Chats?page=1             │
└────────────┬────────────────────┘
             │
    ┌────────┴────────┬────────────┐
    │ Показать чаты   │ Поиск      │ Создать
    │                 │ пользователей
    ▼                 ▼            ▼
┌─────────┐      ┌─────────┐  ┌──────────┐
│ChatScreen│      │SearchScreen│CreateChat│
│Сообщения │      │Найти юзера │GET/POST  │
└────┬────┘      └─────────┘  └──────────┘
     │
     ├─ GET /Messages/{chatId}
     ├─ POST /Messages/send
     ├─ PUT  /Messages/edit/{id}
     └─ DELETE /Messages/delete/{id}
```

### 3. Управление состоянием

```dart
// Provider используется для управления состоянием
// Пример: ThemeProvider
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  
  bool get isDarkMode => _isDarkMode;
  
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners(); // Уведомить UI об изменении
  }
}
```

---

## Функциональность

### ✅ Реализованные функции

#### Аутентификация
- ✅ Регистрация нового пользователя
- ✅ Вход в систему
- ✅ Выход из системы
- ✅ Обновление токена
- ✅ Сохранение JWT-токена

#### Управление чатами
- ✅ Просмотр списка чатов
- ✅ Создание личного чата
- ✅ Создание группового чата
- ✅ Удаление чата
- ✅ Выход из группового чата
- ✅ Управление участниками

#### Сообщения
- ✅ Отправка текстовых сообщений
- ✅ Загрузка и отправка файлов
- ✅ Редактирование сообщений
- ✅ Удаление сообщений
- ✅ Просмотр истории сообщений
- ✅ Поиск сообщений

#### Профиль пользователя
- ✅ Просмотр профиля
- ✅ Редактирование профиля
- ✅ Загрузка аватара
- ✅ Просмотр статуса пользователя

#### UI/UX
- ✅ Светлая и тёмная темы
- ✅ Адаптивный дизайн
- ✅ Анимированная заставка
- ✅ Сайдбар профиля
- ✅ Pull-to-refresh для обновления чатов

### 📋 Возможные улучшения

- [ ] Видео-звонки
- [ ] Голосовые сообщения
- [ ] Шифрование сообщений
- [ ] Реакции на сообщения
- [ ] Стикеры и эмодзи
- [ ] Синхронизация offline-сообщений
- [ ] WebSocket для real-time обновлений
- [ ] Analytics и статистика

---

## Установка и запуск

### Требования
- Flutter SDK 3.0+
- Dart SDK 3.0+
- Android SDK (API 21+) или Xcode (13+)
- Git

### Шаги установки

#### 1. Клонирование репозитория
```bash
git clone https://github.com/Kacheer/msger-raven.git
cd raven_messenger
```

#### 2. Установка зависимостей
```bash
flutter clean
flutter pub get
```

#### 3. Конфигурация API
Убедитесь, что URL сервера в `api_client.dart` указан правильно:
```dart
const String _baseUrl = 'https://ravenapp.ru/api';
```

#### 4. Запуск приложения

**На эмуляторе Android:**
```bash
flutter run
```

**На реальном устройстве Android:**
```bash
flutter run -v
```

**На iOS:**
```bash
cd ios
pod install
cd ..
flutter run
```

#### 5. Создание APK/IPA
```bash
# Android APK
flutter build apk --release

# iOS IPA
flutter build ios --release
```

---

## Описание ключевых компонентов

### ApiClient

**Файл:** `lib/data/datasources/remote/api_client.dart`

Класс для работы с REST API сервера:

```dart
class ApiClient {
  final Dio _dio;
  String? _token;
  String? _currentUserId;
  
  // Методы аутентификации
  Future<Response> register(String email, String password, ...) {}
  Future<Response> login(String email, String password) {}
  
  // Методы работы с чатами
  Future<Response> getChats({int page = 1, int pageSize = 25}) {}
  Future<Response> createChat({required String name, ...}) {}
  Future<Response> deleteChat(String chatId) {}
  
  // Методы работы с сообщениями
  Future<Response> getMessages(String chatId, {int page = 1}) {}
  Future<Response> sendMessage(String chatId, String content) {}
  
  // Методы работы с пользователем
  Future<Response> getUserProfile() {}
  Future<Response> updateProfile({required UpdateUserRequest request}) {}
  
  // Методы для управления токеном
  void setToken(String token) {}
  void clearToken() {}
}
```

### Screens (Экраны)

#### SplashScreen
- Анимированная заставка при загрузке приложения
- Отображает логотип с масштабированием
- Переходит на экран входа через 3 секунды

#### LoginScreen
- Форма входа с полями email и пароль
- Валидация входных данных
- Вызов API `/Auth/login`
- Ссылка на экран регистрации

#### RegisterScreen
- Форма регистрации с полями: имя, фамилия, email, пароль, никнейм
- Проверка минимальной длины пароля (6 символов)
- Вызов API `/Auth/register`
- Возврат на экран входа после успешной регистрации

#### HomeScreen
- Список всех чатов пользователя
- Pull-to-refresh для обновления
- Сайдбар профиля при свайпе влево
- Удаление чата со свайпом влево с подтверждением
- Поиск пользователей для создания чатов

#### ChatScreen
- Список сообщений чата
- Поле ввода для отправки сообщений
- Загрузка файлов
- Редактирование и удаление сообщений
- Информация о чате в header

---

## Структура файлов приложения

### lib/screens/
```
screens/
├── splash_screen.dart       # Заставка (3 сек)
├── login_screen.dart        # Вход в систему
├── register_screen.dart     # Регистрация
├── home_screen.dart         # Список чатов с сайдбаром
├── chat_screen.dart         # Экран чата
└── search_screen.dart       # Поиск пользователей
```

### lib/data/
```
data/
├── datasources/
│   └── remote/
│       └── api_client.dart  # HTTP-клиент
└── models/
    └── chat_models.dart     # Модели Dart
```

### lib/theme/
```
theme/
└── app_theme.dart           # Цвета, шрифты, стили
```

---

## Обработка ошибок

### Ошибки аутентификации
```dart
try {
  await apiClient.login(email, password);
} catch (e) {
  // Status 400: Invalid credentials
  // Status 401: Unauthorized
  // Status 500: Server error
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Ошибка входа: $e')),
  );
}
```

### Проверка mounted
```dart
// Избегаем ошибок "widget has been unmounted"
if (!mounted) return;
setState(() => _isLoading = false);
```

### Перехват ошибок API
```dart
// ApiClient имеет перехватчики для логирования
_dio.interceptors.add(
  InterceptorsWrapper(
    onRequest: (options, handler) {
      // Логирование запроса
      return handler.next(options);
    },
    onError: (error, handler) {
      // Обработка ошибки
      logger.e('API Error: $error');
      return handler.next(error);
    },
  ),
);
```

---

## Безопасность

### JWT-токены
- Токены сохраняются в памяти приложения
- Включаются в заголовок `Authorization: Bearer {token}`
- Автоматически обновляются при необходимости

### Валидация входных данных
```dart
// Email
if (!emailPattern.hasMatch(email)) {
  // Ошибка: невалидный email
}

// Пароль (минимум 6 символов)
if (password.length < 6) {
  // Ошибка: пароль слишком короткий
}

// UUID
final uuidPattern = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
  caseSensitive: false,
);
```

---

## Тестирование

### Тестовые аккаунты
```
Email: okak500@gmail.com
Password: okak500
FirstName: okakich
LastName: okakov
Username: okak500
```

### Примеры API-запросов

**Регистрация:**
```bash
curl -X POST https://ravenapp.ru/api/Auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "firstName": "Test",
    "lastName": "User",
    "username": "testuser"
  }'
```

**Вход:**
```bash
curl -X POST https://ravenapp.ru/api/Auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

**Получение чатов:**
```bash
curl -X GET "https://ravenapp.ru/api/Chats?page=1&pageSize=25" \
  -H "Authorization: Bearer {token}"
```

---

## Заключение

### Итоги разработки

Raven Messenger представляет собой полнофункциональное мобильное приложение-мессенджер, построенное на современных технологиях и следующее лучшим практикам разработки:

**Достигнутые результаты:**
- ✅ Реализована полная система аутентификации и авторизации
- ✅ Реализованы личные и групповые чаты
- ✅ Успешно интегрирован REST API
- ✅ Реализована поддержка светлой/тёмной темы
- ✅ Обеспечена удобная пользовательская навигация

**Архитектурные решения:**
- Использование паттерна MVC для разделения ответственности
- Применение Provider для управления состоянием
- Использование Dio для асинхронной работы с API
- JWT-аутентификация для безопасности

**Возможности для масштабирования:**
- Модульная структура позволяет легко добавлять новые функции
- Разделение на слои облегчает тестирование
- API документирована и готова к расширению

### Ссылки на репозитории

- **Frontend (Flutter):** https://github.com/Kacheer/msger-raven
- **Backend (.NET):** https://github.com/Grincheser/ServerMsg
- **API Swagger:** https://ravenapp.ru/swagger

### Контактная информация

- **Разработчик:** Kacheer
- **Email:** [ваш_email]
- **GitHub:** https://github.com/Kacheer

---

**Документация подготовлена:** 16.03.2024
**Версия приложения:** 1.0.0
**Статус:** Готово к использованию