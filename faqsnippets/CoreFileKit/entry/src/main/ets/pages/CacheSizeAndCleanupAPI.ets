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
* FAQ:怎么获取应用已使用的缓存大小，如何使用API清理缓存
*/

// [Start CacheSizeAndCleanupAPI]
import { fileIo, storageStatistics } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct ClearCache {
  // Create a file in the cache
  writeFile() {
    let filePath = this.getUIContext().getHostContext()!.cacheDir + '/test.txt';
    let fileStream = fileIo.createStreamSync(filePath, 'w+');
    fileStream.writeSync('1145141919810');
    fileStream.close();
  }

  // Obtain the size of the application data space
  getCache() {
    storageStatistics.getCurrentBundleStats((error: BusinessError, bundleStats: storageStatistics.BundleStats) => {
      if (error) {
        console.error('getCurrentBundleStats failed with error:' + JSON.stringify(error));
      } else {
        console.info('getCurrentBundleStats successfully:' + JSON.stringify(bundleStats));
        console.info('appsize :' + bundleStats.appSize);
        console.info('cacheSize :' + bundleStats.cacheSize);
        console.info('dataSize :' + bundleStats.dataSize);
      }
    });
  }

  // Clear cache
  clearCache() {
    let cacheDir = this.getUIContext().getHostContext()!.cacheDir;
    console.info(cacheDir);

    fileIo.listFile(cacheDir).then((filenames) => {
      for (let i = 0; i < filenames.length; i++) {
        let dirPath = cacheDir + '/' + filenames[i];
        console.log(dirPath);
        // Determine whether it is a folder
        let isDirectory: boolean = false;
        try {
          isDirectory = fileIo.statSync(dirPath).isDirectory();
        } catch (e) {
          console.error(JSON.stringify(e));
        }

        if (isDirectory) {
          fileIo.rmdirSync(dirPath);
        } else {
          fileIo.unlink(dirPath).then(() => {
            console.info('remove file succeed');
          }).catch((err: Error) => {
            console.error('remove file failed with error message: ' + err.message);
          });
        }
      }

    })
  }

  build() {
    Column() {
      Button('Write data to cache')
        .onClick(() => {
          this.writeFile();
        })
      Button('Get the system cache size')
        .onClick(() => {
          this.getCache();
        })
      Button('Click to clear cache')
        .onClick(() => {
          this.clearCache();
        })
    }
  }
}
// [End CacheSizeAndCleanupAPI]