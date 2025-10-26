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

import { display } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { image } from '@kit.ImageKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Constants, DrawPosition, DrawState, MoveForward } from '../common/Constants';
import { MyNodeController, RectRenderNode } from '../viewmodel/PageNodeController';
import { ReaderPage } from './ReaderPage';

@Component
export struct EmulationFlipPage {
  @StorageLink('positionX') positionX: number = -1;
  @StorageLink('positionY') positionY: number = -1;
  @StorageLink('drawPosition') drawPosition: number = DrawPosition.DP_NONE;
  @StorageLink('windowHeight') windowHeight: number = 0;
  @StorageLink('windowWidth') @Watch('updateScreenW') windowWidth: number = 0;
  @StorageLink('moveForward') gestureMoveForward: number = 0;
  @StorageLink('pagePixelMap') pagePixelMap: image.PixelMap | undefined = undefined;
  @StorageLink('pageHide') @Watch('isPageHide') pageHide: boolean = false;
  @State leftPageContent: string = '';
  @State midPageContent: string = '';
  @State rightPageContent: string = '';
  @State offsetX: number = 0;
  @State isNodeShow: boolean = false;
  @State isMiddlePageHide: boolean = false;
  @Link currentPageNum: number;
  @Link isMenuViewVisible: boolean;
  @State screenW: number = 0;
  private myNodeController: MyNodeController = new MyNodeController();
  private isDrawing: boolean = false;
  private panPositionX: number = 0;
  private timeID: number = -1;
  private snapPageId: string = '';
  private isAllowPanGesture: boolean = true;
  private pageMoveForward: number = MoveForward.MF_NONE;

  updateScreenW() {
    this.screenW = this.getUIContext().px2vp(this.windowWidth);
    this.finishLastGesture();
  }

  isPageHide() {
    if (this.pageHide) {
      this.finishLastGesture();
    }
  }

  aboutToAppear() {
    this.simulatePageContent();
    this.updateScreenW();
  }

  // [Start emulation_3_a]
  // entry/src/main/ets/view/EmulationFlipPage.ets
  newRectNode() {
    // Creates a RectRenderNode object.
    const rectNode = new RectRenderNode();
    // [StartExclude emulation_3_a]
    // Defines the pixel format of rectNode.
    rectNode.frame = {
      x: 0,
      y: 0,
      width: this.getUIContext().px2vp(this.windowWidth),
      height: this.getUIContext().px2vp(this.windowHeight)
    };
    rectNode.pivot = { x: 1, y: 1 };
    rectNode.scale = { x: 1, y: 1 };
    // [EndExclude emulation_3_a]
    this.myNodeController.clearNodes();
    this.myNodeController.addNode(rectNode);
  }
  // [End emulation_3_a]

  simulatePageContent() {
    this.leftPageContent =
      Constants.PAGE_FLIP_RESOURCE + (this.currentPageNum - 1).toString();
    this.midPageContent = Constants.PAGE_FLIP_RESOURCE + (this.currentPageNum).toString();
    this.rightPageContent =
      Constants.PAGE_FLIP_RESOURCE + (this.currentPageNum + 1).toString();
  }

