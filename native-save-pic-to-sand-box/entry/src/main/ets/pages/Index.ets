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
import { hilog } from '@kit.PerformanceAnalysisKit';
import { fileUri } from '@kit.CoreFileKit';
import testNapi from 'libentry.so';
import CommonConstants from '../constants/CommonContants';

@Entry
@Component
struct Index {
  @State internetSandBoxPath: string = "";
  @State rawfileSandBoxPath: string = "";
  // Get the file path of the application.
  private resMgr = this.getUIContext().getHostContext()!.resourceManager;
  private fileDir = this.getUIContext().getHostContext()!.filesDir + "/";
  // Picture name in rawfile.
  private rawfilePicPath: string = "IMG_4558.JPG";
  private internetPicUrl: string =
    "https://developer.huawei.com/allianceCmsResource/resource/HUAWEI_Developer_VUE/images/homeNew/next-pc.png";
  // The image name of the network image saved to the sandbox.
  private internetSandBoxFileName: string = "internet_image.png";

  build() {
    Column() {
      // Save web images to sandbox.
      Row() {
        Image(this.internetSandBoxPath)
          .margin({ right: $r('app.integer.common_margin_right') })
          .width(CommonConstants.FORTY_PARENT)
          .height($r('app.integer.image_height'))
          .borderRadius($r('app.integer.common_radius'))

        Column() {
          Column() {
            Text($r('app.string.txt_sandBox_path'))
              .fontSize($r('app.integer.font_size'))
              .opacity(CommonConstants.NINETY_PARENT_OPACITY)
              .alignSelf(ItemAlign.Start)
              .textAlign(TextAlign.Start)
              .align(Alignment.Start)
              .margin({ bottom: $r('app.integer.common_margin_bottom') })
            Text(this.internetSandBoxPath)
              .fontSize($r('app.integer.title_font_size'))
              .opacity(CommonConstants.SIXTY_PARENT_OPACITY)
              .align(Alignment.Start)
              .alignSelf(ItemAlign.Start)
              .wordBreak(WordBreak.BREAK_ALL)
          }
          .width(CommonConstants.FULL_PARENT)

          Button($r('app.string.tbn_InternetPicture'))
            .onClick(() => {
              /*
               * Obtain the path of downloaded network images saved in the sandbox through the Native exposed interface
               * saveImageOfInternetCallback interface.
               */
              testNapi.saveImageOfInternet(this.internetPicUrl, this.fileDir, this.internetSandBoxFileName,
                ((result: string) => {
                  if (result === undefined || result === '') {
                    this.getUIContext().showAlertDialog({
                      message: $r('app.string.internet_file_write_fail'),
                      alignment: DialogAlignment.Center
                    });
                    this.internetSandBoxPath = '';
                  } else {
                    this.internetSandBoxPath = fileUri.getUriFromPath(result);
                  }
                }))
            })
            .alignSelf(ItemAlign.Center)
            .width(CommonConstants.FULL_PARENT)
        }
        .layoutWeight(CommonConstants.LAYOUT_WEIGHT)
        .height($r('app.integer.image_height'))
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .border({
        width: $r('app.integer.border_width'),
        color: $r('app.color.border_color'),
        radius: $r('app.integer.common_radius'),
        style: BorderStyle.Solid
      })
      .padding($r('app.integer.common_padding'))
      .margin({ bottom: $r('app.integer.card_margin_bottom') })
      .width(CommonConstants.FULL_PARENT)

      Row() {
        Image(this.rawfileSandBoxPath)
          .margin({ right: $r('app.integer.common_margin_right') })
          .width(CommonConstants.FORTY_PARENT)
          .height($r('app.integer.image_height'))
          .borderRadius($r('app.integer.common_radius'))

        Column() {
          Column() {
            Text($r('app.string.txt_sandBox_path'))
              .fontSize($r('app.integer.font_size'))
              .opacity(CommonConstants.NINETY_PARENT_OPACITY)
              .alignSelf(ItemAlign.Start)
              .textAlign(TextAlign.Start)
              .align(Alignment.Start)
              .margin({ bottom: $r('app.integer.common_margin_bottom') })
            Text(this.rawfileSandBoxPath)
              .fontSize($r('app.integer.title_font_size'))
              .opacity(CommonConstants.SIXTY_PARENT_OPACITY)
              .align(Alignment.Start)
              .alignSelf(ItemAlign.Start)
              .wordBreak(WordBreak.BREAK_ALL)
          }
          .width(CommonConstants.FULL_PARENT)

          Button($r('app.string.tbn_RawFilePicture'))
            .onClick(() => {
              /*
              * Obtain the path where the image in rawfile is saved in the sandbox through the
              * saveImageOfRawfileCallback interface exposed by Native.
              */
              testNapi.saveImageOfRawfile(this.resMgr, this.rawfilePicPath, this.fileDir, ((result: string) => {
                if (result === undefined || result === '') {
                  this.getUIContext().showAlertDialog({
                    message: $r('app.string.rawfile_write_fail'),
                    alignment: DialogAlignment.Center
                  });
                  this.rawfileSandBoxPath = '';
                } else {
                  this.rawfileSandBoxPath = fileUri.getUriFromPath(result);
                }
              }))
            })
            .alignSelf(ItemAlign.Center)
            .width(CommonConstants.FULL_PARENT)
        }
        .layoutWeight(CommonConstants.LAYOUT_WEIGHT)
        .height($r('app.integer.image_height'))
        .justifyContent(FlexAlign.SpaceBetween)

      }
      .border({
        width: $r('app.integer.border_width'),
        color: $r('app.color.border_color'),
        radius: $r('app.integer.common_radius'),
        style: BorderStyle.Solid
      })
      .padding($r('app.integer.common_padding'))
      .width(CommonConstants.FULL_PARENT)
    }
    .width(CommonConstants.FULL_PARENT)
    .height(CommonConstants.FULL_PARENT)
    .padding($r('app.integer.card_common_padding'))
  }
}
