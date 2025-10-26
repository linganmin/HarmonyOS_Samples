/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

import { LengthMetrics, window } from '@kit.ArkUI';
import { getBottom, getLeft, getRight, getTop } from './Constants';
import { photoType } from '../model/dataType';

@Component
export struct PhotoSideBar {
  @State localPadding: LocalizedPadding = { top: LengthMetrics.vp(0), start: LengthMetrics.vp(0) };
  @StorageLink('cutout') @Watch('cutoutChange') avoidAreas: window.AvoidAreaOptions | undefined = undefined;
  @StorageLink('windowHeight') windowHeight: number = 0;
  @StorageLink('windowWidth') windowWidth: number = 0;
  @State photoList: photoType[] = [
    new photoType($r('app.string.picture'), 1234),
    new photoType($r('app.string.video'), 12),
    new photoType($r('app.string.collect'), 7),
    new photoType($r('app.string.newAlbum'), 11),
    new photoType($r('app.string.avatar'), 223),
    new photoType($r('app.string.address'), 125),
    new photoType($r('app.string.category'), 234),
    new photoType($r('app.string.pictureType'), 22),
    new photoType($r('app.string.hidden'), 1),
  ];
  cutoutChange(): void {
    let topPX = getTop(this.avoidAreas);
    let rightPX = getRight(this.avoidAreas, this.windowWidth);
    let bottomPX = getBottom(this.avoidAreas, this.windowHeight);
    let leftPX = getLeft(this.avoidAreas);
    this.localPadding = {
      top: LengthMetrics.px(topPX),
      end: LengthMetrics.px(rightPX),
      bottom: LengthMetrics.px(bottomPX),
      start: LengthMetrics.px(leftPX)
    };
  }

  build() {
    Column() {
      Row() {
        Search({ placeholder: $r('app.string.placeholderText') })
          .backgroundColor($r('sys.color.white'))
          .focusable(false)
      }
      .width('100%')
      .height(56)

      List() {
        ListItem() {
          Row() {
            Image($r('app.media.ic_public_picture'))
              .width(24)
              .aspectRatio(1)
            Text($r('app.string.photo'))
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .opacity(0.9)
              .height(48)
              .margin({ left: 8 })
          }
          .width('100%')
          .padding({ left: 8 })
        }

        ListItem() {
          Row() {
            Image($r('app.media.ic_public_folder'))
              .width(24)
              .aspectRatio(1)
            Text($r('app.string.album'))
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .opacity(0.9)
              .height(48)
              .margin({ left: 8 })
              .fontColor('rgb(10,89,247)')
            Blank()
            Image($r('app.media.ic_public_arrow_down_0'))
              .width(24)
              .height(12)
              .rotate({ angle: 90 })
              .opacity(0.8)
          }
          .width('100%')
          .padding({ left: 8 })
          .backgroundColor('#19254ff7')
          .borderRadius(10)
        }

        ForEach(this.photoList, (item: photoType, index: number | undefined) => {
          ListItem() {
            Row() {
              Text(item.name)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .opacity(0.9)
                .height(48)
                .margin({ left: 8 })
              Blank()
              if (index === this.photoList.length - 1) {
                Image($r('app.media.ic_public_lock_filled'))
                  .width(24)
                  .aspectRatio(1)
              } else {
                Text(item.count.toString())
                  .fontSize(14)
                  .fontWeight(FontWeight.Regular)
              }
            }
            .width('100%')
            .padding({ left: 16, right: 24 })
          }
        })
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .margin({ top: 16 })
      .padding({ bottom: AppStorage.get<number>('naviIndicatorHeight') as number + 48 })
    }
    .height('100%')
    .width('100%')
    .padding({ left: 12 + this.getUIContext().px2vp(getLeft(this.avoidAreas)), right: 12 })
  }
}