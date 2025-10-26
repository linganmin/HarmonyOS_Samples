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

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
export class BreakpointHeight {
  updateHeightBreakpoint(): void {
    const uiContext: UIContext | undefined = AppStorage.get('uiContext');
    // [Start source_add3]
    let heightBreakpoint: string = AppStorage.get('heightBreakpoint') as string;
    if (heightBreakpoint === 'md') {
      let promise = window.getLastWindow(uiContext?.getHostContext());
      promise.then((mainWindow: window.Window) => {
        mainWindow.setPreferredOrientation(window.Orientation.AUTO_ROTATION_RESTRICTED);
      }).catch((err: BusinessError) => {
        console.error(`Failed to obtain the top window. Cause code: ${err.code}, message: ${err.message}`);
      });
    }
    // [End source_add3]
  }
}