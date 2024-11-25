class RouteNames {
  /// Home Screen path name no {Params || queryParams} required [home]
  static String home = "home";
  static String homePath = "/";

  /// Profile Screen path name "Params = {'id':"vch1111"} required " required [profile]
  static String profile = "profile";
  static String profilePath = "/profile/:id";

  /// Leaves  Screen path name no {Params || queryParams} required [leave]
  static String leave = "leave";
  static String leavePath = "/leave";

  /// Attendance Report Screen path name no {Params || queryParams} required [atReport]
  static String atReport = "at-report";
  static String atReportPath = "/at-report";

  /// Shifts Report Screen path name no {Params || queryParams} required [stReport]
  static String stReport = "st-report";
  static String stReportPath = "/st-report";

  /// Clock Attendance Screen path name no {Params || queryParams} required [clock]
  static String clock = "clock";
  static String clockPath = "/$clock";

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
