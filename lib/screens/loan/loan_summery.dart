import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:vcare_attendance/api/api.dart';
import 'package:vcare_attendance/getit.dart';
import 'package:vcare_attendance/models/loan_model.dart';
import 'package:vcare_attendance/services/state.dart';

class LoanSummeryScreen extends StatefulWidget {
  final String id;
  const LoanSummeryScreen({super.key, required this.id});

  @override
  State<LoanSummeryScreen> createState() => _LoanSummeryScreenState();
}

class _LoanSummeryScreenState extends State<LoanSummeryScreen> {
  final apiL = Api.loan;
  bool _loading = false;

  LoanFullReport? loans;
  final profile = getIt<AppState>().profile;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _getLoans() async {
    final res = await apiL.getLoanReport(profile?.userId ?? "", widget.id);
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
  Widget build(BuildContext context) {
    // i need the remaining loan amount and the total loan amount
    final loanPaidPer =
        (((loans?.loan.loanAmount ?? 0) - (loans?.loan.loanBalance ?? 0)) /
                (loans?.loan.loanAmount ?? 1)) *
            100;
    final loanPaid = loanPaidPer.toStringAsFixed(2);
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(loans != null ? loans!.loan.loanType : "Loan Summery"),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : loans == null
              ? const Center(child: Text("No Loan Found"))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Loaned Amount",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Rs. ${loans!.loan.loanAmount}",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      LoanChartBlock(loans: loans, loanPaid: loanPaid),
                      const Divider(),
                      const SizedBox(height: 10),
                      const ListTile(title: Text("Payments")),
                      if (loans?.payments != null && loans!.payments.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: loans!.payments.length,
                          itemBuilder: (context, index) {
                            final payment = loans!.payments[index];
                            return LoanPaymentTile(payment: payment);
                          },
                        )
                      else
                        const Center(child: Text("No Payments Found")),
                    ],
                  ),
                ),
    );
  }
}

class LoanPaymentTile extends StatelessWidget {
  const LoanPaymentTile({
    super.key,
    required this.payment,
  });

  final LoanPayment payment;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            payment.paymentDate,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      leading: CircleAvatar(
        backgroundColor: payment.credited ? Colors.green : Colors.red,
        child: Icon(
          payment.credited ? Icons.arrow_upward : Icons.arrow_downward,
          color: Colors.white,
        ),
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Amount: Rs. ${payment.amountPaid}",
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
          Text(
            "Remaining: Rs. ${payment.balance}",
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class LoanChartBlock extends StatelessWidget {
  const LoanChartBlock({
    super.key,
    required this.loans,
    required this.loanPaid,
  });

  final LoanFullReport? loans;
  final String loanPaid;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: 200,
          width: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              LoanPieChart(loans: loans!),
              LoanCompletePercent(loanPaid: loanPaid),
            ],
          ),
        ),
        LoanSummeryTextBlock(loans: loans),
      ],
    );
  }
}

class LoanSummeryTextBlock extends StatelessWidget {
  const LoanSummeryTextBlock({
    super.key,
    required this.loans,
  });

  final LoanFullReport? loans;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              "Repaid Amount:",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          "Rs. ${loans!.loan.loanAmount - loans!.loan.loanBalance}",
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.yellowAccent,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              "Balance Amount:",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          "Rs. ${loans!.loan.loanBalance}",
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class LoanCompletePercent extends StatelessWidget {
  const LoanCompletePercent({
    super.key,
    required this.loanPaid,
  });

  final String loanPaid;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "$loanPaid%",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          "Completed",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class LoanPieChart extends StatelessWidget {
  const LoanPieChart({
    super.key,
    required this.loans,
  });

  final LoanFullReport loans;

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: loans.loan.loanBalance,
            color: Colors.yellowAccent,
            showTitle: false,
            radius: 25,
          ),
          PieChartSectionData(
            value: loans.loan.loanAmount - loans.loan.loanBalance,
            color: Colors.green,
            showTitle: false,
            radius: 25,
          ),
        ],
        sectionsSpace: 5,
        centerSpaceRadius: 60,
      ),
    );
  }
}
