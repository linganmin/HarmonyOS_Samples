/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

import {
  DEVICE_PAGE,
  MONITOR_PAGE,
  SERVICE_PAGE,
  P2P_PAGE,
  STRING_MARGIN,
  STRING_PERCENT,
  NOTIFY_PAGE,
  SENSOR_PAGE,
  AUTH_PAGE
} from '../util/Constant';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct MainPage {
  @State pages: string[] = [AUTH_PAGE, DEVICE_PAGE, P2P_PAGE, MONITOR_PAGE, NOTIFY_PAGE, SENSOR_PAGE, SERVICE_PAGE];
  @State pageNames: string[] = ['Auth', 'Device', 'P2P', 'Monitor', 'Notify', 'Sensor', 'Service'];

  build() {
    Scroll() {
      Column() {
        ForEach(this.pages, (item: string, index: number | undefined) => {
          Button(this.pageNames[index as number], { type: ButtonType.Normal })
            .fontSize(STRING_MARGIN.BUTTON_FONT_SIZE)
            .width(STRING_PERCENT.NINETY_PERCENT)
            .height(STRING_PERCENT.TEN_PERCENT)
            .fontWeight(FontWeight.Medium)
            .backgroundColor($r("app.color.base_button_color"))
            .margin({ top: 25 })
            .onClick(() => {
              router.pushUrl({
                url: item
              })
            })
        }, (item: number) => JSON.stringify(item))
      }.width('100%')
    }
    .scrollable(ScrollDirection.Vertical)
  }
}