  // [Start emulation_2_a]
  // [Start emulation_2_b]
  // [Start emulation_2_c]
  // [Start emulation_4]
  // entry/src/main/ets/view/EmulationFlipPage.ets
  build() {
    // [Start emulation_1]
    // [StartExclude emulation_2_a]
    // [StartExclude emulation_2_b]
    // [StartExclude emulation_2_c]
    // [StartExclude emulation_4]
    // entry/src/main/ets/view/EmulationFlipPage.ets
    // [EndExclude emulation_2_a]
    // [EndExclude emulation_2_b]
    // [EndExclude emulation_2_c]
    // [EndExclude emulation_4]
    Stack() {
      // [StartExclude emulation_2_a]
      // [StartExclude emulation_2_b]
      // [StartExclude emulation_2_c]
      // [StartExclude emulation_4]
      // Page area is the same as overlay page cover.
      ReaderPage({ content: this.rightPageContent })

      ReaderPage({ content: this.midPageContent })
        .translate({ x: this.offsetX >= Constants.PAGE_FLIP_ZERO ? Constants.PAGE_FLIP_ZERO : this.offsetX })
        .id('middlePage')// Mark the component ID and use it as a screenshot.
        // [StartExclude emulation_1]
        .width(this.screenW)
        .visibility(!this.isMiddlePageHide ? Visibility.Visible : Visibility.None)
        // [EndExclude emulation_1]

      ReaderPage({ content: this.leftPageContent })
        .translate({ x: -this.screenW + this.offsetX })
        .id('leftPage') // Mark the component ID and use it as a screenshot.

      // Display when flipping pages, drawing the current or previous page.
      NodeContainer(this.myNodeController)
        .width(this.getUIContext().px2vp(this.windowWidth))
        .height(this.getUIContext().px2vp(this.windowHeight))
        .visibility(this.isNodeShow ? Visibility.Visible : Visibility.None)
      // [EndExclude emulation_2_a]
      // [EndExclude emulation_2_b]
      // [EndExclude emulation_2_c]
      // [EndExclude emulation_4]
    }
    // [End emulation_1]
    .gesture(
      PanGesture({ fingers: 1 })
      // [StartExclude emulation_4]
        .onActionUpdate((event: GestureEvent) => {
          // [StartExclude emulation_2_a]
          // [StartExclude emulation_2_b]
          // [StartExclude emulation_2_c]
          if (!event || event.fingerList.length <= 0) {
            return;
          }

          // Exit directly when sliding is prohibited.
          if (!this.isAllowPanGesture) {
            return;
          }

          // If the timer has not ended at the beginning of the slide, end the timer and end the page flipping.
          if (this.timeID !== -1) {
            this.finishLastGesture();
            return;
          }

          // Record the horizontal axis of the first sliding point, move to obtain the second point,
          // confirm the sliding direction, and then start drawing.
          let tmpFingerInfo: FingerInfo = event.fingerList[0];
          if (!tmpFingerInfo) {
            return;
          }
          // [EndExclude emulation_2_a]
          if (this.panPositionX === 0) {
            this.initPanPositionX(tmpFingerInfo);
            return;
          }
          // [StartExclude emulation_2_a]

          // [EndExclude emulation_2_b]
          // Perform a check before starting to draw.
          if (!this.isDrawing) {
            // [StartExclude emulation_2_b]
            // When the first or last page slides out of bounds, it is prohibited to slide and toast prompts.
            if (!this.isPageValid(tmpFingerInfo)) {
              hilog.info(0x0000, 'EmulationFlip', 'page not allow panGesture');
              return;
            }
            // [EndExclude emulation_2_b]
            this.firstDrawingInit(tmpFingerInfo);
          }
          // [StartExclude emulation_2_b]
          // [EndExclude emulation_2_c]
          // Execute drawing.
          this.drawing(tmpFingerInfo);
          // [EndExclude emulation_2_a]
          // [EndExclude emulation_2_b]
        })
        // [StartExclude emulation_2_a]
        // [StartExclude emulation_2_b]
        // [StartExclude emulation_2_c]
        // [EndExclude emulation_4]
        .onActionEnd(() => {
          // [StartExclude emulation_4]
          // Exit directly when sliding is prohibited.
          if (!this.isAllowPanGesture) {
            this.isAllowPanGesture = true;
            return;
          }
          // [EndExclude emulation_4]

          // Perform automatic sliding.
          this.autoFlipPage();
          this.isDrawing = false;
        })
      // [EndExclude emulation_2_a]
      // [EndExclude emulation_2_b]
      // [EndExclude emulation_2_c]
    )
    // [StartExclude emulation_2_a]
    // [StartExclude emulation_2_b]
    // [StartExclude emulation_2_c]
    // [StartExclude emulation_4]
    .onClick((event?: ClickEvent) => {
      if (!event) {
        hilog.error(0x0000, 'EmulationFlipPage', 'onClick event is undefined');
        return
      }
      // The timer has not finished executing, ending the previous automatic drawing.
      if (this.timeID !== -1) {
        this.finishLastGesture();
        return;
      }

      // Click on the right 1/3 area to scroll back.
      if (event.x > (this.screenW / Constants.PAGE_FLIP_THREE * Constants.PAGE_FLIP_TWO)) {
        if (this.currentPageNum !== Constants.PAGE_FLIP_PAGE_END) {
          // Set initial value.
          this.clickAutoFlipInit(MoveForward.MF_BACKWARD, event, 'middlePage');

          // After taking a screenshot, perform drawing, hide the middle page,
          // and then perform automatic drawing to prevent the next page from flashing after hiding the middle page.
          this.newRectNode();
          this.isMiddlePageHide = true;
          this.autoFlipPage();
        } else {
          try {
            // The last page is flipped back with a toast prompt.
            this.getUIContext().getPromptAction().showToast({ message: $r('app.string.last_page') });
          } catch (error) {
            let err = error as BusinessError;
            hilog.error(0x0000, 'EmulationFlipPage', `showToast failed. code=${err.code}, message=${err.message}`);
          }
          return;
        }
      } else if (event.x > (this.screenW / Constants.PAGE_FLIP_THREE)) {
        // Control the visibility of the menu bar.
        this.isMenuViewVisible = !this.isMenuViewVisible;
      } else {
        if (this.currentPageNum !== Constants.PAGE_FLIP_PAGE_START) {
          this.clickAutoFlipInit(MoveForward.MF_FORWARD, event, 'leftPage');
          this.autoFlipPage();
        } else {
          // Page forward on the homepage, toast prompt.
          try {
            this.getUIContext().getPromptAction().showToast({ message: $r('app.string.first_page') });
          } catch (error) {
            let err = error as BusinessError;
            hilog.error(0x0000, 'EmulationFlipPage', `showToast failed. code=${err.code}, message=${err.message}`);
          }
          return;
        }
      }
    })
    // [EndExclude emulation_2_a]
    // [EndExclude emulation_2_b]
    // [EndExclude emulation_2_c]
    // [EndExclude emulation_4]
  }
  // [StartExclude emulation_2_a]
  // [StartExclude emulation_2_b]
  // [StartExclude emulation_2_c]
  // [StartExclude emulation_4]
  /**
   * Record the first sliding position.
   *
   * @param tmpFingerInfo Finger info
   */
  // [EndExclude emulation_2_a]
  private initPanPositionX(tmpFingerInfo: FingerInfo): void {
    this.panPositionX = tmpFingerInfo.localX;
    let panPositionY = this.getUIContext().vp2px(tmpFingerInfo.localY);

    // Obtain the position of the first touch point and determine the starting area for sliding.
    if (panPositionY < (this.windowHeight / 3)) {
      this.drawPosition = DrawPosition.DP_TOP;
    } else if (panPositionY >
      (this.windowHeight * 2 / 3)) {
      this.drawPosition = DrawPosition.DP_BOTTOM;
    } else {
      this.drawPosition = DrawPosition.DP_MIDDLE;
    }
  }
  // [End emulation_2_a]

