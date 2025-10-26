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
import { mediaquery, window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit'
import { SavePages } from './SavePages';
import { MyRenderNode, MyNodeController } from '../model/RenderNodeModel';
import CommonConstants from '../constants/CommonContants';

@Entry
@Component
struct Index {
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack();
  @State nodeCount: number = 0; // The number of child nodes mounted to the root node
  @State drawAreaHeight: string = '100%'; // pure
  private myNodeController: MyNodeController = new MyNodeController();
  private currentNode: MyRenderNode | null = null;
  private listener: mediaquery.MediaQueryListener | null = null; // pure

  @Builder
  PageMap(name: string, param: number) {
    if (name === 'SavePages') {
      SavePages();
    }
  }

  async aboutToAppear(): Promise<void> {
    try {
      let windowHeight: window.Window = await window.getLastWindow(this.getUIContext().getHostContext()!);
      await windowHeight.setPreferredOrientation(window.Orientation.LANDSCAPE);
      await windowHeight.setWindowLayoutFullScreen(true);
      await windowHeight.setSpecificSystemBarEnabled('status', false);
      this.onApplicationHeightChange();
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'testTag', `setColorMode fail. code = ${err.code}, message = ${err.message}`);
    }
  }

  onApplicationHeightChange() {
    const condition = CommonConstants.FOLD_CONDITION;
    this.listener = this.getUIContext().getMediaQuery().matchMediaSync(condition);
    this.listener.on('change', (mediaQueryResult) => {
      if (mediaQueryResult.matches) {
        this.drawAreaHeight = CommonConstants.FOLD_DRAW_AREA_HEIGHT;
      } else {
        this.drawAreaHeight = CommonConstants.FULL_SCREEN;
      }
    })
  }

  build() {
    Navigation(this.pageInfos) {
      Stack({ alignContent: Alignment.TopEnd }) {
        Stack({ alignContent: Alignment.Bottom }) {
          Row() {
            NodeContainer(this.myNodeController)
              .width(CommonConstants.FULL_SCREEN)
              .height(this.drawAreaHeight)
              .onTouch((event: TouchEvent) => {
                this.onTouchEvent(event);
              })
              .id(CommonConstants.NODE_CONTAINER_ID)
          }
          .border({
            width: $r('app.integer.hand_writing_border_width'),
            style: BorderStyle.Dashed,
            color: $r('app.color.hand_writing_border_color')
          })

          Row({ space: CommonConstants.ROW_SPACE }) {
            Button($r('app.string.hand_writing_revert'), { buttonStyle: ButtonStyleMode.EMPHASIZED })
              .onClick(() => {
                this.goBack();
              })
              .width(CommonConstants.THIRTY_PERCENT)
              .height($r('app.integer.button_height'))
            Button($r('app.string.hand_writing_reset'), { buttonStyle: ButtonStyleMode.EMPHASIZED })
              .onClick(() => {
                this.resetCanvas();
              })
              .width(CommonConstants.THIRTY_PERCENT)
              .height($r('app.integer.button_height'))
          }
          .padding({ bottom: $r('app.integer.button_padding_bottom') })
        }

        Stack() {
          Image($rawfile('ic_public_arrow_right.png'))
            .onClick(() => {
              this.pageInfos.pushPath({ name: 'SavePages', param: this.nodeCount })
            })
            .width(CommonConstants.FULL_SCREEN)
            .height(CommonConstants.FULL_SCREEN)
            .borderRadius(CommonConstants.BORDER_RADIUS)
            .backgroundColor($r('app.color.save_background_color'))
        }
        .width($r('app.integer.image_width'))
        .height($r('app.integer.image_height'))
        .margin({ top: $r('app.integer.image_margin'), right: $r('app.integer.image_margin') })
      }
      .width(CommonConstants.FULL_SCREEN)
      .height(CommonConstants.FULL_SCREEN)
      .padding({
        left: $r('app.integer.padding_16'),
        right: $r('app.integer.padding_16'),
        bottom: $r('app.integer.padding_16'),
        top: $r('app.integer.padding_18')
      })
      .backgroundColor($r('app.color.start_window_background'))
    }
    .width(CommonConstants.FULL_SCREEN)
    .height(CommonConstants.FULL_SCREEN)
    .navDestination(this.PageMap)
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .hideToolBar(true)
  }

  /**
   * Draw the finger movement trajectory after the touch event is triggered.
   */
  onTouchEvent(event: TouchEvent): void {
    // Get the coordinate point of the finger touch position
    const positionX: number = this.getUIContext().vp2px(event.touches[0].x);
    const positionY: number = this.getUIContext().vp2px(event.touches[0].y);
    switch (event.type) {
      case TouchType.Down: {
        /**
         * Each time a finger is pressed, a MyRenderNode object is created to record and draw the trajectory of
         * the finger movement.
         */
        const newNode = new MyRenderNode();
        newNode.frame = {
          x: 0,
          y: 0,
          width: this.myNodeController.width,
          height: this.myNodeController.height
        };
        this.currentNode = newNode;
        this.currentNode.path.moveTo(positionX, positionY);
        if (this.myNodeController.rootRenderNode !== null) {
          this.myNodeController.rootRenderNode.appendChild(this.currentNode);
          this.nodeCount++;
        }
        break;
      }
      case TouchType.Move: {
        if (this.currentNode !== null) {
          this.currentNode.path.lineTo(positionX, positionY);
          this.currentNode.invalidate();
        }
        break;
      }
      case TouchType.Up: {
        this.currentNode = null;
        break;
      }
      default: {
        hilog.info(0xffffff, 'Test', 'Gesture acquisition failed');
        break;
      }
    }
  }

  /**
   * Undo the last draw.
   */
  goBack() {
    if (this.myNodeController.rootRenderNode !== null && this.nodeCount > 0) {
      const node = this.myNodeController.rootRenderNode.getChild(this.nodeCount - 1);
      this.myNodeController.rootRenderNode.removeChild(node);
      this.nodeCount--;
    }
  }

  /**
   * Reset canvas.
   */
  resetCanvas() {
    if (this.myNodeController.rootRenderNode !== null && this.nodeCount > 0) {
      this.myNodeController.rootRenderNode.clearChildren();
      this.nodeCount = 0;
    }
  }
}