import 'package:flutter/material.dart';
import 'package:reepay_demo_app/auth/providers/index.dart';

import '../../checkout/domain/models/customer_model.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        "E-mail",
                      ),
                    ),
                    TextFormField(
                      controller: emailController..text = 'carl@mail.com',
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        filled: true,
                        hintText: 'your@email.com',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter e-mail';
                        } else {
                          bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value);
                          if (!emailValid) {
                            return 'Please enter valid e-mail';
                          }
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        "Password",
                      ),
                    ),
                    TextFormField(
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      controller: passwordController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        filled: true,
                        hintText: '••••••',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Center(
                  child: SizedBox(
                    width: 400,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.amber,
                        primary: Colors.black,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _signIn(context);
                        }
                      },
                      child: const Text(
                        'Sign In',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // dummy sign in
  void _signIn(context) {
    var email = emailController.text;
    var password = passwordController.text;

    if (email == 'carl@mail.com') {
      Customer customer = Customer();
      customer.first_name = "Carl";
      customer.last_name = "Johnson";
      customer.address = "Beachstreet 123";
      customer.email = "carl@mail.com";
      customer.phone = "11223344";
      AuthProvider().setStorageCustomer(customer).then((value) {
        var snackBar = SnackBar(
          content: Text('Signed in as ${customer.email}'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        // setState(() {});
        Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
      });
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account does not exist.')));
  }
}
