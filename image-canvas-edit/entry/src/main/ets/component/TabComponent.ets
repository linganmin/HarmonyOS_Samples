/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { image } from '@kit.ImageKit';
import { WatermarkView } from '../view/WatermarkView';
import { CommonConstants } from '../common/constant/CommonConstants';
import { ImageDisplaySize, TranslateListType } from '../viewModel/PictureEditModel';
import { AdjustType, CropType, MainTabId, MirrorType, FilterType } from '../viewModel/OptionViewModel';
import ApplyFilterView from '../view/ApplyFilterView';
import AdjustContentView from '../view/AdjustContentView';
import CropView from '../view/CropView';
import { PixelMapManager } from '../utils/PixelMapManager';
import ZoomView from '../view/ZoomView';


enum EditMode {
  CROP_MODE,
  ADJUST_MODE,
  FILTER_MODE,
  TRANSLATE_MODE,
  ZOOM_MODE,
  WATER_MODE
}

export function getResource(arr: string[] | TranslateListType, index: number): Resource {
  if (Array.isArray(arr)) {
    return $r(arr[index]);
  } else {
    return $r(arr.icon);
  }
}

@CustomDialog
struct MyCustomDialog {
  controller?: CustomDialogController;
  title: string = '';
  cancel: () => void = () => {
  };
  confirm: () => void = () => {
  };

  build() {
    Column() {
      Text($r(this.title))
        .textAlign(TextAlign.Center)
        .fontSize('16vp')
        .fontColor('rgba(0, 0, 0, 0.9)')
        .lineHeight('21vp')

      Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
        Button($r('app.string.cancel'), { buttonStyle: ButtonStyleMode.EMPHASIZED, role: ButtonRole.NORMAL })
          .flexGrow(1)
          .backgroundColor(Color.Transparent)
          .fontColor('#0A59F7')
          .fontSize('16vp')
          .fontWeight(500)
          .onClick(() => {
            this.cancel();
          })
        Divider()
          .vertical(true)
          .strokeWidth('0.5vp')
          .height(24)
          .color('rgba(0, 0, 0, 0.05)')
          .margin({ left: 4, right: 4 })
        Button($r('app.string.confirm'), { buttonStyle: ButtonStyleMode.EMPHASIZED, role: ButtonRole.NORMAL })
          .flexGrow(1)
          .backgroundColor(Color.Transparent)
          .fontColor('#0A59F7')
          .fontSize('16vp')
          .fontWeight(500)
          .onClick(() => {
            this.confirm();
          })
      }
      .height('40vp')
      .margin({ top: '8vp' })
    }
    .width('328vp')
    .padding(24)
    .borderRadius(32)
    .backgroundColor(Color.White)
  }
}

