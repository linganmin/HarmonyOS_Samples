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

import { hilog } from '@kit.PerformanceAnalysisKit';
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { UploadTask, UploadConfig, UploadManager, UploadProgressInfo, UploadListener, } from '@hadss/super_fast_file_trans';
import { Want } from '@kit.AbilityKit';
import { abilityDelegatorRegistry } from '@kit.TestKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { BusinessError } from '@ohos.base';
import { Context } from '@ohos.arkui.UIContext';
import { XTS_CONFIG } from '../Common';
import { sleep } from '../TestUtil';

const delegator = abilityDelegatorRegistry.getAbilityDelegator();
const bundleName = abilityDelegatorRegistry.getArguments().bundleName;

export default function uploadAbilityTest() {
  // mate60
  describe('uploadAbilityTest', () => {
    const TAG = 'uploadTest';
    const DOMAIN = 0x0002;

    // context
    let context: Context;
    let fileDir: string;

    const dataBaseName = XTS_CONFIG.sfftUploadDBName;
    const defaultUploadUrl = XTS_CONFIG.uploadUrl;
    const defaultChunkUploadUrl = XTS_CONFIG.chunkUploadUrl;
    const defaultUploadFileName = XTS_CONFIG.defaultUploadFileName;
    let localFilePath: string;


    let uploadManager: UploadManager;
    let uploadConfig: UploadConfig;
    let uploadListener: UploadListener;

    // listenerTrigger
    let isOnStartTriggerred: boolean;
    let isOnPauseTriggerred: boolean;
    let isOnResumeTriggerred: boolean;
    let isOnCancelTriggerred: boolean;
    let isOnSuccessTriggerred: boolean;
    let isOnFailTriggerred: boolean;
    let isOnProgressUpdateTriggerred: boolean;

    beforeAll(async () => {
      const want: Want = {
        bundleName: bundleName,
        abilityName: 'TestAbility'
      }
      await delegator.startAbility(want);
      await sleep(1000);

      hilog.info(DOMAIN, TAG, '%{public}s', 'beforeAll - setup');
      context = AppStorage.get('context')!;
      expect(context !== undefined).assertTrue();

      fileDir = context.filesDir;
      localFilePath = `${fileDir}/${defaultUploadFileName}`;
      uploadManager = UploadManager.getInstance();

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
      isOnStartTriggerred = false;
      isOnPauseTriggerred = false;
      isOnResumeTriggerred = false;
      isOnCancelTriggerred = false;
      isOnSuccessTriggerred = false;
      isOnFailTriggerred = false;
      isOnProgressUpdateTriggerred = false;
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
      uploadListener = {
        onStart: () => {
          isOnStartTriggerred = true;
        },
        onPause: (uploadProgressInfo: UploadProgressInfo) => {
          isOnPauseTriggerred = true;
          expect(uploadProgressInfo !== undefined && uploadProgressInfo !== null).assertTrue();
        },
        onResume: (uploadProgressInfo: UploadProgressInfo) => {
          isOnResumeTriggerred = true;
          expect(uploadProgressInfo !== undefined && uploadProgressInfo !== null).assertTrue();
        },
        onCancel: () => {
          isOnCancelTriggerred = true;
        },
        onSuccess: (filePath: string) => {
          isOnSuccessTriggerred = true;
          expect(filePath !== undefined && filePath !== null);
        },
        onFail: (err: BusinessError<void>) => {
          isOnFailTriggerred = true;
          expect(err !== undefined && err !== null).assertTrue();
        },
        onProgressUpdate: (downloadProgress: UploadProgressInfo) => {
          isOnProgressUpdateTriggerred = true;
          expect(downloadProgress !== undefined && downloadProgress !== null).assertTrue();
        }
      };

      await uploadManager.init(context);
    })

    afterEach(async () => {
      await uploadManager.cleanAll(context);
    })

    afterAll(() => {
    })

    it('getUploadManager', 1, () => {
      hilog.info(DOMAIN, TAG, '%{public}s', 'getUploadManager begin');
      expect(uploadManager !== null && uploadManager !== undefined).assertTrue();
    });

    it('verifyUploadManagerInit', 2, async () => {
      hilog.info(DOMAIN, TAG, '%{public}s', 'verifyUploadInit begin');
      const databaseFilePath = `${context.databaseDir}/rdb/${dataBaseName}`; // /data/storage/el2/database/ohosTest/rdb/dataBaseName
      expect(fs.accessSync(databaseFilePath)).assertTrue();
    });

    it('verifyUploadManagerCleanAll', 3, async () => {
      hilog.info(DOMAIN, TAG, '%{public}s', 'verifyUploadManagerCleanAll begin');
      const databaseFilePath = `${context.databaseDir}/rdb/${dataBaseName}`; // /data/storage/el2/database/ohosTest/rdb/dataBaseName
      await uploadManager.cleanAll(context);
      expect(fs.accessSync(databaseFilePath)).assertFalse();
    });

    it('getUploadTask_correctConfig', 4, async () => {
      hilog.info(DOMAIN, TAG, '%{public}s', 'getUploadInstance_correctConfig begin');
      let uploadTask: UploadTask | undefined = uploadManager.createUploadTask(uploadConfig);
      expect(uploadTask !== null && uploadTask !== undefined).assertTrue();
    });

    it('getUploadTask_incorrectConfig', 5, async () => {
      hilog.info(DOMAIN, TAG, '%{public}s', 'getUploadInstance_incorrectConfig begin');

      // incorrect chunkSize
      uploadConfig.chunkSize = 0;
      let uploadTask1: UploadTask | undefined = uploadManager.createUploadTask(uploadConfig);
      expect(uploadTask1 === null || uploadTask1 === undefined).assertTrue();
      uploadConfig.chunkSize = 1 * 1024 * 1024 * 1024 + 1;
      let uploadTask2: UploadTask | undefined = uploadManager.createUploadTask(uploadConfig);
      expect(uploadTask2 === null || uploadTask2 === undefined).assertTrue();

      // incorrect maxRetries
      uploadConfig.maxRetries = -1;
      let uploadTask3: UploadTask | undefined = uploadManager.createUploadTask(uploadConfig);
      expect(uploadTask3 === null || uploadTask3 === undefined).assertTrue();
      uploadConfig.maxRetries = 11;
      let uploadTask4: UploadTask | undefined = uploadManager.createUploadTask(uploadConfig);
      expect(uploadTask4 === null || uploadTask4 === undefined).assertTrue();

      // incorrect maxRetries
      uploadConfig.retryInterval = 0;
      let uploadTask5: UploadTask | undefined = uploadManager.createUploadTask(uploadConfig);
      expect(uploadTask5 === null || uploadTask5 === undefined).assertTrue();
      uploadConfig.retryInterval = 10001;
      let uploadTask6: UploadTask | undefined = uploadManager.createUploadTask(uploadConfig);
      expect(uploadTask6 === null || uploadTask6 === undefined).assertTrue();
    });

    it('verifyUpload_Start_without_ChunkUpload', 6, async () => {
      hilog.info(DOMAIN, TAG, '%{public}s', 'verifyUpload_Start_without_ChunkUpload begin');

      let uploadTask: UploadTask | undefined = uploadManager.createUploadTask(uploadConfig, uploadListener);
      if (uploadTask) {
        await uploadTask.start();
        expect(isOnStartTriggerred).assertTrue();
        await sleep(8000); // 设置合适的等待时长，防止测试用例超时
        expect(isOnSuccessTriggerred).assertTrue();
      }
    });

    it('verifyUpload_Cancel_without_ChunkUpload', 7, async () => {
      hilog.info(DOMAIN, TAG, '%{public}s', 'verifyUpload_Cancel_without_ChunkUpload begin');

      let uploadTask: UploadTask | undefined = uploadManager.createUploadTask(uploadConfig, uploadListener);
      if (uploadTask) {
        await uploadTask.start();
        expect(isOnStartTriggerred).assertTrue();
        await sleep(500); // 设置合适的等待时长，防止测试用例超时
        await uploadTask.cancel();
        expect(isOnCancelTriggerred).assertTrue();
        await sleep(5000); // 设置合适的等待时长，防止测试用例超时
        expect(isOnSuccessTriggerred).assertFalse();
      }
    });

    it('verifyUpload_Success_Pause_Resume_with_ChunkUpload', 8, async () => {
      hilog.info(DOMAIN, TAG, '%{public}s', 'verifyUpload_Success_Pause_Resume_with_ChunkUpload begin');

      uploadConfig.isChunk = true;
      uploadConfig.url = defaultChunkUploadUrl;

      let uploadTask: UploadTask | undefined = uploadManager.createUploadTask(uploadConfig, uploadListener);
      if (uploadTask) {
        await uploadTask.start();
        expect(isOnStartTriggerred).assertTrue();

        await sleep(200); // 设置合适的等待时长，防止测试用例超时
        await uploadTask.pause();
        expect(isOnPauseTriggerred).assertTrue();

        await sleep(200); // 设置合适的等待时长，防止测试用例超时
        await uploadTask.resume();
        expect(isOnResumeTriggerred).assertTrue();

        await sleep(12000); // 设置合适的等待时长，防止测试用例超时
        expect(isOnSuccessTriggerred).assertTrue();
      }
    });

    it('verifyUpload_Fail_with_ChunkUpload', 9, async () => {
      hilog.info(DOMAIN, TAG, '%{public}s', 'verifyUpload_Success_Pause_Resume_with_ChunkUpload begin');

      uploadConfig.isChunk = true;
      uploadConfig.url = defaultChunkUploadUrl;

      let uploadTask: UploadTask | undefined = uploadManager.createUploadTask(uploadConfig, uploadListener);
      if (uploadTask) {
        await uploadTask.start();
        expect(isOnStartTriggerred).assertTrue();

        await sleep(200); // 设置合适的等待时长，防止测试用例超时
        await uploadTask.pause();
        expect(isOnPauseTriggerred).assertTrue();

        await uploadManager.cleanAll(context); // 删除数据库

        await sleep(200); // 设置合适的等待时长，防止测试用例超时
        await uploadTask.resume(); // 重试失败

        expect(isOnResumeTriggerred).assertFalse();
        expect(isOnFailTriggerred).assertTrue();

        await sleep(8000); // 设置合适的等待时长，防止测试用例超时
        expect(isOnSuccessTriggerred).assertFalse();
      }
    });
  })
}