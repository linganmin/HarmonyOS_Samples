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

import { curves, display } from '@kit.ArkUI';
import { i18n } from '@kit.LocalizationKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Component
export struct DifferentItemDrag {
  @StorageProp('currentBreakpoint') curBp: string = 'sm';
  @State isFoldAble: boolean = false;
  @State foldStatus: number = 2;
  @State numbers: number[] = [];
  @State dragItem: number = -1;
  @State scaleItem: number = -1;
  @State rotateZ: number = 0;
  @State offsetX: number = 0;
  @State offsetY: number = 0;
  @State isEnglish: boolean = false;
  private dragRefOffSetX: number = 0;
  private dragRefOffSetY: number = 0;
  private FIX_VP_X: number = 180;
  private FIX_VP_Y: number = 84;
  private bigItemIndex: number = 0;

  aboutToAppear(): void {
    for (let i = 0; i < 19; i++) {
      this.numbers.push(i);
    }
    try {
      this.isFoldAble = display.isFoldable();
      let foldStatus: display.FoldStatus = display.getFoldStatus();
      if (foldStatus === 2) {
        this.FIX_VP_X = 162;
      } else if (foldStatus === 1) {
        this.FIX_VP_X = 227;
      }
      if (this.isFoldAble) {
        this.foldStatus = foldStatus;
        let callback: Callback<number> = () => {
          let data: display.FoldStatus = display.getFoldStatus();
          this.foldStatus = data;
          if (this.foldStatus === 2) {
            this.FIX_VP_X = 162;
          } else if (this.foldStatus === 1) {
            this.FIX_VP_X = 227;
          }
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

  // [Start itemMove_start]
  itemMove(index: number, newIndex: number): void {
    if (!this.isDraggable(newIndex)) {
      return;
    }
    let tmp = this.numbers.splice(index, 1);
    this.numbers.splice(newIndex, 0, tmp[0]);
    this.bigItemIndex = this.numbers.findIndex((item) => item === 0);
  }

  isInLeft(index: number) {
    if (index === this.bigItemIndex) {
      return index % 2 == 0;
    }
    if (this.bigItemIndex % 2 === 0) {
      if (index - this.bigItemIndex === 2 || index - this.bigItemIndex === 1) {
        return false;
      }
    } else {
      if (index - this.bigItemIndex === 1) {
        return false;
      }
    }
    if (index > this.bigItemIndex) {
      return index % 2 == 1;
    } else {
      return index % 2 == 0;
    }
  }

  down(index: number): void {
    if ([this.numbers.length - 1, this.numbers.length - 2].includes(index)) {
      return;
    }
    if (this.bigItemIndex - index === 1) {
      return;
    }
    if ([14, 15].includes(this.bigItemIndex) && this.bigItemIndex === index) {
      return;
    }
    this.offsetY -= this.FIX_VP_Y;
    this.dragRefOffSetY += this.FIX_VP_Y;
    if (index - 1 === this.bigItemIndex) {
      this.itemMove(index, index + 1);
    } else {
      this.itemMove(index, index + 2);
    }
  }

  up(index: number): void {
    if (!this.isDraggable(index - 2)) {
      return;
    }
    if (index - this.bigItemIndex === 3) {
      return;
    }
    this.offsetY += this.FIX_VP_Y;
    this.dragRefOffSetY -= this.FIX_VP_Y;
    if (this.bigItemIndex === index) {
      this.itemMove(index, index - 2);
    } else {
      if (index - 2 === this.bigItemIndex) {
        this.itemMove(index, index - 1);
      } else {
        this.itemMove(index, index - 2);
      }
    }
  }

  left(index: number): void {
    if (this.bigItemIndex % 2 === 0) {
      if (index - this.bigItemIndex === 2) {
        return;
      }
    }
    if (this.isInLeft(index)) {
      return;
    }
    if (!this.isDraggable(index - 1)) {
      return;
    }
    this.offsetX += this.FIX_VP_X;
    this.dragRefOffSetX -= this.FIX_VP_X;
    this.itemMove(index, index - 1)
  }

  right(index: number): void {
    if (this.bigItemIndex % 2 === 1) {
      if (index - this.bigItemIndex === 1) {
        return;
      }
    }
    if (!this.isInLeft(index)) {
      return;
    }
    if (!this.isDraggable(index + 1)) {
      return;
    }
    this.offsetX -= this.FIX_VP_X;
    this.dragRefOffSetX += this.FIX_VP_X;
    this.itemMove(index, index + 1)
  }

  isDraggable(index: number): boolean {
    return index >= 0;
  }
  // [End itemMove_start]

  isBigLeft() {
    if ([0, 2, 4, , 6, 8, 10, 12, 14, 16].includes(this.bigItemIndex)) {
      return true;
    }
    return false
  }

  getHeight(item: number) {
    if (item.toString() === '0') {
      return 158;
    } else {
      return 73;
    }
  }

  getRowEnd(item: number) {
    if (item.toString() === '0') {
      return 1;
    } else {
      return 0;
    }
  }

  changeImage(item: number): ResourceStr {
    if (this.curBp === 'md') {
      return item === 0 ? $r('app.media.device_big') : $r(`app.media.device${item % 3}`);
    }
    return item === 0 ? $r('app.media.Equipment_big') :
      this.isEnglish ? $r(`app.media.device${item % 3}_en`) : $r(`app.media.Equipment${item % 3}`)
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
        .fontColor(Color.White)
        .opacity(0.9)
    }
    .width('100%')
  }

  build() {
    NavDestination() {
      Column() {
        Row({ space: 12 }) {
          Button() {
            Text($r('app.string.equipment'))
              .fontColor(Color.White)
              .width('100%')
              .height('100%')
              .textAlign(TextAlign.Center)
          }
          .backgroundColor('#0A59F7')
          .height(36)
          .width(this.isEnglish ? 120 : 60)

          Button() {
            Text($r('app.string.space'))
              .fontColor(Color.White)
              .width('100%')
              .height('100%')
              .textAlign(TextAlign.Center)
          }
          .backgroundColor('#6e95ba')
          .height(36)
          .width(this.isEnglish ? 80 : 60)

          Button() {
            Text($r('app.string.mine'))
              .fontColor(Color.White)
              .width('100%')
              .height('100%')
              .textAlign(TextAlign.Center)
          }
          .backgroundColor('#6e95ba')
          .height(36)
          .width(this.isEnglish ? 80 : 60)
        }
        .padding({ left: 16, right: 16 })
        .width('100%')
        .height(56)
        .justifyContent(FlexAlign.Start)
        .margin({ top: -4 })

        Row() {
          // [Start GridItem_start]
          Grid() {
            ForEach(this.numbers, (item: number) => {
              GridItem() {
                Stack({ alignContent: Alignment.TopEnd }) {
                  Image(this.changeImage(item))
                    .width('100%')
                    .borderRadius(16)
                    .objectFit(this.curBp === 'md' ? ImageFit.Fill : ImageFit.Cover)
                    .draggable(false)
                    .animation({ curve: Curve.Sharp, duration: 300 })
                }
              }
              .rowStart(0)
              .rowEnd(this.getRowEnd(item))
              .scale({ x: this.scaleItem === item ? 1.02 : 1, y: this.scaleItem === item ? 1.02 : 1 })
              .zIndex(this.dragItem === item ? 1 : 0)
              .translate(this.dragItem === item ? { x: this.offsetX, y: this.offsetY } : { x: 0, y: 0 })
              .hitTestBehavior(this.isDraggable(this.numbers.indexOf(item)) ? HitTestMode.Default : HitTestMode.None)
              // [StartExclude GridItem_start]
              // [Start gesture_start]
              .gesture(
                GestureGroup(GestureMode.Sequence,
                  LongPressGesture({ repeat: true })
                    .onAction(() => {
                      this.getUIContext().animateTo({ curve: Curve.Friction, duration: 300 }, () => {
                        this.scaleItem = item;
                      })
                    })
                    .onActionEnd(() => {
                      this.getUIContext().animateTo({ curve: Curve.Friction, duration: 300 }, () => {
                        this.scaleItem = -1;
                      })
                    }),
                  PanGesture({ fingers: 1, direction: null, distance: 0 })
                    .onActionStart(() => {
                      this.dragItem = item;
                      this.dragRefOffSetX = 0;
                      this.dragRefOffSetY = 0;
                    })
                    .onActionUpdate((event: GestureEvent) => {
                      this.offsetX = event.offsetX - this.dragRefOffSetX;
                      this.offsetY = event.offsetY - this.dragRefOffSetY;
                      this.getUIContext().animateTo({ curve: curves.interpolatingSpring(0, 1, 400, 38) }, () => {
                        let index = this.numbers.indexOf(this.dragItem);
                        if (this.offsetY >= this.FIX_VP_Y / 2 && (this.offsetX <= 44 && this.offsetX >= -44)) {
                          this.down(index);
                        } else if (this.offsetY <= -this.FIX_VP_Y / 2 && (this.offsetX <= 44 && this.offsetX >= -44)) {
                          this.up(index);
                        } else if (this.offsetX >= this.FIX_VP_X / 2 && (this.offsetY <= 50 && this.offsetY >= -50)) {
                          this.right(index);
                        } else if (this.offsetX <= -this.FIX_VP_Y / 2 && (this.offsetY <= 50 && this.offsetY >= -50)) {
                          this.left(index);
                        }
                      })
                    })
                    .onActionEnd(() => {
                      this.getUIContext().animateTo({ curve: curves.interpolatingSpring(0, 1, 400, 38) }, () => {
                        this.dragItem = -1;
                      })
                      this.getUIContext().animateTo({ curve: curves.interpolatingSpring(14, 1, 170, 17), delay: 150 }, () => {
                        this.scaleItem = -1;
                      })
                    })
                )
                  .onCancel(() => {
                    this.getUIContext().animateTo({ curve: curves.interpolatingSpring(0, 1, 400, 38) }, () => {
                      this.dragItem = -1;
                    })
                    this.getUIContext().animateTo({ curve: curves.interpolatingSpring(14, 1, 170, 17), delay: 150 }, () => {
                      this.scaleItem = -1;
                    })
                  })
              )
              // [End gesture_start]
              // [EndExclude GridItem_start]
            }, (item: number) => item.toString())
          }
          .width('100%')
          .height('100%')
          .editMode(true)
          .scrollBar(BarState.Off)
          .columnsTemplate('1fr 1fr')
          .supportAnimation(true)
          .columnsGap(12)
          .rowsGap(12)
          .enableScrollInteraction(true)
          // [End GridItem_start]
        }
        .width('100%')
        .height('100%')
        .padding({
          left: 16,
          right: 16,
          bottom: this.isFoldAble && this.foldStatus === 1 ? 112 : 84
        })
      }
      .width(this.curBp === 'md' ? '67%' : '100%')
      .height('100%')
    }
    .title(this.NavDestinationTitle())
    .backButtonIcon($r('app.media.back2'))
    .backgroundImage($r('app.media.backgroundImage'))
    .backgroundImageSize({ width: '100%', height: '100%' })
    .backgroundImagePosition(Alignment.TopStart)
  }
}