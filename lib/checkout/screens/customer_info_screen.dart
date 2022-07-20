// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:namefully/namefully.dart';
import 'package:reepay_demo_app/checkout/index.dart';

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

  late String handle;

  @override
  void initState() {
    super.initState();
    CheckoutProvider().getCustomerHandle().then((value) {
      handle = CheckoutProvider().customerHandle;
    });
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

  Widget _errorPopup(BuildContext context) {
    return AlertDialog(
      title: const Text('Server Error'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text("Unexpected error. Please check your internet connection."),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            setState(() {
              CheckoutProvider().setCart([]);
            });
            Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
          },
          child: const Text('Close'),
        ),
      ],
    );
  }

  void _checkout(context) {
    if (handle.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) => _errorPopup(context),
      );
      return;
    }

    var customer = Customer();
    var name = Namefully(fullnameController.text);
    customer.firstName = name.first;
    customer.lastName = name.last;
    customer.address = address1Controller.text;
    customer.address2 = address2Controller.text;
    customer.phone = phoneController.text;
    customer.email = emailController.text;
    CheckoutProvider().setCustomer(customer);
    // print('handle: $handle');
    // print(customer.toJson());

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New customer'),
      ),
      body: customerForm(context),
    );
  }

  Widget customerForm(context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => {
          if (_formKey.currentState!.validate())
            {
              _checkout(context),
            }
        },
        label: const Text("Next"),
      ),
      body: Form(
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
                    // The validator receives the text that the user has entered.
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
                    // The validator receives the text that the user has entered.
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
                    // The validator receives the text that the user has entered.
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
                      "Phone number",
                    ),
                  ),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      hintText: 'Phone number',
                    ),
                    // The validator receives the text that the user has entered.
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
                    controller: emailController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      hintText: 'E-mail',
                    ),
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter e-mail';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
