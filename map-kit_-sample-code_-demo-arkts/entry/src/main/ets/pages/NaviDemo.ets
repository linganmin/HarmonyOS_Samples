/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2023. All rights reserved.
 */
import { navi } from '@kit.MapKit';
import { deviceInfo } from '@kit.BasicServicesKit';

@Builder
export function NaviDemoBuilder() {
  NaviDemo();
}

@Entry
@Component
struct NaviDemo {
  pathStack: NavPathStack = new NavPathStack();
  private TAG = "OHMapSDK_NaviDemo";
  @State private tipText: string = "";

  build() {
    NavDestination() {
      Column({ space: 20 }) {
        Button() {
          Text('getWalkingRoutes').fontSize(20).fontWeight(FontWeight.Bold)
        }
        .type(ButtonType.Capsule)
        .backgroundColor('#0D9FFB')
        .width('50%')
        .height('5%')
        .onClick(async () => {
          const params: navi.RouteParams = {
            origins: [
              {
                latitude: 39.992281,
                longitude: 116.31088
              },
              {
                latitude: 39.996,
                longitude: 116.311
              }
            ],
            destination: {
              latitude: 39,
              longitude: 116.311
            },
            language: "zh_CN",
            avoids: [0],
            extension: 0
          };

          try {
            const rsp = await navi.getWalkingRoutes(params);
            this.setTipText("getWalkingRoutes success." + JSON.stringify(rsp));
          } catch (err) {
            console.error(this.TAG, "getWalkingRoutes fail err, error code:" + err.code + " message:" + err.message);
            this.setTipText("getWalkingRoutes fail err, error code:" + err.code + " message:" + err.message);
          }
        })

        Button() {
          Text('getCyclingRoutes').fontSize(20).fontWeight(FontWeight.Bold)
        }
        .type(ButtonType.Capsule)
        .backgroundColor('#0D9FFB')
        .width('50%')
        .height('5%')
        .onClick(async () => {
          const params: navi.RouteParams = {
            origins: [
              {
                latitude: 54.216608,
                longitude: -4.66529
              }
            ],
            destination: {
              latitude: 54.2166,
              longitude: -4.66552
            },
            language: "zh_CN",
            avoids: [0, 8],
            extension: 0
          };

          try {
            const rsp = await navi.getCyclingRoutes(params);
            this.setTipText("getCyclingRoutes success." + JSON.stringify(rsp));
          } catch (err) {
            console.error(this.TAG, "getCyclingRoutes fail err, error code:" + err.code + " message:" + err.message);
            this.setTipText("getCyclingRoutes fail err, error code:" + err.code + " message:" + err.message);
          }
        })

        Button() {
          Text('getDrivingRoutes').fontSize(20).fontWeight(FontWeight.Bold)
        }
        .type(ButtonType.Capsule)
        .backgroundColor('#0D9FFB')
        .width('50%')
        .height('5%')
        .onClick(async () => {
          const params: navi.DrivingRouteParams = {
            origins: [
              {
                latitude: 31.982129213545843,
                longitude: 120.27745557768591
              }
            ],
            destination: {
              latitude: 31.982129213545843,
              longitude: 120.27745557768591
            },
            waypoints: [
              {
                latitude: 31.967236140819114,
                longitude: 120.27142088866847
              },
              {
                latitude: 31.972868002238872,
                longitude: 120.2943211817165
              },
              { latitude: 31.98469327973332,
                longitude: 120.29101107384068
              }
            ],
            isViaType: true,
            optimize: true,
            alternatives: true,
            departAt: 0,
            trafficMode: 1,
            language: "zh_CN",
            avoids: [0],
            extension: 0
          };

          try {
            const rsp = await navi.getDrivingRoutes(params);
            this.setTipText("getDrivingRoutes success." + JSON.stringify(rsp));
          } catch (err) {
            console.error(this.TAG, "getDrivingRoutes fail err, error code:" + err.code + " message:" + err.message);
            this.setTipText("getDrivingRoutes fail err, error code:" + err.code + " message:" + err.message);
          }
        })

        Button() {
          Text('snapToRoads').fontSize(20).fontWeight(FontWeight.Bold)
        }
        .type(ButtonType.Capsule)
        .backgroundColor('#0D9FFB')
        .width('50%')
        .height('5%')
        .onClick(async () => {
          const params: navi.SnapToRoadsParams = {
            points: [{
              latitude: 54.216608,
              longitude: -4.66529
            }],
          };

          try {
            const rsp = await navi.snapToRoads(params);
            this.setTipText("snapToRoads success." + JSON.stringify(rsp));
          } catch (err) {
            console.error(this.TAG, "snapToRoads fail err, error code:" + err.code + " message:" + err.message);
            this.setTipText("snapToRoads fail err, error code:" + err.code + " message:" + err.message);
          }
        })

        Button() {
          Text('getWalkingMatrix').fontSize(20).fontWeight(FontWeight.Bold)
        }
        .type(ButtonType.Capsule)
        .backgroundColor('#0D9FFB')
        .width('50%')
        .height('5%')
        .onClick(async () => {
          const params: navi.MatrixParams = {
            origins: [
              {
                longitude: 2.359782,
                latitude: 48.862544
              },
              {
                longitude: 2.358537,
                latitude: 48.861443
              }
            ],
            destinations: [
              {
                longitude: 2.361702,
                latitude: 48.86042
              }
            ],
            language: "zh_CN"
          };

          try {
            const rsp = await navi.getWalkingMatrix(params);
            this.setTipText("getWalkingMatrix success." + JSON.stringify(rsp));
          } catch (err) {
            console.error(this.TAG, "getWalkingMatrix fail err, error code:" + err.code + " message:" + err.message);
            this.setTipText("getWalkingMatrix fail err, error code:" + err.code + " message:" + err.message);
          }
        })

        Button() {
          Text('getCyclingMatrix').fontSize(20).fontWeight(FontWeight.Bold)
        }
        .type(ButtonType.Capsule)
        .backgroundColor('#0D9FFB')
        .width('50%')
        .height('5%')
        .onClick(async () => {
          const params: navi.MatrixParams = {
            origins: [
              {
                longitude: 2.359782,
                latitude: 48.862544
              }
            ],
            destinations: [
              {
                longitude: 2.361702,
                latitude: 48.860420
              }
            ],
            language: "zh_CN"
          };

          try {
            const rsp = await navi.getCyclingMatrix(params);
            this.setTipText("getCyclingMatrix success." + JSON.stringify(rsp));
          } catch (err) {
            console.error(this.TAG, "getCyclingMatrix fail err, error code:" + err.code + " message:" + err.message);
            this.setTipText("getCyclingMatrix fail err, error code:" + err.code + " message:" + err.message);
          }
        })

        Button() {
          Text('getDrivingMatrix').fontSize(20).fontWeight(FontWeight.Bold)
        }
        .type(ButtonType.Capsule)
        .backgroundColor('#0D9FFB')
        .width('50%')
        .height('5%')
        .onClick(async () => {
          const params: navi.DrivingMatrixParams = {
            origins: [
              {
                longitude: -1.894679,
                latitude: 54.974887
              },
              {
                longitude: -2.882682,
                latitude: 54.857616
              }
            ],
            destinations: [
              {
                longitude: -1.744955,
                latitude: 54.775040
              }
            ],
            avoids: [1, 2],
            trafficMode: 2,
            language: "zh_CN"
          };

          try {
            const rsp = await navi.getDrivingMatrix(params);
            this.setTipText("getDrivingMatrix success." + JSON.stringify(rsp));
          } catch (err) {
            console.error(this.TAG, "getDrivingMatrix fail err, error code:" + err.code + " message:" + err.message);
            this.setTipText("getDrivingMatrix fail err, error code:" + err.code + " message:" + err.message);
          }
        })

        if (deviceInfo.deviceType === "2in1") {
          Button() {
            Text("goBack").fontSize(20).fontWeight(FontWeight.Bold)
          }
          .type(ButtonType.Capsule)
          .backgroundColor('#0D9FFB')
          .width('50%')
          .height('5%')
          .onClick(async () => {
            this.pathStack.clear();
          })
        }
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
          right: 50,
          bottom: 20
        })
        .visibility(!(this.tipText === undefined
          || this.tipText === null
          || this.tipText.length === 0) ? Visibility.Visible : Visibility.Hidden)
        .backgroundColor('#99302e2e')
        .borderRadius(15);

      }.margin({ top: 20 }).width('100%')
    }.title('NaviDemo')
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
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
    await new Promise<void>(resolve => setTimeout(resolve, duration === undefined ? 5000 : duration));
  }
}