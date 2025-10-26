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
import { display } from '@kit.ArkUI';
import { i18n } from '@kit.LocalizationKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Component
export struct SameItemDrag {
  @StorageProp('currentBreakpoint') curBp: string = 'sm';
  @State numbers: number[] = [];
  @State item: number = -1;
  @State imageNum: number = 0;
  @State isFoldAble: boolean = false;
  @State foldStatus: number = 2;
  @State isEnglish: boolean = false;

  aboutToAppear(): void {
    for (let i = 1; i <= 9; i++) {
      this.numbers.push(i);
    }
    try {
      this.isFoldAble = display.isFoldable();
      let foldStatus: display.FoldStatus = display.getFoldStatus();
      if (this.isFoldAble) {
        this.foldStatus = foldStatus;
        let callback: Callback<number> = () => {
          let data: display.FoldStatus = display.getFoldStatus();
          this.foldStatus = data;
        }
        display.on('change', callback);
      }
      let systemLanguage = i18n.System.getSystemLanguage();
      if (systemLanguage === 'en-Latn-US') {
        this.isEnglish = true;
      }
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'DifferentItemDrag',
        `getFoldStatus failed. code=${err.code}, message=${err.message}`);
    }
  }

  // [Start data_exchange_start]
  changeIndex(index1: number, index2: number) {
    let tmp = this.numbers.splice(index1, 1);
    this.numbers.splice(index2, 0, tmp[0])
  }
  // [End data_exchange_start]

  @Builder
  pixelMapBuilder() {
    Column() {
      Image($r(`app.media.image${this.imageNum}`))
        .height(this.curBp === 'md' ? 140 : 106)
        .width(this.curBp === 'md' ? 140 : 116)
        .draggable(false)
        .objectFit(ImageFit.Fill)
    }
    .zIndex(1)
    .scale({ x: 1.05, y: 1.05 })
    .translate({ x: 0, y: 0 })
  }

  @Builder
  NavDestinationTitle() {
    Column() {
      Text($r('app.string.details_page'))
        .fontSize(20)
        .lineHeight(42)
        .fontWeight(700)
        .width('100%')
        .padding({ left: 12 })
    }
    .width('100%')
  }

  build() {
    NavDestination() {
      Column() {
        Column({ space: this.curBp === 'md' ? 4 : 12 }) {
          Row() {
            Row({ space: 8 }) {
              Image($r('app.media.circle'))
                .objectFit(ImageFit.Cover)
                .draggable(false)
                .width(36)
                .height(36)
                .borderRadius(36)
              Image(this.isEnglish ? $r('app.media.detail_en') : $r('app.media.detail'))
                .objectFit(ImageFit.Cover)
                .draggable(false)
                .height(36)
            }

            Image(this.isEnglish ? $r('app.media.button_en') : $r('app.media.button'))
              .objectFit(ImageFit.Cover)
              .draggable(false)
              .height(28)
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .width('100%')
          .height(36)

          Text($r('app.string.text'))
            .width('100%')
            .fontSize(this.curBp === 'md' ? 18 : 16)
            .lineHeight(this.curBp === 'md' ? 26 : 24)
            .textAlign(TextAlign.JUSTIFY)

          // [Start developers_start]
          Grid() {
            ForEach(this.numbers, (item: number) => {
              GridItem() {
                Image($r(`app.media.image${item}`))
                  .width('100%')
                  .height(this.curBp === 'md' ? 131 : 105)
                  .draggable(false)
                  .animation({ curve: Curve.Sharp, duration: 300 })
              }
            }, (item: number) => item.toString())
          }
          .width(this.curBp === 'md' ? '66%' : '100%')
          .scrollBar(BarState.Off)
          .columnsTemplate('1fr 1fr 1fr')
          .columnsGap(this.curBp === 'md' ? 6 : 4)
          .rowsGap(this.curBp === 'md' ? 6 : 4)
          .height(this.curBp === 'md' ? 406 : 323)
          // [End developers_start]

          // [Start edit_grid_start]
          .editMode(true)
          .supportAnimation(true)
          // [End edit_grid_start]

          // [Start events_start]
          .onItemDragStart((_, itemIndex: number) => {
            this.imageNum = this.numbers[itemIndex];
            return this.pixelMapBuilder();
          })
          .onItemDrop((_, itemIndex: number, insertIndex: number, isSuccess: boolean) => {
            if (!isSuccess || insertIndex >= this.numbers.length) {
              return;
            }
            this.changeIndex(itemIndex, insertIndex);
          })
          // [End events_start]

        }
        .padding(this.curBp === 'md' ? {
          left: 24,
          right: 24,
          top: 8,
          bottom: 24
        } : {
          left: 16,
          right: 16,
          top: 4,
          bottom: 16
        })

        Row() {
          Image(this.isEnglish ? $r('app.media.component_en') :
            this.curBp === 'md' ? $r('app.media.bottom2') : $r('app.media.bottom_image'))
            .width('100%')
            .height(this.isFoldAble && this.foldStatus === 2 ? 35 : 40)
            .objectFit(ImageFit.Cover)
            .draggable(false)
            .padding(this.curBp === 'md' ? {
              left: 24,
              right: 24,
            } : {
              left: 16,
              right: 16,
            })
        }
        .border({
          width: {
            top: 1,
            bottom: 0,
            left: 0,
            right: 0
          },
          color: '#F1F3F5'
        })
        .width('100%')
        .padding({ top: 8 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.White)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ bottom: 8 })
    }
    .title(this.NavDestinationTitle())
  }
}