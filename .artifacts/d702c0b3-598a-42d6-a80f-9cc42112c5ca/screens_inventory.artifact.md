# Shopping Admin Panel - Screen Inventory & Architecture

This document provides a comprehensive overview of all screens and dialogs in the `shopping_admin_panel` module (`new_flutter_project`).

## 🔐 Authentication & Navigation
- [AdminLoginScreen](file:///C:/Users/Welcome/StudioProjects/new_flutter_project/lib/screens/admin_login_screen.dart): Admin sign-in and authentication interface.
- [MainScreen](file:///C:/Users/Welcome/StudioProjects/new_flutter_project/lib/screens/main_screen.dart): Main container shell providing navigation across dashboard and management sections.

## 📊 Dashboard & Analytics
- [AdminDashboardScreen](file:///C:/Users/Welcome/StudioProjects/new_flutter_project/lib/screens/admin_dashboard_screen.dart): Central admin dashboard featuring responsive layouts, entry animations, financial overview, sales analytics charts, low stock alerts, recent orders, order status distribution, top products, and top categories.
- [TopProductsScreen](file:///C:/Users/Welcome/StudioProjects/new_flutter_project/lib/screens/top_products_screen.dart): Detailed analytics and listing of top-selling products.
- [TopCategoriesScreen](file:///C:/Users/Welcome/StudioProjects/new_flutter_project/lib/screens/top_categories_screen.dart): Detailed analytics and listing of top-performing categories.

## 📦 Catalog & Product Management
- [ProductsScreen](file:///C:/Users/Welcome/StudioProjects/new_flutter_project/lib/screens/products/products_screen.dart): Product catalog management, listing, search, and filtering.
- [ProductFormDialog](file:///C:/Users/Welcome/StudioProjects/new_flutter_project/lib/screens/products/product_form_dialog.dart): Comprehensive form dialog for creating and updating products (pricing, variants, images, stock).
- [CategoryListScreen](file:///C:/Users/Welcome/StudioProjects/new_flutter_project/lib/screens/products/category_list_screen.dart) & [CategoryDialog](file:///C:/Users/Welcome/StudioProjects/new_flutter_project/lib/screens/products/category_dialog.dart): Category list and creation/edit dialogs.
- [SubCategoryListScreen](file:///C:/Users/Welcome/StudioProjects/new_flutter_project/lib/screens/products/sub_category_list_screen.dart) & [SubCategoryDialog](file:///C:/Users/Welcome/StudioProjects/new_flutter_project/lib/screens/products/sub_category_dialog.dart): Sub-category list and management dialogs.
- [CategoryProductsScreen](file:///C:/Users/Welcome/StudioProjects/new_flutter_project/lib/screens/category_products_screen.dart): Products filtered by specific category.
- [BrandManagementScreen](file:///C:/Users/Welcome/StudioProjects/new_flutter_project/lib/screens/brand_management_screen.dart): Brand management and listing interface.

## 🛍️ Orders, Returns & Customers
- [AdminOrdersScreen](file:///C:/Users/Welcome/StudioProjects/new_flutter_project/lib/screens/admin_orders_screen.dart): Order tracking, status updates, and order details management.
- [AdminReturnsScreen](file:///C:/Users/Welcome/StudioProjects/new_flutter_project/lib/screens/admin_returns_screen.dart): Return requests, refunds, and return status handling.
- [AdminUsersScreen](file:///C:/Users/Welcome/StudioProjects/new_flutter_project/lib/screens/admin_users_screen.dart): Customer user accounts management and statistics.

## 📢 Marketing, Banners & Support
- [AdminBannersScreen](file:///C:/Users/Welcome/StudioProjects/new_flutter_project/lib/screens/admin_banners_screen.dart): Promotional banner management and scheduling.
- [AdminOffersScreen](file:///C:/Users/Welcome/StudioProjects/new_flutter_project/lib/screens/admin_offers_screen.dart): Discount offers and promotional campaign management.
- [AdminSupportScreen](file:///C:/Users/Welcome/StudioProjects/new_flutter_project/lib/screens/admin_support_screen.dart): Customer support tickets and resolution management.