  /**
   * First time drawing initialization information.
   *
   * @param tmpFingerInfo Finger info
   */
  // [EndExclude emulation_2_b]
  private firstDrawingInit(tmpFingerInfo: FingerInfo): void {
    // The initial sliding direction of the page is used to determine whether to continue or cancel flipping forward or backward.
    if (this.panPositionX < tmpFingerInfo.localX) {
      // When flipping forward, take a screenshot of the previous page, and the flipping type is middle flipping.
      this.pageMoveForward = MoveForward.MF_FORWARD;
      this.snapPageId = 'leftPage';
      this.drawPosition = DrawPosition.DP_MIDDLE
    } else {
      // When flipping back, take a screenshot of the current page and hide it.
      this.pageMoveForward = MoveForward.MF_BACKWARD;
      this.snapPageId = 'middlePage';
      this.isMiddlePageHide = true;
    }

    // Take a screenshot after confirming the sliding direction of the page.
    if (this.pagePixelMap) {
      this.pagePixelMap.release();
    }
    try {
      this.pagePixelMap = this.getUIContext().getComponentSnapshot().getSync(this.snapPageId);
    } catch (error) {
      hilog.error(0x0000, 'EmulationFlip',
        `getComponentSnapshot().getSync failed. Cause: ${JSON.stringify(error)}`)
    }
    this.isDrawing = true;
    this.isNodeShow = true;
  }
  // [End emulation_2_b]

