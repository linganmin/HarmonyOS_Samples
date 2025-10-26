/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
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

import { hilog } from '@kit.PerformanceAnalysisKit';
import { AlertDialog } from '@kit.ArkUI';
import { image } from '@kit.ImageKit';
import { cropIconChangeList, menuIconList } from '../viewModel/IconListViewModel';
import { RotateType, CropType, MainTabId } from '../viewModel/OptionViewModel';
import { CommonConstants } from '../common/constant/CommonConstants';
import { square, banner, rectangle } from '../utils/CropUtil';
import { IconStatus } from '../viewModel/IconListViewModel';
import { encode } from '../utils/EncodeUtil';
import AdjustContentView from '../view/AdjustContentView';
import getPixelMap from '../utils/DecodeUtil';
import TitleBar from '../view/TitleBar';

const TAG: string = '[HomePage]';

@Entry
@Component
struct HomePage {
  @State currentIndex: number = 0;
  @State currentCropIndex: number = 0;
  @Provide('imageInfo') imageInfo: image.ImageInfo = {
    size: { height: 0, width: 0 },
    density: 0,
    stride: 0,
    alphaType: 0,
    pixelFormat: 0,
    mimeType: '',
    isHdr: false
  };
  @Provide('currentAdjustData') currentAdjustData: Array<number> =
    CommonConstants.ADJUST_SLIDER_VALUE.map((item: number) => item);
  @Provide('isPixelMapChange') @Watch('flushPixelMap') isPixelMapChange: boolean = false;
  @Provide('pixelMap') pixelMap?: image.PixelMap = undefined;
  menuIconChangeList = menuIconList;
  cropIconChange: Array<IconStatus> = cropIconChangeList;
  dialogControllerConfirm: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      primaryTitle: $r('app.string.save_image'),
      content: $r('app.string.confirm_save'),
      primaryButton: {
        value: $r('app.string.cancel'),
        action: () => {
          hilog.info(0x0000, TAG, '%{public}s', 'cancel');
        }
      },
      secondaryButton: {
        value: $r('app.string.ok'),
        action: () => {
          if (this.pixelMap) {
            encode(this, this.pixelMap);
          }
        }
      }
    })
  });

  @Builder
  TabBuilderMenu(index: number, name: string | Resource) {
    Column() {
      Image(this.currentIndex === index ? this.menuIconChangeList[index]?.chosen :
        this.menuIconChangeList[index]?.normal)
        .width(24)
        .height(24)

      Text(name)
        .fontColor(this.currentIndex === index ? '#006CDE' : Color.White)
        .fontSize(10)
        .margin({ top: 8 })
    }
    .width('100%')
  }

  async cropImage(proportion: CropType): Promise<void> {
    if (!this.pixelMap) {
      return;
    }
    const imageInfo = await this.pixelMap.getImageInfo();
    const size = imageInfo.size;
    const imageWidth = size?.width;
    const imageHeight = size?.height;
    switch (proportion) {
      case CropType.ORIGINAL_IMAGE:
        this.pixelInit();
        break;
      case CropType.SQUARE:
        if (this.pixelMap) {
          square(this.pixelMap, imageWidth, imageHeight).then(() => {
            this.flushPixelMapChange();
          });
        }
        break;
      case CropType.BANNER:
        if (this.pixelMap) {
          banner(this.pixelMap, imageWidth, imageHeight).then(() => {
            this.flushPixelMapChange();
          });
        }
        break;
      case CropType.RECTANGLE:
        if (this.pixelMap) {
          rectangle(this.pixelMap, imageWidth, imageHeight).then(() => {
            this.flushPixelMapChange();
          });
        }
        break;
      default:
        break;
    }
  }

  rotateImage(rotateType: RotateType): void {
    if (rotateType === RotateType.CLOCKWISE) {
      if (!this.pixelMap) {
        return;
      }
      try {
        this.pixelMap.rotate(90)
          .then(() => {
            this.flushPixelMapChange();
          })
      } catch (error) {
        hilog.error(0x0000, TAG, '%{public}s', `there is a error in rotate process with ${error?.code}`);
      }
    }
    if (rotateType === RotateType.ANTI_CLOCK) {
      if (!this.pixelMap) {
        return;
      }
      try {
        this.pixelMap.rotate(-90)
          .then(() => {
            this.flushPixelMapChange();
          })
      } catch (error) {
        hilog.error(0x0000, TAG, '%{public}s', `there is a error in rotate process with ${error?.code}`);
      }
    }
  }

  flushPixelMapChange(): void {
    this.isPixelMapChange = !this.isPixelMapChange;
  }

  flushPixelMap(): void {
    const temp = this.pixelMap;
    this.pixelMap = undefined;
    this.pixelMap = temp;
  }

  pixelInit(): void {
    getPixelMap(this.getUIContext())
      .then((pixelMap?: image.PixelMap) => {
        if (pixelMap) {
          this.isPixelMapChange = !this.isPixelMapChange;
          this.pixelMap = pixelMap;
        }
        this.currentCropIndex = 0;
        this.currentAdjustData = CommonConstants.ADJUST_SLIDER_VALUE.map((item: number) => item);
      })
  }

  aboutToAppear() {
    this.pixelInit();
  }

  @Builder
  TitleNavigation() {
    TitleBar({
      onBack: () => {
        this.getUIContext().getRouter().back();
      },
      onReset: () => {
        this.pixelInit();
      },
      onSave: () => {
        this.dialogControllerConfirm.open();
      }
    })
  }

  build() {
    Navigation() {
      Column() {
        Column() {
          this.TitleNavigation()
          if (this.isPixelMapChange) {
            Image(this.pixelMap)
              .objectFit(ImageFit.None)
          } else {
            Image(this.pixelMap)
              .objectFit(ImageFit.None)
          }
        }
        .justifyContent(FlexAlign.Start)
        .padding({ top: 8 })
        .width('100%')
        .height('70%')

        Column() {
          Tabs({ barPosition: BarPosition.End }) {
            TabContent() {
              Row() {
                ForEach(this.cropIconChange, (item: IconStatus, index?: number | undefined) => {
                  Image(this.currentCropIndex === index ? item?.chosen : item?.normal)
                    .width(36)
                    .height(36)
                    .onClick(() => {
                      if (typeof (index) === 'number') {
                        this.currentCropIndex = index;
                        this.cropImage(index);
                      }
                    })
                }, (item: IconStatus) => JSON.stringify(item))
              }
              .width('100%')
              .height('100%')
              .justifyContent(FlexAlign.SpaceEvenly)
            }
            .tabBar(this.TabBuilderMenu(MainTabId.CROP, $r('app.string.crop')))

            TabContent() {
              Row() {
                Image($r('app.media.ic_clockwise'))
                  .width(30)
                  .height(30)
                  .onClick(() => {
                    this.rotateImage(RotateType.CLOCKWISE);
                  })

                Image($r('app.media.ic_anti_clockwise'))
                  .width(30)
                  .height(30)
                  .onClick(() => {
                    this.rotateImage(RotateType.ANTI_CLOCK);
                  })
              }
              .justifyContent(FlexAlign.SpaceEvenly)
              .width('100%')
              .height('100%')
            }
            .tabBar(this.TabBuilderMenu(MainTabId.ROTATE, $r('app.string.rotate')))

            TabContent() {
              AdjustContentView()
            }
            .tabBar(this.TabBuilderMenu(MainTabId.ADJUST, $r('app.string.adjust')))
          }
          .scrollable(false)
          .onChange((index: number) => {
            this.currentIndex = index;
          })
        }
        .padding({ bottom: 16 })
        .width('100%')
        .height('30%')
      }
      .width('100%')
      .height('100%')
    }
    .padding({
      top: (AppStorage.get<number>('statusBarHeight') ?? 0),
      bottom: (AppStorage.get<number>('naviIndicatorHeight') ?? 0)
    })
    .hideToolBar(true)
    .hideTitleBar(true)
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
  }
}