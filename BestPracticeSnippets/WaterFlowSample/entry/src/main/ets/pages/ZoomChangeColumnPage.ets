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

// [Start quick_start]
import { hilog } from '@kit.PerformanceAnalysisKit';
import { image } from '@kit.ImageKit';
import { CommonConstants } from '../common/constants/CommonConstants';
import { MyDataSource } from '../model/MyDataSource'

const TAG: string = 'StickOnTopPage';

// [StartExclude quick_start]
@Reusable
@Component
struct ReusableItem {
  @State item: number = 0;

  aboutToReuse(params: Record<string, number>): void {
    this.item = params.item;
    console.log('Reuse item: ' + this.item);
  }

  build() {
    Column() {
      Text('N ' + this.item)
        .fontSize(12)
        .height('16vp')
      Image($rawfile(`sections/${this.item % 4}.jpg`))
        .objectFit(ImageFit.Cover)
        .width('100%')
        .layoutWeight(1)
    }
  }
}

// [EndExclude quick_start]
@Entry
@Component
struct ZoomChangeColumnPage {
  // [StartExclude quick_start]
  @State minSize: number = 120
  @State maxSize: number = 210;
  @State fontSize: number = 24;
  @State colors: number[] = [0xFFC0CB, 0xDA70D6, 0x6B8E23, 0x6A5ACD, 0x00FFFF, 0x00FF7E];
  @State sections: WaterFlowSections = new WaterFlowSections();
  private data: MyDataSource = new MyDataSource();
  private itemWidthArray: number[] = [];
  private itemHeightArray: number[] = [];
  // [EndExclude quick_start]
  // 1、Variables required for scaling operations.
  @State itemScale: number = 1;
  @State imageScale: number = 1;
  @State itemOpacity: number = 1;
  @State gestureEnd: boolean = false;
  @State pixelMap: image.PixelMap | undefined = undefined;
  @State columns: number = 4;
  @StorageProp(CommonConstants.AS_KEY_STATUS_BAR_HEIGHT) statusBarHeight: number = 0;
  private pinchTime: number = 0;
  private columnChanged: boolean = false;
  private oldColumn: number = this.columns;

  // [StartExclude quick_start]
  getSize(): number {
    let ret: number = Math.floor(Math.random() * this.maxSize);
    return (ret > this.minSize ? ret : this.minSize);
  }

  setItemSizeArray(): void {
    for (let i: number = 0; i < 100; i++) {
      this.itemWidthArray.push(this.getSize());
      this.itemHeightArray.push(this.getSize());
    }
  }

  aboutToAppear(): void {
    for (let i: number = 0; i < 100; i++) {
      this.data.pushData(i);
    }
    let lastCount: number| undefined = AppStorage.get<number>('columnsCount');
    if (typeof lastCount != 'undefined') {
      this.columns = lastCount;
    }
    this.setItemSizeArray();
  }

  // [EndExclude quick_start]
  // 7、Adjust the number of columns according to the zoom ratio.
  changeColumns(scale: number): void {
    this.oldColumn = this.columns;
    if (scale > (this.columns / (this.columns - 0.5))) {
      this.columns--;
      this.columnChanged = true;
    } else if (scale < 1 && this.columns < 4) {
      this.columns++;
      this.columnChanged = true;
    }
    this.columns = Math.min(4, Math.max(1, this.columns));
  }

  build() {
    Column({ space: 2 }) {
      // [StartExclude quick_start]
      Row() {
        Text($r('app.string.zoom_change_column'))
          .width('100%')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .margin({ top: '18vp', left: '16vp', bottom: '16vp' })
      }

      // [EndExclude quick_start]
      Stack() {
        // 2、Display the current screen's snapshot when zooming.
        Image(this.pixelMap)
          .width('100%')
          .height('100%')
          .scale({
            x: this.imageScale,
            y: this.imageScale,
            centerX: 0,
            centerY: 0
          })
        WaterFlow() {
          // [StartExclude quick_start]
          LazyForEach(this.data, (item: number) => {
            FlowItem() {
              ReusableItem({ item: item })
            }
            .width('100%')
            .aspectRatio(this.itemHeightArray[item % 100] / this.itemWidthArray[item % 100])
            .backgroundColor(this.colors[item % 5])
          }, (item: number) => item.toString())
          // [EndExclude quick_start]
        }
        .id('waterflow')
        // 3、Dynamic adjustment of column numbers.
        .columnsTemplate('1fr '.repeat(this.columns))
        .backgroundColor(0xFAEEE0)
        .width('100%')
        .height('100%')
        .layoutWeight(1)
        // 4、WaterFlow's scaling information.
        .opacity(this.itemOpacity)
        .scale({
          x: this.itemScale,
          y: this.itemScale,
          centerX: 0,
          centerY: 0
        })
        .priorityGesture(
          PinchGesture()
            .onActionStart((event: GestureEvent) => {
              // 5、Initialise scaling parameters.
              this.gestureEnd = false;
              this.pinchTime = event.timestamp;
              this.columnChanged = false;
              this.getUIContext().getComponentSnapshot().get('waterflow', (error: Error, pixelMap: image.PixelMap) => {
                if (error) {
                  console.info('error: ' + error.message);
                  return;
                }
                this.pixelMap = pixelMap;
              })
            })
            .onActionUpdate((event: GestureEvent) => {
              // 6、Calculate the zoom ratio based on the finger swipe event and dynamically change the number of columns.
              // 6.1、Intercept duplicate gestures.
              if (event.timestamp - this.pinchTime < 10000000) {
                return;
              }
              this.pinchTime = event.timestamp;
              // 6.2、Calculate the scaling ratio.
              let maxScale: number = this.oldColumn / (this.oldColumn - 1);
              this.itemScale = event.scale > maxScale ? maxScale : event.scale;
              this.imageScale = event.scale > maxScale ? maxScale : event.scale;
              this.itemOpacity = (this.itemScale > 1) ? (this.itemScale - 1) : (1 - this.itemScale);
              this.itemOpacity *= 3;
              // 6.3、Dynamically adjust the number of columns.
              if (!this.columnChanged) {
                this.changeColumns(event.scale);
              }
              if (this.columnChanged) {
                this.itemScale = this.imageScale * this.columns / this.oldColumn;
                if (event.scale < 1) {
                  this.itemScale = this.itemScale > 1 ? this.itemScale : 1;
                } else {
                  this.itemScale = this.itemScale < 1 ? this.itemScale : 1;
                }
              }
            })
            .onActionEnd((event: GestureEvent) => {
              // 8、Reset the relevant scaling parameters and execute the scaling animation.
              this.gestureEnd = true;
              try {
                this.getUIContext().animateTo({ duration: 300 }, () => {
                  this.itemScale = 1;
                  this.itemOpacity = 1;
                });
              } catch (err) {
                hilog.error(0x0000, TAG, `animateTo get exception, error:${JSON.stringify(err)}.`);
              }
              AppStorage.setOrCreate<number>('columnsCount', this.columns);
            })
        )
      }
      .width('100%')
      .height('100%')
    }
    .padding({
      top: this.statusBarHeight
    })
  }
}

// [End quick_start]