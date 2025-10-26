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

import { DataSource, PhotoData } from '../util/DataSource';
import { CommonConstants } from '../common//CommonConstants';
import { common } from '@kit.AbilityKit';
import { display } from '@kit.ArkUI';

@Entry
@Component
struct Index {
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
  scroller: Scroller = new Scroller();

  aboutToAppear(): void {
    this.isFoldable = display.isFoldable();
    let foldStatus: display.FoldStatus = display.getFoldStatus();
    if (this.isFoldable) {
      this.foldStatus = foldStatus;
      let callback: Callback<number> = () => {
        let data: display.FoldStatus = display.getFoldStatus();
        this.foldStatus = data;
      }
      display.on('change', callback);
    }
    let list: PhotoData[] = [];
    for (let i = 1; i <= 7; i++) {
      let newPhotoData = new PhotoData();
      newPhotoData.id = i;
      list.push(newPhotoData);
    }
    this.progressData = list;
    this.data = new DataSource(list);
  }

  // DocsCode 2
  // [Start progress_component]
  @Builder
  progressComponent() {
    Row({ space: 5 }) {
      ForEach(this.progressData, (item: PhotoData, index: number) => {
        Stack({ alignContent: Alignment.Start }) {
          Row()
            .zIndex(1)
            .width(this.currentIndex >= index && !this.slide ? '100%' : '0')
            .height(2)
            .borderRadius(2)
            .backgroundColor(Color.White)
            .animation(!this.slide ? {
              duration: this.duration - 400,
              curve: Curve.Linear,
              iterations: 1,
              playMode: PlayMode.Normal,
              onFinish: () => {
                if (this.currentIndex === this.progressData.length - 1) {
                  this.duration = 400;
                  this.currentIndex = -1;
                }
              }
            } : { duration: 0, iterations: 1 })
        }
        .width('100%')
        .height(2)
        .borderRadius(2)
        .backgroundColor(this.currentIndex >= index && this.slide ? Color.White : Color.Grey)
        .layoutWeight(1)
      }, (item: PhotoData) => JSON.stringify(item))
    }
    .width('100%')
    .height(50)
  }
  // [End progress_component]
  // DocsCode 2

  build() {
    Column() {
      Row() {
        Image($r('app.media.back'))
          .width($r('app.float.image_width'))
          .height($r('app.float.image_height'))
          .margin({ top: $r('app.float.image_margin_top') })
      }
      .width(CommonConstants.FULL_PERCENT)
      .height($r('app.float.row_image_height'))
      .padding({ left: $r('app.float.padding_left'), right: $r('app.float.padding_right') })

      Stack({ alignContent: Alignment.BottomStart }) {
        Scroll() {
          List() {
            ListItem() {
              // DocsCode 1
              // [Start Index_swiper_part_one]
              // [Start Index_swiper_part_two]
              Swiper(this.swiperController) {
                // [StartExclude Index_swiper_part_two]
                LazyForEach(this.data, (item: PhotoData, index: number) => {
                  Image($r(`app.media.` + item.id))
                    .width(this.foldStatus === 2 ? '100%' : '70%')
                    .height('100%')
                }, (item: PhotoData) => JSON.stringify(item))
                // [EndExclude Index_swiper_part_two]
              }
              // [End Index_swiper_part_two]
              .loop(!this.slide ? true : false)
              .autoPlay(!this.slide ? true : false)
              .interval(3000)
              .indicator(false)
              // [End Index_swiper_part_one]
              // DocsCode 1
              // [Start Index_swiper_part_two]
              .onGestureSwipe((index: number, extraInfo: SwiperAnimationEvent) => {
                // [End Index_swiper_part_two]
                if (extraInfo.currentOffset > 0 && index === 0 && !this.slide) {
                  let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
                  context.terminateSelf();
                }
                // [Start Index_swiper_part_two]
                this.slide = true;
                // [End Index_swiper_part_two]
                if (extraInfo.currentOffset > 0 && this.currentIndex > 0) {
                  this.currentIndex = index - 1;
                }
                // [Start Index_swiper_part_two]
              })
              // [End Index_swiper_part_two]
              .cachedCount(CommonConstants.SWIPER_CACHED_COUNT)
              .index($$this.slideIndex)
              .indicatorInteractive(false)
              .duration(CommonConstants.IMAGE_DURATION)
              .itemSpace(CommonConstants.ITEM_SPACE)
              .displayArrow(false)
              .curve(Curve.Linear)
              .onChange((index: number) => {
                this.duration = 3000;
                this.currentIndex = index;
              })
              .onAppear(() => {
                this.currentIndex = 0;
              })
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
      .margin({ top: $r('app.float.stack_margin_top'), })
      .height($r('app.float.stack_height'))
    }
    .backgroundColor(Color.Black)
    .height(CommonConstants.FULL_PERCENT)
    .width(CommonConstants.FULL_PERCENT)
  }
}