import 'dart:html';

import 'package:budgetbreeze/components.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';

import 'model/model.dart';

final viewModel = ChangeNotifierProvider.autoDispose<ViewModel>(
  (ref) => ViewModel(),
);

class ViewModel extends ChangeNotifier {
  final auth = FirebaseAuth.instance;

  List<Models> expenses = [];
  List<Models> incomes = [];

  var logger = Logger();

  bool isSignedIn = false;
  bool isObscure = true;

  final expenseName = [];
  final expenseAmount = [];
  final incomeName = [];
  final incomeAmount = [];

  int totalExpense = 0;
  int totalIncome = 0;
  int budgetLeft = 0;

  CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  void calculate() {
    totalExpense = 0;
    totalIncome = 0;
    for (int i = 0; i < expenses.length; i++) {
      totalExpense = totalExpense + int.parse(expenses[i].amount);
    }
    for (int i = 0; i < incomes.length; i++) {
      totalIncome = totalIncome + int.parse(incomes[i].amount);
    }
    budgetLeft = totalIncome - totalExpense;
    notifyListeners();
  }

  Future<void> isLoggedIn() async {
    await auth.authStateChanges().listen((User? user) {
      if (user == null) {
        isSignedIn = false;
      } else {
        isSignedIn = true;
      }
    });
    notifyListeners();
  }

  toggleObscure() {
    isObscure != isObscure;

    notifyListeners();
  }

  //logout........

  Future<void> logout() async {
    await auth.signOut();
  }

  //Authentication

  //Authentication
  Future<void> createUserWithEmailAndPassword(
      BuildContext context, String email, String password) async {
    await auth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((value) async {
      logger.d("Registration successful");
    }).onError((error, stackTrace) {
      logger.d(error);
      DialogBox(context, error.toString().replaceAll(RegExp('\\[.*?\\]'), ''));
    });
  }

  Future<void> signInWithEmailAndPassword(
      BuildContext context, String _email, String _password) async {
    await auth
        .signInWithEmailAndPassword(email: _email, password: _password)
        .then((value) {
      logger.d("Login successful");
    }).onError((error, stackTrace) {
      logger.d(error);
      DialogBox(context, error.toString().replaceAll(RegExp('\\[.*?\\]'), ''));
    });
  }

  Future<void> signInWithGoogleWeb(BuildContext context) async {
    GoogleAuthProvider googleProvider = GoogleAuthProvider();

    await auth.signInWithPopup(googleProvider).onError(
          (error, stackTrace) => DialogBox(
            context,
            error.toString().replaceAll(RegExp('\\[.*?\\]'), ''),
          ),
        );
    logger
        .d(" Current user is not empty = ${auth.currentUser!.uid.isNotEmpty}");
  }

