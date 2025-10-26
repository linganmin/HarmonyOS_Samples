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

import { EditableLeftIconType, EditableTitleBar, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { JSON } from '@kit.ArkTS';
import { ImageItemView } from '../view/ImageItemView';
import { ThumbnailView } from '../view/ThumbnailView';
import { ImageInfo } from '../model/CommonModel';

const DOMAIN = 0x0000;
const TAG = 'HomePage';
const FORMAT = '%{public}s';

@Entry
@Component
struct HomePage {
  @State @Watch('isOverlayMethod') isOverlay: boolean = true;
  @Provide isDisableSwipe: boolean = false;
  @Provide isImageReset: boolean = false;
  @Provide bgc: string = '#F1F3F5';
  private thumbnailSwipeController: SwiperController = new SwiperController();
  private homeSwipeController: SwiperController = new SwiperController();
  private windowClass: window.Window = AppStorage.get<window.Window>('windowClass')!;
  private StatusImgData: ImageInfo[] = [
    new ImageInfo($r('app.media.ic_share'), $r('app.string.text_share')),
    new ImageInfo($r('app.media.ic_collect'), $r('app.string.text_collect')),
    new ImageInfo($r('app.media.ic_edit'), $r('app.string.text_edit')),
    new ImageInfo($r('app.media.ic_delete'), $r('app.string.text_edit'))
  ];
  private ImgData: Resource[] = [
    $r('app.media.ic_image1'),
    $r('app.media.ic_image2'),
    $r('app.media.ic_image3'),
    $r('app.media.ic_image4'),
    $r('app.media.ic_image5'),
    $r('app.media.ic_image6'),
    $r('app.media.ic_image7'),
    $r('app.media.ic_image8'),
    $r('app.media.ic_image9'),
    $r('app.media.ic_image10')
  ];

  isOverlayMethod(): void {
    let SystemBarProperties: window.SystemBarProperties;
    if (this.isOverlay) {
      SystemBarProperties = { statusBarContentColor: '#000000' };
    } else {
      SystemBarProperties = { statusBarContentColor: '#FFFFFF' };
    }
    this.windowClass.setWindowSystemBarProperties(SystemBarProperties).catch((err: BusinessError) => {
      hilog.error(DOMAIN, TAG, FORMAT,
        `StartPiP SetWindowSystemBarProperties. Cause code: ${err.code}, message: ${err.message}`);
    });
  }

  @Builder
  StatusBar() {
    Column() {
      Column() {
        EditableTitleBar({
          leftIconStyle: EditableLeftIconType.Back,
          title: $r('app.string.text_title'),
          menuItems: [
            {
              value: $r('app.media.ic_more'),
              isEnabled: true
            }
          ],
          isSaveIconRequired: false,
          onCancel: () => {
            this.getUIContext().getRouter().back();
          }
        })
      }
      .padding({ top: (AppStorage.get<number>('statusBarHeight') ?? 0) })
      .backgroundColor($r('sys.color.background_secondary'))
      .width('100%')
      .height(90)

      Column() {
        Row() {
          Swiper(this.thumbnailSwipeController) {
            ForEach(this.ImgData, (img: Resource, index: number) => {
              ThumbnailView({
                imageData: img
              })
                .aspectRatio(1)
                .onClick(() => {
                  this.homeSwipeController.changeIndex(index);
                })
            }, (img: Resource, index: number) => JSON.stringify(img) + index)
          }
          .cachedCount(10)
          .displayCount(8)
          .indicator(false)
          .loop(true)
          .itemSpace(2)
          .onChange((index: number) => {
            this.homeSwipeController.changeIndex(index);
          })
        }
        .backgroundColor($r('sys.color.background_secondary'))
        .width('100%')
        .height(52)

        Row() {
          ForEach(this.StatusImgData, (item: ImageInfo) => {
            Row() {
              Column() {
                Image(item.icon)
                  .width(24)
                  .height(24)
                Text(item.name)
                  .fontSize(10)
                  .margin({ top: 4 })
              }
            }
            .onClick(() => {
              this.isDisableSwipe = true;
            })
          }, (item: Resource) => JSON.stringify(item))
        }
        .padding({
          top: 6,
          bottom: (AppStorage.get<number>('naviIndicatorHeight') ?? 0) + 16
        })
        .justifyContent(FlexAlign.SpaceAround)
        .backgroundColor($r('sys.color.background_secondary'))
        .width('100%')
        .height(80)
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .visibility(this.isOverlay ? Visibility.Visible : Visibility.Hidden)
    .hitTestBehavior(HitTestMode.None)
  }

  // [Start photo_swiper]
  @Builder
  PhotoSwiper() {
    Swiper(this.homeSwipeController) {
      ForEach(this.ImgData, (img: Resource) => {
        ImageItemView({
          imageData: img,
          isOverlay: this.isOverlay
        })
          .width('100%')
          .height('100%')
      }, (img: Resource, index: number) => JSON.stringify(img) + index)
    }
    // [StartExclude photo_swiper]
    .effectMode(EdgeEffect.Spring)
    .loop(true)
    .itemSpace(8)
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .autoPlay(false)
    // [EndExclude photo_swiper]
    .disableSwipe(this.isDisableSwipe)
    // [StartExclude photo_swiper]
    .indicator(false)
    .cachedCount(20)
    .onChange((index: number) => {
      this.thumbnailSwipeController.changeIndex(index);
    })
    .onGestureSwipe(() => {
      this.isImageReset = false;
    })
    .onAnimationStart((index: number, targetIndex: number) => {
      if (index !== targetIndex) {
        this.isImageReset = true;
      }
    })
  }
  // [EndExclude photo_swiper]
  // [End photo_swiper]

  build() {
    Column() {
      Stack() {
        this.PhotoSwiper()
        this.StatusBar()
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.isOverlay ? this.bgc = '#F1F3F5' : this.bgc = '#000000')
  }
}