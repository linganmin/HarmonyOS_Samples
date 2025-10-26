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
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { IconStatus } from '../viewModel/IconListViewModel';
import { CommonConstants } from '../common/constant/CommonConstants';
import { TitleComponent } from '../component/TitleComponent';
import { TabComponent } from '../component/TabComponent';
import { decodePixelMapFromImageSource, getResourceFd } from '../utils/DecodeUtil';
import { ContextStorageManager } from '../utils/ContextStorageUtil';
import { cropIconChangeList } from '../viewModel/IconListViewModel';
import { cropListData, translateListData } from '../viewModel/PictureEditModelData';
import { ImageDisplaySize, InitDataArrType, ParamsType, TranslateListType } from '../viewModel/PictureEditModel';
import { display } from '@kit.ArkUI';
import { PixelMapManager } from '../utils/PixelMapManager';
import { MirrorType, CropType, FilterType } from '../viewModel/OptionViewModel';

const DOMAIN = 0xFF00;
const TAG: string = 'PictureEdit';

enum EditMode {
  CROP_MODE,
  ADJUST_MODE,
  FILTER_MODE,
  TRANSLATE_MODE,
  ZOOM_MODE,
  WATER_MODE
}

@Entry
@Component
struct PictureEdit {
  uiContext: UIContext = ContextStorageManager.getInstance().getContext();
  uri: string = '';
  imageSource?: image.ImageSource;
  @StorageProp('imageInfoArr') imageInfoArr: InitDataArrType[] = [];
  @Provide pixelMapManager?: PixelMapManager | undefined = undefined;
  @State previewCropPixelMap?: image.PixelMap = undefined;
  @Provide previewPixelMap?: image.PixelMap = undefined;
  @Provide currentEditMode: EditMode = EditMode.CROP_MODE;
  @Provide currentCropMode: number = CropType.ORIGINAL_IMAGE;
  @Provide filterCurrMode: number = FilterType.ORIGIN;
  @Provide currentTranslateData: number[] = [0, 0];
  @Provide currentTranslateMode: number = 0;
  @Provide currentZoom: number = 100;
  @State isShow: boolean = false;
  @Provide('pixelMap') pixelMap?: image.PixelMap = undefined;
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
  cropIconChange: Array<IconStatus> = cropIconChangeList;
  @State saveButtonOptions: SaveButtonOptions = {
    icon: SaveIconStyle.FULL_FILLED
  };
  @Provide currentIndex: number = 0;
  @Provide currentCropIndex: number = 0;
  @State currentTranslateIndex: number = 0;
  @State cropList: TranslateListType[] = cropListData;
  @State translateList: TranslateListType[] = translateListData;
  @State waterShow: boolean = false;
  @State dividerList: number[] = [0, 1, 2, 3, 4, 5];
  @Provide('pixelMapInit') pixelMapInit?: image.PixelMap = undefined;
  @Provide filterPixelMap?: image.PixelMap = undefined;
  @Provide savePixelMap?: image.PixelMap = undefined;
  @Provide cropPixelMap?: image.PixelMap = undefined;
  @Provide cropInitPixelMap?: image.PixelMap = undefined;
  @Provide adjustPixelMap?: image.PixelMap = undefined;
  @Provide filterCurrIndex: number = 0;
  @Provide translateX: number = 0;
  @Provide translateY: number = 0;
  @Provide isInitTranslateValue: boolean = false;
  private canvasRenderingContext: CanvasRenderingContext2D = new CanvasRenderingContext2D();
  @State containerWidth: number = 0;
  @State containerHeight: number = 0;
  @State imageWidth: number = 0;
  @State imageHeight: number = 0;
  @State canvasReady: boolean = false;
  @State imageLoaded: boolean = false;
  @Provide isRotate: boolean = false;
  @State canvasOffsetX: number = 0;
  @State canvasOffsetY: number = 0;
  @State displaySize: ImageDisplaySize | null = null;
  @State imageToRender: image.PixelMap | undefined = undefined;
  private redrawRequested: boolean = false;
  @State refreshRate: number = 0;

  aboutToAppear() {
    AppStorage.setOrCreate('isColorInfo', false);
    this.getRefreshRate();
    try {
      const params = this.uiContext.getRouter().getParams() as ParamsType;
      if (params && params.selectUris) {
        this.uri = params.selectUris;
        hilog.info(DOMAIN, TAG, '%{public}s, %{public}s', 'Got URI from router params:', this.uri);
        ContextStorageManager.getInstance().initUri(this.uri);
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, '%{public}s, %{public}s', 'Failed to get router params:', JSON.stringify(error));
    }

    this.pixelInit();
    this.initData();
  }

  aboutToDisappear(): void {
    this.imageSource?.release();
  }

