/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import TodoListActions from '../store/TodoListActions';
import { TodoStore } from '../store/TodoListStore';
import RdbUtil from '../utils/RdbUtil';
import GlobalContext from '../utils/GlobalContext';
import { BusinessError } from '@kit.BasicServicesKit'

export default class EntryAbility extends UIAbility {
  onCreate(_want: Want, _launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      const error = err as BusinessError;
      hilog.error(0x0000, 'testTag', `Failed to setColorMode. code = ${error.code}, message = ${error.message}`);
    }
    RdbUtil.getInstance(this.context).then((rdb) => {
      rdb.initRdb();
    }).catch((err: Error) => {
      const error = err as BusinessError;
      hilog.error(0x0000, 'RDB', `Failed to getInstance. code = ${error.code}, message = ${error.message}`);
    });
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
      let uiContext: UIContext = windowStage.getMainWindowSync().getUIContext()
      AppStorage.setOrCreate('uiContext', uiContext);

      let GlobalContent = GlobalContext.getInstance();
      GlobalContent.saveUIContext(uiContext); // 存储到全局状态
      let win = windowStage.getMainWindowSync();
      let navigationHeight = uiContext.px2vp(win.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR)
        .bottomRect
        .height);
      TodoStore.dispatch(TodoListActions.setButtonMargin.setPayload(navigationHeight + 16));
      win.on('keyboardHeightChange', (height) => {
        if (height > 0) {
          TodoStore.dispatch(TodoListActions.setButtonMargin.setPayload(16));
        } else {
          TodoStore.dispatch(TodoListActions.setButtonMargin.setPayload(navigationHeight + 16));
        }
      });
    });
  }
};