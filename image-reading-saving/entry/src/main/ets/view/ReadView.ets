/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { ReadBtn } from '../component/ReadBtn';

@Builder
export function ReadViewBuild() {
  ReadView();
}

@Component
export struct ReadView {
  @Consume('pageInfo') pageStack: NavPathStack;

  build() {
    NavDestination() {
      Flex({
        direction: FlexDirection.Column,
        alignItems: ItemAlign.Center
      }) {
        ReadBtn();
      }
      .padding(16)
    }
    .title($r('app.string.reading_images_from_the_gallery'))
  }
}