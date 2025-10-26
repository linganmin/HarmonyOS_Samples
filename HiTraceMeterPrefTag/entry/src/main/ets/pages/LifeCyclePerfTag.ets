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
import { ColorData, ColorModel } from '../model/ListDataSource';
import { ReusableComponent } from '../view/ReusableComponent';
import CommonConstants from '../common/CommonConstants'

@Component
export struct LifeCyclePerfTag {
  // Used for avoiding the status bar.
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @Consume('pageInfos') pageInfos: NavPathStack;
  @State title: string = this.getUIContext().getHostContext()!.resourceManager.getStringSync($r('app.string.LifeCyclePerfTag_Title'));
  private colorData: ColorData = new ColorData();

  aboutToAppear(): void {
    this.colorData.getColorData();
  }

  build() {
    NavDestination() {
      Column() {
        List({ space: CommonConstants.LIST_SPACE }) {
          LazyForEach(this.colorData, (ColorModel: ColorModel) => {
            ListItem() {
              // Component reuse.
              ReusableComponent({ color: ColorModel.color, text: ColorModel.text })
            }
          }, (color: ColorModel) => color.id)
        }
        .width(CommonConstants.FULL_PARENT)
        .height(CommonConstants.FULL_PARENT)
        .cachedCount(5)
        .margin({ top: 8 })
      }
      .width(CommonConstants.FULL_PARENT)
    }
    .padding({ top: this.topRectHeight })
    .backgroundColor($r('app.color.window_background_color'))
    .title(this.title)
  }
}

