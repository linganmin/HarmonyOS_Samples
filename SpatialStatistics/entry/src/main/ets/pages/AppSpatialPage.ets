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

import { fileIo as fs, ReadOptions, statfs } from '@kit.CoreFileKit';
import { buffer } from '@kit.ArkTS';
import { Constants } from '../constants/Constants';
import { SpaceInfo } from '../view/SpaceInfo';
import commonViewModel from '../viewmodel/CommonViewModel';
import Logger from '../utils/Logger';

@Component
export struct AppSpacePage {
  @State freeSize: number = 0;
  @State totalSize: number = 0;
  private context = this.getUIContext().getHostContext()!;
  private path = this.context.filesDir;

  aboutToAppear(): void {
    this.createCacheFile();
  }

  createCacheFile(): void {
    try {
      let filePath = this.context.cacheDir + Constants.FILE_PATH_NAME;
      let file = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      let writeLen = fs.writeSync(file.fd, Constants.WRITE_CONTENT);
      Logger.info(`Write data to file succeed and size is: ${writeLen}`);
      // Reads a piece of content from a file.
      let arrayBuffer = new ArrayBuffer(4096);
      let readOptions: ReadOptions = {
        offset: 0,
        length: arrayBuffer.byteLength
      };
      let readLen = fs.readSync(file.fd, arrayBuffer, readOptions);
      let buf = buffer.from(arrayBuffer, 0, readLen);
      Logger.info(`The content of file: ${buf.toString()}`);
      fs.closeSync(file);
    } catch (err) {
      Logger.error(`CreateCacheFile failed . Cause code: ${err.code}, message: ${err.message}`);
    }
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          Stack() {
            DataPanel({
              values: [this.freeSize, this.totalSize],
              max: this.freeSize + this.totalSize,
              type: DataPanelType.Circle
            })
              .width($r('app.integer.data_panel_size'))
              .height($r('app.integer.data_panel_size'))
            Text($r('app.string.spatial_statistics'))
              .fontSize($r('app.integer.data_panel_text_size'))
          }

          Column() {
            SpaceInfo({ name: $r('app.string.free_bytes'), value: this.freeSize })
            SpaceInfo({ name: $r('app.string.total_bytes'), value: this.totalSize })
          }
          .borderRadius($r('app.integer.comm_border_radius1'))
          .backgroundColor($r('app.color.white_background'))
          .padding({
            right: $r('app.integer.comm_padding_margin2'),
            left: $r('app.integer.comm_padding_margin2')
          })
        }

        Button($r('app.string.app_space_statistics'))
          .width(Constants.FULL_PERCENT)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            try {
              this.freeSize = statfs.getFreeSizeSync(this.path);
              this.totalSize = statfs.getTotalSizeSync(this.path);
            } catch (err) {
              Logger.error(`getFreeSizeSync and getTotalSizeSync failed . Cause code: ${err.code}, message: ${err.message}`);
            }
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
    .title(commonViewModel.getResourceString(this.context, $r('app.string.app_space_statistics')))
    .backgroundColor($r('app.color.comm_background1'))
  }
}