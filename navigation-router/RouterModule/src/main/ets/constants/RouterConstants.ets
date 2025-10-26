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

// Key of the builderMap of the routing table in the RouterModule. The format is as follows:{bundleName}_${pageName}.
export class BuilderNameConstants {
  static readonly HARA_A1: string = '@ohos/hara_A1';
  static readonly HARA_A2: string = '@ohos/hara_A2';
  static readonly HARB_B1: string = '@ohos/harb_B1';
  static readonly HARB_B2: string = '@ohos/harb_B2';
  static readonly HARB_B3: string = '@ohos/harb_B3';
  static readonly HARC_C1: string = '@ohos/harc_C1';
  static readonly HARC_C2: string = '@ohos/harc_C2';
}

// Indicates the key of the routerMap table in the RouterModule.
export class RouterNameConstants {
  static readonly ENTRY_HAP: string = 'EntryHap_Router';
}