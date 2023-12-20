import 'package:budgetbreeze/view_model.dart';
import 'package:budgetbreeze/webversion/expense_view_web.dart';
import 'package:budgetbreeze/webversion/login_view_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'mobileversion/expense_view_mobile.dart';
import 'mobileversion/login_view_mobile.dart';

class ResposibWidget extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewmodelprovider = ref.watch(viewModel);
    viewmodelprovider.isLoggedIn();

    if (viewmodelprovider.isSignedIn == true) {
      return LayoutBuilder(builder: (context, Constraints) {
        if (Constraints.maxWidth > 600) {
          return WebViewExpensive();
        } else {
          return MobileViewExpensive();
        }
      });
    }
    else{
        return LayoutBuilder(builder: (context, Constraints) {
        if (Constraints.maxWidth > 600) {
          return LoginViewWeb();
        } else {
          return LoginViewMobile();
        }
      });

    }
    
  }
}
