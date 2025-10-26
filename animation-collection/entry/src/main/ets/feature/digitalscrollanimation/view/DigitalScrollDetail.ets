/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { CommonConstants } from '../common/CommonConstants';

@Component
export struct DigitalScrollDetail {
  @State scrollYList: number[] = [];
  @Prop @Watch('onDataRefresh') isRefresh: boolean;
  private dataItem: number[] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
  private currentData: number[] = new Array(CommonConstants.NUMBER_LENGTH).fill(0);
  private preData: number[] = new Array(CommonConstants.NUMBER_LENGTH).fill(0);

  onDataRefresh() {
    if (this.isRefresh === false) {
      this.refreshData();
    }
  }

  refreshData() {
    const tempArr: number[] = [];
    for (let i = 0; i < CommonConstants.NUMBER_LENGTH; i++) {
      tempArr.push(Math.floor(Math.random() * 10));
    }
    this.currentData = tempArr;
    this.currentData.forEach((item: number, index: number) => {
      this.getUIContext().animateTo({
        duration: Math.abs(item - this.preData[index]) * CommonConstants.DURATION_TIME,
        curve: Curve.LinearOutSlowIn,
        onFinish: () => {
          this.preData = this.currentData;
          this.isRefresh = false;
        }
      }, () => {
        this.scrollYList[index] = -item * CommonConstants.ITEM_HEIGHT;
      });
    });
  }

  build() {
    Row() {
      ForEach(this.currentData, (_dataItem: number, index: number) => {
        if ((CommonConstants.NUMBER_LENGTH - index) % CommonConstants.MILLENNIAL_LENGTH === 0 && index !== 0) {
          Text($r('app.string.digital_scroll_animation_comma'))
            .fontColor($r('sys.color.ohos_id_color_palette9'))
        }

        Column() {
          ForEach(this.dataItem, (subItem: number) => {
            Text(subItem.toString())
              .fontColor(Color.Orange)
              .fontWeight(FontWeight.Bold)
              .height($r('app.string.max_size'))
              .textAlign(TextAlign.Center)
              .translate({
                x: CommonConstants.TEXT_TRANSLATE,
                y: this.scrollYList[index]
              })
          }, (item: number) => JSON.stringify(item))
        }
        .height(CommonConstants.ITEM_HEIGHT)
        .clip(true)
      }, (item: number) => JSON.stringify(item))
    }
  }
}