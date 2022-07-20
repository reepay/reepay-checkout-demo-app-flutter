// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_new

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:localstore/localstore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reepay_demo_app/checkout/index.dart';

import 'checkout/domain/models/bike_model.dart';

InAppLocalhostServer localhostServer = InAppLocalhostServer();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await localhostServer.start();
  final appDocumentDirectory = await getApplicationDocumentsDirectory();
  print("Storage data: $appDocumentDirectory");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reepay Checkout Demo',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: const MyHomePage(title: 'Bike Shop'),
      routes: {
        '/checkout': (context) => CheckoutScreen(),
        '/android-checkout': (context) => AndroidCheckoutScreen(),
        '/local-checkout': (context) => LocalCheckout(),
        '/completed': (context) => CompletedScreen(),
        '/customer-info': (context) => CustomerInfoScreen(),
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
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        bottomNavigationBar: menu(),
        body: TabBarView(
          children: [
            products(),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/checkout');
                    },
                    child: Text("Test Checkout"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/android-checkout');
                    },
                    child: Text("Android Only"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/local-checkout');
                    },
                    child: Text("Localhost HTML"),
                  ),
                  TextButton(
                    onPressed: () {
                      final db = Localstore.instance;
                      db.collection('cartCollection').doc("cart").delete();
                      print("deleted storage");
                    },
                    child: Text("Delete storage"),
                  ),
                ],
              ),
            ),
            cartPage(),
          ],
        ),
      ),
    );
  }

  Widget menu() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF3F5AA6),
      ),
      child: SafeArea(
        minimum: EdgeInsets.only(bottom: 20),
        child: Container(
          color: Color(0xFF3F5AA6),
          child: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: EdgeInsets.all(5.0),
            indicatorColor: Colors.blue,
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
                text: "Cart ${provider.cart.length}",
                icon: Icon(Icons.shopping_basket),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget cartPage() {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => {
          if (cart.isNotEmpty) {Navigator.pushNamed(context, '/customer-info')}
        },
        label: Text("Next"),
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
                          MaterialBanner(
                            elevation: 5,
                            content: Row(children: [
                              Text(uniqueBikes[i].name),
                              Text(" (${uniqueBikes[i].amount} DKK)"),
                            ]),
                            leading: SizedBox(
                              width: 50,
                              height: 50,
                              child: Image.network(uniqueBikes[i].url),
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
                                    setState(() {});
                                  });
                                },
                              ),
                            ],
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
    return Stack(
      children: <Widget>[
        new Card(
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
                    "Price - ${bike.amount}",
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
        new Positioned.fill(
          child: new Material(
            color: Colors.transparent,
            child: new InkWell(
              onTap: () => {
                setState(() {
                  cart.add(bike);
                  CheckoutProvider().setCart(cart);
                })
              },
            ),
          ),
        ),
      ],
    );
  }
}
