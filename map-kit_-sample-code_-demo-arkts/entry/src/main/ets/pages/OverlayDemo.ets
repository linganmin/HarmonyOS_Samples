/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2023. All rights reserved.
 */

import { map, mapCommon, MapComponent } from '@kit.MapKit';
import { AsyncCallback, deviceInfo } from '@kit.BasicServicesKit';

@Builder
export function OverlayDemoBuilder() {
  OverlayDemo();
}

@Entry
@Component
struct OverlayDemo {
  pathStack: NavPathStack = new NavPathStack();
  private TAG = "OHMapSDK_OverlayDemo";
  private mapOptions?: mapCommon.MapOptions;
  private callback?: AsyncCallback<map.MapComponentController>;
  private mapController?: map.MapComponentController;
  private marker?: map.Marker;
  private mapCircle?: map.MapCircle;
  private mapPolyline?: map.MapPolyline;
  private mapPolygon?: map.MapPolygon;
  @State private visible: boolean = true;
  @State private tipText: string = "";
  private timeInterval: number = 2000;

  aboutToAppear(): void {
    let target: mapCommon.LatLng = {
      latitude: 31.985019,
      longitude: 118.765998
    };

    let cameraPosition: mapCommon.CameraPosition = {
      target: target,
      zoom: 10
    };
    this.mapOptions = {
      position: cameraPosition,
      rotateGesturesEnabled: true,
      scrollGesturesEnabled: true,
      zoomGesturesEnabled: true,
      tiltGesturesEnabled: true,
      zoomControlsEnabled: false,
      myLocationControlsEnabled: false,
      compassControlsEnabled: false,
      scaleControlsEnabled: false
    };

    this.callback = async (err, mapController) => {
      if (!err) {
        this.mapController = mapController;
      }
    };
  }

  build() {
    NavDestination() {
      Stack() {
        MapComponent({ mapOptions: this.mapOptions, mapCallback: this.callback })
          .width('100%')
          .height('100%');

        Button('MarkerSample')
          .fontSize(12)
          .height(44)
          .margin({
            left: 16,
            top: 12
          })
          .visibility(this.visible ? Visibility.Visible : Visibility.Hidden)
          .onClick(async () => {
            this.visible = false;
            await this.markerFunction();
            this.visible = true;
          });

        Button('CircleSample')
          .fontSize(12)
          .height(44)
          .margin({
            left: 16,
            top: 68
          })
          .visibility(this.visible ? Visibility.Visible : Visibility.Hidden)
          .onClick(async () => {
            this.visible = false;
            this.mapController?.animateCamera(map.newLatLng({
              latitude: 39.908795,
              longitude: 116.397454
            }), 1000);
            await this.sleep();
            await this.circleFunction();
            this.visible = true;
          });

        Button('PolylineSample')
          .fontSize(12)
          .height(44)
          .margin({
            left: 16,
            top: 124
          })
          .visibility(this.visible ? Visibility.Visible : Visibility.Hidden)
          .onClick(async () => {
            this.visible = false;
            this.mapController?.animateCamera(map.newLatLng({
              latitude: 22.536265,
              longitude: 114.051047
            }), 1000);
            await this.sleep();
            await this.polylineFunction();
            this.visible = true;
          });

        Button('PolygonSample')
          .fontSize(12)
          .height(44)
          .margin({
            left: 16,
            top: 180
          })
          .visibility(this.visible ? Visibility.Visible : Visibility.Hidden)
          .onClick(async () => {
            this.visible = false;
            this.mapController?.animateCamera(map.newLatLng({
              latitude: 31.240348,
              longitude: 121.502295
            }), 1000);
            await this.sleep();
            await this.polygonFunction();
            this.visible = true;
          });

        if (deviceInfo.deviceType === "2in1") {
          Button("goBack")
            .fontSize(12)
            .margin({
              left: 16,
              top: 236
            })
            .onClick(async () => {
              this.pathStack.clear();
            })
        }
        Row() {
          Text(this.tipText)
            .height(30)
            .width('100%')
            .fontWeight(FontWeight.Bold)
            .fontSize(15)
            .fontColor(Color.White)
            .textAlign(TextAlign.Center)
            .margin({
              left: 10,
              top: 10,
              right: 10,
              bottom: 10
            });
        }
        .align(Alignment.Center)
        .margin({
          left: 50,
          top: 20,
          right: 50,
          bottom: 20
        })
        .visibility(!(this.tipText === undefined || this.tipText === null || this.tipText.length === 0) ?
          Visibility.Visible : Visibility.Hidden)
        .backgroundColor('#99302e2e')
        .borderRadius(15);


      }
      .alignContent(Alignment.TopStart)
      .height('100%')
    }.title('Overlay')
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
  }

