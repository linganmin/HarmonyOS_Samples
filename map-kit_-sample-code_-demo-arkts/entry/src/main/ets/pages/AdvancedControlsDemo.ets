/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2023. All rights reserved.
 */
import { map, mapCommon, MapComponent, sceneMap, site } from '@kit.MapKit';
import { AsyncCallback, BusinessError, deviceInfo } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';

@Builder
export function AdvancedControlsDemoBuilder() {
  AdvancedControlsDemo();
}

@Entry
@Component
struct AdvancedControlsDemo {
  pathStack: NavPathStack = new NavPathStack();
  private TAG = "OHMapSDK_AdvancedControlsDemo";
  private mapOption?: mapCommon.MapOptions;
  private mapController?: map.MapComponentController;
  private callback?: AsyncCallback<map.MapComponentController>;
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
      tiltGesturesEnabled: true
    };

    this.callback = async (err, mapController) => {
      if (!err) {
        this.mapController = mapController;
        this.mapController?.on("poiClick", (poi) => {
          try {
            let option: sceneMap.LocationQueryOptions = {
              siteId: poi.id,
              name: poi.name,
              location: poi.position,
              language: 'zh'
            };
            sceneMap.queryLocation(this.getUIContext().getHostContext() as common.UIAbilityContext, option).then(() => {
              console.info(this.TAG, "queryLocation success:");
            }).catch((err: BusinessError) => {
              console.error(this.TAG, "queryLocation fail err=" + JSON.stringify(err));
            });
          } catch (err) {
            console.error(this.TAG, "queryLocation fail err=" + JSON.stringify(err));
          }
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
            .height('85%')

          Row() {
            Button() {
              Text('queryLocation').fontSize(20).fontWeight(FontWeight.Bold)
            }
            .type(ButtonType.Capsule)
            .margin({ top: 30 })
            .backgroundColor('#0D9FFB')
            .width('45%')
            .height('5%')
            .onClick(() => {
              try {
                let option: sceneMap.LocationQueryOptions = {
                  name: 'Beihai Park',
                  location: {
                    latitude: 39.925653,
                    longitude: 116.389264
                  },
                  address: 'No. 1, Wenjin Street, Xian Gate, Xicheng District, Beijing, China',
                  language: 'zh'
                };
                sceneMap.queryLocation(this.getUIContext().getHostContext() as common.UIAbilityContext, option)
                  .then(() => {
                    console.info(this.TAG, "queryLocation success:");
                  })
                  .catch((err: BusinessError) => {
                    console.error(this.TAG, "queryLocation fail err=" + JSON.stringify(err));
                  });
              } catch (err) {
                console.error(this.TAG, "queryLocation fail err=" + JSON.stringify(err));
              }
            })

            Button() {
              Text('chooseLocation').fontSize(20).fontWeight(FontWeight.Bold)
            }
            .type(ButtonType.Capsule)
            .margin({ top: 30, left: 12 })
            .backgroundColor('#0D9FFB')
            .width('45%')
            .height('5%')
            .onClick(() => {
              let option: sceneMap.LocationChoosingOptions =
                { searchEnabled: true, showNearbyPoi: true, snapshotEnabled: true };
              sceneMap.chooseLocation(this.getUIContext().getHostContext() as common.UIAbilityContext, option)
                .then(() => {
                  console.info(this.TAG, "chooseLocation success:");
                })
                .catch((err: BusinessError) => {
                  console.error(this.TAG, "chooseLocation fail err=" + JSON.stringify(err));
                });
            })
          }

        }.width('100%')

        Column({ space: 12 }) {
          Button() {
            Text('TextSearch').fontSize(14).fontWeight(FontWeight.Bold)
          }
          .type(ButtonType.Capsule)
          .backgroundColor('#0D9FFB')
          .width('100%')
          .height(30)
          .onClick(async () => {
            try {
              const rsp = await site.searchByText({
                query: 'Nanjing Museum',
                radius: 50,
                pageIndex: 1,
                pageSize: 5
              });
              if (rsp != undefined && rsp.sites != undefined) {
                this.setTipText(formatSites(rsp.sites));
              }
            } catch (error) {
              console.error(this.TAG, "query error = " + JSON.stringify(error));
              this.setTipText("query error = " + JSON.stringify(error));
            }
          })

          Button() {
            Text('DetailSearch').fontSize(14).fontWeight(FontWeight.Bold)
          }
          .type(ButtonType.Capsule)
          .backgroundColor('#0D9FFB')
          .width('100%')
          .height(30)
          .onClick(async () => {
            try {
              const rsp = await site.searchById({ siteId: '775911119489757696' });
              if (!rsp || !rsp.site) {
                this.setTipText("Result is Empty!");
                return;
              }
              this.setTipText(formatSites([rsp.site]));
            } catch (error) {
              console.error(this.TAG, "query error = " + JSON.stringify(error));
              this.setTipText("query error = " + JSON.stringify(error));
            }
          })

          Button() {
            Text('NearbySearch').fontSize(14).fontWeight(FontWeight.Bold)
          }
          .type(ButtonType.Capsule)
          .backgroundColor('#0D9FFB')
          .width('100%')
          .height(30)
          .onClick(async () => {
            try {
              const rsp = await site.nearbySearch({
                location: {
                  latitude: 32.040802206278556,
                  longitude: 118.82506327354875
                },
                pageIndex: 1,
                pageSize: 5
              });

              if (rsp != undefined && rsp.sites != undefined) {
                this.setTipText(formatSites(rsp.sites));
              }
            } catch (error) {
              console.error(this.TAG, "query error = " + JSON.stringify(error));
              this.setTipText("query error = " + JSON.stringify(error));
            }
          })

          Button() {
            Text('AutoComplete').fontSize(14).fontWeight(FontWeight.Bold)
          }
          .type(ButtonType.Capsule)
          .backgroundColor('#0D9FFB')
          .width('100%')
          .height(30)
          .onClick(async () => {
            try {
              const rsp = await site.queryAutoComplete({
                query: 'Nanjing Museum',
                radius: 1000,
                location: {
                  latitude: 32.040802206278556,
                  longitude: 118.82506327354875
                }
              });
              if (rsp != undefined && rsp.sites != undefined) {
                this.setTipText(formatSites(rsp.sites));
              }
            } catch (error) {
              console.error(this.TAG, "query error = " + JSON.stringify(error));
              this.setTipText("query error = " + JSON.stringify(error));
            }
          })

          Button() {
            Text('reverseGeocode').fontSize(14).fontWeight(FontWeight.Bold)
          }
          .type(ButtonType.Capsule)
          .backgroundColor('#0D9FFB')
          .width('100%')
          .height(30)
          .onClick(async () => {
            try {
              const rsp = await site.reverseGeocode({
                location: {
                  latitude: 32.040802206278556,
                  longitude: 118.82506327354875
                }
              });
              this.setTipText(JSON.stringify(rsp));
            } catch (error) {
              console.error(this.TAG, "query error = " + JSON.stringify(error));
              this.setTipText("query error = " + JSON.stringify(error));
            }
          })

          if (deviceInfo.deviceType === "2in1") {
            Button() {
              Text("goBack").fontSize(14).fontWeight(FontWeight.Bold)
            }
            .type(ButtonType.Capsule)
            .backgroundColor('#0D9FFB')
            .width('100%')
            .height(30)
            .onClick(async () => {
              this.pathStack.clear();
            })
          }

        }
        .margin({
          left: 12,
          top: 12
        })
        .width('40%')

        Row() {
          Text(this.tipText)
            .width('100%')
            .fontWeight(FontWeight.Bold)
            .fontSize(10)
            .fontColor(Color.White)
            .textAlign(TextAlign.Center)
            .margin({
              left: 1,
              top: 10,
              right: 1,
              bottom: 10
            })
        }
        .align(Alignment.Center)
        .margin({
          left: 1,
          top: 20,
          right: 1,
          bottom: 20
        })
        .visibility(!(this.tipText === undefined
          || this.tipText === null
          || this.tipText.length === 0) ? Visibility.Visible : Visibility.Hidden)
        .backgroundColor('#99302e2e')
        .borderRadius(15);
      }.height('100%')
      .alignContent(Alignment.TopStart)
    }.title('AdvancedControls')
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

export function formatSites(sites: Array<site.Site>) {
  let string = "success\n";
  let site = sites[0];
  if (site) {
    string += `[0] ${JSON.stringify(site)}\n`;
  }
  return string;
}