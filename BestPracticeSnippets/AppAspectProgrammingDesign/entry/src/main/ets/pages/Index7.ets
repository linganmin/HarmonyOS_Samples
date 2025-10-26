/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
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

/*
* 最佳实践: 应用切面编程设计
*/

// [Start fragment1]
// index.ets
import { util } from '@kit.ArkTS';
import { geoLocationManager } from "@kit.LocationKit";
import { Child } from '../components/child';

@Entry
@Component
struct Index {
  build() {
    // UIcode
  }
}
let cached_location: Object | undefined;
let time: number | undefined;
util.Aspect.replace(Child, 'getCurrentLocation', false, () => {
  let newTime = new Date().getTime();
  // Real-time location can be called at most once per minute.
  if (!cached_location || !time || newTime - time > 60000) {
    time = newTime;
    cached_location = geoLocationManager.getCurrentLocation();
  }
  // Return cached location information
  return cached_location;
});
new Child().getCurrentLocation()
// [End fragment1]