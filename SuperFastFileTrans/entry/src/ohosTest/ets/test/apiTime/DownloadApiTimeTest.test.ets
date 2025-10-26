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

import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { Want } from '@kit.AbilityKit';
import { abilityDelegatorRegistry } from '@kit.TestKit';
import { Context } from '@ohos.arkui.UIContext';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { XTS_CONFIG } from '../Common';
import { DownloadConfig, DownloadListener, DownloadManager } from '@hadss/super_fast_file_trans';
import { calculateFunctionTime, sleep } from '../TestUtil';

const delegator = abilityDelegatorRegistry.getAbilityDelegator();
const bundleName = abilityDelegatorRegistry.getArguments().bundleName;

export default function downloadApiTimeTest() {
  describe('downloadApiTimeTest', () => {
    const TAG = 'downloadApiTimeTest';
    const DOMAIN = 0x0004;

    // context
    let context: Context;
    let fileDir: string;

    const defaultFileName = XTS_CONFIG.defaultDownloadFileName;
    const defaultDownloadUrl = XTS_CONFIG.downloadUrl;

    // download
    let downloadManager: DownloadManager;
    let downloadConfig: DownloadConfig;
    let downloadListener: DownloadListener;

    beforeAll(async () => {
      const want: Want = {
        bundleName: bundleName,
        abilityName: 'TestAbility'
      }
      await delegator.startAbility(want);
      await sleep(1000);

      // context
      hilog.info(DOMAIN, TAG, '%{public}s', 'beforeAll - setup');
      context = AppStorage.get('context')!;
      expect(context !== undefined).assertTrue();

      // download
      fileDir = context.filesDir;

      // test
      downloadManager = DownloadManager.getInstance();
      expect(downloadManager !== undefined).assertTrue();
    });

    beforeEach(async () => {
      downloadConfig = {
        url: defaultDownloadUrl,
        fileName: defaultFileName,
        fileDir: fileDir,
        concurrency: 4,
        maxRetries: 3,
        retryInterval: 1000,
        connectTimeout: 60000,
        transferTimeout: 600000,
        inactivityTimeout: 10000,
        isBreakpointResume: true,
        isOverwrite: true,
        requestHeaders: {
          'X-Custom-Header': 'custom_header'
        }
      };

      downloadListener = {}

      await downloadManager.init(context);
    })

    afterEach(async () => {
      await downloadManager.cleanAll(context);
    })

    afterAll(() => {
    })

    it('ApiTime_Download_getDownloadManager', 1, async () => {
      hilog.info(DOMAIN, TAG, '%{public}s', 'ApiTime_Download_getDownloadManager begin');
      let apiResponseTime: number;

      apiResponseTime = await calculateFunctionTime(DownloadManager.getInstance);
      hilog.info(DOMAIN, TAG, 'Time: DownloadManager.getInstance:', apiResponseTime, 'ms')
      expect(apiResponseTime <= 1).assertTrue();
    });

    it('ApiTime_Download_init_clearAll', 2, async () => {
      hilog.info(DOMAIN, TAG, '%{public}s', 'ApiTime_Download_init_clearAll begin');
      let apiResponseTime: number;

      // clearALl
      apiResponseTime = await calculateFunctionTime(downloadManager.cleanAll, context);
      hilog.info(DOMAIN, TAG, 'Time: downloadManager.clearAll:', apiResponseTime, 'ms')
      expect(apiResponseTime <= 100).assertTrue();

      // init
      apiResponseTime = await calculateFunctionTime(downloadManager.init, context);
      hilog.info(DOMAIN, TAG, 'Time: downloadManager.init:', apiResponseTime, 'ms')
      expect(apiResponseTime <= 100).assertTrue();
    });

    it('ApiTime_Download_createDownloadTask', 3, async () => {
      hilog.info(DOMAIN, TAG, '%{public}s', 'ApiTime_Download_createDownloadTask begin');
      let apiResponseTime: number;

      // createDownloadTask
      apiResponseTime = await calculateFunctionTime(downloadManager.createDownloadTask, downloadConfig, downloadListener);
      hilog.info(DOMAIN, TAG, 'Time: downloadManager.createDownloadTask:', apiResponseTime, 'ms')
      expect(apiResponseTime <= 1).assertTrue();
    });

    it('ApiTime_Download_start_pause_resume_cancel_gerProgressInfo', 4, async () => {
      hilog.info(DOMAIN, TAG, '%{public}s', 'ApiTime_Download_start_pause_resume_cancel_gerProgressInfo begin');
      let apiResponseTime: number;

      let downloadTask = downloadManager.createDownloadTask(downloadConfig, downloadListener);
      if (downloadTask) {
        // start包含试连，响应时间与服务端、网络条件强相关
        apiResponseTime = await calculateFunctionTime(downloadTask.start);
        hilog.info(DOMAIN, TAG, 'Time: downloadTask.start:', apiResponseTime, 'ms')
        expect(apiResponseTime <= 500).assertTrue();

        // pause
        apiResponseTime = await calculateFunctionTime(downloadTask.pause);
        hilog.info(DOMAIN, TAG, 'Time: downloadTask.pause:', apiResponseTime, 'ms')
        expect(apiResponseTime <= 10).assertTrue();

        // getProgress
        apiResponseTime = await calculateFunctionTime(downloadTask.getProgress);
        hilog.info(DOMAIN, TAG, 'Time: downloadTask.getProgress:', apiResponseTime, 'ms')
        expect(apiResponseTime <= 10).assertTrue();

        // resume包含试连，api响应时间与服务端、网络条件强相关
        apiResponseTime = await calculateFunctionTime(downloadTask.resume);
        hilog.info(DOMAIN, TAG, 'Time: downloadTask.resume:', apiResponseTime, 'ms')
        expect(apiResponseTime <= 500).assertTrue();

        // cancel
        apiResponseTime = await calculateFunctionTime(downloadTask.cancel);
        hilog.info(DOMAIN, TAG, 'Time: downloadTask.cancel:', apiResponseTime, 'ms')
        expect(apiResponseTime <= 10).assertTrue();
      }
    });
  })
}