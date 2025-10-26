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
 * 场景一：HarmonyOS资产保护关键技术介绍-混淆前
 */

// [Start application_asset_protection_before]
function getAgeInfo() {
  let age = 20;
  let name = 'jack';
  if (name) {
    return age;
  } else {
    return -1;
  }
}

console.log('' + getAgeInfo());
// [End application_asset_protection_before]