/*
 * Copyright (c) 2023 Hunan OpenValley Digital Industry Development Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { getStringData } from '../../../../data/ResourceDataHandle';
import { TitleBar } from '../../../../common/TitleBar';

class Utils {
  static rect_left: number;
  static rect_top: number;
  static rect_right: number;
  static rect_bottom: number;
  static rect_value: Record<string, Object>;

  // Get the coordinates of the rectangular area occupied by the component
  static getComponentRect(key: string) {
    // This interface is only used for testing your application. It is not recommended due to its long time.
    let strJson = getInspectorByKey(key);
    let obj: Record<string, Object> = JSON.parse(strJson);
    let rectInfo: Record<string, Object> = JSON.parse('[' + obj.$rect + ']');
    Utils.rect_left = JSON.parse('[' + rectInfo[0] + ']')[0];
    Utils.rect_top = JSON.parse('[' + rectInfo[0] + ']')[1];
    Utils.rect_right = JSON.parse('[' + rectInfo[1] + ']')[0];
    Utils.rect_bottom = JSON.parse('[' + rectInfo[1] + ']')[1];
    return Utils.rect_value = {
      "left": Utils.rect_left, "top": Utils.rect_top, "right": Utils.rect_right, "bottom": Utils.rect_bottom
    };
  }
}

@Extend(Button)
function buttonStyle() {
  .fontSize(16)
  .height(40)
  .width('100%')
  .margin({ left: 24, right: 24, top: 12, bottom: 8 })
}

@Entry
@Component
struct ComponentIDSample {
  @State text: string = '';

  build() {
    Column() {
      TitleBar({ title: $r('app.string.component_id') })
      Row() {
        Column() {
          Row() {
            Text(this.text)
              .fontSize(16)
              .width('100%')
              .textAlign(TextAlign.Start)
              .margin({ left: 12 })
          }
          .justifyContent(FlexAlign.Center)
          .borderRadius(24)
          .backgroundColor(Color.White)
          .height(60)
          .margin({ left: 12, right: 12, bottom: 8 })
          .width('100%')

          Button($r('app.string.component_id_onKeyTab'))
            .buttonStyle(0)
            .onKeyEvent(() => {
              this.text = getStringData($r('app.string.component_id_onKeyTab'));
            })

          Button($r('app.string.component_id_click'))
            .buttonStyle(0)
            .onClick(() => {
              this.text = getStringData($r('app.string.component_id_click_text'));
              setTimeout(() => {
                // Send a long click event to the component with id "longClick"
                // This interface is only used for testing your application. It is not recommended due to its long time.
                sendEventByKey(getStringData($r('app.string.componentId_longClick')), 11, '');
              }, 2000);
            })
            .id('click')

          Button($r('app.string.component_id_longClick'))
            .buttonStyle(0)
            .gesture(
              LongPressGesture().onActionEnd(() => {
                this.text = getStringData($r('app.string.component_id_longClick_text'));
                setTimeout(() => {
                  // Get the coordinates of the rectangular area the component with id "onTouch"
                  let rect = Utils.getComponentRect(getStringData($r('app.string.componentId_onTouch')));
                  let touchPoint: TouchObject = {
                    id: 1,
                    displayX: rect.left + (rect.right - rect.left) / 2, // Component center point x coordinate
                    displayY: rect.top + (rect.bottom - rect.top) / 2, // Component center point y coordinate
                    windowX: rect.left + (rect.right - rect.left) / 2, // Component center point x coordinate
                    windowY: rect.top + (rect.bottom - rect.top) / 2, // Component center point y coordinate
                    x: rect.left + (rect.right - rect.left) / 2, // Component center point x coordinate
                    y: rect.top + (rect.bottom - rect.top) / 2, // Component center point y coordinate
                    type: TouchType.Down,
                    screenX: rect.left + (rect.right - rect.left) / 2, // Component center point x coordinate
                    screenY: rect.top + (rect.right - rect.left) / 2, // Component center point y coordinate
                  };
                  // This interface is only used for testing your application. It is not recommended due to its long time.
                  sendTouchEvent(touchPoint); // Send touch events
                  touchPoint.type = TouchType.Up;
                  sendTouchEvent(touchPoint); // Send touch events
                }, 2000);
              }))
            .id('longClick')

          Button($r('app.string.component_id_onTouch'))
            .buttonStyle(0)
            .onClick(() => {
              this.text = getStringData($r('app.string.component_id_onTouch_text'))
              setTimeout(() => {
                // Get the coordinates of the rectangular area of the component with id "onMouse"
                let rect = Utils.getComponentRect(getStringData($r('app.string.componentId_onMouse')));
                let mouseEvent: MouseEvent = {
                  button: MouseButton.Left,
                  action: MouseAction.Press,
                  displayX: rect.left + (rect.right - rect.left) / 2, // Component center point x coordinate
                  displayY: rect.top + (rect.bottom - rect.top) / 2, // Component center point y coordinate
                  windowY: rect.top + (rect.bottom - rect.top) / 2, // Component center point y coordinate
                  windowX: rect.left + (rect.right - rect.left) / 2, // Component center point x coordinate
                  x: rect.left + (rect.right - rect.left) / 2, // Component center point x coordinate
                  y: rect.top + (rect.bottom - rect.top) / 2, // Component center point y coordinate
                  screenX: rect.left + (rect.right - rect.left) / 2, // Component center point x coordinate
                  screenY: rect.top + (rect.bottom - rect.top) / 2, // Component center point y coordinate
                  timestamp: 1,
                  target: {
                    area: {
                      width: 1,
                      height: 1,
                      position: {
                        x: 1,
                        y: 1
                      },
                      globalPosition: {
                        x: 1,
                        y: 1
                      }
                    }
                  },
                  source: SourceType.Mouse,
                  pressure: 1,
                  tiltX: 1,
                  tiltY: 1,
                  sourceTool: SourceTool.Unknown
                } as MouseEvent;
                // This interface is only used for testing your application. It is not recommended due to its long time.
                sendMouseEvent(mouseEvent); // Send mouse events
              }, 2000)
            })
            .id('onTouch')

          Button($r('app.string.component_id_onMouse'))
            .buttonStyle(0)
            .onMouse(() => {
              this.text = getStringData($r('app.string.component_id_onMouse_text'));
              setTimeout(() => {
                let keyEvent: KeyEvent = {
                  type: KeyType.Down,
                  keyCode: 2049,
                  keyText: 'tab',
                  keySource: 4,
                  deviceId: 0,
                  metaKey: 0,
                  timestamp: 0,
                  intentionCode: 2
                } as KeyEvent;
                // This interface is only used for testing your application. It is not recommended due to its long time.
                sendKeyEvent(keyEvent); // Send key events
              }, 2000)
            })
            .id('onMouse')
        }
      }
      .justifyContent(FlexAlign.Center)
    }
    .height('100%')
    .width('100%')
    .backgroundColor($r('app.color.background_shallow_grey'))
  }
}