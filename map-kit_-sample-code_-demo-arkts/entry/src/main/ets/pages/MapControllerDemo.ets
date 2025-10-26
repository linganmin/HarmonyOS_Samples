/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2023. All rights reserved.
 */

import { MapComponent, mapCommon, map } from '@kit.MapKit';
import { AsyncCallback, deviceInfo } from '@kit.BasicServicesKit';
import { geoLocationManager } from '@kit.LocationKit';

@Builder
export function MapControllerDemoBuilder() {
  MapControllerDemo();
}

@Entry
@Component
struct MapControllerDemo {
  pathStack: NavPathStack = new NavPathStack();
  private TAG = "OHMapSDK_MapControllerDemo";
  private mapOption?: mapCommon.MapOptions;
  private mapController?: map.MapComponentController;
  private callback?: AsyncCallback<map.MapComponentController>;
  @State scaleEnable: boolean = false;
  @State tiltGesturesEnabled: boolean = false;
  @State private tipText: string = "";

  aboutToAppear(): void {
    this.mapOption = {
      position: {
        target: {
          latitude: 2.922865,
          longitude: 101.58584
        },
        zoom: 10
      },
      tiltGesturesEnabled: this.tiltGesturesEnabled
    };

    this.callback = async (err, mapController) => {
      if (!err) {
        this.mapController = mapController;
        this.mapController?.on("mapLoad", async () => {
          console.info(this.TAG, `on-mapLoad`);
          await this.setTipText(`on mapLoad`);
        });
      }
    };
  }

