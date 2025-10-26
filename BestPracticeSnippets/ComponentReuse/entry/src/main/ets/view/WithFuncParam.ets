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

import { Constants } from '../common/Constants';
import { FriendMoment } from '../model/BasicDataSource';
import { FriendMomentsData } from '../model/FriendMomentData';
// [Start opt_funcParam]

// [Start with_func_param]
@Entry
@Component
struct WithFuncParam {
  @State sum: number = 0;
  // [StartExclude opt_funcParam]
  private momentData: FriendMomentsData =
    new FriendMomentsData(this.getUIContext().getHostContext(), Constants.NAV_DESTINATION_ITEM_3);
  private readonly LIST_CACHE_COUNT: number = 5;
  private readonly LIST_SPACE: number = 18;
  // [EndExclude opt_funcParam]
  private readonly MOCK_ASYNC_DEFAULT_NUM: number = 1000000;
  private readonly MOCK_ASYNC_TIME_OUT_NUM: number = 2000;

  aboutToAppear(): void {
    this.momentData.getFriendMomentFromRawFile();
    // Execute the asynchronous function
    this.countAndReturn();
  }

  async countAndReturn(): Promise<void> {
    await this.sleep();
    this.sum = this.MOCK_ASYNC_DEFAULT_NUM;
  }

  sleep(): Promise<string> {
    return new Promise<string>((resolve) => {
      setTimeout(() => {
        resolve('ok');
      }, this.MOCK_ASYNC_TIME_OUT_NUM)
    });
  }

  build() {
    Column() {
      List({ space: this.LIST_SPACE }) {
        LazyForEach(this.momentData, (moment: FriendMoment) => {
          ListItem() {
            // Parameters of subcomponents are transferred through status variables
            OneMoment({
              moment: moment,
              sum: this.sum
            })
          }
        }, (moment: FriendMoment) => moment.id)
      }
      // [StartExclude opt_funcParam]
      .cachedCount(this.LIST_CACHE_COUNT)
      .margin({ top: 8 })
      .width(Constants.LAYOUT_MAX)
      .height(Constants.LAYOUT_MAX)
      // [EndExclude opt_funcParam]
    }
  }
}

@Reusable
@Component
export struct OneMoment {
  @ObjectLink moment: FriendMoment;
  @State sum: number = 0;
  // [StartExclude opt_funcParam]
  private readonly LAST_ITEM_INDEX: number = 2;
  // [EndExclude opt_funcParam]

  aboutToReuse(params: Record<string, Object>): void {
    this.sum = params.sum as number;
  }

  // [StartExclude opt_funcParam]
  build() {
    Column() {
      Text(this.moment.text)
        .fontSize(18)
        .textAlign(TextAlign.Center)
        .fontWeight(500)
        .lineHeight(24)
        .fontColor(Color.Black)
        .opacity(0.6)
      Column() {
        this.item();
        this.item();
        this.item(this.LAST_ITEM_INDEX);
      }
      .borderRadius(16)
      .margin({ top: 14 })
      .padding({
        left: 12,
        right: 12,
        top: 13,
        bottom: 13
      })
      .backgroundColor(Color.White)
      .width(Constants.LAYOUT_MAX)
    }
    .alignItems(HorizontalAlign.Start)
    .margin({
      left: 16,
      right: 16
    })
  }

  @Builder
  item(index?: number) {
    Column() {
      Row() {
        Text(this.moment.userName)
          .fontSize(16)
          .fontWeight(500)
          .lineHeight(22)
          .textAlign(TextAlign.Start)
          .opacity(0.9)
        Text(`${this.moment.id}/${this.sum}`)
          .fontSize(14)
          .fontWeight(400)
          .lineHeight(19)
          .textAlign(TextAlign.End)
          .layoutWeight(1)
          .opacity(0.6)
      }
      .width(Constants.LAYOUT_MAX)
    }

    if (index !== this.LAST_ITEM_INDEX) {
      Row()
        .width(Constants.LAYOUT_MAX)
        .height(1)
        .backgroundColor(Color.Black)
        .margin({
          top: 12.5,
          bottom: 13
        })
        .opacity(0.1)
    }
  }
  // [EndExclude opt_funcParam]
}
// [End opt_funcParam]

// [Start with_func_param]
@Builder
function getWithFuncParam(name: string): void {
  if (name === Constants.NAV_DESTINATION_ITEM_3) {
    NavDestination() {
      WithFuncParam()
    }
    .title(title())
    .backgroundColor('#F1F3F5')
  }
}

@Builder
function title() {
  Text($r('app.string.net_name_message'))
    .fontSize(20)
    .fontColor($r('sys.color.font_primary'))
    .fontWeight(FontWeight.Bold)
    .margin({
      left: 8,
      top: 16
    })
    .maxLines(1)
    .textOverflow({ overflow: TextOverflow.Ellipsis })
    .lineHeight(24)
}

export const wrappedBuilderWithFuncParam: WrappedBuilder<[string]> =
  wrapBuilder(getWithFuncParam);