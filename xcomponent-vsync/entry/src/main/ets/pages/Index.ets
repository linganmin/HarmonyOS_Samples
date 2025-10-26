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
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit'
import CommonConstants from '../constants/CommonContants';

const uiContext: UIContext | undefined = AppStorage.get('uiContext');
let context = uiContext!.getHostContext()!;
@Entry
@Component
struct Index {
  async aboutToAppear(): Promise<void> {
    try {
      let windowHeight: window.Window = await window.getLastWindow(context);
      await windowHeight.setWindowLayoutFullScreen(true);
      let sysBarProps: window.SystemBarProperties = {
        isStatusBarLightIcon: true
      };
      await windowHeight.setWindowSystemBarProperties(sysBarProps);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'testTag', `set WindowSystemBarProperties fail. code = ${err.code}, message = ${err.message}`);
    }
  }

  build() {
    Stack() {
      XComponent({
        id: CommonConstants.X_COMPONENT_ID,
        type: XComponentType.SURFACE,
        libraryname: CommonConstants.X_COMPONENT_LIBRARY_NAME
      })
        .id(CommonConstants.X_COMPONENT_ID)
        .width(CommonConstants.FULL_PARENT)
        .height(CommonConstants.FULL_PARENT)
    }
    .alignContent(Alignment.TopStart)
    .width(CommonConstants.FULL_PARENT)
    .height(CommonConstants.FULL_PARENT)
  }
}
