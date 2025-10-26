/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

/*
* 最佳实践: 应用切面编程设计
*/

// [Start WindowWrap]
// WindowWrap.ets

import { window } from '@kit.ArkUI';
import { util } from '@kit.ArkTS';

export class WindowWrap {
  private static instance: WindowWrap = new WindowWrap();

  private constructor() {
  }

  public static getInstance() {
    return WindowWrap.instance;
  }

  public createWindow() {
    let config: window.Configuration = {
      name: 'test',
      windowType: window.WindowType.TYPE_DIALOG
    }
    window.createWindow(config, () => {
      // do something
    })
  }
}

util.Aspect.addBefore(WindowWrap, 'createWindow', false, (instance: WindowWrap): void => {
  console.info('addBefore createWindow');
})

// [End WindowWrap]