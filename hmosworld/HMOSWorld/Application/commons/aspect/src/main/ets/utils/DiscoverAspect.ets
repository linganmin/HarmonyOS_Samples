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

import { AspectUtil } from './AspectUtil';
import { Logger } from '@ohos/utils';

const TAG = '[DiscoverAspect]';

export class DiscoverAspect {
  static createAspect() {
    const harName: string = '@ohos/discover';
    import(harName).then((ns: ESObject) => {
      const targetClass: ESObject = ns.DiscoverModel;
      const methodClassName: string = 'DiscoverModel';
      AspectUtil.addBefore(methodClassName, targetClass, 'getHomeResources', false);
      AspectUtil.addAfter<Promise<void>>(methodClassName, targetClass, 'getHomeResources', false);
      AspectUtil.addBefore(methodClassName, targetClass, 'loadMoreArticle', false);
      AspectUtil.addAfter<Promise<void>>(methodClassName, targetClass, 'loadMoreArticle', false);

      AspectUtil.addBefore(methodClassName, targetClass, 'loadMoreFeed', false);
      AspectUtil.addAfter<void>(methodClassName, targetClass, 'loadMoreFeed', false);

      AspectUtil.addBefore(methodClassName, targetClass, 'search', false);
      AspectUtil.addAfter<void>(methodClassName, targetClass, 'search', false);

      AspectUtil.addBefore(methodClassName, targetClass, 'getSearchHistory', false);
      AspectUtil.addAfter<void>(methodClassName, targetClass, 'getSearchHistory', false);

      AspectUtil.addBefore(methodClassName, targetClass, 'clearSearchHistory', false);
      AspectUtil.addAfter<void>(methodClassName, targetClass, 'clearSearchHistory', false);

      AspectUtil.addBefore(methodClassName, targetClass, 'setCollectionCount', false);
      AspectUtil.addAfter<void>(methodClassName, targetClass, 'setCollectionCount', false);

      AspectUtil.addBefore(methodClassName, targetClass, 'setLikesCount', false);
      AspectUtil.addAfter<void>(methodClassName, targetClass, 'setLikesCount', false);

      AspectUtil.addBefore(methodClassName, targetClass, 'setViewsCount', false);
      AspectUtil.addAfter<void>(methodClassName, targetClass, 'setViewsCount', false);
    }).catch((e: Error) => {
      Logger.error(TAG, `import ${harName} error, ${JSON.stringify(e)}`);
    })
  }
}