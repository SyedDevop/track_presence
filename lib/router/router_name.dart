class RouteNames {
  /// Home Screen path name no {Params || queryParams} required [home]
  static String home = "home";
  static String homePath = "/";

  /// Profile Screen path name "Params = {'id':"vch1111"} and queryParams = {"img-path": "/path/tp/img"}" required [profile]
  static String profile = "profile";
  static String profilePath = "/profile/:id";

  /// Account Screen path name no {Params || queryParams} required "[account]
  static String account = "account";
  static String accountPath = "/account/:id";

  /// Leaves  Screen path name no {Params || queryParams} required [leave]
  static String leave = "leave";
  static String leavePath = "/leave";

  /// Attendance Report Screen path name no {Params || queryParams} required [atReport]
  static String atReport = "at-report";
  static String atReportPath = "/at-report";

  /// Shifts Report Screen path name no {Params || queryParams} required [stReport]
  static String stReport = "st-report";
  static String stReportPath = "/st-report";

  /// Clock Attendance Screen path name Params = {'location': '12.3443,123.123124'} no {queryParams} required [clock]
  static String clock = "clock";
  static String clockPath = "/$clock/:location";

  /// Registration Screen path name no {Params || queryParams} required [register]
  static String register = "register";
  static String registerPath = "/$register";

  /// Registration Scan Screen path name no {Params || queryParams} required [registerScan]
  static String registerScan = "register-scan";
  static String registerScanPath = "/$registerScan";

  /// Login Screen path name no {Params || queryParams} required [login]
  static String login = "login";
  static String loginPath = "/$login";
}
