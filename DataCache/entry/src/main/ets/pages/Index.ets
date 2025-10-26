/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
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

import { FULL_HEIGHT, FULL_WIDTH } from '../common/constant/CommonConstants';
import TabBar from '../view/TabBar';

const uiContext: UIContext | undefined = AppStorage.get('uiContext');
const storage = uiContext?.getSharedLocalStorage()

@Entry(storage)
@Component
struct Index {
  build() {
    Column() {
      TabBar()
    }
    .height(FULL_HEIGHT)
    .width(FULL_WIDTH)
    .backgroundColor($r('app.color.app_background'))
  }
}