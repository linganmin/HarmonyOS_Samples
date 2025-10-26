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
import { storageStatistics } from '@kit.CoreFileKit';
import { Constants } from '../constants/Constants';
import { SpaceInfo } from '../view/SpaceInfo';
import commonViewModel from '../viewmodel/CommonViewModel';
import Logger from '../utils/Logger';

@Component
export struct FileSpacePage {
  @State appSize: number = 0;
  @State cacheSize: number = 0;
  @State dataSize: number = 0;

  build() {
    NavDestination() {
      Column() {
        Column() {
          Stack() {
            DataPanel({
              values: [this.appSize, this.cacheSize, this.dataSize],
              max: this.appSize + this.cacheSize + this.dataSize,
              type: DataPanelType.Circle
            })
              .width($r('app.integer.data_panel_size'))
              .height($r('app.integer.data_panel_size'))
            Text($r('app.string.spatial_statistics'))
              .fontSize($r('app.integer.data_panel_text_size'))
          }

          Column() {
            SpaceInfo({ name: $r('app.string.app_data_size'), value: this.appSize })
            SpaceInfo({ name: $r('app.string.cache_file_size'), value: this.cacheSize })
            SpaceInfo({ name: $r('app.string.app_total_data_size'), value: this.dataSize })
          }
          .borderRadius($r('app.integer.comm_border_radius1'))
          .backgroundColor($r('app.color.white_background'))
          .padding({
            right: $r('app.integer.comm_padding_margin2'),
            left: $r('app.integer.comm_padding_margin2')
          })
        }

        Button($r('app.string.file_space_statistics'))
          .width(Constants.FULL_PERCENT)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            storageStatistics.getCurrentBundleStats().then((BundleStats: storageStatistics.BundleStats) => {
              Logger.info(`getCurrentBundleStats successfully: ${JSON.stringify(BundleStats)}`);
              this.appSize = BundleStats.appSize;
              this.cacheSize = BundleStats.cacheSize;
              this.dataSize = BundleStats.dataSize;
            }).catch((err: BusinessError) => {
              Logger.error(`getCurrentBundleStats failed with error: ${JSON.stringify(err)}`);
            });
          })
      }
      .height(Constants.FULL_PERCENT)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({
        bottom: $r('app.integer.comm_padding_margin3')
      })
      .margin({
        right: $r('app.integer.comm_padding_margin3'),
        left: $r('app.integer.comm_padding_margin3')
      })
    }
    .title(commonViewModel.getResourceString(this.getUIContext().getHostContext()!,
      $r('app.string.file_space_statistics')))
    .backgroundColor($r('app.color.comm_background1'))
  }
}