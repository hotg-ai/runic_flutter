import 'package:ai_barcode/ai_barcode.dart';
import 'package:flutter/material.dart';
import 'package:runic_flutter/config/theme.dart';

class BarcodeScanner extends StatefulWidget {
  const BarcodeScanner(this.resultCallback);

  final void Function(String result) resultCallback;

  @override
  State<StatefulWidget> createState() {
    return _BarcodeScannerState();
  }
}

class _BarcodeScannerState extends State<BarcodeScanner> {
  late ScannerController _scannerController;

  @override
  void initState() {
    super.initState();

    _scannerController = ScannerController(scannerResult: (result) async {
      if (scanned == false) {
        scanned = true;
        print(scanned);
        setState(() {});
        await Future.delayed(const Duration(milliseconds: 1000), () {});
        showBackButton = false;
        setState(() {});
        await Future.delayed(const Duration(milliseconds: 100), () {});
        widget.resultCallback(result);
        Navigator.pop(context);
      }
    }, scannerViewCreated: () {
      final TargetPlatform platform = Theme.of(context).platform;
      if (TargetPlatform.iOS == platform) {
        Future.delayed(const Duration(seconds: 2), () {
          _scannerController
            ..startCamera()
            ..startCameraPreview();
        });
      } else {
        _scannerController
          ..startCamera()
          ..startCameraPreview();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    _scannerController
      ..stopCameraPreview()
      ..stopCamera();
  }

  bool scanned = false;
  bool showBackButton = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      PlatformAiBarcodeScannerWidget(
        platformScannerController: _scannerController,
      ),
      showBackButton
          ? Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              height: 100,
              child: Center(
                  child:
                      Text(scanned ? "Scan Complete" : "Scan Rune URL QRCode",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ))))
          : Container(),
      showBackButton
          ? Center(
              child: Container(
                  width: 320,
                  height: 320,
                  child: Stack(
                    children: [
                      Positioned(
                          height: 84,
                          width: 84,
                          top: 0,
                          left: 0,
                          child: Container(
                            decoration: BoxDecoration(
                                //borderRadius: BorderRadius.circular(2),
                                border: Border(
                              left: BorderSide(
                                color: Colors.white.withAlpha(100),
                                width: 4,
                              ),
                              top: BorderSide(
                                color: Colors.white.withAlpha(100),
                                width: 4,
                              ),
                            )),
                          )),
                      Positioned(
                          height: 84,
                          width: 84,
                          top: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                                //borderRadius: BorderRadius.circular(2),
                                border: Border(
                              top: BorderSide(
                                color: Colors.white.withAlpha(100),
                                width: 4,
                              ),
                              right: BorderSide(
                                color: Colors.white.withAlpha(100),
                                width: 4,
                              ),
                            )),
                          )),
                      Positioned(
                          height: 84,
                          width: 84,
                          bottom: 0,
                          left: 0,
                          child: Container(
                            decoration: BoxDecoration(
                                //borderRadius: BorderRadius.circular(2),
                                border: Border(
                                    left: BorderSide(
                                      color: Colors.white.withAlpha(100),
                                      width: 4,
                                    ),
                                    bottom: BorderSide(
                                      color: Colors.white.withAlpha(100),
                                      width: 4,
                                    ))),
                          )),
                      Positioned(
                          height: 84,
                          width: 84,
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                                //borderRadius: BorderRadius.circular(2),
                                border: Border(
                                    right: BorderSide(
                                      color: Colors.white.withAlpha(100),
                                      width: 4,
                                    ),
                                    bottom: BorderSide(
                                      color: Colors.white.withAlpha(100),
                                      width: 4,
                                    ))),
                          )),
                      (scanned)
                          ? Image.asset("assets/images/scan.png")
                          : Container(),
                      (scanned)
                          ? Center(
                              child: RawMaterialButton(
                              onPressed: () {},
                              elevation: 0.0,
                              fillColor: Color(0xAAE5C5EB),
                              padding: EdgeInsets.all(42),
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 96.0,
                              ),
                              shape: CircleBorder(),
                            ))
                          : Container()
                    ],
                  )))
          : Container(),
      showBackButton
          ? Positioned(
              left: 21,
              top: 42,
              height: 42,
              width: 42,
              child: IconButton(
                  onPressed: () async {
                    showBackButton = false;
                    setState(() {});
                    await Future.delayed(
                        const Duration(milliseconds: 100), () {});
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back_ios, color: Colors.white)))
          : Container()
    ]));
  }
}
