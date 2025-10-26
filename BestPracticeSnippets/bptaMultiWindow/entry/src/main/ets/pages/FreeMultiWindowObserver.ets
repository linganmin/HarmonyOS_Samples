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
* 最佳实践: 一多窗口适配开发实践
*/

import { hilog } from '@kit.PerformanceAnalysisKit';
import { settings } from '@kit.BasicServicesKit';

const DOMAIN = 0x0000;
const TAG = 'FreeMultiWindowObserver';
const FORMAT = '%{public}s';

// [Start FreeMultiWindowObserver]
const context: UIContext | undefined = AppStorage.get('uiContext');
settings.registerKeyObserver(context?.getHostContext(), 'window_pcmode_switch_status',
  settings.domainName.USER_PROPERTY, () => {
    settings.getValue(context?.getHostContext(), 'window_pcmode_switch_status',
      settings.domainName.USER_PROPERTY).then((data) => {
      if (data) {
        hilog.info(DOMAIN, TAG, FORMAT, `settings value changed, window_pcmode_switch_status: ${JSON.stringify(data)}`);
        return;
      }
    });
  });
// [End FreeMultiWindowObserver]