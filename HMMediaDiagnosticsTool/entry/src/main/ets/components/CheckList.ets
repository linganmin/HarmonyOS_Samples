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

import { Option } from '../common/store/Score';
import { AppStore } from '../common/store/AppStore';
import { setBorder } from '../common/utils/ListBorder';

@Component
export struct CheckList {
  @Prop checkList: Array<Option> = [];
  @Link currentOptionIndex: number | null;
  private timeStamp = Date.now();

  build() {
    Column() {
      ForEach(this.checkList, (item: Option, index: number) => {
        Row() {
          Radio({ value: item.text, group: 'radioGroup' + this.timeStamp, indicatorType: RadioIndicatorType.TICK })
            .width(20)
            .height(20)
            .checked(this.currentOptionIndex === index)
            .margin({
              left: 2,
              right: 14
            })
            .onChange((isChecked: boolean) => {
              if (isChecked) {
                AppStore.getInstance().currentOptionIndex = index;
                this.currentOptionIndex = index;
              }
            });
          Text(item.text)
            .layoutWeight(1)
            .fontSize(14)
            .lineHeight(19)
            .fontColor($r('app.color.text'))
            .opacity(0.9)
            .textAlign(TextAlign.Start);
        }
        .width('100%')
        .padding({
          top: 12,
          bottom: 12
        })
        .border(setBorder(index, this.checkList.length - 1))
        .onClick(() => {
          AppStore.getInstance().currentOptionIndex = index;
          this.currentOptionIndex = index;
        });
      }, (item: Option) => item.text.toString());
    }
    .padding(8)
    .width('100%')
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_list_card'));
  }
}