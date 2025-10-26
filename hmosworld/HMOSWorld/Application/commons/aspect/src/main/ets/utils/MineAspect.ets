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

import { Logger } from '@ohos/utils';
import { AspectUtil } from './AspectUtil';

const TAG: string = '[MineAspect]';

export class MineAspect {
  static createAspect() {
    const harName: string = '@ohos/mine';
    import(harName).then((ns: ESObject) => {
      const targetClass: ESObject = ns.UserModel;
      const methodClassName: string = 'UserModel';
      AspectUtil.addBefore(methodClassName, targetClass, 'getUserData', false);
      AspectUtil.addAfter<void>(methodClassName, targetClass, 'getUserData', false);

      AspectUtil.addBefore(methodClassName, targetClass, 'getViewedResources', false);
      AspectUtil.addAfter<Promise<void>>(methodClassName, targetClass, 'getViewedResources', false);

      AspectUtil.addBefore(methodClassName, targetClass, 'getCollectedResources', false);
      AspectUtil.addAfter<Promise<void>>(methodClassName, targetClass, 'getCollectedResources', false);

      AspectUtil.addBefore(methodClassName, targetClass, 'getUserAchievements', false);
      AspectUtil.addAfter<Promise<void>>(methodClassName, targetClass, 'getUserAchievements', false);

      AspectUtil.addBefore(methodClassName, targetClass, 'savePushToken', false);
      AspectUtil.addAfter<void>(methodClassName, targetClass, 'savePushToken', false);

      AspectUtil.addBefore(methodClassName, targetClass, 'handleCollected', false);
      AspectUtil.addAfter<void>(methodClassName, targetClass, 'handleCollected', false);

      AspectUtil.addBefore(methodClassName, targetClass, 'handleLiked', false);
      AspectUtil.addAfter<void>(methodClassName, targetClass, 'handleLiked', false);

      AspectUtil.addBefore(methodClassName, targetClass, 'handleLearningEvent', false);
      AspectUtil.addAfter<void>(methodClassName, targetClass, 'handleLearningEvent', false);
    }).catch((e: Error) => {
      Logger.error(TAG, `import ${harName} error, ${JSON.stringify(e)}`);
    })
  }
}