  build() {
    NavDestination() {
      Stack() {
        Column() {
          MapComponent({ mapOptions: this.mapOption, mapCallback: this.callback })
            .width('100%')
            .height('65%');

          Scroll(new Scroller()) {
            Column() {
              this.buildDemoUI();
            }.width('100%')
            .margin({ bottom: 48 })
            .backgroundColor(0xf2f2f2)
          }.width('100%')
          .height('30%')
        }.width('100%')

        Row() {
          Text(this.tipText)
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
          right: 50
        })
        .visibility(!(this.tipText === undefined
          || this.tipText === null
          || this.tipText.length === 0) ? Visibility.Visible : Visibility.Hidden)
        .backgroundColor('#99302e2e')
        .borderRadius(15);
      }.height('100%')
      .alignContent(Alignment.TopStart)
    }.title('MapController')
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
  }

  @Builder
  buildDemoUI() {
    Text("MapController")
      .height(30)
      .width('100%')
      .fontWeight(FontWeight.Bold)
      .fontSize(15)
      .margin({ left: 24 });

    Row() {
      Button("moveCamera")
        .fontSize(12)
        .margin({ left: 6 })
        .onClick(async () => {
          if (this.mapController === null || this.mapController === undefined) {
            console.info(this.TAG, "moveCamera mapController is null");
            await this.setTipText(`mapController is null`);
            return;
          }

          let cameraPosition: mapCommon.CameraPosition = {
            target: {
              latitude: 32,
              longitude: 118
            },
            zoom: 10
          };
          this.mapController?.moveCamera(map.newCameraPosition(cameraPosition));
          await this.setTipText(`moveCamera.newCameraPosition ${JSON.stringify(cameraPosition)}`);

          this.sleep(1500);
          let bounds: mapCommon.LatLngBounds = {
            northeast: {
              latitude: 30,
              longitude: 117
            },
            southwest: {
              latitude: 26,
              longitude: 119
            }
          };
          this.mapController?.moveCamera(map.newLatLngBounds(bounds));
          await this.setTipText(`moveCamera.newLatLngBounds ${JSON.stringify(bounds)}`);

          this.sleep(1500);
          this.mapController?.moveCamera(map.scrollBy(100, 200));
          await this.setTipText(`moveCamera.scrollBy {100, 200}`);

          this.sleep(1500);
          let focus: mapCommon.MapPoint = {
            positionX: 100,
            positionY: 200
          };
          this.mapController?.moveCamera(map.zoomBy(10, focus));
          await this.setTipText(`moveCamera.zoomBy 10, {100, 200}`);

          this.sleep(1500);
          let latLng: mapCommon.LatLng = {
            latitude: 33,
            longitude: 119
          };
          this.mapController?.moveCamera(map.newLatLng(latLng));
          await this.setTipText(`moveCamera.newLatLng ${JSON.stringify(latLng)}`);

          this.sleep(1500);
          this.mapController?.moveCamera(map.zoomIn());
          await this.setTipText(`moveCamera.zoomIn`);

          this.sleep(1500);
          this.mapController?.moveCamera(map.zoomOut());
          await this.setTipText(`moveCamera.zoomOut`);

          this.sleep(1500);
          this.mapController?.moveCamera(map.zoomTo(10));
          await this.setTipText(`moveCamera.zoomTo(10)`);

          this.sleep(1500);
          let cameraPos = this.mapController?.getCameraPosition();
          await this.setTipText(`getCameraPosition ${JSON.stringify(cameraPos)}`);
        })

      Button("animateCamera")
        .fontSize(12)
        .margin({ left: 6 })
        .onClick(async () => {
          if (this.mapController === null || this.mapController === undefined) {
            console.info(this.TAG, "animateCamera mapController is null");
            await this.setTipText(`mapController is null`);
            return;
          }

          let cameraPosition: mapCommon.CameraPosition = {
            target: {
              latitude: 32,
              longitude: 118
            },
            zoom: 10
          };
          this.mapController?.animateCamera(map.newCameraPosition(cameraPosition), 300);
          await this.setTipText(`animateCamera.newCameraPosition ${JSON.stringify(cameraPosition)}`);

          this.sleep(1500);
          let bounds: mapCommon.LatLngBounds = {
            northeast: {
              latitude: 30,
              longitude: 117
            },
            southwest: {
              latitude: 26,
              longitude: 119
            }
          };
          this.mapController?.animateCamera(map.newLatLngBounds(bounds), 300);
          await this.setTipText(`animateCamera.newLatLngBounds ${JSON.stringify(bounds)}`);

          this.sleep(1500);
          this.mapController?.animateCamera(map.scrollBy(100, 200));
          await this.setTipText(`animateCamera.scrollBy {100, 200}`);

          this.sleep(1500);
          let focus: mapCommon.MapPoint = {
            positionX: 100,
            positionY: 200
          };
          this.mapController?.animateCamera(map.zoomBy(10, focus), 300);
          await this.setTipText(`animateCamera.zoomBy 10, {100, 200}`);

          this.sleep(1500);
          let latLng: mapCommon.LatLng = {
            latitude: 33,
            longitude: 119
          };
          this.mapController?.animateCamera(map.newLatLng(latLng), 300);
          await this.setTipText(`animateCamera.newLatLng ${JSON.stringify(latLng)}`);

          this.sleep(1500);
          this.mapController?.animateCamera(map.zoomIn(), 300);
          await this.setTipText(`animateCamera.zoomIn`);

          this.sleep(1500);
          this.mapController?.animateCamera(map.zoomOut(), 300);
          await this.setTipText(`animateCamera.zoomOut`);

          this.sleep(1500);
          this.mapController?.animateCamera(map.zoomTo(10), 300);
          await this.setTipText(`animateCamera.zoomTo(10)`);

          this.sleep(1500);
          let cameraPos = this.mapController?.getCameraPosition();
          await this.setTipText(`getCameraPosition ${JSON.stringify(cameraPos)}`);
        })

      Button("Projection")
        .fontSize(12)
        .margin({ left: 6 })
        .onClick(async () => {
          if (this.mapController === null || this.mapController === undefined) {
            console.info(this.TAG, "getProjection mapController is null");
            await this.setTipText(`mapController is null`);
            return;
          }

          try {
            let projection: map.Projection = this.mapController?.getProjection();
            await this.setTipText(`getProjection`);
            if (!projection) {
              await this.setTipText(`getProjection error`);
              return;
            }

            this.sleep(1500);
            let focus: mapCommon.MapPoint = {
              positionX: 10,
              positionY: 10
            };
            let latLng: mapCommon.LatLng = projection.fromScreenLocation(focus);
            await this.setTipText(`projection.fromScreenLocation ${JSON.stringify(latLng)}`);

            this.sleep(1500);
            let point: mapCommon.MapPoint = projection.toScreenLocation({ latitude: 0, longitude: 0 });
            await this.setTipText(`projection.toScreenLocation ${JSON.stringify(point)}`);

            this.sleep(1500);
            let visibleRegion: mapCommon.VisibleRegion = projection.getVisibleRegion();
            await this.setTipText(`projection.getVisibleRegion ${JSON.stringify(visibleRegion)}`);

            this.sleep(1500);
            let scalePerPixel = this.mapController?.getScalePerPixel();
            console.info(this.TAG, "getScalePerPixel:" + scalePerPixel);
            await this.setTipText(`getScalePerPixel ${scalePerPixel}`);
          } catch (err) {
            console.error(this.TAG, "getProjection fail err, error code:" + err.code + " message:" + err.message);
          }
        })
    }.margin({ top: 12 })

    Row() {
      Button("setMyLocation")
        .fontSize(12)
        .onClick(async () => {
          if (!this.mapController) {
            console.info(this.TAG, "setMyLocation mapController is null");
            await this.setTipText(`mapController is null`);
            return;
          }

          try {
            let initNumber = 0;
            let position: geoLocationManager.Location = {
              latitude: 64,
              longitude: 112,
              altitude: 0,
              accuracy: 0,
              speed: 0,
              timeStamp: 0,
              direction: 0,
              timeSinceBoot: 0,
              altitudeAccuracy: 0,
              speedAccuracy: 0,
              directionAccuracy: 0,
              uncertaintyOfTimeSinceBoot: 0,
              sourceType: 1
            };
            let count = 0;
            const intervalId = setInterval(async () => {
              position.direction = initNumber + count * 3;
              position.accuracy = initNumber + count * 100;
              position.latitude = initNumber + count * 0.1;
              position.longitude = initNumber + count * 0.1;
              this.mapController?.setMyLocation(position);
              if (count++ === 10) {
                clearInterval(intervalId);
              }
            }, 200);
            await this.setTipText(`setMyLocation`);
            console.info(this.TAG, `setMyLocation success param:${position}`);
          } catch (err) {
            console.error(this.TAG, "setMyLocation fail err, error code:" + err.code + " message:" + err.message);
          }
        })

      Button("setMyLocationStyle")
        .fontSize(12)
        .margin({ left: 6 })
        .onClick(async () => {
          if (!this.mapController) {
            console.info(this.TAG, "setMyLocationStyle mapController is null");
            await this.setTipText(`mapController is null`);
            return;
          }

          try {
            let style: mapCommon.MyLocationStyle = {
              anchorU: 0.5,
              anchorV: 1,
              radiusFillColor: 0xffff0000,
              icon: 'icon/avocado.png'
            }
            await this.mapController?.setMyLocationStyle(style);
            await this.setTipText(`setMyLocationStyle`);
            console.info(this.TAG, `setMyLocationStyle success param:${style}`);
          } catch (err) {
            console.error(this.TAG, "setMyLocationStyle fail err, error code:" + err.code + " message:" + err.message);
          }
        })
    }.margin({ top: 12 })

    Row() {
      Button("setTrue")
        .fontSize(12)
        .onClick(async () => {
          if (!this.mapController) {
            console.info(this.TAG, "setTrue mapController is null");
            await this.setTipText(`mapController is null`);
            return;
          }

          this.mapController?.setMyLocationEnabled(true);
          await this.setTipText(`setMyLocationEnabled true`);

          this.sleep(1500);
          this.mapController?.setTrafficEnabled(true);
          await this.setTipText(`setTrafficEnabled true`);

          this.sleep(1500);
          this.mapController?.setBuildingEnabled(true);
          await this.setTipText(`setBuildingEnabled true`);

          this.sleep(1500);
          this.mapController?.setZoomGesturesEnabled(true);
          await this.setTipText(`setZoomGesturesEnabled true`);

          this.sleep(1500);
          this.mapController?.setScrollGesturesEnabled(true);
          await this.setTipText(`setScrollGesturesEnabled true`);

          this.sleep(1500);
          this.mapController?.setRotateGesturesEnabled(true);
          await this.setTipText(`setRotateGesturesEnabled true`);

          this.sleep(1500);
          this.mapController?.setMyLocationControlsEnabled(true);
          await this.setTipText(`setMyLocationControlsEnabled true`);

          this.sleep(1500);
          this.mapController?.setZoomControlsEnabled(true);
          await this.setTipText(`setZoomControlsEnabled true`);

          this.sleep(1500);
          this.mapController?.setGestureScaleByMapCenter(true);
          await this.setTipText(`setGestureScaleByMapCenter true`);

          this.sleep(1500);
          this.mapController?.setScaleControlsEnabled(true);
          await this.setTipText(`setScaleControlsEnabled true`);

          this.sleep(1500);
          this.mapController?.setTiltGesturesEnabled(true);
          await this.setTipText(`setTiltGesturesEnabled true`);
        })

      Button("setFalse")
        .fontSize(12)
        .margin({ left: 6 })
        .onClick(async () => {
          if (!this.mapController) {
            console.info(this.TAG, "setTrafficEnabled mapController is null");
            await this.setTipText(`mapController is null`);
            return;
          }

          this.mapController?.setMyLocationEnabled(false);
          await this.setTipText(`setMyLocationEnabled false`);

          this.sleep(1500);
          this.mapController?.setTrafficEnabled(false);
          await this.setTipText(`setTrafficEnabled false`);

          this.sleep(1500);
          this.mapController?.setBuildingEnabled(false);
          await this.setTipText(`setBuildingEnabled false`);

          this.sleep(1500);
          this.mapController?.setZoomGesturesEnabled(false);
          await this.setTipText(`setZoomGesturesEnabled false`);

          this.sleep(1500);
          this.mapController?.setScrollGesturesEnabled(false);
          await this.setTipText(`setScrollGesturesEnabled false`);

          this.sleep(1500);
          this.mapController?.setRotateGesturesEnabled(false);
          await this.setTipText(`setRotateGesturesEnabled false`);

          this.sleep(1500);
          this.mapController?.setMyLocationControlsEnabled(false);
          await this.setTipText(`setMyLocationControlsEnabled false`);

          this.sleep(1500);
          this.mapController?.setZoomControlsEnabled(false);
          await this.setTipText(`setZoomControlsEnabled false`);

          this.sleep(1500);
          this.mapController?.setGestureScaleByMapCenter(false);
          await this.setTipText(`setGestureScaleByMapCenter false`);

          this.sleep(1500);
          this.mapController?.setScaleControlsEnabled(false);
          await this.setTipText(`setScaleControlsEnabled false`);

          this.sleep(1500);
          this.mapController?.setTiltGesturesEnabled(false);
          await this.setTipText(`setTiltGesturesEnabled false`);
        })

      Button("getEnabled")
        .fontSize(12)
        .margin({ left: 6 })
        .onClick(async () => {
          if (!this.mapController) {
            console.info(this.TAG, "setTrafficEnabled mapController is null");
            await this.setTipText(`mapController is null`);
            return;
          }

          let enable = this.mapController?.isMyLocationEnabled();
          await this.setTipText(`isMyLocationEnabled ${enable}`);

          this.sleep(1500);
          enable = this.mapController?.isTrafficEnabled();
          await this.setTipText(`isTrafficEnabled ${enable}`);

          this.sleep(1500);
          enable = this.mapController?.isBuildingEnabled();
          await this.setTipText(`isBuildingEnabled ${enable}`);

          this.sleep(1500);
          enable = this.mapController?.isZoomGesturesEnabled();
          await this.setTipText(`isZoomGesturesEnabled ${enable}`);

          this.sleep(1500);
          enable = this.mapController?.isScrollGesturesEnabled();
          await this.setTipText(`isScrollGesturesEnabled ${enable}`);

          this.sleep(1500);
          enable = this.mapController?.isRotateGesturesEnabled();
          await this.setTipText(`isRotateGesturesEnabled ${enable}`);

          this.sleep(1500);
          enable = this.mapController?.isMyLocationControlsEnabled();
          await this.setTipText(`isMyLocationControlsEnabled ${enable}`);

          this.sleep(1500);
          enable = this.mapController?.isZoomControlsEnabled();
          await this.setTipText(`isZoomControlsEnabled ${enable}`);

          this.sleep(1500);
          enable = this.mapController?.isGestureScaleByMapCenter();
          await this.setTipText(`isGestureScaleByMapCenter ${enable}`);

          this.sleep(1500);
          enable = this.mapController?.isScaleControlsEnabled();
          await this.setTipText(`isScaleControlsEnabled ${enable}`);

          this.sleep(1500);
          enable = this.mapController?.isTiltGesturesEnabled();
          await this.setTipText(`isTiltGesturesEnabled ${enable}`);
        })

      if (deviceInfo.deviceType === "2in1") {
        Button("goBack")
          .fontSize(12)
          .margin({ left: 6 })
          .onClick(async () => {
            this.pathStack.clear();
          })
      }
    }.margin({ top: 12 })
  }

  async setTipText(text: string) {
    if (text == undefined
      || text.length == 0) {
      return;
    }

    this.tipText = text;
    await this.sleep();
    this.tipText = "";
  }

  private async sleep(duration?: number) {
    await new Promise<void>(resolve => setTimeout(resolve, duration === undefined ? 2000 : duration));
  }
}