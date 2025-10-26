/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { image } from '@kit.ImageKit';
import { IconStatus } from '../viewModel/IconListViewModel';
import CropView from '../view/CropView';
import AdjustContentView from '../view/AdjustContentView';
import ApplyFilterView from '../view/ApplyFilterView';
import TranslateView from '../view/TranslateView';
import ZoomView from '../view/ZoomView';
import { cropIconChangeList } from '../viewModel/IconListViewModel';
import { MirrorType, CropType, MainTabId, AdjustType, FilterType, TranslateType } from '../viewModel/OptionViewModel';
import { encode } from '../utils/EncodeUtil';
import { CommonConstants } from '../common/constant/CommonConstants';
import { decodePixelMapFromImageSource, getResourceFd } from '../utils/DecodeUtil';
import { BusinessError } from '@kit.BasicServicesKit';
import { PixelMapManager } from './PixelMapManager';

interface initDataArrType {
  label: '',
  value: ''
}

@CustomDialog
struct MyCustomDialog {
  controller?: CustomDialogController;
  title: string = ''
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

@CustomDialog
struct SaveDialog {
  controller?: CustomDialogController;
  cancel: () => void = () => {
  };
  confirm: () => void = () => {
  };

  build() {
    Column() {
      Row() {
        Text($r('app.string.save_image'))
          .fontColor('#000')
          .fontSize(20)
          .fontWeight(700)
      }

      Row() {
        Text($r('app.string.confirm_save'))
          .textAlign(TextAlign.Center)
          .fontSize(16)
          .fontColor('rgba(0, 0, 0, 0.9)')
          .lineHeight('21vp')
      }
      .padding({ top: 20, bottom: 20 })

      Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
        Text($r('app.string.cancel'))
          .textAlign(TextAlign.Center)
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
        Text($r('app.string.save'))
          .textAlign(TextAlign.Center)
          .flexGrow(1)
          .backgroundColor(Color.Transparent)
          .fontColor('#0A59F7')
          .fontSize('16vp')
          .fontWeight(500)
          .onClick(() => {
            this.confirm();
          })
      }
    }
    .width('328vp')
    .padding({
      left: 24,
      right: 24,
      top: 12,
      bottom: 12
    })
    .borderRadius(32)
    .backgroundColor(Color.White)
  }
}

enum EditMode {
  CROP_MODE,
  ADJUST_MODE,
  FILTER_MODE,
  TRANSLATE_MODE,
  ZOOM_MODE
}

