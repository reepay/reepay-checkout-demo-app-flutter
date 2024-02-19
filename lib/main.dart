// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_new

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:localstore/localstore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reepay_checkout_flutter_example/auth/providers/index.dart';
import 'package:reepay_checkout_flutter_example/auth/screens/sign_in_screen.dart';
import 'package:reepay_checkout_flutter_example/checkout/index.dart';
import 'package:url_launcher/url_launcher.dart';

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

Future<void> _launchUrl(url) async {
  if (!await launchUrl(url)) {
    throw 'Could not launch $url';
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        '/completed': (context) => CompletedScreen(),
        '/customer-info': (context) => CustomerInfoScreen(),
        '/sign-in': (context) => SignInScreen(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late Future<List<Bike>> bikes;
  late List<Bike> cart;
  late CheckoutProvider provider;
  late dynamic quantities;
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    bikes = CheckoutService().getBikeProducts();
    provider = CheckoutProvider();
    provider.getCart().then((value) => setState(() {}));
    cart = provider.cart;
    quantities = provider.getQuantities(cart);
    AuthProvider().setSignIn();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          automaticallyImplyLeading: false,
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
          controller: tabController,
          children: [
            productsPage(),
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
            controller: tabController,
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
          crossAxisAlignment: CrossAxisAlignment.center,
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
                final Uri url = Uri.parse('https://github.com/reepay/reepay-checkout-demo-app-flutter#readme');
                _launchUrl(url);
              },
              child: Text("README"),
            ),
            TextButton(
              onPressed: () {
                final Uri url = Uri.parse('https://reference.reepay.com/api/');
                _launchUrl(url);
              },
              child: Text("API Reference"),
            ),
            TextButton(
              onPressed: () {
                final Uri url = Uri.parse('https://docs.reepay.com/reference/reference-introduction');
                _launchUrl(url);
              },
              child: Text("Checkout Docs"),
            ),
            Spacer(),
            TextButton(
              onPressed: () {
                final db = Localstore.instance;
                db.collection('cartCollection').doc("cart").delete();
                db.collection('customerCollection').doc("customer").delete();

                // Reset app
                Navigator.of(context).push(
                  new MaterialPageRoute(
                    builder: (context) => MyHomePage(
                      title: 'Reepay Bike Shop',
                    ),
                  ),
                );
              },
              child: Text("Reset application"),
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
            var currency = data['currency'];

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
                            content: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(
                                uniqueBikes[i].name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text("Price: ${uniqueBikes[i].amount} ${uniqueBikes[i].currency}"),
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
                                    bikes = CheckoutService().getBikeProducts(); // update products page
                                  });
                                },
                              ),
                            ],
                          )
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(40),
                      child: Text("Total: $total $currency"),
                    ),
                  ],
                ),
              ],
            );
          }
          return Text("Error");
        },
      ),
    );
  }

  Widget productsPage() {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: CheckoutProvider().cart.isEmpty
          ? null
          : Container(
              width: 400,
              padding: EdgeInsets.only(left: 15, right: 15),
              child: FloatingActionButton.extended(
                backgroundColor: Color(0xFF1cb080),
                onPressed: () => {tabController.index = 2},
                label: Text("Go to Cart"),
              ),
            ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: FutureBuilder(
          future: bikes,
          builder: ((context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              List<Bike> bikes = snapshot.data as List<Bike>;

              // update products' quantities from saved cart
              for (var bikeElement in bikes) {
                var index = cart.indexWhere((cartElement) => cartElement.name == bikeElement.name);
                if (index < 0) continue;
                var found = cart.elementAt(index);
                bikeElement.quantity = found.quantity;
              }

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
              radius: 30,
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
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Text(
              bike.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          )),
          Text('${bike.amount.toString()} ${bike.currency}'),
          IconButton(
            onPressed: () => {
              setState(() {
                if (bike.quantity > 0) bike.quantity--;
                var index = cart.indexWhere((element) => element.name == bike.name);
                if (index < 0) return;
                var found = cart.elementAt(index);
                cart.remove(found);
                CheckoutProvider().setCart(cart);
              })
            },
            icon: Icon(
              Icons.remove_circle,
              color: Color(0xFF1cb080),
            ),
          ),
          Text("${bike.quantity}"),
          IconButton(
            onPressed: () => {
              setState(() {
                bike.quantity++;
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
                  "Price: ${bike.amount} ${bike.currency}",
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
      actions: <Widget>[
        new TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            textStyle: TextStyle(color: Theme.of(context).primaryColor),
          ),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
