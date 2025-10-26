/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
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

/*
* FAQ:手势卡顿或者不生效
 */

// [Start GestureStuttering]
import { AsyncCallback, BusinessError } from '@kit.BasicServicesKit';
import { map, mapCommon, MapComponent } from '@kit.MapKit';

class MyDataSource implements IDataSource {
  private list: number[] = [];

  constructor(list: number[]) {
    this.list = list;
  }

  totalCount(): number {
    return this.list.length;
  }

  getData(index: number): number {
    return this.list[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
  }
}

@Entry
@Component
struct SwiperExample {
  private swiperController: SwiperController = new SwiperController();
  private data: MyDataSource = new MyDataSource([]);
  private mapOptions?: mapCommon.MapOptions;
  private callback?: AsyncCallback<map.MapComponentController>;
  private mapController?: map.MapComponentController;
  private mapEventManager?: map.MapEventManager;
  @State mapPositionX: number = 0;
  @State mapPositionY: number = 0;
  @State mapHeight: number = 0;
  @State mapWidth: number = 0;
  @State index: number = 0;

  // Determine whether the coordinates are within the map rectangle
  isMap(event: TouchEvent) {
    if (event.changedTouches[0].displayX > this.mapPositionX
      && event.changedTouches[0].displayX < this.mapPositionX + this.mapWidth
      && event.changedTouches[0].displayY > this.mapPositionY
      && event.changedTouches[0].displayY < this.mapPositionY + this.mapHeight) {
      return true;
    }
    return false;
  }

  aboutToAppear(): void {
    let list: number[] = [];
    for (let i = 1; i <= 10; i++) {
      list.push(i);
    }
    this.data = new MyDataSource(list);

    this.mapOptions = {
      position: {
        target: {
          latitude: 31.98441025,
          longitude: 118.766253
        },
        zoom: 10,
        tilt: 10,
        bearing: 90
      },
      scaleControlsEnabled: true
    }

    this.callback = async (err, mapController) => {
      if (!err) {
        this.mapController = mapController;
        this.mapEventManager = this.mapController.getEventManager();
        let callback = () => {
          console.info(`on-mapLoad`);
        };
        this.mapEventManager.on("mapLoad", callback);
      }
    }
  }

  build() {
    Column({ space: 5 }) {
      Swiper(this.swiperController) {
        LazyForEach(this.data, (item: string) => {
          if (item == "3") {
            Column() {
              Text(item.toString())
                .width('90%')
                .height(160)
                .backgroundColor(0xAFEEEE)
                .textAlign(TextAlign.Center)
                .fontSize(30)
              MapComponent({ mapOptions: this.mapOptions, mapCallback: this.callback })
                // 获取MapComponent的位置和长宽
                .width('100%')
                .height('65%')
                .onAreaChange((_oldValue: Area, newValue: Area) => {
                  try {
                    if (newValue.globalPosition.x !== undefined && newValue.globalPosition.y !== undefined) {
                      this.mapPositionX = Number(newValue.globalPosition.x);
                      this.mapPositionY = Number(newValue.globalPosition.y);
                      this.mapHeight = Number(newValue.height);
                      this.mapWidth = Number(newValue.width);
                    }
                  } catch (error) {
                    let e: BusinessError = error as BusinessError;
                    console.log("onAreaChange error code:" + e.code + "message:" + e.message);
                  }
                })
            }.height("100%")
          } else {
            Text(item.toString())
              .width('90%')
              .height(160)
              .backgroundColor(0xAFEEEE)
              .textAlign(TextAlign.Center)
              .fontSize(30)
          }
        }, (item: string) => item)
      }
      // Gesture judgment: When the index indicates the existence of a map page and the click is within the map rectangle,
      // it is HitTestMode. None (does not respond to the Swiper gesture, responds to the sub component gesture)
      .onTouchIntercept((event: TouchEvent) => {
        if (this.index === 2 && this.isMap(event)) {
          return HitTestMode.None;
        }
        return HitTestMode.Transparent;
      })
      .cachedCount(2)
      .index(1)
      .loop(true)
      .itemSpace(0)
      // Set the style of circular navigation points
      .indicator(
        new DotIndicator()
          .itemWidth(15)
          .itemHeight(15)
          .selectedItemWidth(15)
          .selectedItemHeight(15)
          .color(Color.Gray)
          .selectedColor(Color.Blue))
      .displayArrow({
        // Set navigation point arrow style
        showBackground: true,
        isSidebarMiddle: true,
        backgroundSize: 24,
        backgroundColor: Color.White,
        arrowSize: 18,
        arrowColor: Color.Blue
      }, false)
      .curve(Curve.Linear)
      .onChange((index: number) => {
        this.index = index;
      })
      .onGestureSwipe((index: number, extraInfo: SwiperAnimationEvent) => {
        console.info("index: " + index);
        console.info("current offset: " + extraInfo.currentOffset);
      })

      Row({ space: 12 }) {
        Button('showNext')
          .onClick(() => {
            this.swiperController.showNext();
          })
        Button('showPrevious')
          .onClick(() => {
            this.swiperController.showPrevious();
          })
      }.margin(5)
    }.width('100%')
    .margin({ top: 5 })
  }
}
// [End GestureStuttering]