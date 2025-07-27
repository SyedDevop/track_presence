import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vcare_attendance/api/api.dart';
import 'package:vcare_attendance/getit.dart';
import 'package:vcare_attendance/models/loan_model.dart';
import 'package:vcare_attendance/router/router_name.dart';
import 'package:vcare_attendance/services/service.dart';
import 'package:vcare_attendance/snackbar/snackbar.dart';

class LoanScreen extends StatefulWidget {
  const LoanScreen({super.key});

  @override
  State<LoanScreen> createState() => _LoanScreenState();
}

class _LoanScreenState extends State<LoanScreen> {
  final apiL = Api.loan;
  bool _loading = false;

  List<Loan> loans = [];
  final _appSr = getIt<AppStore>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final _reasonCt = TextEditingController(text: "");
  final _formKey = GlobalKey<FormState>();
  final _loanAmountCt = TextEditingController(text: "");

  Future<void> _getLoans() async {
    final res = await apiL.getLeaves(_appSr.token.sub);
    setState(() => loans = res);
  }

  Future<void> _start() async {
    setState(() => _loading = true);
    await _getLoans();
    setState(() => _loading = false);
  }

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    super.dispose();
    _reasonCt.dispose();
    _loanAmountCt.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text("Loan"),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : loans.isEmpty
              ? const Center(child: Text("No loans"))
              : ListView.builder(
                  itemCount: loans.length,
                  itemBuilder: (context, index) {
                    final loan = loans[index];
                    return LoanCard(loan: loan);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          scaffoldKey.currentState!.showBottomSheet((_) => _showLoanForm());
        },
        child: const Icon(
          Icons.check_circle_rounded, // Updated icon for loan approval
          size: 28,
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    try {
      final reason = _reasonCt.text;
      final amount = _loanAmountCt.text;
      await apiL.postLoan(
        userId: _appSr.token.sub,
        loanType: reason,
        amount: double.tryParse(amount) ?? 0.0,
        department: _appSr.token.department,
      );
      snackbarSuccess(context, message: "Loan Applied Successfully");
      await _getLoans();
    } on DioException catch (e) {
      snackbarError(context, message: "${e.message}  😭");
    } catch (e) {
      snackbarError(context, message: "Failed to apply loan");
    } finally {
      if (mounted) context.pop();
    }
  }

  Widget _showLoanForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surface, // Matches dark theme surface color
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Text(
              "Apply For Loan",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Divider(
              color: Theme.of(context)
                  .colorScheme
                  .outline, // Matches divider color
            ),

            // Form
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Loan Reason Field
                  Text(
                    "Loan Reason",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _reasonCt,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      hintText: "Enter the reason for the loan",
                      prefixIcon: const Icon(Icons.psychology_alt_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter a reason";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Loan Amount Field
                  Text(
                    "Loan Amount",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _loanAmountCt,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      hintText: "Enter the loan amount",
                      prefixIcon: const Icon(Icons.attach_money_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter a loan amount";
                      } else if (double.tryParse(value) == null ||
                          double.tryParse(value)! < 0) {
                        return "Please enter a valid amount";
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  Center(
                    child: FilledButton(
                      onPressed: _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 50,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Submit",
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoanCard extends StatelessWidget {
  const LoanCard({super.key, required this.loan});
  final Loan loan;

  @override
  Widget build(BuildContext context) {
    // Determine the color for the approval status
    Color getApprovalColor(String approval) {
      switch (approval.toLowerCase()) {
        case "approved":
          return Colors.green;
        case "pending":
          return Colors.orange;
        case "decline":
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    // Determine the color for the loan status
    Color getStatusColor(String status) {
      return status.toLowerCase() == "active" ? Colors.blue : Colors.grey;
    }

    return InkWell(
      onTap: () => {
        context.pushNamed(RouteNames.loanSummery, pathParameters: {
          "id": loan.id.toString(),
        }),
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Loan Type
              Text(
                loan.loanType,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(),
              // Loan Amount and Balance
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Loan Amount",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  "Rs. ${loan.loanAmount.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Loan Balance",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  "Rs. ${loan.loanBalance.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Status and Approval
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Loan Status
                            Row(
                              children: [
                                const Text(
                                  "Status: ",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  loan.status,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: getStatusColor(loan.status),
                                  ),
                                ),
                              ],
                            ),

                            // Approval Status
                            Row(
                              children: [
                                const Text(
                                  "Approval: ",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  loan.approval,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: getApprovalColor(loan.approval),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.keyboard_double_arrow_right_rounded),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
