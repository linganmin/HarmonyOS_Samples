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
import { fileIo as fs } from '@kit.CoreFileKit';
import { XTS_CONFIG } from '../Common';
import { UploadConfig, UploadListener, UploadManager } from '@hadss/super_fast_file_trans';
import { calculateFunctionTime, sleep } from '../TestUtil';

const delegator = abilityDelegatorRegistry.getAbilityDelegator();
const bundleName = abilityDelegatorRegistry.getArguments().bundleName;

export default function uploadApiTimeTest() {
  describe('uploadApiTimeTest', () => {
    const TAG = 'uploadApiTimeTest';
    const DOMAIN = 0x0005;

    // context
    let context: Context;
    let fileDir: string;

    const defaultUploadUrl = XTS_CONFIG.uploadUrl;
    const defaultChunkUploadUrl = XTS_CONFIG.chunkUploadUrl;
    const defaultUploadFileName = XTS_CONFIG.defaultUploadFileName;
    let localFilePath: string;

    // upload
    let uploadManager: UploadManager;
    let uploadConfig: UploadConfig;
    let uploadListener: UploadListener;

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

      // upload
      fileDir = context.filesDir;
      localFilePath = `${fileDir}/${defaultUploadFileName}`;
      uploadManager = UploadManager.getInstance();
      expect(uploadManager !== undefined).assertTrue();

      // 由于测试前环境会清空沙箱，需要复制本地文件到沙箱中, 再进行上传
      // "resources/rawfile/demo.zip"
      let readContent: Uint8Array = await context.resourceManager.getRawFileContent(defaultUploadFileName);
      if (readContent) {
        let file = fs.openSync(localFilePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
        fs.writeSync(file.fd, readContent.buffer);
        fs.fsyncSync(file.fd);
        fs.closeSync(file);
      }
    });

    beforeEach(async () => {
      uploadConfig = {
        url: defaultUploadUrl,
        filePath: localFilePath,
        uploadFileName: defaultUploadFileName,
        contentType: 'application/zip',
        isChunk: false,
        chunkSize: 1 * 1024 * 1024,
        maxRetries: 3,
        retryInterval: 1000,
        connectTimeout: 60000,
        transferTimeout: 600000,
        inactivityTimeout: 10000,
        requestHeaders: {
          'X-Custom-Header': 'custom_header'
        },
        hashConfig: {
          hashAlgorithm: 'md5',
          hashHeader: 'custom-file-hash'
        }
      };

      uploadListener = {}

      await uploadManager.init(context);
    })

    afterEach(async () => {
      await uploadManager.cleanAll(context);
    })

    afterAll(() => {
    })

    it('ApiTime_Upload_getUploadManager', 1, async () => {
      hilog.info(DOMAIN, TAG, '%{public}s', 'ApiTime_Upload_getUploadManager begin');
      let apiResponseTime: number;

      // getUploadManager
      apiResponseTime = await calculateFunctionTime(UploadManager.getInstance);
      hilog.info(DOMAIN, TAG, 'time: UploadManager.getInstance:', apiResponseTime, 'ms')
      expect(apiResponseTime <= 1).assertTrue();
    });

    it('ApiTime_Upload_init_clearAll', 2, async () => {
      hilog.info(DOMAIN, TAG, '%{public}s', 'ApiTime_Upload_init_clearAll begin');
      let apiResponseTime: number;

      // clearALl
      apiResponseTime = await calculateFunctionTime(uploadManager.cleanAll, context);
      hilog.info(DOMAIN, TAG, 'time: uploadManager.clearAll:', apiResponseTime, 'ms')
      expect(apiResponseTime <= 100).assertTrue();

      // init
      apiResponseTime = await calculateFunctionTime(uploadManager.init, context);
      hilog.info(DOMAIN, TAG, 'time: uploadManager.init:', apiResponseTime, 'ms')
      expect(apiResponseTime <= 100).assertTrue();
    });

    it('ApiTime_Upload_createUploadTask', 3, async () => {
      hilog.info(DOMAIN, TAG, '%{public}s', 'ApiTime_Upload_createUploadTask begin');
      let apiResponseTime: number;

      // createUploadTask
      apiResponseTime = await calculateFunctionTime(uploadManager.createUploadTask, uploadConfig, uploadListener);
      hilog.info(DOMAIN, TAG, 'time: uploadManager.createUploadTask:', apiResponseTime, 'ms')
      expect(apiResponseTime <= 1).assertTrue();
    });

    it('ApiTime_Upload_start_cancel', 4, async () => {
      hilog.info(DOMAIN, TAG, '%{public}s', 'ApiTime_Upload_createUploadTask begin');
      let apiResponseTime: number;

      let uploadTask = uploadManager.createUploadTask(uploadConfig, uploadListener);

      if (uploadTask) {
        // start，响应时间与本地文件大小强相关
        apiResponseTime = await calculateFunctionTime(uploadTask.start);
        hilog.info(DOMAIN, TAG, 'Time: uploadTask.start:', apiResponseTime, 'ms')
        expect(apiResponseTime <= 1000).assertTrue()

        // cancel，响应时间与本地文件大小强相关
        apiResponseTime = await calculateFunctionTime(uploadTask.cancel);
        hilog.info(DOMAIN, TAG, 'Time: uploadTask.cancel:', apiResponseTime, 'ms')
        expect(apiResponseTime <= 100).assertTrue()
      }
    });

    it('ApiTime_ChunkUpload_start_pause_resume_cancel_gerProgressInfo', 5, async () => {
      hilog.info(DOMAIN, TAG, '%{public}s', 'ApiTime_ChunkUpload_start_pause_resume_cancel_gerProgressInfo begin');
      let apiResponseTime: number;

      uploadConfig.isChunk = true;
      uploadConfig.url = defaultChunkUploadUrl;

      let uploadTask = uploadManager.createUploadTask(uploadConfig, uploadListener);
      if (uploadTask) {
        // start，响应时间与本地文件大小强相关
        apiResponseTime = await calculateFunctionTime(uploadTask.start);
        hilog.info(DOMAIN, TAG, 'Time: uploadTask.start:', apiResponseTime, 'ms')
        expect(apiResponseTime <= 1000).assertTrue();

        // pause，与分片大小/多少强相关
        apiResponseTime = await calculateFunctionTime(uploadTask.pause);
        hilog.info(DOMAIN, TAG, 'Time: uploadTask.pause:', apiResponseTime, 'ms')
        expect(apiResponseTime <= 20).assertTrue();

        // getProgress
        apiResponseTime = await calculateFunctionTime(uploadTask.getProgress);
        hilog.info(DOMAIN, TAG, 'Time: uploadTask.getProgress:', apiResponseTime, 'ms')
        expect(apiResponseTime <= 20).assertTrue();

        // resume，响应时间与本地文件大小强相关
        apiResponseTime = await calculateFunctionTime(uploadTask.resume);
        hilog.info(DOMAIN, TAG, 'Time: uploadTask.resume:', apiResponseTime, 'ms')
        expect(apiResponseTime <= 1000).assertTrue();

        // cancel，与分片大小/多少强相关
        apiResponseTime = await calculateFunctionTime(uploadTask.cancel);
        hilog.info(DOMAIN, TAG, 'Time: uploadTask.cancel:', apiResponseTime, 'ms')
        expect(apiResponseTime <= 20).assertTrue();
      }
    });
  })
}