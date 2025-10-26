/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
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
* FAQ:如何获取当前应用程序缓存目录
 */

// [Start get_cache]
import { common } from '@kit.AbilityKit';

@Entry
@Component
export struct GetCacheDirectoryView {
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  @State cachePath: string = '';

  build() {
    Column() {
      Text(this.cachePath)
        .margin({ bottom: 24 })
      Button() {
        Text('Get the application cache directory address')
      }
      .onClick(() => {
        const applicationContext = this.context.getApplicationContext();
        // Get the application file path
        const cacheDir = applicationContext.cacheDir;
        this.cachePath = cacheDir + '/test.txt';
      })
      .width(300)
      .height(50)
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height('100%')
  }
}
// [End get_cache]