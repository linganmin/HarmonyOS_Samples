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
import { GlobalBuilderContext } from '../common/GlobalBuilderContext';
// [Start example]
@Entry
@Component
struct Index {
  // [StartExclude example]
  @StorageProp('topRectHeight')
  topRectHeight: number = 0;
  private readonly LIST_SPACE: number = 12;
  private navDestinationData: NavDestinationItem[] = Constants.NavDestinationData;
  private pageInfos: NavPathStack = new NavPathStack();
  @State switch: boolean = false;
  private typeStr: string = "type1";

  @Builder
  PagesMap(id: string) {
    if (GlobalBuilderContext.getContext().getObject(id)) {
      (GlobalBuilderContext.getContext().getObject(id) as WrappedBuilder<[string]>).builder(id);
    }
  }
  // [EndExclude example]

  build() {
    Column() {
      // [StartExclude example]
      Navigation(this.pageInfos) {
        List({ space: this.LIST_SPACE }) {
          ForEach(this.navDestinationData, (item: NavDestinationItem) => {
            ListItem() {
              Button(item.detail)
                .width(Constants.LAYOUT_MAX)
                .height(40)
                .borderRadius(20)
                .fontSize(16)
                .fontColor(Color.White)
                .fontWeight(500)
                .onClick(() => {
                  this.pageInfos.pushPathByName(item.id, '');
                })
            }
          }, (item: NavDestinationItem) => JSON.stringify(item))
        }
        .scrollBar(BarState.Off)
        .width('90%')
        .height('40%')
        .margin({ top: 432 })
      }
      .mode(NavigationMode.Stack)
      .title({
        builder: this.mainPageTitle(),
        height: 112
      })
      .navDestination(this.PagesMap)
      // [EndExclude example]
      if (this.switch) {
        // 3.layout the component and set reuse id
        ReusableComponent({ text: this.typeStr })
          .reuseId(this.typeStr)
      }
    }
    // [StartExclude example]
    .height(Constants.LAYOUT_MAX)
    .width(Constants.LAYOUT_MAX)
    .backgroundColor('#F1F3F5')
    .padding({ top: this.getUIContext().px2vp(this.topRectHeight) })
    // [EndExclude example]
  }

  // [StartExclude example]
  @Builder
  mainPageTitle() {
    Row() {
      Text($r('app.string.EntryAbility_label'))
        .fontSize(30)
        .lineHeight(40)
        .fontWeight(700)
        .fontColor('#E6000000')
    }
    .width(Constants.LAYOUT_MAX)
    .height(Constants.LAYOUT_MAX)
    .padding({
      left: 16,
      top: 64,
      bottom: 8
    })
  }
  // [EndExclude example]
}

// 1.add @Reusable to mark component
@Reusable
@Component
struct ReusableComponent {
  @State text: string = ''

  // 2.update data in aboutToReuse
  aboutToReuse(params: Record<string, Object>): void {
    this.text = params.text as string;
  }

  build() {
    // [StartExclude example]
    Row() {
      Text(this.text)
        .fontSize(20)
        .margin({ left: 10 })
    }.margin({ left: 10, right: 10 })
    // [EndExclude example]
  }
}
// [End example]

export interface NavDestinationItem {
  id: string,
  detail: Resource
}
