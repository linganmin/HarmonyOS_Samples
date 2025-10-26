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

import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Constants } from '../common/Constants';
import { ReaderPage } from './ReaderPage';

// [Start cover_flip_1]
// entry/src/main/ets/view/CoverFlipPage.ets
@Component
export struct CoverFlipPage {
  // [StartExclude cover_flip_1]
  @StorageLink('pageHide') @Watch('isPageHide') pageHide: boolean = false;
  @StorageLink('windowWidth') @Watch('updateScreenW') windowWidth: number = 0;
  @State leftPageContent: string = '';
  @State midPageContent: string = '';
  @State rightPageContent: string = '';
  @Link isMenuViewVisible: boolean;
  @Link currentPageNum: number;
  // [EndExclude cover_flip_1]
  @State offsetX: number = 0;
  @State screenW: number = 0;
  // [StartExclude cover_flip_1]
  private panOption: PanGestureOptions = new PanGestureOptions({ direction: PanDirection.Left | PanDirection.Right });
  private isAnimating: boolean = false;
  private panStartPositionX: number = 0;
  private isAllowPanGesture: boolean = true;
  private isPanGestureStart: boolean = false;
  private isPageForward: boolean = false;
  private isGestureForward: boolean = false;
  private lastPanPositionX: number = 0;

  updateScreenW(){
    this.screenW = this.getUIContext().px2vp(this.windowWidth);
  }

  isPageHide() {
    if (this.pageHide) {
      if (this.offsetX > Constants.PAGE_FLIP_RIGHT_FLIP_OFFSETX &&
        this.currentPageNum !== Constants.PAGE_FLIP_PAGE_START) {
        // Previous page.
        this.currentPageNum -= 1;
      } else if (this.offsetX < Constants.PAGE_FLIP_LEFT_FLIP_OFFSETX &&
        this.currentPageNum !== Constants.PAGE_FLIP_PAGE_END) {
        // Next page.
        this.currentPageNum += 1;
      }
      this.offsetX = Constants.PAGE_FLIP_ZERO;
      this.simulatePageContent();

      this.isPanGestureStart = false;
      this.panStartPositionX = 0;
    }
  }

  aboutToAppear() {
    this.simulatePageContent();
    this.updateScreenW();
  }

  /**
   * Retrieve page content based on page number.
   */
  simulatePageContent() {
    this.leftPageContent =
      Constants.PAGE_FLIP_RESOURCE + (this.currentPageNum - 1).toString();
    this.midPageContent = Constants.PAGE_FLIP_RESOURCE + (this.currentPageNum).toString();
    this.rightPageContent =
      Constants.PAGE_FLIP_RESOURCE + (this.currentPageNum + 1).toString();
  }

