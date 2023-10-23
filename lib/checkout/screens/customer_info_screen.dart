// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:reepay_checkout_flutter_example/auth/providers/index.dart';
import 'package:reepay_checkout_flutter_example/checkout/index.dart';

import '../domain/models/customer_model.dart';

class CustomerInfoScreen extends StatefulWidget {
  const CustomerInfoScreen({Key? key}) : super(key: key);

  @override
  State<CustomerInfoScreen> createState() => _CustomerInfoScreenState();
}

class _CustomerInfoScreenState extends State<CustomerInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  final fullnameController = TextEditingController();
  final address1Controller = TextEditingController();
  final address2Controller = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (AuthProvider().isSignInCustomer) {
      AuthProvider().getStorageCustomer().then((data) {
        if (data.isEmpty) {
          return;
        }
        Customer customer = data['customer'];
        fullnameController.text = '${customer.first_name} ${customer.last_name}';
        address1Controller.text = customer.address;
        address2Controller.text = customer.address2;
        phoneController.text = customer.phone;
        emailController.text = customer.email;
      });
    }
  }

  @override
  void dispose() {
    fullnameController.dispose();
    address1Controller.dispose();
    address2Controller.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void _checkout(context) {
    var customer = Customer();
    var names = fullnameController.text.trim().split(' ');
    customer.first_name = names[0];
    customer.last_name = names.isNotEmpty ? names[names.length - 1] : '';
    customer.address = address1Controller.text;
    customer.address2 = address2Controller.text;
    customer.phone = phoneController.text;
    customer.email = emailController.text;
    CheckoutProvider().setCustomer(customer);
    // print('handle: $handle');
    // print(customer.toJson());

    if (AuthProvider().isSignInCustomer) {
      AuthProvider().getStorageCustomer().then((data) {
        if (data.isNotEmpty) {
          CheckoutProvider().setCustomerHandle(data['handle']).then((value) {
            _navigateCheckout();
          });
        }
      });
      return;
    }

    CheckoutProvider().setCustomerHandle('').then((value) {
      _navigateCheckout();
    });
  }

  void _navigateCheckout() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CheckoutScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer'),
      ),
      body: customerForm(context),
    );
  }

  Widget customerForm(context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      "Full name",
                    ),
                  ),
                  TextFormField(
                    controller: fullnameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      hintText: 'Full name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter full name';
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
                      "Address line 1",
                    ),
                  ),
                  TextFormField(
                    controller: address1Controller,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      hintText: 'Address line 1',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter address';
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
                      "Address line 2",
                    ),
                  ),
                  TextFormField(
                    controller: address2Controller,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      hintText: 'Floor, door etc.',
                    ),
                    validator: (value) {
                      // if (value == null || value.isEmpty) {
                      //   return 'Please enter address';
                      // }
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
                      "Phone number",
                    ),
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: phoneController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      hintText: 'Phone number',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter phone number';
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
                      "E-mail",
                    ),
                  ),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: emailController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      hintText: 'E-mail',
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
              const SizedBox(
                height: 20,
              ),
              Center(
                child: SizedBox(
                  width: 400,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: const Color(0xFF1cb080),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _checkout(context);
                      }
                    },
                    child: const Text(
                      'Next',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
