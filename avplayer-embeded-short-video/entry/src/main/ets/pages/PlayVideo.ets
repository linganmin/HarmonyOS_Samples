/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { AppRouter } from '../common/utils/AppRouter';
import { VideoList } from '../component/VideoList';

@Entry
@Component
struct PlayVideo {
  @State isShow: boolean = true;

  onPageShow(): void {
    this.isShow = true;
  }

  onPageHide(): void {
    this.isShow = false;
  }

  // [Start navigation]
  build() {
    Navigation(AppRouter.getInstance().getPathStack()) {
      // [StartExclude navigation]
      Flex({ direction: FlexDirection.Column }) {
        VideoList({ isShow: this.isShow });
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#1A1A1A')

      // [EndExclude navigation]
    }
    .hideTitleBar(true)
    .width('100%')
    .height('100%')
    .mode(NavigationMode.Stack)
  }

  // [End navigation]
}