/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { BusinessError } from '@kit.BasicServicesKit';
import { Constants } from '../constants/Constants';
import { AppSpacePage } from './AppSpatialPage';
import { FileSpacePage } from './FileSpacePage';
import Logger from '../utils/Logger';

@Entry
@Component
struct Index {
  private pageStack: NavPathStack = new NavPathStack();

  @Builder
  pageMap(pageName: string): void {
    if (pageName === Constants.APP_SPACE_PAGE) {
      AppSpacePage()
    } else if (pageName === Constants.FILE_SPACE_PAGE) {
      FileSpacePage()
    }
  }

  build() {
    Navigation(this.pageStack) {
      Column() {
        Button($r('app.string.app_space_statistics'))
          .width(Constants.FULL_PERCENT)
          .onClick(() => {
            this.pageStack.pushDestinationByName(Constants.APP_SPACE_PAGE, null, true).catch((err: BusinessError) => {
              Logger.error(`pushDestinationByName failed. Code: ${err.code}, message: ${err.message}`);
            });
          })
        Button($r('app.string.file_space_statistics'))
          .width(Constants.FULL_PERCENT)
          .margin({
            top: $r('app.integer.comm_padding_margin2')
          })
          .onClick(() => {
            this.pageStack.pushDestinationByName(Constants.FILE_SPACE_PAGE, null, true).catch((err: BusinessError) => {
              Logger.error(`pushDestinationByName failed. Code: ${err.code}, message: ${err.message}`);
            });
          })
      }
      .width(Constants.FULL_PERCENT)
      .height(Constants.FULL_PERCENT)
      .justifyContent(FlexAlign.End)
      .padding({
        right: $r('app.integer.comm_padding_margin3'),
        left: $r('app.integer.comm_padding_margin3'),
        bottom: $r('app.integer.comm_padding_margin3')
      })
    }
    .title($r('app.string.system_spatial_statistics'))
    .backgroundColor($r('app.color.comm_background1'))
    .navDestination(this.pageMap)
    .mode(NavigationMode.Stack)
    .hideToolBar(true)
  }
}