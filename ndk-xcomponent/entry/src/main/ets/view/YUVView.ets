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

import { fileIo } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { CommonConstant as Common }  from '../common/CommonConstant';

const TAG: string = 'YUVView';

@Component
export struct YUVView {
  @State isClick: boolean = true;
  private xComponentContext: Record<string, () => void> = {};

  aboutToAppear(): void {
    this.writeYUVFile();
  }

  build() {
    Column() {
      Column() {
        XComponent({
          id: Common.YUV_XCOMPONENT_ID,
          type: XComponentType.TEXTURE,
          libraryname: Common.LIBRARY_NAME
        })
          .onLoad((xComponentContext?: object | Record<string, () => void>) => {
            if (xComponentContext) {
              this.xComponentContext = xComponentContext as Record<string, () => void>;
            }
          })
          .width($r('app.float.xcomponent_width'))
          .aspectRatio(1)
          .borderRadius($r('app.float.xcomponent_border_radius'))
          .backgroundColor(Color.White)
      }

      Row() {
        Button($r('app.string.load_yuv'))
          .fontSize($r('app.float.button_font_size'))
          .fontWeight(Common.FONT_WEIGHT_500)
          .onClick(() => {
            if (this.xComponentContext) {
              this.xComponentContext.loadYuv();
              this.isClick = false;
            }
          })
          .width(Common.BUTTON_WIDTH)
          .height($r('app.float.button_height'))
          .margin({
            bottom: $r('app.float.button_margin_bottom')
          })
          .backgroundColor(this.isClick ? $r('app.color.button_clickable') : $r('app.color.button_unclickable'))
          .stateEffect(this.isClick)
      }
      .width(Common.FULL_PERCENT)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Bottom)
      .layoutWeight(1)
    }
    .width(Common.FULL_PERCENT)
    .height(Common.FULL_PERCENT)
  }

  async writeYUVFile() {
    try {
      // Write the yuv file to the sandbox path.
      const resourceManager = this.getUIContext().getHostContext()!.resourceManager;
      const imageArray = await resourceManager.getMediaContent($r('app.media.ic_picture').id);
      let path: string = this.getUIContext().getHostContext()!.filesDir + '/image.yuv';
      let file = fileIo.openSync(path, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
      fileIo.write(file.fd, imageArray.buffer).then(() => {
        fileIo.closeSync(file);
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, TAG, `write data to file failed with error message: ${err.message}, code: ${err.code}`);
      });
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, TAG, `writeYUVFile failed. error code=${err.code}, message=${err.message}`);
    }
  }
}