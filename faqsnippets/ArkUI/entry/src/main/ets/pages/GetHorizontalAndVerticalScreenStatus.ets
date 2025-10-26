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
* FAQ:如何获取设备屏幕横竖屏状态
*/

// [Start get_window_status]
import { mediaquery, UIContext } from '@kit.ArkUI';

// Store context in EntryAbility
const context = AppStorage.get("context") as UIContext;
let listener = context.getMediaQuery().matchMediaSync('(orientation: landscape)'); // Listen to landscape events
function onPortrait(mediaQueryResult: mediaquery.MediaQueryResult) {
  console.info('mediaQueryResult.matches:' + mediaQueryResult.matches)
  if (mediaQueryResult.matches) {
    // do something here
  } else {
    // do something here
  }
}
listener.on('change', onPortrait) // Register callback
listener.off('change', onPortrait) // Unregister callback

@Entry
@Component
struct Index {
  build() {
    Column() {
      Column() {
        Text('test')
      }
      .width('100%')
    }
    .height('100%')
    .width('100%')
    .justifyContent(FlexAlign.End)
  }
}
// [End get_window_status]