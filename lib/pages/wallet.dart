import 'package:flutter/material.dart';
import 'package:frankmichaelflutterproject/service/shared_pref.dart';
import 'package:frankmichaelflutterproject/widget/widget_support.dart';

class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  int walletBalance = 0;
  int selectedAmount = 100;

  @override
  void initState() {
    super.initState();
    getWalletBalance();
  }

  Future<void> getWalletBalance() async {
    String? wallet = await SharedPreferenceHelper().getUserWallet();
    setState(() {
      walletBalance = int.tryParse(wallet ?? "0") ?? 0;
    });
  }

  Future<void> addMoney() async {
    int newBalance = walletBalance + selectedAmount;
    await SharedPreferenceHelper().saveUserWallet(newBalance.toString());
    setState(() {
      walletBalance = newBalance;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Money added successfully!")),
    );
  }

  Widget buildAmountBox(int amount) {
    bool isSelected = selectedAmount == amount;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAmount = amount;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal : Colors.white,
          border: Border.all(color: const Color(0xFFE9E2E2)),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          "\$$amount",
          style: AppWidget.semiBoldTextFeildStyle().copyWith(
              color: isSelected ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 60.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Material(
              elevation: 2.0,
              child: Container(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Center(
                  child: Text("Wallet", style: AppWidget.semiBoldTextFeildStyle()),
                ),
              ),
            ),
            const SizedBox(height: 30.0),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(color: Color(0xFFF2F2F2)),
              child: Row(
                children: [
                  Image.asset("images/wallet.png", height: 60, width: 60, fit: BoxFit.cover),
                  const SizedBox(width: 40.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Your Wallet", style: AppWidget.LightTextFeildStyle()),
                      const SizedBox(height: 5.0),
                      Text("\$$walletBalance", style: AppWidget.boldTextFeildStyle()),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Text("Add money", style: AppWidget.semiBoldTextFeildStyle()),
            ),
            const SizedBox(height: 10.0),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildAmountBox(100),
                    buildAmountBox(500),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildAmountBox(1000),
                    buildAmountBox(2000),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 50.0),
            GestureDetector(
              onTap: addMoney,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: const Color(0xFF008080),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    "Add Money",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
