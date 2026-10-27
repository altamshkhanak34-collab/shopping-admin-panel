# Shopping Admin Panel - Comprehensive Documentation Guide

Welcome to the official documentation guide for the **Shopping Admin Panel**, built with Flutter, Provider state management, and modern UI/UX principles.

---

## 1. Architecture & Tech Stack

- **Framework**: Flutter (Dart)
- **State Management**: Provider (`ChangeNotifier`) across modular providers (`AuthProvider`, `AdminProductProvider`, `AdminOrderProvider`, `AdminStatsProvider`, etc.).
- **Typography & Styling**: Google Fonts (`Lexend`), Material 3 design guidelines.
- **Networking**: Dio HTTP client for REST API communication.
- **Local Storage**: `shared_preferences` for session persistence & auto-login.
- **Effects**: `confetti` package for celebration and reward animations.

---

## 2. Authentication & Security

### [AdminLoginScreen](file:///C:/Users/Welcome/StudioProjects/new_flutter_project/lib/screens/admin_login_screen.dart)
- **Modern Responsive Split-Screen Layout**:
  - **Desktop/Web (>900px)**: Left-side branding panel with dark slate gradient (`#1E293B`, `#0F172A`, `#090D16`) highlighting Enterprise Grade Security, Real-Time Insights, and Seamless Control. Right-side clean floating login card.
  - **Mobile/Tablet**: Adaptive single-column layout.
- **Security Features**: Input validation, password visibility toggle, error handling, session management with auto-login via `AuthProvider`.

---

## 3. Core Modules & Navigation (`MainScreen`)

The admin panel provides a persistent sidebar (desktop) / drawer (mobile) with categorized navigation:

### A. Overview
- **Dashboard Overview** (`AdminDashboardScreen`): High-level revenue cards, profit & loss analysis, stats providers, and quick charts (`fl_chart`).

### B. Catalog Management
- **Products** (`ProductsScreen`): Add, edit, delete, and filter products, stock management.
- **Categories** (`CategoryListScreen`): Manage primary product categories.
- **Sub Categories** (`SubCategoryListScreen`): Manage subcategories associated with main categories.
- **Brands** (`BrandManagementScreen`): Brand list and management.

### C. Operations
- **Orders** (`AdminOrdersScreen`): Track customer orders, update order status, fulfill shipments.
- **Returns & Refunds** (`AdminReturnsScreen`): Manage customer return requests and refunds.
- **Support Tickets** (`AdminSupportScreen`): Handle customer service queries and support tickets.

### D. Marketing & Users
- **Banners** (`AdminBannersScreen`): Manage promotional carousel banners.
- **Offers** (`AdminOffersScreen`): Control discount coupons and special offers.
- **Users** (`AdminUsersScreen`): View and manage customer/admin user accounts.

### E. System & Fun Zone
- **Settings** (`AdminSettingsScreen`): App configurations, profile settings, and system preferences.
- **Quiz & Fun Zone** (`AdminQuizScreen`): Interactive trivia and brain-boost game for admins.

---

## 4. Admin Quiz & Fun Zone (`AdminQuizScreen`)

Designed to give administrators an engaging, brain-boosting break while testing e-commerce, architecture, and Flutter expertise.

### Key Features:
- **Randomized Question Bank**: Master pool of 15+ diverse questions. Each game session automatically shuffles and selects a random subset of 6 questions so questions never repeat in the same order.
- **Countdown Timer**: 15 seconds per question with animated countdown indicators.
- **Instant Color Feedback**: Green highlights for correct answers, red highlights for incorrect selections, accompanied by educational explanations.
- **Celebration Effects**: Triggers an explosive multi-color confetti celebration (`confetti` package) upon winning (achieving 60%+ score), along with final score and accuracy metrics.

---

## 5. Getting Started & Development

1. **Install Dependencies**:
   ```bash
   flutter pub get
   ```
2. **Run the Application**:
   ```bash
   flutter run
   ```
3. **Run Tests**:
   ```bash
   flutter test
   ```
