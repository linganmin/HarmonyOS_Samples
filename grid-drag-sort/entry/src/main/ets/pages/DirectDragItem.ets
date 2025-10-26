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
export struct DirectDragItem {
  @StorageProp('currentBreakpoint') curBp: string = 'sm';
  @State isFoldAble: boolean = false;
  @State foldStatus: number = 2;
  @State numbers: number[] = [];
  @State dragItem: number = -1;
  @State scaleItem: number = -1;
  @State item: number = -1;
  @State offsetX: number = 0;
  @State offsetY: number = 0;
  @State isEnglish: boolean = false;
  private dragRefOffSetX: number = 0;
  private dragRefOffSetY: number = 0;
  private FIX_VP_X: number = 92;
  private FIX_VP_Y: number = 84;

  aboutToAppear(): void {
    for (let i = 1; i <= 5; i++) {
      this.numbers.push(i);
    }
    try {
      this.isFoldAble = display.isFoldable();
      let foldStatus: display.FoldStatus = display.getFoldStatus();
      if (foldStatus === 2) {
        this.FIX_VP_X = 81;
      } else if (foldStatus === 1) {
        this.FIX_VP_X = 110;
      }
      if (this.isFoldAble) {
        this.foldStatus = foldStatus;
        let callback: Callback<number> = () => {
          let data: display.FoldStatus = display.getFoldStatus();
          this.foldStatus = data;
          if (this.foldStatus === 2) {
            this.FIX_VP_X = 81;
          } else if (this.foldStatus === 1) {
            this.FIX_VP_X = 110;
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
      hilog.error(0x0000, 'DirectDragItem',
        `getFoldStatus failed. code=${err.code}, message=${err.message}`);
    }
  }

  // [Start itemMove2_start]
  itemMove(index: number, newIndex: number): void {
    if (!this.isDraggable(newIndex)) {
      return;
    }
    let tmp = this.numbers.splice(index, 1);
    this.numbers.splice(newIndex, 0, tmp[0]);
  }

  down(index: number): void {
    if (!this.isDraggable(index + 5)) {
      return;
    }
    this.offsetY -= this.FIX_VP_Y;
    this.dragRefOffSetY += this.FIX_VP_Y;
    this.itemMove(index, index + 5)
  }

  up(index: number): void {
    if (this.curBp === 'md') {
      if (!this.isDraggable(index - 5)) {
        return;
      }
      this.offsetY += this.FIX_VP_Y;
      this.dragRefOffSetY -= this.FIX_VP_Y;
      this.itemMove(index, index - 5)
    } else {
      if (!this.isDraggable(index - 4)) {
        return;
      }
      this.offsetY += this.FIX_VP_Y;
      this.dragRefOffSetY -= this.FIX_VP_Y;
      this.itemMove(index, index - 4)
    }
  }

  left(index: number): void {
    if (!this.isDraggable(index - 1)) {
      return;
    }
    this.offsetX += this.FIX_VP_X;
    this.dragRefOffSetX -= this.FIX_VP_X;
    this.itemMove(index, index - 1)
  }

  right(index: number): void {
    if (!this.isDraggable(index + 1)) {
      return;
    }
    this.offsetX -= this.FIX_VP_X;
    this.dragRefOffSetX += this.FIX_VP_X;
    this.itemMove(index, index + 1)
  }

  lowerRight(index: number): void {
    if (!this.isDraggable(index + 3)) {
      return;
    }
    this.offsetX -= this.FIX_VP_X;
    this.dragRefOffSetX += this.FIX_VP_X;
    this.offsetY -= this.FIX_VP_Y;
    this.dragRefOffSetY += this.FIX_VP_Y;
    this.itemMove(index, index + 3);
  }

  upperRight(index: number): void {
    if (!this.isDraggable(index - 3)) {
      return;
    }
    this.offsetX -= this.FIX_VP_X;
    this.dragRefOffSetX += this.FIX_VP_X;
    this.offsetY += this.FIX_VP_Y;
    this.dragRefOffSetY -= this.FIX_VP_Y;
    this.itemMove(index, index - 3);
  }

  lowerLeft(index: number): void {
    if (!this.isDraggable(index + 3)) {
      return;
    }
    this.offsetX += this.FIX_VP_X;
    this.dragRefOffSetX -= this.FIX_VP_X;
    this.offsetY -= this.FIX_VP_Y;
    this.dragRefOffSetY += this.FIX_VP_Y;
    this.itemMove(index, index + 3);
  }

  upperLeft(index: number): void {
    if (!this.isDraggable(index - 3)) {
      return;
    }
    this.offsetX += this.FIX_VP_X;
    this.dragRefOffSetX -= this.FIX_VP_X;
    this.offsetY += this.FIX_VP_Y;
    this.dragRefOffSetY -= this.FIX_VP_Y;
    this.itemMove(index, index - 3);
  }

  isDraggable(index: number): boolean {
    return index >= 0;
  }
  // [End itemMove2_start]

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
        Column({ space: 5 }) {
          Row({ space: 12 }) {
            Button() {
              Text($r('app.string.equipment'))
                .fontColor(Color.White)
                .width('100%')
                .height('100%')
                .textAlign(TextAlign.Center)
            }
            .backgroundColor('#6e95ba')
            .height(36)
            .width(this.isEnglish ? 120 : 60)

            Button() {
              Text($r('app.string.space'))
                .fontColor(Color.White)
                .width('100%')
                .height('100%')
                .textAlign(TextAlign.Center)
            }
            .backgroundColor('#0A59F7')
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
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .margin({ top: -4 })

          // [Start GridItem2_start]
          Grid() {
            ForEach(this.numbers, (item: number) => {
              GridItem() {
                Column() {
                  Image($r(`app.media.space${item}`))
                    .width(44)
                    .height(44)
                    .draggable(false)
                  Image($r('app.media.space_bottom'))
                    .width(16)
                    .height(16)
                    .draggable(false)
                }
                .width('100%')
                .height(73)
                .justifyContent(FlexAlign.Center)
                .borderRadius(10)
                .backgroundColor('#F1F3F5')
                .animation({ curve: Curve.Sharp, duration: 300 })
              }
              .scale({ x: this.scaleItem === item ? 1.05 : 1, y: this.scaleItem === item ? 1.05 : 1 })
              .zIndex(this.dragItem === item ? 1 : 0)
              .translate(this.dragItem === item ? { x: this.offsetX, y: this.offsetY } : { x: 0, y: 0 })
              // [StartExclude GridItem2_start]
              // [Start gesture2_start]
              .gesture(
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
                      if (this.curBp === 'md') {
                        if (this.offsetX >= this.FIX_VP_X / 2 && (this.offsetY <= 50 && this.offsetY >= -50) &&
                          ![4].includes(index)) {
                          this.right(index);
                        } else if (this.offsetX <= -this.FIX_VP_X / 2 && (this.offsetY <= 50 && this.offsetY >= -50)) {
                          this.left(index);
                        }
                      } else {
                        if (this.offsetY >= this.FIX_VP_Y / 2 && (this.offsetX <= 44 && this.offsetX >= -44) &&
                          ![1, 2, 3, 4].includes(index)) {
                          this.down(index);
                        } else if (this.offsetY <= -this.FIX_VP_Y / 2 && (this.offsetX <= 44 && this.offsetX >= -44)) {
                          this.up(index);
                        } else if (this.offsetX >= this.FIX_VP_X / 2 && (this.offsetY <= 50 && this.offsetY >= -50) &&
                          ![3, 4].includes(index)) {
                          this.right(index);
                        } else if (this.offsetX <= -this.FIX_VP_Y / 2 && (this.offsetY <= 50 && this.offsetY >= -50) &&
                          ![4].includes(index)) {
                          this.left(index);
                        } else if (this.offsetX >= this.FIX_VP_X / 2 && this.offsetY >= this.FIX_VP_Y / 2) {
                          this.lowerRight(index);
                        } else if (this.offsetX >= this.FIX_VP_X / 2 && this.offsetY <= -this.FIX_VP_Y / 2) {
                          this.upperRight(index);
                        } else if (this.offsetX <= -this.FIX_VP_X / 2 && this.offsetY >= this.FIX_VP_Y / 2) {
                          this.lowerLeft(index);
                        } else if (this.offsetX <= -this.FIX_VP_X / 2 && this.offsetY <= -this.FIX_VP_Y / 2) {
                          this.upperLeft(index);
                        }
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
              // [End gesture2_start]
              // [EndExclude GridItem2_start]
            }, (item: number) => item.toString())
          }
          .width('100%')
          .editMode(true)
          .scrollBar(BarState.Off)
          .columnsTemplate(this.curBp === 'md' ? '1fr 1fr 1fr 1fr 1fr' : '1fr 1fr 1fr 1fr')
          .columnsGap(12)
          .rowsGap(12)
          .margin({ top: 5 })
          // [End GridItem2_start]
        }
        .width(this.curBp === 'md' ? '80%' : '100%')
        .height('100%')
        .padding({
          left: 16,
          right: 16,
          top: 12,
          bottom: 16
        })
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ bottom: 50 })
    }
    .title(this.NavDestinationTitle())
    .backButtonIcon($r('app.media.back2'))
    .backgroundImage($r('app.media.backgroundImage'))
    .backgroundImageSize({ width: '100%', height: '100%' })
  }
}