  getRefreshRate() {
    try {
      const refreshRateNow = display.getDefaultDisplaySync().refreshRate;
      this.refreshRate = Math.floor(1000 / refreshRateNow);
    } catch (err) {
      hilog.error(DOMAIN, TAG, '%{public}s', 'have errors', `${JSON.stringify(err)}`);
    }
  }

  async initData() {
    try {
      this.imageSource = image.createImageSource(await getResourceFd(this.uiContext, this.uri));


      this.imageSource.getImageInfo((err, imageInfo) => {
        if (err) {
          hilog.error(DOMAIN, TAG, '%{public}s, %{public}s', 'Failed to get image info:', JSON.stringify(err));
          return;
        }
        this.imageInfo = imageInfo;
        this.imageWidth = imageInfo.size.width;
        this.imageHeight = imageInfo.size.height;
        this.imageLoaded = true;
        hilog.info(DOMAIN, TAG, '%{public}s', `Image loaded successfully: ${this.imageWidth} x ${this.imageHeight}`);

        this.triggerCanvasRedraw();

        Object.keys(imageInfo).forEach((key) => {
          if (key === 'size') {
            Object.keys(imageInfo[key]).forEach((chlKey) => {
              this.imageInfoArr.push({
                label: chlKey as '',
                value: imageInfo[key][chlKey]
              });
            });
          } else {
            this.imageInfoArr.push({
              label: key as '',
              value: imageInfo[key]
            });
          }
        });
      });
      AppStorage.setOrCreate('imageInfoArr', this.imageInfoArr);
    } catch (error) {
      hilog.error(DOMAIN, TAG, '%{public}s, %{public}s', 'Error in initData:', JSON.stringify(error));
    }
  }

  calculateImageDisplaySize(): ImageDisplaySize {
    if (this.containerWidth === 0 || this.containerHeight === 0 || this.imageWidth === 0 || this.imageHeight === 0) {
      return {
        x: 0,
        y: 0,
        width: 0,
        height: 0
      };
    }

    const containerRatio = this.containerWidth / this.containerHeight;
    const imageRatio = this.imageWidth / this.imageHeight;

    const zoomFactor = this.currentZoom / 100;

    let baseDisplayWidth: number;
    let baseDisplayHeight: number;
    if (this.currentEditMode === 0 && this.isRotate) {
      baseDisplayWidth = this.displaySize!.height;
      baseDisplayHeight = this.displaySize!.width;
    } else {
      if (imageRatio > containerRatio) {
        baseDisplayWidth = this.containerWidth;
        baseDisplayHeight = this.containerWidth / imageRatio;
      } else {
        baseDisplayHeight = this.containerHeight;
        baseDisplayWidth = this.containerHeight * imageRatio;
      }
    }
    const displayWidth = baseDisplayWidth * zoomFactor;
    const displayHeight = baseDisplayHeight * zoomFactor;

    const x = (this.containerWidth - displayWidth) / 2;
    const y = (this.containerHeight - displayHeight) / 2;
    this.isRotate = false;
    return {
      x,
      y,
      width: displayWidth,
      height: displayHeight
    };
  }

  // Top reset
  async pixelInit() {
    try {
      let uri = '';
      let imageSource = image.createImageSource(await getResourceFd(this.getUIContext(), uri));
      const px = await decodePixelMapFromImageSource(imageSource);
      this.pixelMapManager = new PixelMapManager(px!, (pixelMap: image.PixelMap) => {
        this.pixelMap = pixelMap;
        this.previewPixelMap = pixelMap;
        this.previewCropPixelMap = pixelMap;
      });
      this.filterCurrMode = FilterType.ORIGIN;
      this.currentCropMode = CropType.ORIGINAL_IMAGE;

      this.filterCurrIndex = 0;
      this.currentCropIndex = 0;
      this.translateX = 0;
      this.translateY = 0;
      this.isRotate = false;
      this.currentAdjustData = CommonConstants.ADJUST_SLIDER_VALUE.map((item: number) => item);

      this.currentTranslateData = [0, 0];
      this.currentZoom = 100;

      this.triggerCanvasRedraw();
      this.isInitTranslateValue = true;
    } catch (error) {
      hilog.error(DOMAIN, TAG, '%{public}s, %{public}s', 'Error in pixelInit:', JSON.stringify(error));
    }
  }

  rotateImage() {
    this.pixelMapManager?.rotateImage();
  }

  mirrorImage() {
    this.pixelMapManager?.mirrorImage(MirrorType.CLOCKWISE);
  }

  flushPixelMapChange() {
    setTimeout(() => {
      this.drawImageOnCanvas();
    }, this.refreshRate);
  }

