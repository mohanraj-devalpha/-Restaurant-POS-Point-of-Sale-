# Emzo Restaurant POS Application

A modern, high-performance Restaurant Point of Sale (POS) application built with Flutter, following Clean Architecture principles and BLoC for state management.

## 🚀 Overview

Emzo POS is designed for restaurant staff to manage orders, tables, and customers efficiently. It features a stunning, premium UI with smooth animations and a highly responsive layout.

## 🔑 Login Credentials

For testing and evaluation, use the following credentials:

- **Business ID**: `EMZO123`
- **Passcode**: `123456`

## ✨ Key Features

- **🛡️ Secure Authentication**: Multi-step login with Business ID and a 6-digit secure passcode.
- **🍽️ Menu Management**: 
  - Dynamic category switching.
  - Product search and filtering.
  - Grid and List view toggles.
  - Interactive "Add to Cart" with quantity controls.
- **🛒 Advanced Cart**:
  - Detailed billing breakdown (Sub-total, Tax, Service Charge).
  - Multiple payment types (Card, Cash, UPI).
  - Swipe-to-delete items.
- **📦 Order Management**:
  - **Pending Orders**: Track active orders, edit them, or print bills.
  - **Settled Orders**: View history of completed payments.
  - Print/Reprint functionality for physical receipts.
- **🪑 Table & Customer Selection**:
  - Interactive table selection with real-time capacity info.
  - Customer database with search and "Quick Add" features.

## 🏗️ Architecture & State Management

The project is built using a **Clean Architecture** approach, ensuring separation of concerns and testability:

1.  **Domain Layer**: Entities and Repository Interfaces (Pure Dart).
2.  **Data Layer**: Repository implementations and Local/Remote data sources.
3.  **Presentation Layer**: 
    - **BLoC**: Manages business logic and UI state (`AuthBloc`, `MenuBloc`, `CartBloc`, `OrderBloc`).
    - **UI Components**: Atomic design widgets and feature-specific screens.

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/)
- **State Management**: [flutter_bloc](https://pub.dev/packages/flutter_bloc)
- **Dependency Injection**: [provider](https://pub.dev/packages/provider)
- **Data Handling**: [Equatable](https://pub.dev/packages/equatable) for state comparison.
- **Styling**: Google Fonts (Inter, Roboto) and a custom theme engine.

## ⚙️ Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Android Studio / VS Code with Flutter extension

### Installation
1.  Clone the repository.
2.  Run `flutter pub get` to install dependencies.
3.  Launch the app using `flutter run`.

---

© 2026 Emzo Restaurant Systems. Built for excellence.