  /**
   * Page animation.
   *
   * @param isClick Is it an animation triggered by a click?
   * @param isLeft Is the clickable area on the left side?
   */
  // [Start cover_flip_3]
  // entry/src/main/ets/view/CoverFlipPage.ets
  private pageAnimateTo(isClick: boolean, isLeft?: boolean) {
    this.getUIContext().animateTo({
      duration: Constants.PAGE_FLIP_TO_AST_DURATION,
      curve: Curve.EaseOut,
      onFinish: () => {
        // [StartExclude cover_flip_3]
        if (this.offsetX > Constants.PAGE_FLIP_RIGHT_FLIP_OFFSETX &&
          this.currentPageNum !== Constants.PAGE_FLIP_PAGE_START) {
          // Previous page.
          this.currentPageNum -= 1;
        } else if (this.offsetX < Constants.PAGE_FLIP_LEFT_FLIP_OFFSETX &&
          this.currentPageNum !== Constants.PAGE_FLIP_PAGE_END) {
          // Next page.
          this.currentPageNum += 1;
        }
        // [EndExclude cover_flip_3]
        this.offsetX = Constants.PAGE_FLIP_ZERO;
        this.simulatePageContent();
        // [StartExclude cover_flip_3]
        // Mark the end of the animation.
        this.isAnimating = false;
        // [EndExclude cover_flip_3]
      }
    }, () => {
      // [StartExclude cover_flip_3]
      if (isClick) {
        if (isLeft) {
          // Previous page.
          this.offsetX = this.screenW;
        } else {
          // Next page.
          this.offsetX = -this.screenW;
        }
      } else {
        if (!this.isPageForward && !this.isGestureForward && this.offsetX < Constants.PAGE_FLIP_RIGHT_FLIP_OFFSETX &&
          this.currentPageNum !== Constants.PAGE_FLIP_PAGE_END) {
          // The initial sliding direction is the same as the gesture direction at the end,
          // and if the current page is not the last page, flip the page backwards.
          this.offsetX = -this.screenW;
        } else if (this.isPageForward && this.isGestureForward &&
          this.offsetX > Constants.PAGE_FLIP_LEFT_FLIP_OFFSETX &&
          this.currentPageNum !== Constants.PAGE_FLIP_PAGE_START) {
          // The initial sliding direction is the same as the gesture direction at the end,
          // and the current page is not the first page. Page forward.
          // [EndExclude cover_flip_3]
          this.offsetX = this.screenW;
          // [StartExclude cover_flip_3]
        } else if (this.isPageForward && !this.isGestureForward && this.lastPanPositionX < this.panStartPositionX &&
          this.currentPageNum !== Constants.PAGE_FLIP_PAGE_END) {
          // The initial sliding direction is forward, and the gesture direction is backward at the end.
          // The end position is on the left side of the initial position, and the current page is not the last page.
          // The page is flipped backward.
          // [EndExclude cover_flip_3]
          this.offsetX = -this.screenW;
          // [StartExclude cover_flip_3]
        } else if (!this.isPageForward && this.isGestureForward && this.lastPanPositionX > this.panStartPositionX &&
          this.currentPageNum !== Constants.PAGE_FLIP_PAGE_START) {
          // The initial sliding direction is backward, and the gesture direction is forward at the end.
          // The end position is on the right side of the initial position, and the current page is not the first page.
          // Page forward.
          this.offsetX = this.screenW;
        } else {
          // In other cases, the page will be restored.
          this.offsetX = Constants.PAGE_FLIP_ZERO;
        }
      }
      // [EndExclude cover_flip_3]
    });
  }
  // [End cover_flip_3]
  // [EndExclude cover_flip_1]

