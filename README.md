# Reepay Checkout - Flutter Example

This is an example of a "Webshop" with Reepay Checkout made with Flutter Framework.

## Getting Started

This project is a starting point for a Flutter application.

- [Install Flutter](https://docs.flutter.dev/get-started/install)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Setup

Upon having Flutter installed, install project packages with `flutter pub get`.

## Table of Contents

- [Available Scripts](#available-scripts)
  - [flutter create ios platform](#flutter-create-ios)
  - [flutter create android platform](#flutter-create-android)
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

## flutter run -d <device_id>

Runs your app on a device or simulator/emulator.

```
flutter run -d <device_id>
```

## Usage

1. Run your Flutter app.
2. Add products to your cart and create a Reepay Checkout.

### Reepay Private API Key

When you have generated a [Private API Key](https://app.reepay.com/#/rp/dev/api) from Reepay. Add the value to `REEPAY_PRIVATE_API_KEY` located in `.env` file.
