import 'package:get/get.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/services/bindings/services_binding.dart';
import '../modules/services/views/services_view.dart';
import '../modules/invoice/bindings/invoice_binding.dart';
import '../modules/invoice/views/invoice_create_view.dart';
import '../modules/invoice/views/invoice_detail_view.dart';
import '../modules/invoice/views/invoice_edit_view.dart';
import '../modules/history/bindings/history_binding.dart';
import '../modules/history/views/history_view.dart';
import '../modules/location/bindings/location_binding.dart';
import '../modules/location/views/location_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/root/root_view.dart';
import '../modules/root/root_binding.dart';
import 'app_routes.dart';
import '../modules/orders/bindings/orders_binding.dart';
import '../modules/orders/views/orders_view.dart';
import '../modules/reports/bindings/reports_binding.dart';
import '../modules/reports/views/reports_view.dart';
import '../modules/pickup/bindings/pickup_binding.dart';
import '../modules/pickup/views/pickup_view.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: Routes.ROOT,
      page: () => const RootView(),
      binding: RootBinding(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.SERVICES,
      page: () => const ServicesView(),
      binding: ServicesBinding(),
    ),
    GetPage(
      name: Routes.INVOICE_CREATE,
      page: () => const InvoiceCreateView(),
      binding: InvoiceBinding(),
    ),
    GetPage(
      name: Routes.INVOICE_DETAIL,
      page: () => const InvoiceDetailView(),
      binding: InvoiceBinding(),
    ),
    GetPage(
      name: Routes.INVOICE_EDIT,
      page: () => const InvoiceEditView(),
      binding: InvoiceBinding(),
    ),
    GetPage(
      name: Routes.HISTORY,
      page: () => const HistoryView(),
      binding: HistoryBinding(),
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: Routes.LOCATION,
      page: () => const LocationView(),
      binding: LocationBinding(),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: Routes.ORDERS,
      page: () => const OrdersView(),
      binding: OrdersBinding(),
    ),
    GetPage(
      name: Routes.REPORTS,
      page: () => const ReportsView(),
      binding: ReportsBinding(),
    ),
    GetPage(
      name: Routes.PICKUP,
      page: () => const PickupView(),
      binding: PickupBinding(),
    ),
  ];
}