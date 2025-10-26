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

/**
 * 最佳实践：应用资产保护设计
 * 场景二：HarmonyOS资产保护关键技术介绍-混淆后
 */

// [Start application_asset_protection_after]
function getAgeInfo() {
  let c = 0x14;
  let b = 'jack';
  if (b) {
    return c;
  } else {
    return -0x1;
  }
}

console['log']('' + getAgeInfo());
// [End application_asset_protection_after]