  Future<void> signInWithGoogleMobile(BuildContext context) async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn()
        .signIn()
        .onError((error, stackTrace) => DialogBox(
            context, error.toString().replaceAll(RegExp('\\[.*?\\]'), '')));

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    await auth.signInWithCredential(credential).then(
      (value) async {
        logger.e("Signed in successfully $value");
      },
    ).onError((error, stackTrace) {
      logger.d(error);
    });
  }

  Future addExpense(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    TextEditingController controllerName = TextEditingController();
    TextEditingController controllerAmount = TextEditingController();
    return await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        actionsAlignment: MainAxisAlignment.center,
        contentPadding: EdgeInsets.all(32.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          side: BorderSide(width: 1.0, color: Colors.black),
        ),
        title: Form(
          key: formKey,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextForm(
                text: "Name",
                containerWidth: 130.0,
                hintText: "Name",
                controller: controllerName,
                validator: (text) {
                  if (text.toString().isEmpty) {
                    return "Required.";
                  }
                },
              ),
              SizedBox(
                width: 10.0,
              ),
              TextForm(
                text: "Amount",
                containerWidth: 100.0,
                hintText: "Amount",
                controller: controllerAmount,
                digitsOnly: true,
                validator: (text) {
                  if (text.toString().isEmpty) {
                    return "Required.";
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          MaterialButton(
            child: OpenSands(
              text: "Save",
              size: 15.0,
              color: Colors.white,
              fontweight: FontWeight.bold,
            ),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                userCollection
                    .doc(auth.currentUser!.uid)
                    .collection("expenses")
                    .add({
                  "name": controllerName.text,
                  "amount": controllerAmount.text
                }).onError((error, stackTrace) {
                  //logger.d("add expense error = $error");
                  print("Add expense error = $error");
                  return DialogBox(context, error.toString());
                });
                Navigator.pop(context);
              }
            },
            splashColor: Colors.grey,
            color: Colors.black,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
          ),
        ],
      ),
    );
  }

  // Add Income.......................

  Future addIncome(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    TextEditingController controllerName = TextEditingController();
    TextEditingController controllerAmount = TextEditingController();
    return await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        actionsAlignment: MainAxisAlignment.center,
        contentPadding: EdgeInsets.all(32.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          side: BorderSide(width: 1.0, color: Colors.black),
        ),
        title: Form(
          key: formKey,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextForm(
                text: "Name",
                containerWidth: 130.0,
                hintText: "Name",
                controller: controllerName,
                validator: (text) {
                  if (text.toString().isEmpty) {
                    return "Required.";
                  }
                },
              ),
              SizedBox(
                width: 10.0,
              ),
              TextForm(
                text: "Amount",
                containerWidth: 100.0,
                hintText: "Amount",
                controller: controllerAmount,
                digitsOnly: true,
                validator: (text) {
                  if (text.toString().isEmpty) {
                    return "Required.";
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          MaterialButton(
            child: OpenSands(
              text: "Save",
              size: 15.0,
              color: Colors.white,
              fontweight: FontWeight.bold,
            ),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                userCollection
                    .doc(auth.currentUser!.uid)
                    .collection("incomes")
                    .add({
                  "name": controllerName.text,
                  "amount": controllerAmount.text
                }).then((value) {
                  //logger.d("Income added");
                  print("Income Added");
                }).onError((error, stackTrace) {
                  // logger.d("add income error = $error");
                  print("Add Income error = $error");
                  return DialogBox(context, error.toString());
                });
                Navigator.pop(context);
              }
            },
            splashColor: Colors.grey,
            color: Colors.black,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
          ),
        ],
      ),
    );
  }

   expensesStream() async {
    await for (var snapshot in userCollection
        .doc(auth.currentUser!.uid)
        .collection("expenses")
        .snapshots()) {
    
      for (var expenses in snapshot.docs) {
        expenseName.add(expenses.data()['name']);
        expenseAmount.add(expenses.data()['amount']);
        logger.d(expenseName, error: expenseAmount);
        notifyListeners();
      }
    }
  }

   incomesStream() async {
    await for (var snapshot in userCollection
        .doc(auth.currentUser!.uid)
        .collection("incomes")
        .snapshots()) {
      for (var incomes in snapshot.docs) {
        incomeName.add(incomes.data()['name']);
        incomeAmount.add(incomes.data()['amount']);
        logger.d(incomeName, error: incomeAmount);
        logger.d("Income view successfully");
        notifyListeners();
      }
    }
  }
  //  expensesStream() async {
  //   await for (var snapshot in FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(FirebaseAuth.instance.currentUser!.uid)
  //       .collection('expenses')
  //       .snapshots()) {
  //     expenses = [];
  //     snapshot.docs.forEach((element) {
  //       expenses.add(Models.fromJson(element.data()));
  //     });
  //     //logger.d("Expense Models ${expenses.length}");
  //     notifyListeners();
  //     // expensesAmount = [];
  //     // expensesName = [];
  //     // for (var expenses in snapshot.docs) {
  //     //   expensesName.add(expenses.data()['name']);
  //     //   expensesAmount.add(expenses.data()['amount']);
  //     //   logger.d(expensesName, expensesAmount);
  //     //   notifyListeners();
  //     // }
  //    calculate();
  //   }
  // }

  //  incomesStream() async {
  //   await for (var snapshot in FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(FirebaseAuth.instance.currentUser!.uid)
  //       .collection('incomes')
  //       .snapshots()) {
  //     incomes = [];
  //     snapshot.docs.forEach((element) {
  //       incomes.add(Models.fromJson(element.data()));
  //     });
  //     notifyListeners();
  //     // incomesAmount = [];
  //     // incomesName = [];
  //     // for (var expenses in snapshot.docs) {
  //     //   incomesName.add(expenses.data()['name']);
  //     //   incomesAmount.add(expenses.data()['amount']);
  //     //   logger.d(incomesName, incomesAmount);
  //     //   notifyListeners();
  //     // }
  //     calculate();
  //   }
  // }

  //Reset button....................

  Future<void> reset() async {
    await userCollection
        .doc(auth.currentUser!.uid)
        .collection("expenses")
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
    await userCollection
        .doc(auth.currentUser!.uid)
        .collection("incomes")
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
  }
}