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
import { window } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { setWindowCircleShape, setWindowPicShape, setWindowTriangleShape } from '../utils/WindowUtils';
import { ID_EVENT_CLOSE, TYPE_CIRCLE, TYPE_PIC, TYPE_TRIANGLE } from '../common/Constants';

let windowStage: window.WindowStage | undefined;
let subWindow: window.Window;

@Entry
@Component
struct Index {
  aboutToAppear(): void {
    emitter.on(ID_EVENT_CLOSE, () => {
      this.destroySubWindow();
    });
  }

  aboutToDisappear(): void {
    emitter.off(ID_EVENT_CLOSE);
  }

  private async showSubWindow(type: number): Promise<void> {
    // [Start create_sub_window]
    windowStage = AppStorage.get('windowStage');
    if (windowStage === null) {
      hilog.error(0x0000, 'Sample', 'Failed to create the subwindow. Cause: windowStage is null');
      return;
    }
    const windowWidth = 500;
    const windowHeight = 500;
    try {
      subWindow = await windowStage!.createSubWindow('mySubWindow');
      subWindow.moveWindowTo(300, 300);
      subWindow.resize(windowWidth, windowHeight);
      subWindow.setUIContent('pages/SubPage');
      // [StartExclude create_sub_window]
      switch (type) {
        case TYPE_CIRCLE:
          setWindowCircleShape(subWindow, windowWidth, windowHeight);
          break;
        case TYPE_TRIANGLE:
          setWindowTriangleShape(subWindow, windowWidth, windowHeight);
          break;
        case TYPE_PIC:
          setWindowPicShape(subWindow, this.getUIContext().getHostContext()!, windowWidth, windowHeight, 'test.png');
          break;
        default:
          break;
      }
      // [EndExclude create_sub_window]
      // [Start show_sub_window]
      subWindow.showWindow();
      // [End show_sub_window]
    } catch (exception) {
      hilog.error(0x0000, 'Sample', 'Failed to create sub window. Cause: ' + JSON.stringify(exception));
    }
    // [End create_sub_window]
  }

  private destroySubWindow(): void {
    try {
      subWindow?.destroyWindow();
    } catch (exception) {
      hilog.error(0x0000, 'Sample', 'Failed to destroy the window. Cause: ' + JSON.stringify(exception));
    }
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.app_icon'))
          .width(24)
          .height(24)
          .margin({ left: 24 })
          .backgroundColor(Color.Transparent)
        Text($r('app.string.title_index'))
          .fontSize(16)
          .fontColor('#E5000000')
          .height(48)
          .margin({ left: 12 })
          .fontWeight(FontWeight.Medium)
      }
      .height(56)
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)

      Row() {
        Column() {
          Text($r('app.string.figure_shape_window'))
            .fontSize(16)
            .fontColor('#E5000000')
            .fontWeight(FontWeight.Medium)
          Button($r('app.string.create_circle_sub_window'))
            .type(ButtonType.Normal)
            .stateEffect(true)
            .borderRadius(8)
            .width(300)
            .margin({ top: 12 })
            .onClick(() => {
              this.showSubWindow(TYPE_CIRCLE);
            })
          Button($r('app.string.create_triangle_sub_window'))
            .type(ButtonType.Normal)
            .stateEffect(true)
            .borderRadius(8)
            .width(300)
            .margin({ top: 12 })
            .onClick(() => {
              this.showSubWindow(TYPE_TRIANGLE);
            })
          Text($r('app.string.irregular_shape_window'))
            .fontSize(16)
            .fontColor('#E5000000')
            .fontWeight(FontWeight.Medium)
            .margin({ top: 40 })
          Button($r('app.string.create_image_shape_window'))
            .type(ButtonType.Normal)
            .stateEffect(true)
            .borderRadius(8)
            .width(300)
            .margin({ top: 12 })
            .onClick(() => {
              this.showSubWindow(TYPE_PIC);
            })
        }
        .alignSelf(ItemAlign.Center)
        .alignItems(HorizontalAlign.Start)
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .height('100%')
      .alignItems(VerticalAlign.Center)
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
  }
}