  /*===============================================Marker start=======================================================*/

  private async markerFunction() {
    // Add a Marker. 
    this.tipText = "Add a Marker.";
    await this.addMarker();
    await this.sleep();

    // Move a Marker.
    this.tipText = "Move a Marker.";
    this.moveMarker();
    await this.sleep(3000);

    // Change the icon of a Marker.
    this.tipText = "Change the icon of a Marker.";
    await this.marker?.setIcon('icon/avocado.png');
    await this.sleep();

    // Rotate a Marker.
    this.tipText = "Rotate a Marker.";
    let rotation = 0;
    const intervalId = setInterval(async () => {
      this.marker?.setRotation(rotation);
      if (rotation++ === 360) {
        clearInterval(intervalId);
      }
    }, 5);
    await this.sleep(3800);

    // Change the transparency of a Marker.
    this.tipText = "Change the transparency of a Marker.";
    this.alphaMarker();
    await this.sleep(4000);

    // Remove a Marker.
    this.tipText = "Remove a Marker.";
    this.marker?.remove();

    await this.sleep();
    this.tipText = "";
  }

  /**
   * Add a Marker.
   */
  private async addMarker() {
    let markerOptions: mapCommon.MarkerOptions = {
      position: {
        latitude: 31.985019,
        longitude: 118.765998
      },
      rotation: 0,
      visible: true,
      zIndex: 0,
      alpha: 1,
      anchorU: 0.5,
      anchorV: 1,
      clickable: true,
      draggable: true,
      flat: false
    };
    console.info(this.TAG, "markerOptions=" + JSON.stringify(markerOptions));
    this.marker = await this.mapController?.addMarker(markerOptions);
  }

  /**
   * Move a Marker.
   */
  private moveMarker() {
    this.mapController?.moveCamera(map.newLatLng({
      latitude: 32.985019,
      longitude: 118.765998
    }));

    this.marker?.setPosition({
      latitude: 32.985019,
      longitude: 118.765998
    });
  }

  /**
   * Change the transparency of a Marker.
   */
  private alphaMarker() {
    let flag = false;
    let alpha = 100;
    const intervalIdAlpha = setInterval(async () => {
      if (flag) {
        alpha++;
      } else {
        alpha--;
      }
      this.marker?.setAlpha(alpha / 100);

      if (alpha === 0) {
        flag = true;
      }

      if (alpha === 100) {
        clearInterval(intervalIdAlpha);
      }
    }, 10);
  }

  /*===============================================Circle start=======================================================*/

  private async circleFunction() {
    // Add a MapCircle.
    this.tipText = "Add a MapCircle.";
    await this.addCircle();
    await this.sleep();

    // Move a MapCircle.
    this.tipText = "Move a MapCircle.";
    await this.moveCircle();
    await this.sleep(3000);

    this.tipText = "Set the stroke style of a MapCircle.";
    this.mapCircle?.setPatterns([{ type: 0, length: 50 }, { type: 1, length: 50 }, { type: 2, length: 50 }]);
    await this.sleep();

    this.tipText = "Set the fill color of a MapCircle.";
    this.mapCircle?.setFillColor(0xffff0000);
    await this.sleep();

    this.tipText = "Set the stroke color of a MapCircle.";
    this.mapCircle?.setStrokeColor(0xff0000FF);
    await this.sleep();

    this.tipText = "Set the stroke width of a MapCircle.";
    this.mapCircle?.setStrokeWidth(20);
    await this.sleep();

    this.tipText = "Set the radius of a MapCircle.";
    this.mapCircle?.setRadius(10000);
    await this.sleep();

    // Remove a MapCircle.
    this.tipText = "Remove a MapCircle.";
    this.mapCircle?.remove();

    await this.sleep();
    this.tipText = "";
  }

  /**
   * Add a MapCircle.
   */
  private async addCircle() {
    let mapCircleOptions: mapCommon.MapCircleOptions = {
      center: {
        latitude: 39.908795,
        longitude: 116.397454
      },
      radius: 15000
    };
    this.mapCircle = await this.mapController?.addCircle(mapCircleOptions);
  }

  /**
   * Move a MapCircle.
   */
  private async moveCircle() {
    this.mapController?.moveCamera(map.newLatLng({
      latitude: 40.954607,
      longitude: 116.446435
    }));

    this.mapCircle?.setCenter({
      latitude: 40.954607,
      longitude: 116.446435
    });
  }

  /*===============================================Polyline start=======================================================*/