  /**
   * Execute drawing.
   *
   * @param tmpFingerInfo Finger info
   */
  // [EndExclude emulation_2_c]
  private drawing(tmpFingerInfo: FingerInfo): void {
    // Determine the latest sliding direction of the gesture, and after releasing the gesture,
    // combine it with the sliding direction of the page to determine whether to flip or cancel.
    if (this.panPositionX < tmpFingerInfo.localX) {
      this.gestureMoveForward = MoveForward.MF_FORWARD;
      this.panPositionX = tmpFingerInfo.localX;
    } else {
      this.gestureMoveForward = MoveForward.MF_BACKWARD;
      this.panPositionX = tmpFingerInfo.localX;
    }
    AppStorage.setOrCreate('drawState', DrawState.DS_MOVING);

    // Convert to px units.
    this.positionX = this.getUIContext().vp2px(tmpFingerInfo.localX);
    this.positionY = this.getUIContext().vp2px(tmpFingerInfo.localY);
    AppStorage.setOrCreate('positionX', this.positionX);
    AppStorage.setOrCreate('positionY', this.positionY);

    // Execute drawing.
    this.newRectNode();
  }
  // [End emulation_2_c]

  /**
   * Click to trigger automatic drawing of initialization information.
   *
   * @param moveForward Move forward
   * @param event Click event
   * @param snapPageId The component ID to be screenshot
   */
  private clickAutoFlipInit(moveForward: number, event: ClickEvent, snapPageId: string): void {
    // Set initial value.
    this.drawPosition = DrawPosition.DP_MIDDLE;
    this.pageMoveForward = moveForward;
    this.gestureMoveForward = moveForward;
    this.positionX = this.getUIContext().vp2px(event.displayX);
    this.positionY = this.getUIContext().vp2px(event.displayY);
    this.isNodeShow = true;

    // Execute screenshot.
    this.snapPageId = snapPageId;
    if (this.pagePixelMap) {
      this.pagePixelMap.release();
    }
    try {
      this.pagePixelMap = this.getUIContext().getComponentSnapshot().getSync(this.snapPageId);
    } catch (error) {
      hilog.error(0x0000, 'EmulationFlip',
        `getComponentSnapshot().getSync failed. Cause: ${JSON.stringify(error)}`)
    }
  }
  // [EndExclude emulation_4]

  /**
   * Perform automatic drawing.
   */
  private autoFlipPage(): void {
    AppStorage.set('drawState', DrawState.DS_RELEASE);
    // Get the vertical axis of the drawn footer.
    AppStorage.setOrCreate('positionY', (AppStorage.get('flipPositionY') as number));
    let num: number = Constants.DISTANCE_FRACTION;
    if (this.gestureMoveForward === MoveForward.MF_FORWARD) {
      // Page forward to calculate diff.
      let xDiff = (this.windowWidth - this.positionX) / num;
      let yDiff = 0;
      if (this.drawPosition === DrawPosition.DP_BOTTOM) {
        yDiff = (this.windowHeight - this.positionY) / num;
      } else {
        yDiff = (0 - this.positionY) / num;
      }

      this.setTimer(xDiff, yDiff, () => {
        this.newRectNode();
      });
    } else {
      // Next Page.
      this.setTimer(Constants.FLIP_X_DIFF, 0, () => {
        this.newRectNode();
      });
    }
  }
  // [End emulation_4]

  /**
   * Check the first sliding direction and page number to determine if they are out of bounds.
   *
   * @param fingerInfo Finger info
   * @returns Out of bounds - false, normal - true
   */
  private isPageValid(fingerInfo: FingerInfo): boolean {
    if (this.panPositionX >= fingerInfo.localX &&
      this.currentPageNum === Constants.PAGE_FLIP_PAGE_END) {
      try {
        this.getUIContext().getPromptAction().showToast({ message: $r('app.string.last_page') });
      } catch (error) {
        let err = error as BusinessError;
        hilog.error(0x0000, 'EmulationFlip', `showToast failed. error code=${err.code}, message=${err.message}`);
      }
      this.panPositionX = 0;
      this.isAllowPanGesture = false;
      return false;
    }

    if (this.panPositionX < fingerInfo.localX && this.currentPageNum === Constants.PAGE_FLIP_ONE) {
      try {
        this.getUIContext().getPromptAction().showToast({ message: $r('app.string.first_page') });
      } catch (error) {
        let err = error as BusinessError;
        hilog.error(0x0000, 'EmulationFlip', `showToast failed. error code=${err.code}, message=${err.message}`);
      }
      this.panPositionX = 0;
      this.isAllowPanGesture = false;
      return false;
    }
    return true;
  }

