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

import Constants from '../common/Constants';

@Component
export default struct Header {
  @Consume('pathInfos') pathInfos: NavPathStack;

  build() {
    Row() {
      Image($r("app.media.ic_back"))
        .height(Constants.HALF_HEIGHT)
        .borderRadius($r("app.float.small_border_radius"))
        .onClick(() => {
          this.pathInfos.pop();

        })
      Image($r("app.media.ic_dot"))
        .height(Constants.HALF_HEIGHT)
        .borderRadius($r("app.float.small_border_radius"))
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width(Constants.FULL_WIDTH)
    .height($r("app.float.header_height"))
    .backgroundColor(Color.White)
  }
}