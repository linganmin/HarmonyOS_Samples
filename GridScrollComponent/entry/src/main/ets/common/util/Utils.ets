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

// [Start pages_reuse]
import { RecycledPool } from '@hadss/scroll_components';

export class Utils {
  // [StartExclude pages_reuse]

  static Utils() {
    throw new Error('Method not implemented.');
  }
  // [EndExclude pages_reuse]
  private static utils_: Utils;
  nodePool: RecycledPool | null = null;
  // [StartExclude pages_reuse]

  static getInstance() {
    if (Utils.utils_ === undefined) {
      Utils.utils_ = new Utils();
    }
    return Utils.utils_;
  }
  // [EndExclude pages_reuse]
}
// [End pages_reuse]