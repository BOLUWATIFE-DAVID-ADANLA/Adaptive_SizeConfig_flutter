import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_query_test_app/main.dart';

void main() {
  // Define the design dimensions used in tests
  const double designScreenHeight = 812;
  const double designScreenWidth = 375;

  setUpAll(() {
    const Size(designScreenWidth, designScreenHeight);
  });
  testWidgets('SizeConfig Test', (WidgetTester widgetTester) async {
    //design data to be used in test
    const double widgetheight = 175;
    const double widgetWidth = 250;

    // Test different screen sizes
    final testCases = [
      {'height': 812.0, 'width': 375.0}, // iPhone X
      {'height': 640.0, 'width': 360.0}, // Typical Android phone
      {'height': 1024.0, 'width': 768.0}, // iPad
    ];

    for (var testCase in testCases) {
      final double? phoneheight = testCase['height'];
      final double? phoneWidth = testCase['width'];
      if (phoneheight == null || phoneWidth == null) {
        throw Exception('screen size cannot be null');
      }
      await widgetTester.pumpWidget(MediaQuery(
          data: MediaQueryData(
            size: Size(phoneWidth, phoneheight),
          ),
          child: Builder(builder: (BuildContext context) {
            final estimatedHeight =
                SizeConfig.fromDesignHeight(context, widgetheight);
            final expectedHeight =
                (widgetheight / designScreenHeight) * phoneheight;
            expect(estimatedHeight, closeTo(expectedHeight, 0.1));

            final estimatedwidth =
                SizeConfig.fromDesignWidth(context, widgetWidth);
            final expectedwidth =
                (widgetWidth / designScreenWidth) * phoneWidth;
            expect(estimatedwidth, closeTo(expectedwidth, 0.1));
            return Container(
              height: estimatedHeight,
              width: estimatedwidth,
            );
          })));
    }
  });

  testWidgets('check for screen adaptiveness', (WidgetTester tester) async {
    const double baseFontSize = 24;

    final testCases = [
      {'height': 812.0, 'width': 375.0}, // iPhone X
      {'height': 640.0, 'width': 360.0}, // Typical Android phone
      {'height': 1024.0, 'width': 768.0}, // iPad
    ];

    for (var testCase in testCases) {
      final double? phoneHeight = testCase['height'];
      final double? phoneWidth = testCase['width'];
      if (phoneHeight == null || phoneWidth == null) {
        throw Exception('screen size cannot be null');
      }

      await tester.pumpWidget(MediaQuery(
        data: MediaQueryData(
          size: Size(phoneWidth, phoneHeight),
        ),
        child: Builder(builder: (BuildContext context) {
          // Calculate the expected font size
          double referenceWidth = phoneWidth < phoneHeight ? 375 : 1440;
          double referenceHeight = phoneWidth < phoneHeight ? 812 : 900;
          double scalingFactor = phoneWidth < phoneHeight
              ? phoneWidth / referenceWidth
              : phoneHeight / referenceHeight;
          double expectedFontSize = baseFontSize * scalingFactor;

          // Return the MaterialApp with the Text widget
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text(
                  'Test Text',
                  style: TextStyle(
                      fontSize: SizeConfig.fontSize(context, baseFontSize)),
                ),
              ),
            ),
          );
        }),
      ));

      final textWidget = tester.widget<Text>(find.text('Test Text'));
      double referenceWidth =
          phoneWidth < phoneHeight ? 375 : 1440; // Mobile vs web width
      double referenceHeight =
          phoneWidth < phoneHeight ? 812 : 900; // Mobile vs web height
      double scalingFactor = phoneWidth < phoneHeight
          ? phoneWidth / referenceWidth
          : phoneHeight / referenceHeight;
      double expectedFontSize = baseFontSize * scalingFactor;

      // Verify the font size
      expect(textWidget.style!.fontSize, closeTo(expectedFontSize, 0.1));
    }
  });
}
