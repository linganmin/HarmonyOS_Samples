/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
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
* FAQ:如何查询应用包的名称、供应商、版本号、版本文本、安装时间、更新时间描述信息
 */

// [Start get_bundle_info]
import { bundleManager } from '@kit.AbilityKit';

// Apply to obtain BundleInfo and applicationInfo
let bundleFlags = bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION;

try {
  bundleManager.getBundleInfoForSelf(bundleFlags, (err, data) => {
    // Get the bundle name of the application itself
    const bundleName = data.name;
    // Get the version number of the application（versionCode）
    const versionCode = data.versionCode;
    // Get the version name of the application（versionName）
    const versionName = data.versionName;

    if (err) {
      console.error(`getBundleInfoForSelf failed: ${err.message}`);
    } else {
      console.info(`get bundleName successfully: ${bundleName}`);
      console.info(`get versionCode successfully: ${versionCode}`);
      console.info(`get versionName successfully: ${versionName}`);
      console.info(`getBundleInfoForSelf successfully: ${JSON.stringify(data)}`);
    }
  });
} catch (err) {
  console.error(`getBundleInfoForSelf failed: ${JSON.stringify(err)}`);
}
// [End get_bundle_info]