  /**
   * End automatic drawing, calculate page flipping, reset data.
   */
  // [Start emulation_6]
  // entry/src/main/ets/view/EmulationFlipPage.ets
  private finishLastGesture() {
    clearInterval(this.timeID);
    this.timeID = -1;

    // Previous page.
    if (this.pageMoveForward === MoveForward.MF_FORWARD && this.gestureMoveForward === MoveForward.MF_FORWARD) {
      this.currentPageNum--;
      this.simulatePageContent();
    }

    // Next page.
    if (this.pageMoveForward === MoveForward.MF_BACKWARD && this.gestureMoveForward === MoveForward.MF_BACKWARD) {
      this.currentPageNum++;
      this.simulatePageContent();
    }

    AppStorage.setOrCreate('positionX', -1);
    AppStorage.setOrCreate('positionY', -1);
    AppStorage.setOrCreate('drawPosition', DrawPosition.DP_NONE);
    AppStorage.setOrCreate('drawState', DrawState.DS_NONE);
    this.isMiddlePageHide = false;
    this.isNodeShow = false;
    this.gestureMoveForward = MoveForward.MF_NONE;
    this.panPositionX = 0;
    this.drawPosition = DrawPosition.DP_NONE;
    this.isDrawing = false;
    this.pagePixelMap?.release();
  }
  // [End emulation_6]

  /**
   * Timer automatically draws.
   *
   * @param xDiff Horizontal axis diff.
   * @param yDiff Vertical axis diff.
   * @param drawNode Draw function.
   */
  // [Start emulation_5_a]
  // [Start emulation_5_b]
  // entry/src/main/ets/view/EmulationFlipPage.ets
  private setTimer(xDiff: number, yDiff: number, drawNode: () => void) {
    // Automatically flip forward.
    if (this.gestureMoveForward === MoveForward.MF_FORWARD) {
      this.timeID = setInterval((xDiff: number, yDiff: number, drawNode: () => void) => {
        // [StartExclude emulation_5_b]
        let x = AppStorage.get('positionX') as number + xDiff;
        let y = AppStorage.get('positionY') as number + yDiff;
        // [EndExclude emulation_5_b]
        // Page forward termination condition.
        if (x >= (AppStorage.get('windowWidth') as number) - 1 || y >= (AppStorage.get('windowHeight') as number) ||
          y <= 0) {
          this.finishLastGesture();
        } else {
          // [StartExclude emulation_5_b]
          AppStorage.setOrCreate('positionX', x);
          AppStorage.setOrCreate('positionY', y);
          drawNode();
          // [EndExclude emulation_5_b]
        }
      }, Constants.TIMER_DURATION, xDiff, yDiff, drawNode);
    } else {
      // Automatically flip backwards.
      AppStorage.setOrCreate('isFinished', false);
      this.timeID = setInterval((xDiff: number, _: number, drawNode: () => void) => {
        // [StartExclude emulation_5_b]
        let x = AppStorage.get('positionX') as number + xDiff;
        let y = AppStorage.get('positionY') as number;
        // [EndExclude emulation_5_b]
        // Obtain the termination condition for determining when flipping back to draw.
        let isFinished: boolean = AppStorage.get('isFinished') as boolean;
        if (isFinished) {
          // End automatic drawing.
          this.finishLastGesture();
        } else {
          // [StartExclude emulation_5_b]
          AppStorage.setOrCreate('positionX', x);
          AppStorage.setOrCreate('positionY', y);
          drawNode();
          // [EndExclude emulation_5_b]
        }
      }, Constants.TIMER_DURATION, xDiff, yDiff, drawNode);
    }
  }
  // [End emulation_5_a]
  // [End emulation_5_b]
}