@Component
export struct TabComponent {
  @Prop displaySize: ImageDisplaySize;
  @Link containerWidth: number;
  @Link containerHeight: number;
  @Link cropList: TranslateListType[];
  @Link currentCropIndex: number;
  @Link currentIndex: number;
  @Link currentTranslateData: number[];
  @Link currentTranslateIndex: number;
  @Link translateList: TranslateListType[];
  @Link currentZoom: number;
  @Link waterShow: boolean;
  @Link canvasOffsetX: number;
  @Link canvasOffsetY: number;
  @Consume pixelMap: image.PixelMap;
  @Consume currentEditMode: EditMode;
  @Consume currentCropMode: number;
  @Consume filterCurrMode: number;
  @Consume('currentAdjustData') currentAdjustData: Array<number>;
  @Consume pixelMapManager?: PixelMapManager;
  @Consume('pixelMapInit') pixelMapInit?: image.PixelMap;
  @Consume previewPixelMap: image.PixelMap;
  @Consume cropPixelMap: image.PixelMap;
  @Consume cropInitPixelMap: image.PixelMap;
  @Consume adjustPixelMap: image.PixelMap;
  @Consume isInitTranslateValue: boolean;
  @Consume isRotate: boolean;
  @Consume translateX: number;
  @Consume translateY: number;
  triggerCanvasRedraw: () => void = () => {
  };
  flushPixelMapChange: () => void = () => {
  };
  reset: () => void = () => {
  };
  private controller: TabsController = new TabsController();
  private menuIconChangeList = [
    'sys.symbol.crop_rotate',
    'sys.symbol.slider_horizontal_2',
    'sys.symbol.camera_filters',
    'app.media.square_portrait_svg',
    'sys.symbol.checkered_magnifyingglass',
    'sys.symbol.shutter_photo'
  ];
  dialogController: CustomDialogController = new CustomDialogController({
    builder: MyCustomDialog({
      cancel: () => {
        this.onCancel();
      },
      confirm: () => {
        this.onConfirm();
      }
    }),
    autoCancel: false,
    alignment: DialogAlignment.Center,
    customStyle: true
  });
  cropDialogController: CustomDialogController = new CustomDialogController({
    builder: MyCustomDialog({
      title: 'app.string.save_crop',
      cancel: () => {
        this.reset();
        this.cropDialogController.close();
      },
      confirm: () => {
        this.onConfirm();
        this.cropDialogController.close();
      }
    }),
    autoCancel: false,
    alignment: DialogAlignment.Center,
    customStyle: true
  });
  adjustDialogController: CustomDialogController = new CustomDialogController({
    builder: MyCustomDialog({
      title: 'app.string.save_adjust',
      cancel: () => {
        this.reset();
        this.adjustDialogController.close();
      },
      confirm: () => {
        this.onConfirm();
        this.adjustDialogController.close();
      }
    }),
    autoCancel: false,
    alignment: DialogAlignment.Center,
    customStyle: true
  });
  filterDialogController: CustomDialogController = new CustomDialogController({
    builder: MyCustomDialog({
      title: 'app.string.save_filter',
      cancel: () => {
        this.reset();
        this.filterDialogController.close();
      },
      confirm: () => {
        this.onConfirm();
        this.filterDialogController.close();
      }
    }),
    autoCancel: false,
    alignment: DialogAlignment.Center,
    customStyle: true
  });

  onCancel() {
    this.cropImage(0);
    this.pixelMap = this.cropPixelMap;
    this.dialogController.close();
    this.currentCropIndex = 0;
  }

  onCancelAdjust() {
    this.pixelMap = this.adjustPixelMap;
    this.cropPixelMap = this.adjustPixelMap;
    this.adjustDialogController.close();
    this.flushPixelMapChange();
  }

  onConfirm() {
    this.pixelMapManager?.updatePreviewPixelMap(this.previewPixelMap!);
    this.currentCropMode = CropType.ORIGINAL_IMAGE;
    this.filterCurrMode = FilterType.ORIGIN;
    this.currentAdjustData = CommonConstants.ADJUST_SLIDER_VALUE.map((item: number) => item);
    if (this.translateX === 0 && this.translateY === 0) {
      this.currentTranslateData = [0, 0];
    }
    this.currentZoom = 100;
  }

  rotateImage() {
    this.isRotate = true;
    this.pixelMapManager?.rotateImage();
    this.flushPixelMapChange();
  }

  mirrorImage() {
    this.pixelMapManager?.mirrorImage(MirrorType.CLOCKWISE);
    this.flushPixelMapChange();
  }

  // Crop image
  async cropImage(proportion: CropType) {
    await this.pixelMapManager?.cropImage(proportion);
    this.flushPixelMapChange();
  }

  sliderChange(value: number, mode: SliderChangeMode) {
    if ((mode === SliderChangeMode.End) && (value !== this.currentTranslateData[this.currentTranslateIndex])) {
      if (this.isInitTranslateValue) {
        this.translateX = 0;
        this.translateY = 0;
      }
      this.currentTranslateData[this.currentTranslateIndex] = Math.round(value);
      if (this.currentTranslateIndex === 0) {
        this.translateX = (this.displaySize.width + this.displaySize.x) * (value / 1000);
      } else if (this.currentTranslateIndex === 1) {
        this.translateY = this.displaySize.height * (value / 1000);
      }
      this.flushPixelMapChange();
      this.isInitTranslateValue = false;
    }
  }

