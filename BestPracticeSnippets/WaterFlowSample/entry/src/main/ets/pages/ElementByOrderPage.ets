/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { CommonConstants } from '../common/constants/CommonConstants';
// [Start quick_start]
@Entry
@Component
struct ElementByOrderPage {
  @State data1: string[] = ['1', '2', '3', '4', '5', '6'];
  @State colors: number[] = [0xFFC0CB, 0xDA70D6, 0x6B8E23, 0x6A5ACD, 0x00FFFF, 0x00FF7E];
  @StorageProp(CommonConstants.AS_KEY_STATUS_BAR_HEIGHT) statusBarHeight: number = 0;

  getHeight(item: string): number {
    if (item === '2' || item === '3' || item === '5') {
      return 25;
    }
    return 40;
  }

  build() {
    RelativeContainer() {
      ForEach(this.data1, (item: string) => {
        if (item === '1') {
          Text('item' + item +
          this.getUIContext().getHostContext()?.resourceManager.getStringSync($r('app.string.item_height').id) + ':' +
          this.getHeight(item).toString())
            .id('item' + item)
            .alignRules({
              top: { anchor: '__container__', align: VerticalAlign.Top },
              left: { anchor: '__container__', align: HorizontalAlign.Start },
            })
            .height(this.getHeight(item))
            .width('50%')
            .backgroundColor(this.colors[Number(item) - 1])
        } else if (item === '2') {
          Text('item' + item +
          this.getUIContext().getHostContext()?.resourceManager.getStringSync($r('app.string.item_height').id) + ':' +
          this.getHeight(item).toString())
            .id('item' + item)
            .alignRules({
              top: { anchor: '__container__', align: VerticalAlign.Top },
              right: { anchor: '__container__', align: HorizontalAlign.End }
            })
            .height(this.getHeight(item))
            .width('50%')
            .backgroundColor(this.colors[Number(item) - 1])
        } else {
          Text('item' + item +
          this.getUIContext().getHostContext()?.resourceManager.getStringSync($r('app.string.item_height').id) + ':' +
          this.getHeight(item).toString())
            .id('item' + item)
            .alignRules({
              top: { anchor: 'item' + (Number(item) - 2).toString(), align: VerticalAlign.Bottom },
              left: { anchor: 'item' + (Number(item) - 2).toString(), align: HorizontalAlign.Start },
            })
            .height(this.getHeight(item))
            .width('50%')
            .backgroundColor(this.colors[Number(item) - 1])
        }
      }, (item: string, index: number) => index.toString())
    }
    .padding({
      top: this.statusBarHeight
    })
  }
}
// [End quick_start]