  build() {
    Stack() {
      // Next page.
      ReaderPage({ content: this.rightPageContent })

      // Current page.
      ReaderPage({ content: this.midPageContent })
        .translate({ x: this.offsetX >= Constants.PAGE_FLIP_ZERO ? Constants.PAGE_FLIP_ZERO : this.offsetX })
        // [StartExclude cover_flip_1]
        .width(this.screenW)
        .shadow({
          radius: 40,
          color: Color.Gray,
          offsetX: 0,
          offsetY: 0
        })
      // [EndExclude cover_flip_1]

      // Previous page, shift the window width to the left.
      ReaderPage({ content: this.leftPageContent })
        .translate({ x: -this.screenW + this.offsetX })
        // [StartExclude cover_flip_1]
        .shadow({
          radius: 40,
          color: this.offsetX > 0 ? Color.Gray : Color.Transparent,
          offsetX: 0,
          offsetY: 0
        })
      // [EndExclude cover_flip_1]
    }
    // [StartExclude cover_flip_1]
    // [Start cover_flip_2]
    // entry/src/main/ets/view/CoverFlipPage.ets
    .gesture(
      PanGesture(this.panOption)
        .onActionUpdate((event?: GestureEvent) => {
          // [StartExclude cover_flip_2]
          if (!event || event.fingerList.length <= 0) {
            hilog.error(0x0000, 'CoverFlipPage', 'GestureEvent is undefined');
            return;
          }

          // When sliding or motion effects are prohibited, sliding is prohibited.
          if (!this.isAllowPanGesture || this.isAnimating) {
            return;
          }

          // Record the horizontal axis of the first sliding point.
          if (this.panStartPositionX === 0) {
            this.panStartPositionX = event.fingerList[0].localX;
            this.lastPanPositionX = this.panStartPositionX;
            return;
          }

          let tmpFingerInfo: FingerInfo = event.fingerList[0];
          if (!tmpFingerInfo) {
            return;
          }
          if (!this.isPanGestureStart) {
            // Determine the sliding direction and the beginning and end pages.
            // When sliding beyond the limit, it is prohibited to slide and a pop-up prompt will appear.
            if (!this.isPageValid(tmpFingerInfo)) {
              return;
            }

            // Mark the start of sliding.
            this.isPanGestureStart = true;

            // Record the initial sliding direction.
            if (this.panStartPositionX < tmpFingerInfo.localX) {
              this.isPageForward = true;
            } else {
              this.isPageForward = false;
            }
          }

          // Compare the horizontal axis of the previous position with the horizontal axis of the current position,
          // and record the current gesture direction.
          if (this.lastPanPositionX < tmpFingerInfo.localX) {
            this.isGestureForward = true;
          } else {
            this.isGestureForward = false;
          }
          this.lastPanPositionX = tmpFingerInfo.localX;

          // The first and last pages restrict sliding.
          if ((this.currentPageNum === Constants.PAGE_FLIP_ONE && event.offsetX >= 0) ||
            (this.currentPageNum === Constants.PAGE_FLIP_PAGE_END && event.offsetX <= 0)) {
            this.offsetX = 0;
          } else {
            // [EndExclude cover_flip_2]
            this.offsetX = event.offsetX;
            // [StartExclude cover_flip_2]
          }
          // [EndExclude cover_flip_2]
        })
        .onActionEnd(() => {
          // [StartExclude cover_flip_2]
          // Exit directly when sliding is prohibited.
          if (!this.isAllowPanGesture) {
            this.isAllowPanGesture = true;
            return;
          }

          // When the dynamic effect is not executed, execute the dynamic effect.
          if (!this.isAnimating) {
            // [EndExclude cover_flip_2]
            this.pageAnimateTo(false);
            // [StartExclude cover_flip_2]
            this.isAnimating = true;
          }

          // Reset data.
          this.isPanGestureStart = false;
          this.panStartPositionX = 0;
          // [EndExclude cover_flip_2]
        })
    )
    // [End cover_flip_2]
    .onClick((event?: ClickEvent) => {
      if (!event) {
        hilog.error(0x0000, 'CoverFlipPage', 'onClick event is undefined');
        return;
      }
      // Click on the right side of the screen.
      if (event.x > (this.screenW / Constants.PAGE_FLIP_THREE * Constants.PAGE_FLIP_TWO)) {
        if (this.currentPageNum !== Constants.PAGE_FLIP_PAGE_END) {
          // Non last page execution animation.
          this.pageAnimateTo(true, false);
        } else {
          // Pop up prompt for the last page.
          this.getUIContext().getPromptAction().showToast({ message: $r('app.string.last_page') });
          return;
        }
      } else if (event.x > (this.screenW / Constants.PAGE_FLIP_THREE)) {
        // Click in the middle of the screen to bring up the menu.
        this.isMenuViewVisible = !this.isMenuViewVisible;
      } else {
        // Click on the left side of the screen.
        if (this.currentPageNum !== Constants.PAGE_FLIP_PAGE_START) {
          // Non homepage execution animation.
          this.pageAnimateTo(true, true);
        } else {
          // Pop up prompt homepage.
          this.getUIContext().getPromptAction().showToast({ message: $r('app.string.first_page') });
          return;
        }
      }
    })
    // [EndExclude cover_flip_1]
  }
  // [StartExclude cover_flip_1]

  private isPageValid(fingerInfo: FingerInfo): boolean {
    // Check the first sliding direction and page number.
    // If the first page slides forward or the last page slides backward, toast prompt will appear.
    if (this.panStartPositionX >= fingerInfo.localX &&
      this.currentPageNum === Constants.PAGE_FLIP_PAGE_END) {
      try {
        this.getUIContext().getPromptAction().showToast({ message: $r('app.string.last_page') });
      } catch (error) {
        let err = error as BusinessError;
        hilog.error(0x0000, 'CoverFlipPage', `showToast failed. error code=${err.code}, message=${err.message}`);
      }
      this.panStartPositionX = 0;
      this.isAllowPanGesture = false;
      return false;
    }

    if (this.panStartPositionX < fingerInfo.localX && this.currentPageNum === Constants.PAGE_FLIP_ONE) {
      try {
        this.getUIContext().getPromptAction().showToast({ message: $r('app.string.first_page') });
      } catch (error) {
        let err = error as BusinessError;
        hilog.error(0x0000, 'CoverFlipPage', `showToast failed. error code=${err.code}, message=${err.message}`);
      }
      this.panStartPositionX = 0;
      this.isAllowPanGesture = false;
      return false;
    }
    return true;
  }
  // [EndExclude cover_flip_1]
}
// [End cover_flip_1]