  async sliderZoomChange(value: number, mode: SliderChangeMode) {
    if ((mode === SliderChangeMode.End) && (value !== this.currentZoom)) {
      let zoom = value / 100;
      this.pixelMapManager?.editImageScale(zoom);
      this.currentZoom = value;
      this.flushPixelMapChange();
    }
  }

  @Builder
  TabBuilderMenu(index: number, name: string | Resource) {
    Column() {
      if (this.menuIconChangeList[index].includes('svg')) {
        Image(getResource(this.menuIconChangeList, index))
          .fillColor(this.currentEditMode === index ? '#5291FF' : '#FFF')
          .width(CommonConstants.TAB_MENU_WIDTH)
          .height(CommonConstants.TAB_MENU_WIDTH)
      } else {
        Text() {
          SymbolSpan(getResource(this.menuIconChangeList, index))
            .fontColor(this.currentEditMode === index ? ['#5291FF', '#5291FF', '#5291FF'] :
              [Color.White, Color.White, Color.White])
            .fontWeight(FontWeight.Normal)
            .fontSize(20)
        }
        .textAlign(TextAlign.Center)
        .width(CommonConstants.TAB_MENU_WIDTH)
        .height(CommonConstants.TAB_MENU_WIDTH)
      }

      Text(name)
        .fontColor(this.currentEditMode === index ? '#5291FF' : Color.White)
        .fontSize(10)
        .margin({ top: 2 })
    }
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .width(70)
    .padding({ left: 4, right: 4 })
  }