  private async polylineFunction() {
    // Add a MapPolyline.
    this.tipText = "Add a MapPolyline.";
    await this.addPolyline();
    await this.sleep();

    this.tipText = "Change the width of a MapPolyline.";
    this.mapPolyline?.setWidth(30);
    await this.sleep();

    this.tipText = "Change the end cap style of a MapPolyline.";
    this.mapPolyline?.setStartCap(mapCommon.CapStyle.ROUND);
    this.mapPolyline?.setEndCap(mapCommon.CapStyle.ROUND);
    await this.sleep();

    this.tipText = "Change the color of a MapPolyline.";
    this.mapPolyline?.setColor(0xffFF0000);
    await this.sleep();

    this.tipText = "Change the colors of segments of a MapPolyline.";
    this.mapPolyline?.setColors([0xffFF0000, 0xff00FF00, 0xff0000FF]);
    await this.sleep();

    this.tipText = "Set a MapPolyline to a gradient color.";
    this.mapPolyline?.setGradient(true);
    await this.sleep();

    this.tipText = "Set the pattern of a MapPolyline.";
    this.mapPolyline?.setPatterns([{ type: 0, length: 50 }, { type: 1, length: 50 }, { type: 2, length: 50 }]);
    await this.sleep();

    // Remove a MapPolyline.
    this.tipText = "Remove a MapPolyline.";
    this.mapPolyline?.remove();

    await this.sleep();
    this.tipText = "";
  }

  /**
   * Add a MapPolyline.
   */
  private async addPolyline() {
    let polylineOption: mapCommon.MapPolylineOptions = {
      points: [
        { 
          latitude: 22.70106128558265,
          longitude: 114.20485559375003 
        },
        { 
          latitude: 22.527566971297336,
          longitude: 113.90822473437503 
        },
        { 
          latitude: 22.54025141339333,
          longitude: 114.19936242968748 
        },
        { 
          latitude: 22.32373190546129,
          longitude: 113.99650772823661 
        }
      ],
      clickable: true,
      visible: true,
      width: 10,
      zIndex: 0,
      gradient: false
    };
    this.mapPolyline = await this.mapController?.addPolyline(polylineOption);
  }

  /*===============================================Polygon start=======================================================*/

  private async polygonFunction() {
    // Add a MapPolygon. 
    this.tipText = "Add a MapPolygon.";
    await this.addPolygon();
    await this.sleep();

    this.tipText = "Change the stroke width of a MapPolygon.";
    this.mapPolygon?.setStrokeWidth(20);
    await this.sleep();

    this.tipText = "Set the fill color of a MapPolygon.";
    this.mapPolygon?.setFillColor(0xffff0000);
    await this.sleep();

    this.tipText = "Change the stroke color of a MapPolygon.";
    this.mapPolygon?.setStrokeColor(0xff0000FF);
    await this.sleep();

    this.tipText = "Set the pattern of a MapPolygon.";
    this.mapPolygon?.setPatterns([{ type: 0, length: 50 }, { type: 1, length: 50 }, { type: 2, length: 50 }]);
    await this.sleep();

    this.tipText = "Set MapPolygon holes.";
    let holes: Array<Array<mapCommon.LatLng>> = [[
      {
        latitude: 31.30037894464378,
        longitude: 121.46423522042404
      },
      {
        latitude: 31.30037894464378,
        longitude: 121.54153188616067
      },
      {
        latitude: 31.205315739721973,
        longitude: 121.54153188616067
      },
      {
        latitude: 31.205315739721973,
        longitude: 121.46423522042404
      }
    ]];
    this.mapPolygon?.setHoles(holes);
    await this.sleep();

    // Remove a MapPolygon.
    this.tipText = "Remove a MapPolygon.";
    this.mapPolygon?.remove();

    await this.sleep();
    this.tipText = "";
  }

  /**
   * Add a MapPolygon.
   */
  private async addPolygon() {
    let polygonOption: mapCommon.MapPolygonOptions = {
      points: [
        { latitude: 31.379802450447624,
          longitude: 121.38066065290177
        },
        { latitude: 31.379802450447624,
          longitude: 121.6074498549107
        },
        { latitude: 31.065067849247374,
          longitude: 121.6074498549107
        },
        { latitude: 31.065067849247374,
          longitude: 121.38066065290177
        }
      ],
      clickable: true,
      visible: true,
      strokeWidth: 10,
      zIndex: 0
    };
    this.mapPolygon = await this.mapController?.addPolygon(polygonOption);
  }

  private async sleep(duration?: number) {
    await new Promise<void>(resolve => setTimeout(resolve, duration === undefined ? this.timeInterval : duration));
  }
}