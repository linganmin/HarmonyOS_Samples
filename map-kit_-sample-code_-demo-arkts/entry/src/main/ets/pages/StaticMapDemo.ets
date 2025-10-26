/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2023. All rights reserved.
 */

import { staticMap } from '@kit.MapKit';
import { deviceInfo } from '@kit.BasicServicesKit';

@Builder
export function StaticMapDemoBuilder() {
  StaticMapDemo();
}

@Entry
@Component
struct StaticMapDemo {
  pathStack: NavPathStack = new NavPathStack();
  private TAG = "OHMapSDK_StaticMapDemo";
  @State image?: PixelMap = undefined;

  build() {
    NavDestination() {
      Stack() {
        Column() {
          Image(this.image)
            .width('95%')
            .height(350)
            .fitOriginalSize(false)
            .border({ width: 1 })
            .borderStyle(BorderStyle.Dashed)
            .objectFit(ImageFit.Contain)

          Row() {
            Button("getStaticMap")
              .fontSize(12)
              .margin({ left: 6 })
              .onClick(async () => {
                console.info(this.TAG, "getStaticMap before");

                try {
                  let option: staticMap.StaticMapOptions = {
                    location: {
                      latitude: 32,
                      longitude: 118
                    },
                    zoom: 10,
                    imageWidth: 512,
                    imageHeight: 512,
                    scale: 2
                  };

                  await staticMap.getMapImage(option).then((value) => {
                    this.image = value;
                    console.info(this.TAG, "getStaticMap success image=" + this.image);
                  });
                } catch (err) {
                  console.error(this.TAG, "getStaticMap fail err, error code:" + err.code + " message:" + err.message);
                }
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
        }.width('100%')
      }.height('100%')
    }.title('Static')
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
  }
}