  @Builder
  waterMark() {
    Column() {
      Row() {
        Text($r('app.string.watermark'))
          .fontSize(20)
          .fontWeight(700)
      }
      .margin({ bottom: 24 })
      .width('100%')
      .justifyContent(FlexAlign.Start)

      Scroll() {
        WatermarkView({
          flushPixelMapChange: this.flushPixelMapChange
        })
      }
      .padding({
        top: 4,
        bottom: 4,
        left: 12,
        right: 12
      })
      .backgroundColor('#FFF')
      .borderRadius(16)
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto)
      .scrollBarColor('#6DECADENCE')
      .scrollBarWidth(5)
      .friction(0.6)
      .edgeEffect(EdgeEffect.None)
    }
    .padding({
      top: 23,
      bottom: 40,
      right: 16,
      left: 16
    })
    .width('100%')
  }

  build() {
    Column() {
      Tabs({ barPosition: BarPosition.End, controller: this.controller }) {
        TabContent() {
          CropView({
            onCropImage: (proportion: CropType) => {
              this.cropImage(proportion);
            },
            onRotateImage: () => {
              this.rotateImage();
            },
            onMirrorImage: () => {
              this.mirrorImage();
            }
          })
        }
        .padding({ bottom: 16 })
        .tabBar(this.TabBuilderMenu(MainTabId.CROP, $r('app.string.crop')))

        TabContent() {
          AdjustContentView({
            flushPixelMapChange: () => {
              this.flushPixelMapChange();
            }
          })
            .width('100%')
            .height('100%')
        }
        .padding({ bottom: 16 })
        .tabBar(this.TabBuilderMenu(MainTabId.ADJUST, $r('app.string.adjust')))
        .clip(false)

        TabContent() {
          ApplyFilterView({
            flushPixelMapChange: () => {
              this.flushPixelMapChange();
            }
          })
            .margin({ top: 60 })
            .width('100%')
            .height('100%')
        }
        .padding({ bottom: 16 })
        .tabBar(this.TabBuilderMenu(MainTabId.FILTER, $r('app.string.filter')))

        TabContent() {
          Column() {
            Row() {
              Slider({
                value: this.currentTranslateData[this.currentTranslateIndex],
                step: 10,
                min: 0,
                max: 1000
              })
                .trackColor('rgba(255,255,255,0.1)')
                .selectedColor(Color.White)
                .width(CommonConstants.SLIDER_WIDTH)
                .showSteps(true)
                .showTips(true)
                .clip(false)
                .onChange((value: number, mode: SliderChangeMode) => {
                  this.sliderChange(value > 1000 ? 1000 : value, mode);
                })
            }
            .padding({ top: 20, bottom: 20 })
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .clip(false)

            Row() {
              ForEach(this.translateList, (item: TranslateListType, index) => {
                Column() {
                  Text() {
                    SymbolSpan(getResource(item, index))
                      .fontColor(this.currentTranslateIndex === index ?
                        [item.selectColor, item.selectColor, item.selectColor] :
                        [item.color, item.color, item.color])
                      .fontWeight(FontWeight.Normal)
                      .fontSize(24)
                  }
                  .padding(9)
                  .borderRadius('50%')
                  .backgroundColor(this.currentTranslateIndex === index ? '#E6FFFFFF' : '#26FFFFFF')

                  Text(item.title)
                    .margin({ top: 4 })
                    .fontColor('#FFF')
                    .fontSize(10)
                }
                .margin({ left: 37, right: 37 })
                .onClick(() => {
                  this.currentTranslateIndex = index;
                })
              }, (item: string) => item)
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .width(CommonConstants.LAYOUT_FULL_SCREEN)
          .height('100%')
        }
        .width('100%')
        .height('100%')
        .padding({ bottom: 16 })
        .tabBar(this.TabBuilderMenu(MainTabId.TRANSLATE, $r('app.string.translate')))
        .clip(false)

        TabContent() {
          ZoomView({
            onZoomChange: (value: number, mode: SliderChangeMode) => {
              this.sliderZoomChange(value, mode);
            }
          })
        }
        .width('100%')
        .height('100%')
        .padding({ bottom: 16 })
        .clip(false)
        .tabBar(this.TabBuilderMenu(MainTabId.ZOOM, $r('app.string.zoom')))

        TabContent() {
        }
        .padding({ bottom: 16 })
        .clip(false)
        .tabBar(this.TabBuilderMenu(5, $r('app.string.watermark')))
      }
      .vertical(false)
      .barMode(BarMode.Scrollable)
      .barHeight('auto')
      .width('100%')
      .animationDuration(400)
      .fadingEdge(false)
      .scrollable(true)
      .barMode(BarMode.Scrollable)
      .clip(false)
      .onTabBarClick((index: number) => {
        if (this.waterShow === false && index === 5) {
          this.waterShow = true;
        }
      })
      .onChange((index: number) => {
        if (this.currentEditMode === EditMode.CROP_MODE && this.currentCropMode !== 0) {
          this.cropDialogController.open();
        }
        if (this.currentEditMode !== EditMode.CROP_MODE && index === EditMode.CROP_MODE) {
          this.pixelMapManager?.updateCropPixelMap(this.previewPixelMap!);
        }
        if (this.currentEditMode === EditMode.ADJUST_MODE &&
          (this.currentAdjustData[AdjustType.BRIGHTNESS] !== CommonConstants.SLIDER_MAX ||
            this.currentAdjustData[AdjustType.OPACITY] !== CommonConstants.SLIDER_MAX ||
            this.currentAdjustData[AdjustType.SATURATION] !== CommonConstants.SLIDER_MAX)) {
          this.adjustDialogController.open();
        }
        if (this.currentEditMode === EditMode.FILTER_MODE && this.filterCurrMode !== 0) {
          this.filterDialogController.open();
        }
        this.currentEditMode = index;
      })
      .bindSheet($$this.waterShow, this.waterMark(), {
        height: SheetSize.FIT_CONTENT,
        onDisappear: () => {
          this.waterShow = false;
        }
      })
    }
    .width('100%')
    .height('100%')
  }
}