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

import { MediaTools } from '@ohos/mediaservice';

interface DialogText {
  title: string | Resource;
  content: string | Resource;
}

const confirmServiceMap: Map<string, () => DialogText> = new Map();

confirmServiceMap.set('dialService', () => {
  const result: DialogText = {
    title: '',
    content: ''
  };

  if (MediaTools.hasSim()) {
    result.title = $r('app.string.confirm_service_dial_ok_title');
    result.content = $r('app.string.confirm_service_dial_ok_content');
  } else {
    result.title = $r('app.string.confirm_service_dial_wrong_title');
    result.content = $r('app.string.confirm_service_dial_wrong_content');
  }

  return result;
});

export { DialogText, confirmServiceMap };