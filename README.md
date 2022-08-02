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
- [Usage](#usage)
  - [Reepay Private API Key](#reepay-private-api-key)

## Available Scripts

The project is built with `Flutter version 3.0.4`. Before running your Flutter app, you must create iOS and Android platforms respectively.

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

Runs your app in the available devices given that the required platforms are added.

```
flutter run
```

## flutter run device id

Runs your app on a device or simulator/emulator.

```
flutter run -d <device_id>
```

## Usage

1. Run your Flutter app.
2. Add products to your cart and create a Reepay Checkout.

https://user-images.githubusercontent.com/108516218/182375094-a762b250-8dbf-41f5-9e5e-73fe2d8a2c85.mov

### Reepay Private API Key

When you have generated a [Private API Key](https://app.reepay.com/#/rp/dev/api) from Reepay. Add the value to `REEPAY_PRIVATE_API_KEY` located in `.env` file.
