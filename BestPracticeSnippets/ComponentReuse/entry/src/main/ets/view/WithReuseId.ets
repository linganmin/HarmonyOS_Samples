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
import { FriendMomentsData } from '../model/FriendMomentData'
// [Start opt_reuseId]

// [Start with_reuse_id]
@Entry
@Component
struct WithReuseId {
  // [StartExclude opt_reuseId]
  private momentData: FriendMomentsData = new FriendMomentsData(this.getUIContext().getHostContext());
  private readonly LIST_CACHE_COUNT: number = 5;
  private readonly LIST_SPACE: number = 18;

  aboutToAppear(): void {
    this.momentData.getFriendMomentFromRawFile();
  }
  // [EndExclude opt_reuseId]

  build() {
    Column() {
      List({ space: this.LIST_SPACE }) {
        LazyForEach(this.momentData, (moment: FriendMoment) => {
          ListItem() {
            OneMoment({ moment: moment })// ReusId is used to control component reuse
              .reuseId((moment.image !== '') ? 'withImage_id' : 'noImage_id')
          }
        }, (moment: FriendMoment) => moment.id)
      }
      // [StartExclude opt_reuseId]
      .cachedCount(this.LIST_CACHE_COUNT)
      .margin({ top: 8 })
      .width(Constants.LAYOUT_MAX)
      .height(Constants.LAYOUT_MAX)
      // [EndExclude opt_reuseId]
    }
  }
}

@Reusable
@Component
export struct OneMoment {
  @ObjectLink moment: FriendMoment;

  build() {
    Column() {
      // [StartExclude opt_reuseId]
      Text(this.moment.text)
        .width(Constants.LAYOUT_MAX)
        .fontSize(18)
        .fontWeight(500)
        .lineHeight(24)
        .opacity(0.6)
      // [EndExclude opt_reuseId]

      if (this.moment.image !== '') {
        Flex({ wrap: FlexWrap.Wrap }) {
          Image($r(this.moment.image))
            .width(Constants.LAYOUT_MAX)
            .height('27.5%')
            .borderRadius(16)
          Image($r(this.moment.image))
            .width(Constants.LAYOUT_MAX)
            .height('27.5%')
            .borderRadius(16)
            .margin({ top: 10 })
        }
        .width(Constants.LAYOUT_MAX)
        .margin({ top: 14 })
      }
    }
    // [StartExclude opt_reuseId]
    .justifyContent(FlexAlign.Start)
    .margin({
      left: 16,
      right: 16
    })
    // [EndExclude opt_reuseId]
  }
}
// [End opt_reuseId]
// [End with_reuse_id]

@Builder
function getWithReuseId(name: string): void {
  if (name === Constants.NAV_DESTINATION_ITEM_2) {
    NavDestination() {
      WithReuseId()
    }
    .title(title())
    .backgroundColor('#F1F3F5')
  }
}

@Builder
function title() {
  Text($r('app.string.pic_text_list'))
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

export const wrappedBuilderWithReuseId: WrappedBuilder<[string]> =
  wrapBuilder(getWithReuseId);