@Entry
@Component
struct EditImagePages {
  uri: string = '';
  imageSource?: image.ImageSource;
  @StorageProp('imageInfoArr') imageInfoArr: initDataArrType[] = [];
  pixelMapManager?: PixelMapManager;
  @State previewPixelMap?: image.PixelMap = undefined;
  @State previewCropPixelMap?: image.PixelMap = undefined;
  @Provide currentEditMode: EditMode = EditMode.CROP_MODE;
  @Provide currentCropMode: number = CropType.ORIGINAL_IMAGE;
  @Provide filterCurrMode: number = FilterType.ORIGIN;
  @Provide currentTranslateData: number[] = [0, 0];
  @Provide currentTranslateMode: number = TranslateType.HORIZONTAL;
  @Provide currentZoom: number = 100;
  @State isShow: boolean = false;
  @Provide('imageInfo') imageInfo: image.ImageInfo = {
    size: { height: 0, width: 0 },
    density: 0,
    stride: 0,
    alphaType: 0,
    pixelFormat: 0,
    mimeType: '',
    isHdr: false
  };
  @Provide('currentAdjustData') currentAdjustData: Array<number> = [100, 100, 100];
  menuIconChangeList = [
    'crop_rotate',
    'slider_horizontal_2',
    'camera_filters',
    'square_portrait_svg',
    'checkered_magnifyingglass'
  ];
  cropIconChange: Array<IconStatus> = cropIconChangeList;
  @State saveButtonOptions: SaveButtonOptions = {
    icon: SaveIconStyle.FULL_FILLED
  };
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
        this.reset()
        this.filterDialogController.close();
      },
      confirm: () => {
        this.onConfirm()
        this.filterDialogController.close();
      }
    }),
    autoCancel: false,
    alignment: DialogAlignment.Center,
    customStyle: true
  });
  saveDialogController: CustomDialogController = new CustomDialogController({
    builder: SaveDialog({
      cancel: () => {
        this.onSaveCancel();
      },
      confirm: () => {
        this.onSaveConfirm();
      }
    }),
    autoCancel: false,
    alignment: DialogAlignment.Center,
    customStyle: true
  });

  aboutToAppear() {
    AppStorage.setOrCreate('isColorInfo', false);
    this.pixelInit();
    this.initData();
  }

  aboutToDisappear(): void {
    this.pixelMapManager?.destroyPixelMapManager();
    this.imageSource?.release();
  }

  async initData() {
    this.imageSource = image.createImageSource(await getResourceFd(this.getUIContext(), this.uri));

    this.imageSource.getImageInfo((err, imageInfo) => {
      if (err) {
        console.error('Failed to get image info:', err);
        return;
      }
      this.imageInfo = imageInfo;
      Object.keys(imageInfo).forEach((key) => {
        if (key === 'size') {
          Object.keys(imageInfo[key]).forEach((chlKey) => {
            this.imageInfoArr.push({
              label: chlKey as '',
              value: imageInfo[key][chlKey]
            })
          })
        } else {
          this.imageInfoArr.push({
            label: key as '',
            value: imageInfo[key]
          })
        }
      });
    })
    // Read EXIF information, where BitsPerSample represents the number of bits per pixel.
    await this.imageSource.getImageProperties(CommonConstants.IMG_PROPERTIES_KEYS).then((result) => {
      Object.keys(result).forEach((key) => {
        this.imageInfoArr.push({
          label: key as '',
          value: result[key]
        })
      });
    }).catch((error: BusinessError) => {
      console.error('Failed to get the value of the specified attribute key of the image.', error);
    });
    AppStorage.setOrCreate('imageInfoArr', this.imageInfoArr);
  }

  onConfirm() {
    this.pixelMapManager?.updatePreviewPixelMap(this.previewPixelMap!);
    this.currentCropMode = CropType.ORIGINAL_IMAGE;
    this.filterCurrMode = FilterType.ORIGIN;
    this.currentAdjustData = CommonConstants.ADJUST_SLIDER_VALUE.map((item: number) => item);
    this.currentTranslateData = [0, 0];
    this.currentZoom = 100;
  }

  onSaveCancel() {
    this.saveDialogController.close();
  }

  onSaveConfirm() {
    this.saveDialogController.close();
    if (this.pixelMapManager?.getFinalPixelMap()) {
      encode(this.pixelMapManager?.getFinalPixelMap(), this.getUIContext());
    }
  }

  async pixelInit() {
    let uri = ''
    let imageSource = image.createImageSource(await getResourceFd(this.getUIContext(), uri));
    const px = await decodePixelMapFromImageSource(imageSource);
    this.pixelMapManager = new PixelMapManager(px!, (pixelMap: image.PixelMap) => {
      this.previewPixelMap = pixelMap;
      this.previewCropPixelMap = pixelMap;
    })
    this.filterCurrMode = FilterType.ORIGIN;
    this.currentCropMode = CropType.ORIGINAL_IMAGE;
    this.currentAdjustData = CommonConstants.ADJUST_SLIDER_VALUE.map((item: number) => item);
    this.currentTranslateData = [0, 0];
    this.currentZoom = 100;
  }

  async cropImage(proportion: CropType) {
    this.pixelMapManager?.cropImage(proportion);
  }

  rotateImage() {
    this.pixelMapManager?.rotateImage();
  }

  mirrorImage() {
    this.pixelMapManager?.mirrorImage(MirrorType.CLOCKWISE);
  }

  sliderTranslateChange(value: number, mode: SliderChangeMode) {
    if ((mode === SliderChangeMode.End) && (value !== this.currentTranslateData[this.currentTranslateMode])) {
      let moveValue = Math.round(value) - this.currentTranslateData[this.currentTranslateMode];
      this.currentTranslateData[this.currentTranslateMode] = Math.round(value);
      if (this.currentTranslateMode === 0) {
        this.pixelMapManager?.translateImage({ x: moveValue, y: 0 });
      } else {
        this.pixelMapManager?.translateImage({ x: 0, y: moveValue });
      }
    }
  }

  async sliderZoomChange(value: number, mode: SliderChangeMode) {
    if ((mode === SliderChangeMode.End) && (value !== this.currentZoom)) {
      let zoom = value / 100;
      this.pixelMapManager?.editImageScale(zoom);
      this.currentZoom = value;
    }
  }

  reset() {
    this.pixelMapManager?.updatePreviewPixelMap(this.pixelMapManager.getInitPixelMap());
    this.pixelMapManager?.updateCropPixelMap(this.pixelMapManager.getInitPixelMap());
    this.filterCurrMode = FilterType.ORIGIN;
    this.currentCropMode = CropType.ORIGINAL_IMAGE;
    this.currentAdjustData = CommonConstants.ADJUST_SLIDER_VALUE.map((item: number) => item);
    this.currentTranslateData = [0, 0];
    this.currentZoom = 100;
  }

  @Builder
  infoBuilder() {
    Column() {
      Row() {
        Text($r('app.string.picture_information'))
          .fontSize(20)
          .fontWeight(700)
      }
      .margin({ bottom: 24 })
      .width('100%')
      .justifyContent(FlexAlign.Start)

      Scroll() {
        Column() {
          ForEach(this.imageInfoArr, (item: initDataArrType, index) => {
            Row() {
              Text(item.label)
                .fontSize(16)
                .fontWeight(500)
              Text(item.value + '')
                .fontSize(14)
                .fontColor($r('sys.color.mask_secondary'))
            }
            .padding({ top: 13, bottom: 13 })
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(VerticalAlign.Center)

            if ((this.imageInfoArr.length - 1) !== index) {
              Divider()
                .strokeWidth(0.5)
                .color($r('sys.color.mask_fourth'))
            }
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
      }
      .padding({
        top: 4,
        bottom: 4,
        left: 12,
        right: 12
      })
      .backgroundColor('#fff')
      .borderRadius(16)
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto)
      .scrollBarColor('#6dececec')
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

  @Builder
  TabBuilderMenu(index: number, name: string | Resource) {
    Column() {
      if (this.menuIconChangeList[index].includes('svg')) {
        Image($r(`app.media.${this.menuIconChangeList[index]}`))
          .fillColor(this.currentEditMode === index ? '#5291FF' : '#fff')
          .width(CommonConstants.TAB_MENU_WIDTH)
          .height(CommonConstants.TAB_MENU_WIDTH)
      } else {
        Text() {
          SymbolSpan($r(`sys.symbol.${this.menuIconChangeList[index]}`))
            .fontColor(this.currentEditMode === index ? ['#5291FF', '#5291FF', '#5291FF'] :
              [Color.White, Color.White, Color.White])
            .fontWeight(FontWeight.Normal)
            .fontSize(24)
        }
        .width(CommonConstants.TAB_MENU_WIDTH)
        .height(CommonConstants.TAB_MENU_WIDTH)
      }

      Text(name)
        .fontColor(this.currentEditMode === index ? '#5291FF' : Color.White)
        .fontSize($r('app.float.category_font_size'))
        .margin({ top: $r('app.float.category_margin_top') })
    }
    .width(CommonConstants.LAYOUT_FULL_SCREEN)
  }

  build() {
    RelativeContainer() {
      Column() {
        Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
          Row() {
            Text($r('app.string.image_edit'))
              .fontColor('#e6ffffff')
              .fontSize(26)
              .fontWeight(700)
          }
          .padding({ left: 16, right: 16 })
          .alignItems(VerticalAlign.Center)

          Row() {
            Button() {
              Image($r('app.media.ic_reset'))
                .width(22)
                .height(22)
            }
            .padding(9)
            .borderRadius('50%')
            .type(ButtonType.Normal)
            .aspectRatio(1)
            .backgroundColor($r('sys.color.interactive_pressed'))
            .onClick(() => {
              this.reset();
            })

            Text() {
              SymbolSpan($r('sys.symbol.info_circle'))
                .fontColor([Color.White, Color.White, Color.White])
                .fontWeight(FontWeight.Normal)
                .fontSize(22)
            }
            .margin({ left: 8 })
            .padding(9)
            .borderRadius('50%')
            .backgroundColor($r('sys.color.interactive_pressed'))
            .onClick(() => {
              this.isShow = true;
            })

            Text() {
              SymbolSpan($r('sys.symbol.save'))
                .fontColor([Color.White, Color.White, Color.White])
                .fontWeight(FontWeight.Normal)
                .fontSize(22)
            }
            .margin({ left: 8 })
            .padding(9)
            .borderRadius('50%')
            .backgroundColor($r('sys.color.interactive_pressed'))
            .onClick(() => {
              this.saveDialogController.open();
            })
          }
          .padding({ right: 16 })
        }
        .padding({ top: 44 })
        .width('100%')
        .height(92)

        Column() {
          Column() {
            Image(this.previewPixelMap)
              .width('100%')
              .height('100%')
              .objectFit(this.currentEditMode === EditMode.TRANSLATE_MODE ||
              EditMode.ZOOM_MODE ? ImageFit.None : ImageFit.Contain)
              .transition(TransitionEffect.OPACITY.animation({ duration: 200 }))
          }
          .width(CommonConstants.LAYOUT_FULL_SCREEN)
          .height('66%')

          Column() {
            Tabs({ barPosition: BarPosition.End }) {
              TabContent() {
                CropView({
                  pixelMapManager: this.pixelMapManager,
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
              .padding({ bottom: 19 })
              .tabBar(this.TabBuilderMenu(MainTabId.CROP, $r('app.string.crop')))

              TabContent() {
                AdjustContentView({ pixelMapManager: this.pixelMapManager });
              }
              .padding({ bottom: 19 })
              .tabBar(this.TabBuilderMenu(MainTabId.ADJUST, $r('app.string.adjust')))
              .clip(false)

              TabContent() {
                ApplyFilterView({ pixelMapManager: this.pixelMapManager })
                  .margin({ top: 60 })
              }
              .padding({ bottom: 19 })
              .tabBar(this.TabBuilderMenu(MainTabId.FILTER, $r('app.string.filter')))

              TabContent() {
                TranslateView({
                  onTranslateChange: (value: number, mode: SliderChangeMode) => {
                    this.sliderTranslateChange(value, mode);
                  }
                })
              }
              .padding({ bottom: 19 })
              .tabBar(this.TabBuilderMenu(MainTabId.TRANSLATE, $r('app.string.translate')))
              .clip(false)

              TabContent() {
                ZoomView({
                  onZoomChange: (value: number, mode: SliderChangeMode) => {
                    this.sliderZoomChange(value, mode);
                  }
                })
              }
              .padding({ bottom: 19 })
              .clip(false)
              .tabBar(this.TabBuilderMenu(MainTabId.ZOOM, $r('app.string.zoom')))
            }
            .scrollable(false)
            .clip(false)
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
          }
          .padding({ bottom: 30 })
          .width(CommonConstants.LAYOUT_FULL_SCREEN)
          .height('34%')
          .backgroundColor(Color.Black)
        }
        .width(CommonConstants.LAYOUT_FULL_SCREEN)
        .height('calc(100% - 92vp)')
      }
      .width(CommonConstants.LAYOUT_FULL_SCREEN)
      .height(CommonConstants.LAYOUT_FULL_SCREEN)
      .bindSheet($$this.isShow, this.infoBuilder(), {
        height: SheetSize.FIT_CONTENT,
        onWillAppear: () => {
          console.log('BindSheet onWillAppear.');
        },
        onAppear: () => {
          console.log('BindSheet onAppear.');
        },
        onWillDisappear: () => {
          console.log('BindSheet onWillDisappear.');
        },
        onDisappear: () => {
          console.log('BindSheet onDisappear.');
        }
      })
    }
    .backgroundColor(Color.Black)
    .width(CommonConstants.LAYOUT_FULL_SCREEN)
    .height(CommonConstants.LAYOUT_FULL_SCREEN)
  }
}