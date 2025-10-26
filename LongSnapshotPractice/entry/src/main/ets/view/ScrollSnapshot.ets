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
import { PopupUtils } from '../common/PopupUtils';
import { NewsItem } from './NewsItem';
import { SnapshotPreview } from './SnapshotPreview';
import { LazyDataSource } from '../common/LazyDataSource';
import { CommonUtils } from '../common/CommonUtils';
import { ImageUtils } from '../common/ImageUtils';
import { Logger } from '../common/Logger';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

const LIST_ID = 'LIST_ID';
const TAG = 'ScrollSnapshot';

// [Start scroll_snapshot]
// [Start component]
// [Start context]
// src/main/ets/view/ScrollSnapshot.ets
@Component
export struct ScrollSnapshot {
  // Scroll controller
  private scroller: Scroller = new Scroller();
  private listComponentWidth: number = 0;
  private listComponentHeight: number = 0;
  // The current offset of the List component
  private curYOffset: number = 0;
  private scrollHeight: number = 0;

  // [StartExclude scroll_snapshot]
  // The component is overwritten during the screenshot process
  @State componentMaskImage: PixelMap | undefined = undefined;
  // The location of the component before backing up the screenshot
  private yOffsetBefore: number = 0;
  // [StartExclude component]
  // is click to stop scroll
  private isClickStop: boolean = false;
  @State isEnableScroll: boolean = true;
  // [StartExclude context]
  @StorageLink('screenWidth') screenWidth: number = 0;
  @StorageLink('screenHeight') screenHeight: number = 0;
  // The component is overwritten during the screenshot process
  @State snapPopupPosition: Position = { x: 0, y: 0 };
  // Whether to display the preview window
  @State isShowPreview: boolean = false;
  // Displays a long screenshot to preview a larger image
  @State isLargePreview: boolean = false;
  // Long picture after stitching
  @State mergedImage: PixelMap | undefined = undefined;

  // One-click screenshot scrolling process caching
  private areaArray: image.PositionArea[] = [];
  // The y-direction offset of the List component on each page during the screenshot scrolling process, in the unit of vp
  private scrollYOffsets: number[] = [];

  private dataSource = new LazyDataSource<number>();

  aboutToAppear(): void {
    // init List data
    for (let i = 0; i < 20; i++) {
      this.dataSource.pushData(i);
    }
  }
  // [EndExclude component]
  /**
   * One-click screenshot
   */
  async onceSnapshot() {
    await this.beforeSnapshot();
    await this.snapAndMerge();
    await this.afterSnapshot();
    // [StartExclude component]
    this.afterGeneratorImage();
    // [EndExclude component]
  }

  // [EndExclude context]
  /**
   * Scroll through the screenshots
   */
  async scrollSnapshot() {
    // The settings list cannot be manually scrolled during the screenshot process
    // to avoid interference with the screenshot
    this.isEnableScroll = false;
    // Saves the current location of the component for recovery
    this.yOffsetBefore = this.curYOffset;
    // Set the prompt pop-up to be centered
    this.snapPopupPosition = PopupUtils.calcPopupCenter(this.screenWidth, this.screenHeight, 100, 200);
    await this.scrollSnapAndMerge();
    // [StartExclude context]
    // Open the prompt pop-up window
    this.isShowPreview = true;
    // Initial variable after stitching
    await this.afterGeneratorImage();
    // [EndExclude context]
    this.isEnableScroll = true;
    this.isClickStop = false;
  }

