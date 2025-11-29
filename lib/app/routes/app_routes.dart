abstract class Routes {
  Routes._();
  
  static const ROOT = _Paths.ROOT;
  static const HOME = _Paths.HOME;
  static const LOGIN = _Paths.LOGIN;
  static const SERVICES = _Paths.SERVICES;
  static const INVOICE_CREATE = _Paths.INVOICE_CREATE;
  static const INVOICE_DETAIL = _Paths.INVOICE_DETAIL;
  static const INVOICE_EDIT = _Paths.INVOICE_EDIT;
  static const HISTORY = _Paths.HISTORY;
  static const SETTINGS = _Paths.SETTINGS;
  static const LOCATION = _Paths.LOCATION;
  static const PROFILE = _Paths.PROFILE;
  static const ORDERS = _Paths.ORDERS;
  static const REPORTS = _Paths.REPORTS;
  static const PICKUP = _Paths.PICKUP;
}

abstract class _Paths {
  _Paths._();
  
  static const ROOT = '/';
  static const HOME = '/home';
  static const LOGIN = '/login';
  static const SERVICES = '/services';
  static const INVOICE_CREATE = '/invoice/create';
  static const INVOICE_DETAIL = '/invoice/detail';
  static const INVOICE_EDIT = '/invoice/edit';
  static const HISTORY = '/history';
  static const SETTINGS = '/settings';
  static const LOCATION = '/location';
  static const PROFILE = '/profile';
  static const ORDERS = '/orders';
  static const REPORTS = '/reports';
  static const PICKUP = '/pickup';
}