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
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;

  static final routes = [
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
  ];
}