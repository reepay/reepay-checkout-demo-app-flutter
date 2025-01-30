# Reepay Checkout - Flutter Example

This is an example of a "Webshop" with Reepay Checkout made with Flutter Framework.

## Getting Started

This project requires following Flutter prerequisites:

- [Install Flutter](https://docs.flutter.dev/get-started/install)
- [Flutter CLI commands list](https://docs.flutter.dev/reference/flutter-cli)

## Setup

Upon having Flutter installed, install project packages with `flutter pub get`.

```
flutter pub get
```

## Table of Contents

- [Available Scripts](#available-scripts)
  - [flutter create ios platform](#flutter-create-ios-platform)
  - [flutter create android platform](#flutter-create-android-platform)
  - [flutter run](#flutter-run)
  - [flutter run -d <device_id>](#flutter-run-device-id)
- [Events](#events)
  - [Url path changes](#url-path-changes)
  - [Extra](#extra)
  - [Handling events](#handling-events-newly-added-in-v110)
- [Usage](#usage)
  - [Reepay Private API Key](#reepay-private-api-key)
  - [Custom URL schemes](#custom-url-schemes)

## Available Scripts

This project is built with `Flutter version 3.27.1 and Dart version 3.6.0`. Before running your Flutter app, you must create iOS and Android platforms respectively.

### flutter create ios platform

Run the following command from the root of your project directory to add iOS platform.

```
flutter create --platforms=ios . --project-name reepay_checkout_flutter_example
```

### flutter create android platform

Run the following command from the root of your project directory to add Android platform.

```
flutter create --platforms=android . --project-name reepay_checkout_flutter_example
```

## flutter run

Runs your app on the selected available device (requires a platform for the device).

```
flutter run
```

## flutter run device id

Runs your app on a device or simulator/emulator.

```
flutter run -d <device_id>
```

## Events
In the app, we will use URL path changes as events that WebView listens to, thus checking whether URL contains `accept` or `cancel` in the path. In version 1.1.0, we have introduced new event handling via postMessage from the WebView. Read more about handling events below.

### URL path changes
As we are using WebView by passing session URL, we will receive response with as either Accept URL or Cancel URL as defined in the request body [docs](https://docs.reepay.com/reference/createchargesession):
```
{
  ...
  "accept_url":"https://webshop.com/accept/order-12345",
  "cancel_url":"https://webshop.com/decline/order-12345"
}
```
In the WebView, we will listen to URL changes when the checkout has completed a redirect, either accept or cancel by checking the URL path. For example the above cancel_url, we will check for `/decline` meaning the cancel_url has been triggered and WebView has redirected. 

### Extra
For additional parameters to be passed, use query parameters in `accept_url` or `cancel_url`. For example, `https://webshop.com/decline/order-12345?myEvent=someValue&yourEvent=anotherValue`.

### Handling events `Newly added in v1.1.0`
The app will now receive events via postMessage from the WebView. The WebView will send a message with the event type and the event data. The app will then handle the event accordingly. See `checkout_screen.dart` for more details.

## Usage

1. Run your Flutter app with `flutter run`.
2. Add products to your cart.
3. Fill customer information or sign in with the built-in example account.
4. Create Reepay Checkout and complete purchase with a [test card](https://reference.reepay.com/api/#testing).

https://user-images.githubusercontent.com/108516218/182375094-a762b250-8dbf-41f5-9e5e-73fe2d8a2c85.mov

### Reepay Private API Key

When you have generated a [Private API Key](https://app.reepay.com/#/rp/dev/api) from Reepay. Add the value to `REEPAY_PRIVATE_API_KEY` located in `.env` file.

### Custom URL schemes

In order to redirect back to the app after e.g. successful payment from external app such as MobilePay/Vipps, you can use custom URL schemes. 
For example, `reepaycheckout://` which is defined in the `Info.plist` file for iOS and `AndroidManifest.xml` for Android.

An example where the deep link is `reepaycheckout://custom.host` added to `Info.plist`:

```
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLName</key>
    <string>custom.host</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>reepaycheckout</string>
    </array>
  </dict>
</array> 
```

An example where the deep link is `reepaycheckout://your_app` added to `AndroidManifest.xml`:

```
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data
    android:scheme="reepaycheckout"
    android:host="your_app" />
</intent-filter> 
```