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

// [Start Share_Pool_1]
import { RecycledPool } from '@hadss/scroll_components';

export class Utils {
  // [StartExclude Share_Pool_1]
  private constructor() {
  }
  // [EndExclude Share_Pool_1]
  private static utils_: Utils;
  nodePool: RecycledPool | null = null;
  // [StartExclude Share_Pool_1]
  static getInstance() {
    if (Utils.utils_ === undefined) {
      Utils.utils_ = new Utils();
    }
    return Utils.utils_;
  }
  // [EndExclude Share_Pool_1]
}
// [End Share_Pool_1]