  // Canvas drawing
  drawImageOnCanvas() {
    if (!this.canvasReady || !this.imageLoaded || !this.previewPixelMap) {
      return;
    }

    try {
      this.canvasRenderingContext.clearRect(0, 0, this.containerWidth, this.containerHeight);

      this.previewPixelMap?.getImageInfo().then((info) => {
        this.imageWidth = info.size.width;
        this.imageHeight = info.size.height;

        this.displaySize = this.calculateImageDisplaySize();

        if (this.displaySize.width > 0 && this.displaySize.height > 0) {

          const finalX = this.displaySize.x + this.canvasOffsetX + this.translateX;
          const finalY = this.displaySize.y + this.canvasOffsetY + this.translateY;

          this.canvasRenderingContext.drawImage(
            this.previewPixelMap,
            finalX,
            finalY,
          );
          this.savePixelMap = this.canvasRenderingContext.getPixelMap(0, 0, this.containerWidth, this.containerHeight);
        }
      });
    } catch (error) {
      hilog.error(DOMAIN, TAG, '%{public}s, %{public}s', 'Canvas drawing failed:', JSON.stringify(error));
    }
  }

  triggerCanvasRedraw() {
    if (this.canvasReady && this.imageLoaded && this.previewPixelMap) {
      if (!this.redrawRequested) {
        this.redrawRequested = true;
        setTimeout(() => {
          this.drawImageOnCanvas();
          this.redrawRequested = false;
        }, this.refreshRate);
      }
    }
  }

  reset() {
    this.pixelMapManager?.updatePreviewPixelMap(this.pixelMapManager.getInitPixelMap());
    this.pixelMapManager?.updateCropPixelMap(this.pixelMapManager.getInitPixelMap());
    this.filterCurrMode = FilterType.ORIGIN;
    this.currentCropMode = CropType.ORIGINAL_IMAGE;
    this.currentAdjustData = CommonConstants.ADJUST_SLIDER_VALUE.map((item: number) => item);
    if (this.translateX === 0 && this.translateY === 0) {
      this.currentTranslateData = [0, 0];
    }
    this.currentZoom = 100;
    this.triggerCanvasRedraw();
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
          ForEach(this.imageInfoArr, (item: InitDataArrType, index) => {
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

            if (this.dividerList.includes(index)) {
              Divider().strokeWidth(0.5).color($r('sys.color.mask_fourth'));
            }
          }, (item: string) => item)
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
    RelativeContainer() {
      Column() {
        TitleComponent({
          isShow: this.isShow,
          canvasOffsetX: this.canvasOffsetX,
          canvasOffsetY: this.canvasOffsetY,
          pixelInit: () => {
            this.pixelInit();
          }
        })
          .width('100%')

        Column() {
          Column() {
            Canvas(this.canvasRenderingContext)
              .width('100%')
              .height('100%')
              .backgroundColor(Color.Transparent)
              .onReady(() => {
                this.canvasReady = true;
                this.triggerCanvasRedraw();

              })
              .onAreaChange((_oldValue: Area, newValue: Area) => {
                this.containerWidth = Number(newValue.width);
                this.containerHeight = Number(newValue.height);
                this.triggerCanvasRedraw();
              })
              .opacity(this.filterCurrIndex ? 0 : 1)
              .transition(TransitionEffect.OPACITY.animation({ duration: 400 }))

          }
          .margin({ top: 5 })
          .width(CommonConstants.LAYOUT_FULL_SCREEN)
          .height('66%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)

          TabComponent({
            displaySize: this.displaySize as ImageDisplaySize,
            containerWidth: this.containerWidth,
            containerHeight: this.containerHeight,
            cropList: this.cropList,
            currentCropIndex: this.currentCropIndex,
            currentIndex: this.currentIndex,
            currentTranslateData: this.currentTranslateData,
            currentTranslateIndex: this.currentTranslateIndex,
            translateList: this.translateList,
            currentZoom: this.currentZoom,
            waterShow: this.waterShow,
            canvasOffsetX: this.canvasOffsetX,
            canvasOffsetY: this.canvasOffsetY,
            triggerCanvasRedraw: () => {
              this.triggerCanvasRedraw();
            },
            flushPixelMapChange: () => {
              this.flushPixelMapChange();
            },
            reset: () => {
              this.reset();
            }
          })
            .padding({ bottom: 30 })
            .width(CommonConstants.LAYOUT_FULL_SCREEN)
            .height('34%')
            .backgroundColor(Color.Black)
        }
        .width(CommonConstants.LAYOUT_FULL_SCREEN)
        .height('calc(100% - 28vp)')
      }
      .width(CommonConstants.LAYOUT_FULL_SCREEN)
      .height(CommonConstants.LAYOUT_FULL_SCREEN)
      .bindSheet($$this.isShow, this.infoBuilder(), {
        height: SheetSize.FIT_CONTENT,
        onDisappear: () => {
          this.isShow = false;
        }
      })
    }
    .backgroundColor(Color.Black)
    .width(CommonConstants.LAYOUT_FULL_SCREEN)
    .height(CommonConstants.LAYOUT_FULL_SCREEN)
  }
}
