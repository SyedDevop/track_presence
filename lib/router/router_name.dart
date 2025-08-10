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

  /// Loan Screen path name no {Params || queryParams} required [loan]
  static String loan = "loan";
  static String loanPath = "/loan";

  /// Loan Summery Screen path name Params = {'id': 'vch1111'} no {queryParams} required [loanSummery]
  static String loanSummery = "loan-summery";
  static String loanSummeryPath = "/loan-summery:id";

  /// payroll Screen path name no {Params || queryParams} required [payroll]
  static String payroll = "payroll";
  static String payrollPath = "/payroll";

  /// payroll Day Screen path name no {Params || queryParams} required [payrollDay]
  static String payrollDay = "$payroll-day";
  static String payrollDayPath = "/$payroll/day";

  /// payroll Month Screen path name no {Params || queryParams} required [payrollMonth]
  static String payrollMonth = "$payroll-month";
  static String payrollMonthPath = "/$payroll/month";

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

  /// Tasks Screen path name no {Params || queryParams} required [tasks]
  static String tasks = "tasks";
  static String tasksPath = "/tasks";

  /// Task Detail Screen path name Params = {'id': '123'} no {queryParams} required [taskDetail]
  static String taskDetail = "task-detail";
  static String taskDetailPath = "/task/:id";

  /// Task Complete Screen path name Params = {'id': '123'} no {queryParams} required [taskCompletion]
  static String taskCompletion = "task-completion";
  static String taskCompletionPath = "/task/:id/complete";

  static String liveCamera = "live-camera";
  static String liveCameraPath = "/live-camera";
}
