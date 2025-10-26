/*
 *   Copyright (c) 2024 Huawei Device Co., Ltd.
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 */

import { LiveConstants } from '../common/constants/LiveConstants'

@Component
export struct LiveCommentFooter {
  build() {
    Row() {
      Search({placeholder: LiveConstants.LIVING_WRITE})
        .searchIcon({
          src: $r('app.media.ic_s_search')
        })
        .layoutWeight(1)
        .margin({left: 10, top: 10, bottom: 10})
        .enterKeyType(EnterKeyType.Send);
      Image($r('app.media.paperplane'))
        .width(25)
        .margin({left: 16, right: 16});
    };
  }
}