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

import { DataSource, PhotoData } from '../util/DataSource';
import { CommonConstants } from '../common//CommonConstants';
import { display, window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Component
export struct ImageSwitch {
  private swiperController: SwiperController = new SwiperController();
  @State progressData: PhotoData[] = [];
  @State data: DataSource = new DataSource([]);
  @State currentIndex: number = CommonConstants.INITIALLY_CURRENT_INDEX;
  @State slideIndex: number = CommonConstants.SLIDE_INDEX;
  @State duration: number = CommonConstants.DURATION;
  @State swiperMaxHeight: number = CommonConstants.SWIPER_MAX_HEIGHT;
  @State progressHeight: number = CommonConstants.PROGRESS_WRAP_HEIGHT;
  @State slide: boolean = false;
  @State foldStatus: number = 2;
  @State isFoldable: boolean = false;
  @Consume('NavPathStack') pageStack: NavPathStack;
  scroller: Scroller = new Scroller();

  // [Start aboutToAppear]
  aboutToAppear(): void {
    try {
      this.isFoldable = display.isFoldable();
      // Get the foldable screen status
      let foldStatus: display.FoldStatus = display.getFoldStatus();
      if (this.isFoldable) {
        this.foldStatus = foldStatus;
        let callback: Callback<number> = () => {
          let data: display.FoldStatus = display.getFoldStatus();
          this.foldStatus = data;
        }
        // Monitor the changes in the unfolded status of the foldable screen
        display.on('change', callback);
      }
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'ImageSwitch', `getFoldStatus failed. code=${err.code}, message=${err.message}`);
    }
    let list: PhotoData[] = [];
    for (let i = 1; i <= 7; i++) {
      let newPhotoData = new PhotoData();
      newPhotoData.id = i;
      list.push(newPhotoData);
    }
    this.progressData = list;
    this.data = new DataSource(list);

    // [StartExclude aboutToAppear]
    let windowClass: window.Window | undefined = AppStorage.get('windowClass');
    let sysBarProps: window.SystemBarProperties = {
      statusBarColor: '#000000',
      statusBarContentColor: '#ffffff'
    };
    windowClass?.setWindowSystemBarProperties(sysBarProps).catch((error: BusinessError) => {
      hilog.error(0x0000, 'ImageSwitch', `setWindowSystemBarProperties failed. code=${error.code}, message=${error.message}`);
    });
    // [EndExclude aboutToAppear]
  }
  // [Start aboutToAppear]

  aboutToDisappear(): void {
    let windowClass: window.Window | undefined = AppStorage.get('windowClass');
    let sysBarProps: window.SystemBarProperties = {
      statusBarColor: '#ffffff',
      statusBarContentColor: '#000000'
    };
    windowClass?.setWindowSystemBarProperties(sysBarProps).catch((error: BusinessError) => {
      hilog.error(0x0000, 'ImageSwitch', `setWindowSystemBarProperties failed. code=${error.code}, message=${error.message}`);
    });
  }

  // [Start progress_component]
  @Builder
  progressComponent() {
    Row({ space: 5 }) {
      ForEach(this.progressData, (item: PhotoData, index: number) => {
        Stack({ alignContent: Alignment.Start }) {
          // Use the cascading component to stack progress bars of different styles together
          // [StartExclude progress_component]
          Row()
            .zIndex(CommonConstants.Z_INDEX_0)
            .width(CommonConstants.FULL_PERCENT)
            .height(2)
            .borderRadius($r('app.float.row_borderRadius'))
            .backgroundColor(Color.Grey)
          // [EndExclude progress_component]
          Row()
            .zIndex(1)
            .width(this.currentIndex === index ? '100%' : '0')
            .height(2)
            .borderRadius(2)
            .backgroundColor(Color.White)
            // Add a growth animation to the progress bar
            .animation({
              duration: this.currentIndex === index ? this.duration : 0,
              curve: Curve.Linear,
              iterations: 1,
              playMode: PlayMode.Normal
            })
          // [StartExclude progress_component]
          Row()
            .zIndex(CommonConstants.Z_INDEX_2)
            .width(this.currentIndex > index ? CommonConstants.FULL_PERCENT :
            CommonConstants.NONE_PERCENT)
            .height(2)
            .borderRadius($r('app.float.row_borderRadius'))
            .backgroundColor(Color.White)
          // [EndExclude progress_component]
        }
        .layoutWeight(1)
      }, (item: PhotoData) => JSON.stringify(item))
    }
    .width('100%')
    .height(50)
  }

  // [End progress_component]

  build() {
    NavDestination() {
      Row() {
        Image($r('app.media.back'))
          .width($r('app.float.image_width'))
          .height($r('app.float.image_height'))
      }
      .width(CommonConstants.FULL_PERCENT)
      .height($r('app.float.image_width'))
      .padding({ left: $r('app.float.padding_left'), right: $r('app.float.padding_right') })
      .onClick(() => {
        this.pageStack.pop();
      })

      Stack({ alignContent: Alignment.BottomStart }) {
        Scroll() {
          List() {
            ListItem() {
              // [Start on_gesture_swipe]
              // [Start image_swiper]
              Swiper(this.swiperController) {
                // [StartExclude on_gesture_swipe]
                LazyForEach(this.data, (item: PhotoData, index: number) => {
                  Image($r(`app.media.` + item.id))
                    .width(this.foldStatus === 2 ? '100%' : '70%')
                    .height('100%')
                }, (item: PhotoData) => JSON.stringify(item))
                // [EndExclude on_gesture_swipe]
              }
              // [StartExclude on_gesture_swipe]
              .loop(true)
              .autoPlay(true)
              //.autoPlay(this.slide ? false : true)
              .interval(3000)
              .indicator(false)
              // [End image_swiper]
              .cachedCount(CommonConstants.SWIPER_CACHED_COUNT)
              .index($$this.slideIndex)
              .indicatorInteractive(false)
              .duration(CommonConstants.IMAGE_DURATION)
              .itemSpace(CommonConstants.ITEM_SPACE)
              .displayArrow(false)
              .curve(Curve.Linear)
              .onChange((index: number) => {
                this.currentIndex = index;
              })
              .onAppear(() => {
                this.currentIndex = 0;
              })

              // // [EndExclude on_gesture_swipe]
              // .onGestureSwipe((index: number, extraInfo: SwiperAnimationEvent) => {
              //   this.slide = true;
              // })

              // [End on_gesture_swipe]
            }
            .width(CommonConstants.FULL_PERCENT)
            .height(this.swiperMaxHeight)
          }
          .width(CommonConstants.FULL_PERCENT)
          .height(CommonConstants.FULL_PERCENT)
          .sticky(StickyStyle.Footer)
        }
        .layoutWeight(CommonConstants.LAYOUT_WEIGHT)

        Column() {
          Column({ space: CommonConstants.COLUMN_SPACE }) {
            Image($r('app.media.avatar'))
              .width($r('app.float.image_width'))
              .height($r('app.float.image_height'))
              .borderRadius($r('app.float.image_borderRadius'))
            Column({ space: CommonConstants.COLUMN_SPACE_INSIDE }) {
              Image($r("app.media.favor"))
                .width($r('app.float.image_width_inside'))
                .height($r('app.float.image_height_inside'))
              Text($r('app.string.collection'))
                .fontSize($r('app.float.text_font_size'))
                .fontColor(Color.White)
            }
            .width($r('app.float.column_width'))
            .height($r('app.float.column_height'))

            Column({ space: CommonConstants.COLUMN_SPACE_INSIDE }) {
              Image($r('app.media.comments'))
                .width($r('app.float.image_width_inside'))
                .height($r('app.float.image_height_inside'))
              Text($r('app.string.Comments'))
                .fontSize($r('app.float.text_font_size'))
                .fontColor(Color.White)
            }
            .width($r('app.float.column_width'))
            .height($r('app.float.column_height'))

            Column({ space: CommonConstants.COLUMN_SPACE_INSIDE }) {
              Image($r('app.media.share'))
                .width($r('app.float.image_width_inside'))
                .height($r('app.float.image_height_inside'))
              Text($r('app.string.share'))
                .fontSize($r('app.float.text_font_size'))
                .fontColor(Color.White)
            }
            .width($r('app.float.column_width'))
            .height($r('app.float.column_height'))

            Image($r('app.media.recording'))
              .width($r('app.float.image_width'))
              .height($r('app.float.image_height'))
              .borderRadius($r('app.float.image_borderRadius'))
          }
          .margin({ top: $r('app.float.column_image_margin_top') })
        }
        .width(CommonConstants.FULL_PERCENT)
        .height(CommonConstants.FULL_PERCENT)
        .alignItems(HorizontalAlign.End)
        .justifyContent(FlexAlign.Center)
        .padding({ left: $r('app.float.column_padding_left'), right: $r('app.float.column_padding_right') })
        .hitTestBehavior(HitTestMode.Transparent)

        Column() {
          Column({ space: CommonConstants.COLUMN_SPACE_INSIDE }) {
            Row() {
              Text($r('app.string.cute_pet'))
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
              Text($r('app.string.dots'))
                .fontColor(Color.White)
                .margin({ left: 6, right: 6 })
              Text($r('app.string.date'))
                .fontColor(Color.White)
            }
            .width(CommonConstants.FULL_PERCENT)
            .justifyContent(FlexAlign.Start)
            .margin({ top: $r('app.float.row_margin_top') })

            Row() {
              Text($r('app.string.pets'))
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
              Text($r('app.string.dog'))
                .fontColor(Color.White)
                .margin({ left: $r('app.float.text_margin_left'), right: $r('app.float.text_margin_right') })
              Text($r('app.string.spoiled'))
                .fontColor(Color.White)
            }
            .width(CommonConstants.FULL_PERCENT)
            .justifyContent(FlexAlign.Start)

            this.progressComponent();
          }

          TextInput({ placeholder: $r('app.string.placeholder') })
            .width(CommonConstants.FULL_PERCENT)
            .backgroundColor($r('app.color.textInput_backgroundColor'))
            .fontColor(Color.White)
            .placeholderColor(Color.White)
            .focusable(false)
        }
        .width(CommonConstants.FULL_PERCENT)
        .height($r('app.float.description_column_height'))
        .padding({
          left: $r('app.float.padding_left'),
          right: $r('app.float.padding_right'),
          bottom: $r('app.float.padding_bottom')
        })
        .hitTestBehavior(HitTestMode.Transparent)
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .margin({ top: $r('app.float.stack_margin_top') })
      .height($r('app.float.stack_height'))
    }
    .backgroundColor(Color.Black)
    .height(CommonConstants.FULL_PERCENT)
    .width(CommonConstants.FULL_PERCENT)
  }
}