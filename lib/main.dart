// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_new

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:localstore/localstore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reepay_demo_app/auth/providers/index.dart';
import 'package:reepay_demo_app/auth/screens/sign_in_screen.dart';
import 'package:reepay_demo_app/checkout/index.dart';

import 'checkout/domain/models/bike_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  final appDocumentDirectory = await getApplicationDocumentsDirectory();
  print("Storage data: $appDocumentDirectory");
  runApp(MyApp());
}

Map<int, Color> color = {
  50: Color.fromRGBO(28, 176, 128, .1),
  100: Color.fromRGBO(28, 176, 128, .2),
  200: Color.fromRGBO(28, 176, 128, .3),
  300: Color.fromRGBO(28, 176, 128, .4),
  400: Color.fromRGBO(28, 176, 128, .5),
  500: Color.fromRGBO(28, 176, 128, .6),
  600: Color.fromRGBO(28, 176, 128, .7),
  700: Color.fromRGBO(28, 176, 128, .8),
  800: Color.fromRGBO(28, 176, 128, .9),
  900: Color.fromRGBO(28, 176, 128, 1),
};

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reepay Checkout Flutter App',
      theme: ThemeData(
        primarySwatch: MaterialColor(0xFF1cb080, color),
      ),
      home: const MyHomePage(title: 'Reepay Bike Shop'),
      routes: {
        '/checkout': (context) => CheckoutScreen(),
        '/android-checkout': (context) => AndroidCheckoutScreen(),
        '/completed': (context) => CompletedScreen(),
        '/customer-info': (context) => CustomerInfoScreen(),
        '/sign-in': (context) => SignInScreen(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Bike>> bikes;
  late List<Bike> cart;
  late CheckoutProvider provider;
  late dynamic quantities;

  @override
  void initState() {
    super.initState();
    bikes = CheckoutService().getBikeProducts();
    provider = CheckoutProvider();
    provider.getCart().then((value) => setState(() {}));
    cart = provider.cart;
    quantities = provider.getQuantities(cart);
    AuthProvider().setSignIn();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (AuthProvider().isSignInCustomer) {
                  AuthProvider().deleteStorageCustomer().then((value) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Signed out')));
                    setState(() {});
                  });
                } else {
                  Navigator.pushNamed(context, '/sign-in');
                }
              },
              child: Text(
                AuthProvider().isSignInCustomer ? 'Sign Out' : 'Sign In',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        bottomNavigationBar: menu(),
        body: TabBarView(
          children: [
            products(),
            helpPage(),
            cartPage(),
          ],
        ),
      ),
    );
  }

  Widget menu() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1c4c84),
      ),
      child: SafeArea(
        minimum: EdgeInsets.only(bottom: 20),
        child: Container(
          color: Color(0xFF1c4c84),
          child: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: EdgeInsets.all(5.0),
            indicatorColor: Colors.white,
            tabs: [
              Tab(
                text: "Products",
                icon: Icon(Icons.pedal_bike),
              ),
              Tab(
                text: "Help",
                icon: Icon(Icons.help_center),
              ),
              Tab(
                text: provider.cart.isEmpty ? "Cart" : "Cart ${provider.cart.length}",
                icon: Icon(Icons.shopping_basket),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget helpPage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Text(
                "Help",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 40,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                if (Platform.isIOS) {
                  Navigator.pushNamed(context, '/ios-checkout');
                } else {
                  throw Exception("ERROR: Not an iOS device!");
                }
              },
              child: Text("Native WebView - iOS"),
            ),
            TextButton(
              onPressed: () {
                if (Platform.isAndroid) {
                  Navigator.pushNamed(context, '/android-checkout');
                } else {
                  throw Exception("ERROR: Not an Android device!");
                }
              },
              child: Text("Native WebView - Android"),
            ),
            TextButton(
              onPressed: () {
                final db = Localstore.instance;
                db.collection('cartCollection').doc("cart").delete();
                db.collection('customerCollection').doc("customer").delete();
              },
              child: Text("Delete App Localstore"),
            ),
          ],
        ),
      ),
    );
  }

  Widget cartPage() {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        width: 400,
        padding: EdgeInsets.only(left: 15, right: 15),
        child: FloatingActionButton.extended(
          backgroundColor: Color(0xFF1cb080),
          onPressed: () => {
            if (cart.isNotEmpty) {Navigator.pushNamed(context, '/customer-info')}
          },
          label: Text("Next"),
        ),
      ),
      body: FutureBuilder(
        future: CheckoutProvider().getUniqueBikes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var data = snapshot.data as dynamic;
            var uniqueBikes = data['uniqueBikes'];
            var total = data['total'];

            return Column(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 500),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: ListView(
                      key: Key(cart.length.toString()),
                      children: <Widget>[
                        for (var i = 0; i < uniqueBikes.length; i++)
                          Container(
                            child: MaterialBanner(
                              elevation: 5,
                              content: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(
                                  uniqueBikes[i].name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text("Price: ${uniqueBikes[i].amount} DKK"),
                              ]),
                              leading: CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(uniqueBikes[i].url),
                              ),
                              actions: [
                                Text(
                                  "Quantity: ${uniqueBikes[i].quantity}",
                                ),
                                TextButton(
                                  child: const Text('Remove'),
                                  onPressed: () {
                                    setState(() {
                                      var index = cart.indexWhere((element) => element.name == uniqueBikes[i].name);
                                      cart.removeAt(index);
                                      CheckoutProvider().setCart(cart);
                                    });
                                  },
                                ),
                              ],
                            ),
                          )
                      ],
                    ),
                  ),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(40),
                        child: Text("Total: $total DKK"),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return Text("Error");
        },
      ),
    );
  }

  Widget products() {
    return Container(
      padding: EdgeInsets.all(20),
      child: FutureBuilder(
        future: bikes,
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            var bikes = snapshot.data as List<Bike>;
            return ListView.builder(
              itemCount: bikes.length,
              itemBuilder: ((context, index) {
                return product(bikes[index]);
              }),
            );
          }
          return Text("");
        }),
      ),
    );
  }

  Widget product(Bike bike) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Stack(children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(bike.url),
            ),
            new Positioned.fill(
              child: new Material(
                color: Colors.transparent,
                child: new InkWell(
                  customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  onTap: () => {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => showProduct(context, bike),
                    )
                  },
                ),
              ),
            ),
          ]),
          SizedBox(width: 20),
          Expanded(
              child: Text(
            bike.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text('${bike.amount.toString()} DKK'),
          ),
          IconButton(
            onPressed: () => {
              setState(() {
                cart.add(bike);
                CheckoutProvider().setCart(cart);
              })
            },
            icon: Icon(
              Icons.add_circle,
              color: Color(0xFF1cb080),
            ),
          ),
        ],
      ),
    );
  }

  Widget showProduct(BuildContext context, Bike bike) {
    return new AlertDialog(
      content: SingleChildScrollView(
        child: Container(
          child: new Padding(
            padding: new EdgeInsets.all(15.0),
            child: new Column(
              children: <Widget>[
                new SizedBox(
                  child: new Stack(
                    children: <Widget>[
                      Image.network(bike.url),
                    ],
                  ),
                ),
                new Padding(
                  padding: new EdgeInsets.all(
                    7.0,
                  ),
                  child: new Text(
                    bike.name,
                    style: new TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                ),
                new Padding(
                  padding: new EdgeInsets.all(
                    0.0,
                  ),
                  child: new Text(
                    "Price: ${bike.amount} DKK",
                    style: new TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        new FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          textColor: Theme.of(context).primaryColor,
          child: const Text('Close'),
        ),
      ],
    );
  }
}