  // [Start snapand_merge]
  /**
   * One click screenshot loop traversal screenshot and merge
   */
  async snapAndMerge() {
    try {
      this.scrollYOffsets.push(this.curYOffset);
      // Call the component screenshot interface to obtain the current screenshot
      const pixelMap = await this.getUIContext().getComponentSnapshot().get(LIST_ID);
      // Gets the number of bytes per line of image pixels.
      let area: image.PositionArea =
        await ImageUtils.getSnapshotArea(pixelMap, this.scrollYOffsets, this.listComponentWidth,
          this.listComponentHeight);
      this.areaArray.push(area);
      // Determine whether the bottom has been reached during the loop process
      if (!this.scroller.isAtEnd()) {
        CommonUtils.scrollAnimation(this.scroller, 200, this.scrollHeight);
        await CommonUtils.sleep(200)
        await this.snapAndMerge();
      } else {
        this.mergedImage =
          await ImageUtils.mergeImage(this.areaArray, this.scrollYOffsets[this.scrollYOffsets.length - 1],
            this.listComponentWidth, this.listComponentHeight);
      }
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `snapAndMerge err, errCode: ${error.code}, error mesage: ${error.message}`);
    }
  }
  // [End snapand_merge]

  // [Start scroll_snapand_merge]
  /**
   * Rolling screenshots, looping through screenshots, and merge them
   */
  async scrollSnapAndMerge() {
    try {
      // Record an array of scrolls
      this.scrollYOffsets.push(this.curYOffset - this.yOffsetBefore);
      // Call the API for taking screenshots to obtain the current screenshots
      const pixelMap = await this.getUIContext().getComponentSnapshot().get(LIST_ID);
      // Gets the number of bytes per line of image pixels.
      let area: image.PositionArea =
        await ImageUtils.getSnapshotArea(pixelMap, this.scrollYOffsets, this.listComponentWidth,
          this.listComponentHeight)
      this.areaArray.push(area);

      // During the loop, it is determined whether the bottom is reached, and the user does not stop taking screenshots
      if (!this.scroller.isAtEnd() && !this.isClickStop) {
        // Scroll to the next page without scrolling to the end
        CommonUtils.scrollAnimation(this.scroller, 1000, this.scrollHeight);
        await CommonUtils.sleep(1500);
        await this.scrollSnapAndMerge();
      } else {
        // After scrolling to the bottom, the buffer obtained by each round of scrolling is spliced
        // to generate a long screenshot
        this.mergedImage =
          await ImageUtils.mergeImage(this.areaArray, this.scrollYOffsets[this.scrollYOffsets.length - 1],
            this.listComponentWidth, this.listComponentHeight);
      }
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `scrollSnapAndMerge err, errCode: ${error.code}, error mesage: ${error.message}`);
    }
  }
  // [End scroll_snapand_merge]

  async beforeSnapshot() {
    try {
      this.yOffsetBefore = this.curYOffset;
      // Take a screenshot of the loaded List component as a cover image for the List component
      this.componentMaskImage = await this.getUIContext().getComponentSnapshot().get(LIST_ID);
      this.scroller.scrollTo({
        xOffset: 0,
        yOffset: 0,
        animation:
        {
          duration: 200
        }
      });
      // [StartExclude component]
      this.snapPopupPosition = PopupUtils.calcPopupCenter(this.screenWidth, this.screenHeight, 100, 200);
      this.isShowPreview = true;
      // Delay ensures that the scroll has reached the top
      // [EndExclude component]
      await CommonUtils.sleep(200);
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `beforeSnapshot err, errCode: ${error.code}, error mesage: ${error.message}`);
    }
  }

  // [Start after_snapshot]
  async afterSnapshot() {
    this.scroller.scrollTo({
      xOffset: 0,
      yOffset: this.yOffsetBefore,
      animation: {
        duration: 200
      }
    });
    await CommonUtils.sleep(200);
  }
  // [End after_snapshot]

  async afterGeneratorImage() {
    // Delay for transition animation
    await CommonUtils.sleep(200);
    this.snapPopupPosition = PopupUtils.calcPopupBottomLeft(this.screenHeight, 200);
    this.componentMaskImage = undefined;
    this.scrollYOffsets.length = 0;
    this.areaArray.length = 0;
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

  // [EndExclude scroll_snapshot]
  build() {
    // [StartExclude context]
    // [StartExclude component]
    // [StartExclude scroll_snapshot]
    NavDestination() {
      Column() {
    // [EndExclude scroll_snapshot]
        // [EndExclude component]
        Stack() {
          // [StartExclude scroll_snapshot]
          //  The masking layer of the screenshot process prevents users from noticing the screen swiping quickly
          //  and improves the user experience
          if (this.componentMaskImage) {
            Image(this.componentMaskImage)
              // [StartExclude component]
              .width('100%')
              .height('100%')
              .zIndex(2)
              .backgroundColor('#FFDCDCDC')
            // [EndExclude component]
          }
          // [EndExclude scroll_snapshot]
          // [EndExclude context]
          List({
            space: 12,
            scroller: this.scroller
          })
          // [StartExclude context]
          // [StartExclude component]
          // [StartExclude scroll_snapshot]
          {
            LazyForEach(this.dataSource, (item: number) => {
              ListItem() {
                NewsItem({ index: item })
              }
            }, (item: number) => item.toString())
          }
          .scrollBar(BarState.Off)
          .cachedCount(3)
          .width('100%')
          .height('100%')
          .backgroundColor($r('sys.color.background_secondary'))
          .enableScrollInteraction(this.isEnableScroll)
          // [EndExclude scroll_snapshot]
          // [EndExclude component]
          // [EndExclude context]
          .id(LIST_ID)
          .onDidScroll(() => {
            this.curYOffset = this.scroller.currentOffset().yOffset;
          })
          .onAreaChange((oldValue, newValue) => {
            this.listComponentWidth = newValue.width as number;
            this.listComponentHeight = newValue.height as number;
            this.scrollHeight = this.listComponentHeight;
          })
          .onClick(() => {
            // Click on the list to stop scrolling
            if (!this.isEnableScroll) {
              this.scroller.scrollBy(0, 0);
              this.isClickStop = true;
            }
          })
        }
        .width('100%')
        .layoutWeight(1)
        .padding({
          left: 16,
          right: 16,
          top: 16
        })
        .bindContentCover($$this.isShowPreview, this.previewWindowComponent(),
          {
            modalTransition: ModalTransition.NONE,
            onWillDismiss: (action: DismissContentCoverAction) => {
              if (action.reason === DismissReason.PRESS_BACK) {
                Logger.info('BindContentCover dismiss reason is back pressed');
              }
            }
          })

        Row({ space: 12 }) {
          Button($r('app.string.one_click_snapshot'))
            .layoutWeight(1)
            .onClick(() => {
              this.onceSnapshot();
            })
          Button($r('app.string.scroll_snapshot'))
            .layoutWeight(1)
            .onClick(() => {
              // Prevent users from clicking the button during the screenshot process,
              // and the method is repeatedly called, resulting in an exception
              if (this.scrollYOffsets.length === 0) {
                this.scrollSnapshot();
              }
            })
        }
        .width('100%')
        .padding({
          left: 16,
          right: 16,
          bottom: (AppStorage.get<number>('naviIndicatorHeight') ?? 0) + 16,
          top: 12
        })
      }
    }
    .title($r('app.string.title_scroll_snapshot'))
    .backgroundColor($r('sys.color.background_secondary'))
  }
}
// [End context]
// [End scroll_snapshot]
// [End component]