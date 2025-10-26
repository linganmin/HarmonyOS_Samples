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

import { selectImagesFromAlbum } from '../utils/FileUtil';
import { CommonConstants } from '../constants/CommonConstants';
import { LengthMetrics } from '@kit.ArkUI';
import Logger from '../utils/Logger';

const TAG = 'PictureListView';

@ComponentV2
export struct PictureListView {
  @Local uris: ResourceStr[] = [];

  @Computed
  get createText() {
    return this.uris.length === 0 ? $r('app.string.add_high_img') : $r('app.string.continue_add');
  }

  @Computed
  get maxNumber() {
    return CommonConstants.PICTURE_MAX_NUMBER - this.uris.length;
  }

  onCreate() {
    if (this.maxNumber <= 0) {
      try {
        this.getUIContext().getPromptAction().showToast({
          message: $r('app.string.add_picture_prompt')
        });
      } catch (e) {
        Logger.error(TAG, `Failed to show toadst: ${e.message}`);
      }
      return;
    }
    selectImagesFromAlbum(this.maxNumber).then((uris: ResourceStr[]) => {
      this.uris = [...this.uris, ...uris];
    });
  }

  onDelete(index: number) {
    this.uris.splice(index, 1);
  }

  @Builder
  createView() {
    Column() {
      Image($r('app.media.ic_public_list_add_transparent'))
        .objectFit(ImageFit.Cover)
        .width(36)
        .height(36)
      Text(this.createText)
        .fontSize(12)
        .fontColor('#A2A6AC')
    }
    .justifyContent(FlexAlign.Center)
    .borderStyle(BorderStyle.Dashed)
    .borderWidth(1)
    .borderColor('#CCCCCC')
    .borderRadius(10)
    .width(96)
    .height(96)
    .onClick(() => {
      this.onCreate();
    })
  }

  @Builder
  itemView(uri: ResourceStr, index: number) {
    Column() {
      Image(uri)
        .width('100%')
        .height('100%')
      SymbolGlyph($r('sys.symbol.xmark'))
        .fontColor([Color.White])
        .fontSize(12)
        .padding(4)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .borderRadius('50%')
        .position({
          right: 2,
          top: 2
        })
        .onClick(() => {
          this.onDelete(index);
        })
    }
    .width(96)
    .height(96)
    .borderRadius(10)
  }

  build() {
    Flex({
      wrap: FlexWrap.Wrap,
      space: {
        main: LengthMetrics.vp(8),
        cross: LengthMetrics.vp(8)
      }
    }) {
      ForEach(this.uris, (uri: ResourceStr, index: number) => {
        this.itemView(uri, index)
      }, (uri: ResourceStr, index: number) => JSON.stringify(uri) + index)
      if (this.maxNumber) {
        this.createView()
      }
    }
    .width('100%')
    .padding({
      right: 16,
      left: 16
    })
  }
}