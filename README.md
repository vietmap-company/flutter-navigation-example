# Vietmap Flutter GL - Flutter map SDK
[<img src="https://bizweb.dktcdn.net/100/415/690/themes/804206/assets/logo.png?1689561872933" height="40"/> </p>](https://bit.ly/vietmap-api)

## Download the demo app:
- Android: [Deploygate](https://dply.me/rbht07)
- iOS: [Testflight](https://testflight.apple.com/join/72lT6D0w)
 
Contact [vietmap.vn](https://bit.ly/vietmap-api) to register a valid key. 
 
## Getting started
This project use [vietmap_flutter_navigation](https://pub.dev/packages/vietmap_flutter_navigation) and [vietmap_flutter_gl](https://pub.dev/packages/vietmap_flutter_gl) to show and navigate on map. Please read the document of these packages before using this package. VietMap provide many features to help you build a map application easily, please follow our organization on [pub.dev](https://pub.dev/publishers/maps.vietmap.vn/packages).

## Environment configure
- Create `.env` file, which contains all content as [example.env](/example.env) file we created.
- Replace your api key to the `YOUR_API_KEY_HERE` tag in [Info.plist](/ios/Runner/Info.plist) file.
- If you need to test the Android Auto, please replace your api key to `YOUR_API_KEY_HERE` tag in `android/app/androidauto/src/main/java/vn/vietmap/androidauto/VietMapCarAppScreen.kt` file.

## Test the Android Auto
**This app only work with DHU emulator, cause Android Auto feature can't use with physical device until deploy on the Play Store**
#### 1. Please following this official documentation from Google about Desktop Head Unit (DHU) [here](https://developer.android.com/training/cars/testing/dhu?authuser=1)
SDK location:

MacOS:
`/Users/<username>/Library/Android/sdk`

Windows:
`C:\Users\<username>\AppData\Local\Android\sdk`

Linux:
`/home/<username>/Android/Sdk`

CD to the DHU folder
```shell
cd SDK_LOCATION/extras/google/auto
```

Run the DHU
```shell
desktop-head-unit.exe   # Windows
./desktop-head-unit     # macOS or Linux
```

#### 2. Start the DHU
#### 3. Connect the real device to the DHU
#### 4. Run the app on the real device
#### 5. Open the Android Auto app on the DHU
#### 6. Create env file for Android Auto
- Create `vietmap_api_key.xml` file in `android/app/androidauto/src/main/res/values` folder
- Add the content as below to `vietmap_api_key.xml` file with your api key

```xml 
    <?xml version="1.0" encoding="utf-8"?>
    <resources>
        <string name="vietmap_api_key">
            YOUR_API_KEY_HERE
        </string>
    </resources>
```

## Integration Android Auto 
- Follow this document to add Android Auto to your project: [VietMap Android Auto SDK](https://github.com/vietmap-company/vietmap-android-auto)

<br></br>

[<img src="https://github.com/vietmap-company/vietmap-react-native-navigation/blob/HEAD/img/ios_nav.jpeg?raw=true" height="600"/> </p>](https://vietmap.vn/maps-api)

<br></br>

[<img src="https://bizweb.dktcdn.net/100/415/690/themes/804206/assets/logo.png?1689561872933" height="40"/> </p>](https://vietmap.vn/maps-api)
Email us: [maps-api.support@vietmap.vn](mailto:maps-api.support@vietmap.vn)


Contact for [support](https://vietmap.vn/lien-he)

Vietmap API document [here](https://maps.vietmap.vn/docs/map-api/overview/)

Have a bug to report? [Open an issue](https://github.com/vietmap-company/flutter-map-sdk/issues). If possible, include a full log and information which shows the issue.
Have a feature request? [Open an issue](https://github.com/vietmap-company/flutter-map-sdk/issues). Tell us what the feature should do and why you want the feature.

[Tài liệu tiếng Việt](./README.vi.md)