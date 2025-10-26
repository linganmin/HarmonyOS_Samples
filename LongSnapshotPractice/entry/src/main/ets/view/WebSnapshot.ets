/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { image } from '@kit.ImageKit';
import { webview } from '@kit.ArkWeb';
import { Logger } from '../common/Logger';
import { PopupUtils } from '../common/PopupUtils';
import { SnapshotPreview } from './SnapshotPreview';
import { CommonUtils } from '../common/CommonUtils';
import { ImageUtils } from '../common/ImageUtils';
import { BusinessError } from '@kit.BasicServicesKit';

const EXAMPLE_URL =
  'https://developer.huawei.com/consumer/cn/doc/best-practices-V5/bpta-develop-once-deploy-everywhere-V5?catalogVersion=V5';
const WEB_ID = 'WebPage';
const TAG = 'WebSnapshot';

@Component
export struct WebSnapshot {
  @StorageLink('screenWidth') screenWidth: number = 0;
  @StorageLink('screenHeight') screenHeight: number = 0;
  // Web component overlay during screenshot process
  @State componentMaskImage: PixelMap | undefined = undefined;
  // Long picture after stitching
  @State mergedImage: PixelMap | undefined = undefined;
  @State snapPopupPosition: Position = { x: 0, y: 0 };
  // Whether to display the preview window
  @State isShowPreview: boolean = false;
  // Displays a long screenshot to preview a larger image
  @State isLargePreview: boolean = false;
  private scrollYOffsets: number[] = [];
  // One click screenshot scrolling process cache
  private areaArray: image.PositionArea[] = [];
  // Web URL and WebviewController object
  private webviewController: webview.WebviewController = new webview.WebviewController();
  // Web component size
  private webComponentWidth: number = 0;
  private webComponentHeight: number = 0;
  // Current webpage location
  private curYOffset: number = 0;
  // Backup the current webpage location
  private yOffsetBefore: number = 0;
  private scrollHeight: number = 0;
  // Is web loaded finish
  private isLoadedFinish: boolean = false;
  // [Start about_to_appear]
  aboutToAppear(): void {
    try {
      webview.WebviewController.initializeWebEngine();
      webview.WebviewController.enableWholeWebPageDrawing();
      // Pre connect, perform DNS resolution and socket chaining operations on URLs,
      // without obtaining primary or secondary resources
      webview.WebviewController.prepareForPageLoad(EXAMPLE_URL, true, 2);
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `Web sapshot err, errCode: ${error.code}, error mesage: ${error.message}`);
    }
  }
  // [End about_to_appear]
  /**
   * One-click screenshot
   */
  async onceSnapshot() {
    await this.beforeSnapshot();
    await this.snapAndMerge();
    await this.afterSnapshot();
    await this.afterGeneratorImage();
  }
  // [Start snapand_merge1]
  /**
   * One click screenshot loop traversal screenshot and merge
   */
  async snapAndMerge() {
    try {
      this.scrollYOffsets.push(this.curYOffset);
      // Call the component screenshot interface to obtain the current screenshot
      const pixelMap = await this.getUIContext().getComponentSnapshot().get(WEB_ID);
      let area: image.PositionArea =
        await ImageUtils.getSnapshotArea(pixelMap, this.scrollYOffsets, this.webComponentWidth,
          this.webComponentHeight);
      this.areaArray.push(area);
      // Determine whether the bottom has been reached during the loop process
      if (Math.ceil(this.curYOffset + this.webComponentHeight) < this.webviewController.getPageHeight()) {
        // Not scrolling to the bottom, scrolling to the next page
        this.webviewController.scrollBy(0, this.scrollHeight, 500);
        await CommonUtils.sleep(600)
        await this.snapAndMerge();
      } else {
        this.mergedImage =
          await ImageUtils.mergeImage(this.areaArray, this.scrollYOffsets[this.scrollYOffsets.length - 1],
            this.webComponentWidth, this.webComponentHeight);
      }
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `snapAndMerge err, errCode: ${error.code}, error mesage: ${error.message}`);
    }
  }
  // [End snapand_merge1]

  /**
   * The operation before starting the screenshot.
   */
  async beforeSnapshot() {
    try {
      this.yOffsetBefore = this.curYOffset;
      this.componentMaskImage = await this.getUIContext().getComponentSnapshot().get(WEB_ID);
      this.webviewController.scrollTo(0, 0);
      this.snapPopupPosition = PopupUtils.calcPopupCenter(this.screenWidth, this.screenHeight, 100, 200);
      this.isShowPreview = true;
      // Delay ensures that the scroll has reached the top
      await CommonUtils.sleep(500);
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `beforeSnapshot err, errCode: ${error.code}, error mesage: ${error.message}`);
    }
  }

  /**
   * The operation after taking the screenshot.
   * Restore the web page to its original position before the screenshot
   * Cancel the mask layer
   */
  async afterSnapshot() {
    try {
      this.webviewController.scrollTo(0, this.yOffsetBefore, 300);
      await CommonUtils.sleep(300);
      this.componentMaskImage = undefined;
      this.scrollYOffsets.length = 0;
      this.areaArray.length = 0;
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `afterSnapshot err, errCode: ${error.code}, error mesage: ${error.message}`);
    }
  }

  /**
   * The operation of generating stitched images. Used for creating animations that move windows.
   */
  async afterGeneratorImage() {
    await CommonUtils.sleep(200);
    this.snapPopupPosition = PopupUtils.calcPopupBottomLeft(this.screenHeight, 200);
  }

  @Builder
  previewWindowComponent() {
    Column() {
      SnapshotPreview({
        mergedImage: $mergedImage,
        snapPopupPosition: $snapPopupPosition,
        isLargePreview: $isLargePreview,
        isShowPreview: $isShowPreview
      })
    }
  }

  build() {
    NavDestination() {
      Column() {
        Stack() {
          if (this.componentMaskImage) {
            Image(this.componentMaskImage)
              .width('100%')
              .height('100%')
              .zIndex(2)
              .backgroundColor('#FFDCDCDC')
          }

          Web({
            src: EXAMPLE_URL,
            controller: this.webviewController
          })
            .padding(16)
            .backgroundColor($r('sys.color.background_secondary'))
            .width('100%')
            .height('100%')
            .id(WEB_ID)
            .onAreaChange((oldValue, newValue) => {
              this.webComponentWidth = newValue.width as number;
              this.webComponentHeight = newValue.height as number;
              this.scrollHeight = this.webComponentHeight * 0.7;
            })
            .onScroll((event) => {
              this.curYOffset = event.yOffset;
            })
            .onPageEnd(() => {
              Logger.info('onPageEnd');
              this.isLoadedFinish = true;
            })
        }
        .width('100%')
        .layoutWeight(1)
        .borderRadius(12)
        .bindContentCover($$this.isShowPreview, this.previewWindowComponent(),
          {
            modalTransition: ModalTransition.NONE,
            onWillDismiss: (action: DismissContentCoverAction) => {
              if (action.reason === DismissReason.PRESS_BACK) {
                Logger.info('BindContentCover dismiss reason is back pressed');
              }
            }
          })

        Stack() {
          Button($r('app.string.one_click_snapshot'))
            .width('100%')
            .onClick(() => {
              if (this.isLoadedFinish) {
                this.onceSnapshot();
              }
            })
        }
        .backgroundColor(Color.White)
        .padding({
          left: 16,
          right: 16,
          bottom: (AppStorage.get<number>('naviIndicatorHeight') ?? 0) + 16,
          top: 12
        })
      }
      .width('100%')
      .height('100%')
    }
    .title($r('app.string.title_web_snapshot'))
    .backgroundColor($r('sys.color.background_secondary'))
  }
}