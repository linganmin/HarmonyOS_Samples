import { fileGuard } from '@kit.EnterpriseDataGuardKit';
import { fileIo } from '@kit.CoreFileKit'
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = '[ScanFileGuard]';

class ScanFileGuard {
  private fileGuard;
  private testFd: number;
  private jsonContent: ArrayBuffer;
  private jsonStr: string;

  arrayBufferToStr(buf) {
    try {
      let array = new Uint8Array(buf);
      this.jsonStr = String.fromCharCode.apply(null, array);
      hilog.info(0x0000, TAG, `arrayBufferToStr end len: ${this.jsonStr.length} value: ${this.jsonStr}.`);
      return this.jsonStr;
    } catch (err) {
      hilog.error(0x0000, TAG, `arrayBufferToStr error.Code: ${err.code}, message: ${err.message}.`);
    }
  }

  getTestFileContent() {
    hilog.info(0x0000, TAG, `getTestFileContent start.`);
    this.fileGuard.openFile('/data/service/el2/test.json', (err, fd) => {
      if (err) {
        hilog.error(0x0000, TAG,
          `Failed to open file. path: /data/service/el2/test.json,Code: ${err.code}, message: ${err.message}.`);
      }
      hilog.info(0x0000, TAG, `Succeeded in opening file. path: /data/service/el2/test.json, fd: ${fd}.`);
      this.testFd = fd;
      this.jsonContent = new ArrayBuffer(40960);
      let count = fileIo.readSync(this.testFd, this.jsonContent);
      let jsonBuffer = this.jsonContent.slice(0, count);
      let str = this.arrayBufferToStr(jsonBuffer);
      hilog.info(0x0000, TAG, `getTestFileContent end: ${str}.`);
    });
  }

  public constructor() {
    try {
      this.fileGuard = new fileGuard.FileGuard();
      this.getTestFileContent();
    } catch (err) {
      hilog.error(0x0000, TAG, `constructor error. Code: ${err.code}, message: ${err.message}.`);
    }
  }

  getFileFd() {
    hilog.info(0x0000, TAG, `getFileFd start.`);
    let jsonObj = JSON.parse(this.jsonStr);
    jsonObj['file_to_open'].forEach((path, index) => {
      this.fileGuard.openFile(path).then((fd) => {
        hilog.info(0x0000, TAG, `Succeeded in opening file. path: ${path}, fd: ${fd}.`);
      }).catch((err) => {
        hilog.error(0x0000, TAG, `Failed to open file. Code: ${err.code}, message: ${err.message}.`);
      });
    });
  }

  onRecvFilelist(files: Array<string>): void {
    files.forEach((value, index) => {
      hilog.info(0x0000, TAG, `Succeeded in getting file: ${value}.`);
    })
  }

  onCompleteTask(count: number): void {
    hilog.info(0x0000, TAG, `Succeeded in getting count: ${count}.`);
  }

  getFileList() {
    hilog.info(0x0000, TAG, `getFileList start.`);
    try {
      this.fileGuard.startFileScanTask(fileGuard.CommonDirScanType.MEDIA_ONLY, {
        onReceiveFileList: this.onRecvFilelist,
        onTaskCompleted: this.onCompleteTask
      });
    } catch (err) {
      hilog.error(0x0000, TAG, `Failed to scan media file. Code: ${err.code}, message: ${err.message}.`);
    }
  }

  getAllFileList() {
    hilog.info(0x0000, TAG, `getAllFileList start.`);
    try {
      this.fileGuard.startFileScanTask(fileGuard.CommonDirScanType.MEDIA_AND_SANDBOX, {
        onReceiveFileList: this.onRecvFilelist,
        onTaskCompleted: this.onCompleteTask
      });
    } catch (err) {
      hilog.error(0x0000, TAG, `Failed to scan media and sandbox file. Code: ${err.code}, message: ${err.message}.`);
    }
  }

  setKiaFileTag(filePath: string, level, tag: string) {
    hilog.info(0x0000, TAG, `setKiaFileTag start. file: ${filePath}.`);
    this.fileGuard.setFileTag(filePath, level, tag, (err) => {
      if (err) {
        hilog.error(0x0000, TAG, `Failed to set the list of KIA file. Code: ${err.code}, message: ${err.message}.`);
        return;
      }
      hilog.info(0x0000, TAG, `Succeeded in setting the list of KIA file.`);
    });
  }

  testSetKiaFileTag() {
    let jsonObj = JSON.parse(this.jsonStr);
    jsonObj['set_kia_tag'].forEach((tag, index) => {
      this.setKiaFileTag(tag['file'], tag['level'], tag['tag']);
    });
  }

  queryKiaFileTag(filePath: string) {
    hilog.info(0x0000, TAG, `queryKiaFileTag start. file: ${filePath}.`);
    this.fileGuard.queryFileTag(filePath, (err, data) => {
      if (err) {
        hilog.error(0x0000, TAG, `Failed to query file tag. Code: ${err.code}, message: ${err.message}.`);
        return;
      }
      hilog.info(0x0000, TAG, `Succeeded in querying file tag.`);
    });
  }

  testQueryKiaFileTag() {
    let jsonObj = JSON.parse(this.jsonStr);
    jsonObj['query_kia_tag'].forEach((path, index) => {
      this.queryKiaFileTag(path);
    });
  }

  setKiaFileList(kiaPathArr: Array<string>) {
    hilog.info(0x0000, TAG, `setKiaFileList start.`);
    let jsonKiaResult = {};
    jsonKiaResult['kia_filelist'] = kiaPathArr;
    this.fileGuard.setKiaFilelist(JSON.stringify(jsonKiaResult), (err) => {
      if (err) {
        hilog.error(0x0000, TAG, `Failed to set the list of KIA file. Code: ${err.code}, message: ${err.message}.`);
        return;
      }
      hilog.info(0x0000, TAG, `Succeeded in setting the list of KIA file.`);
    })
  }

  queryKiaFileUri(path: string) {
    hilog.info(0x0000, TAG, `queryKiaFileUri start. file: ${path}.`);
    this.fileGuard.getFileUri(path, (err, data) => {
      if (err) {
        hilog.error(0x0000, TAG, `Failed to get file uri. Code: ${err.code}, message: ${err.message}.`);
        return;
      }
      hilog.info(0x0000, TAG, `Succeeded in getting file uri.`);
    });
  }

  testQueryFileUri() {
    let jsonObj = JSON.parse(this.jsonStr);
    jsonObj['query_file_uri'].forEach((path, index) => {
      this.queryKiaFileUri(path);
    });
  }

  deleteKiaFile(path: string) {
    hilog.info(0x0000, TAG, `deleteKiaFile start. file: ${path}.`);
    this.fileGuard.deleteFile(path, (err) => {
      if (err) {
        hilog.error(0x0000, TAG, `Failed to delete file. Code: ${err.code}, message: ${err.message}.`);
        return;
      }
      hilog.info(0x0000, TAG, `Succeeded in deleting file.`);
    });
  }

  testDeleteKiaFile() {
    let jsonObj = JSON.parse(this.jsonStr);
    jsonObj['file_to_delete'].forEach((path, index) => {
      this.deleteKiaFile(path);
    });
  }

  testSetKiaList() {
    hilog.info(0x0000, TAG, `testSetKiaList start.`);
    let jsonObj = JSON.parse(this.jsonStr);
    let fileObj: object = {};
    let fileArr: Array<string> = [];
    let keywordArr: Array<string> = [];
    let suffixArr: Array<string> = [];
    jsonObj['kia_filelist'].forEach((path, index) => {
      fileArr.push(path);
    });
    jsonObj['kia_keyword'].forEach((path, index) => {
      keywordArr.push(path);
    });
    jsonObj['kia_suffix'].forEach((path, index) => {
      suffixArr.push(path);
    });
    fileObj['kia_filelist'] = fileArr;
    fileObj['kia_keyword'] = keywordArr;
    fileObj['kia_suffix'] = suffixArr;
    this.fileGuard.setKiaFilelist(JSON.stringify(fileObj), (err) => {
      if (err) {
        hilog.error(0x0000, TAG, `Failed to set the list of KIA file. Code: ${err.code}, message: ${err.message}.`);
        return;
      }
      hilog.info(0x0000, TAG, `Succeeded in setting the list of KIA file.`);
    })
  }

  testSetKiaListLong() {
    hilog.info(0x0000, TAG, `testSetKiaListlong start.`);
    let fileObj: object = {};
    let fileArr: Array<string> = [];
    let keywordArr: Array<string> = [];
    let suffixArr: Array<string> = [];
    let i = 0;
    for (; i < 10000; i++) {
      let cur: string = '/data/service/el2/100/hmdfs/account/files/Docs/Documents/aaa.txt' + i
      fileArr.push(cur)
    }
    hilog.info(0x0000, TAG, `setKiaFilelist count ${i}`);
    fileObj['kia_filelist'] = fileArr;
    fileObj['kia_keyword'] = keywordArr;
    fileObj['kia_suffix'] = suffixArr;
    this.fileGuard.setKiaFilelist(JSON.stringify(fileObj), (err) => {
      if (err) {
        hilog.error(0x0000, TAG, `Failed to set the list of KIA file. Code: ${err.code}, message: ${err.message}.`);
        return;
      }
      hilog.info(0x0000, TAG, `Succeeded in setting the list of KIA file.`);
    })
  }

  testUpdateKiaList() {
    hilog.info(0x0000, TAG, `testUpdateKiaList start.`);
    let jsonObj = JSON.parse(this.jsonStr);
    let jsonStr = JSON.stringify(jsonObj['add_kia_list']);
    hilog.info(0x0000, TAG, `testUpdateKiaList str: ${jsonStr}.`);

    this.fileGuard.setKiaFilelist(jsonStr, (err) => {
      if (err) {
        hilog.error(0x0000, TAG, `Failed to set the list of KIA file. Code: ${err.code}, message: ${err.message}.`);
        return;
      }
      hilog.info(0x0000, TAG, `Succeeded in setting the list of KIA file.`);
    })
  }

  testDeleteKiaList() {
    hilog.info(0x0000, TAG, `testDeleteKiaList start.`);
    let jsonObj = JSON.parse(this.jsonStr);
    let jsonStr = JSON.stringify(jsonObj['del_kia_list']);
    hilog.info(0x0000, TAG, `testDeleteKiaList str: ${jsonStr}.`);

    this.fileGuard.setKiaFilelist(jsonStr, (err) => {
      if (err) {
        hilog.error(0x0000, TAG, `Failed to set the list of KIA file. Code: ${err.code}, message: ${err.message}.`);
        return;
      }
      hilog.info(0x0000, TAG, `Succeeded in setting the list of KIA file.`);
    })
  }

  stringToArray(strData) {
    let dataArr: Array<string> = strData.split(';');
    return dataArr;
  }

  updateNetRejectPolicy() {
    hilog.info(0x0000, TAG, `updateNetRejectPolicy start.`);
    let jsonObj = JSON.parse(this.jsonStr);
    let jsonStr = JSON.stringify(jsonObj['update_policy']);
    this.fileGuard.updatePolicy(jsonStr, (err) => {
      if (err) {
        hilog.error(0x0000, TAG, `Failed to update policy. Code: ${err.code}, message: ${err.message}.`);
        return;
      }
      hilog.info(0x0000, TAG, `Succeeded in updating policy.`);
    })
  }

  updateIncrementalNetRejectPolicy() {
    hilog.info(0x0000, TAG, `updateIncrementalNetRejectPolicy start.`);
    let jsonObj = JSON.parse(this.jsonStr);
    let jsonStr = JSON.stringify(jsonObj['add_net_policy']);
    hilog.info(0x0000, TAG, `updateIncrementalNetRejectPolicy ${jsonStr}.`);
    this.fileGuard.updatePolicy(jsonStr, (err) => {
      if (err) {
        hilog.error(0x0000, TAG, `Failed to update policy. Code: ${err.code}, message: ${err.message}.`);
        return;
      }
      hilog.info(0x0000, TAG, `Succeeded in updating policy.`);
    })
  }

  testSubscriptionKIAEvent() {
    hilog.info(0x0000, TAG, `testSubscriptionKIAEvent start.`);
    let jsonObj = JSON.parse(this.jsonStr);
    let fileObj: object = {};
    let fileArr: Array<string> = [];
    let compressSuffixArr: Array<string> = [];
    jsonObj['kia_filelist'].forEach((path, index) => {
      fileArr.push(path);
    });
    jsonObj['compress_suffix'].forEach((path, index) => {
      compressSuffixArr.push(path);
    });
    fileObj['kia_filelist'] = fileArr;
    fileObj['compress_suffix'] = compressSuffixArr;

    this.fileGuard.setKiaFilelist(JSON.stringify(fileObj), (err) => {
      if (err) {
        hilog.error(0x0000, TAG, `Failed to set the list of KIA file. Code: ${err.code}, message: ${err.message}.`);
        return;
      }
      hilog.info(0x0000, TAG, `Succeeded in setting the list of KIA file.`);
      this.subscriptionKIAEvent();
    })
  }

  subscriptionKIAEvent() {
    hilog.info(0x0000, TAG, `subscriptionKIAEvent start.`);
    try {
      this.fileGuard.on('kiaCopy', (eventData: string) => {
        hilog.info(0x0000, TAG, `KIA copy receive eventData: ${eventData}.`);
      });
      this.fileGuard.on('kiaRename', (eventData: string) => {
        hilog.info(0x0000, TAG, `KIA rename receive eventData: ${eventData}.`);
      });
      this.fileGuard.on('kiaCompress', (eventData: string) => {
        hilog.info(0x0000, TAG, `KIA compress receive eventData: ${eventData}.`);
      });
      hilog.info(0x0000, TAG, `Succeeded in subscribing to KIA events.`);
    } catch (e) {
      hilog.error(0x0000, TAG, `Failed to listen the KIA event. Code: ${e.code}, message: ${e.message}.`);
    }
  }

  unSubscriptionKIAEvent() {
    hilog.info(0x0000, TAG, `unSubscriptionKIAEvent start.`);
    try {
      this.fileGuard.off('kiaCopy');
      this.fileGuard.off('kiaRename');
      this.fileGuard.off('kiaCompress');
      hilog.info(0x0000, TAG, `Succeeded in unsubscribing from KIA events.`);
    } catch (e) {
      hilog.error(0x0000, TAG, `Failed to cancel listen the KIA event. Code: ${e.code}, message: ${e.message}.`);
    }
  }

  async setKiaWatermarkImage() {
    hilog.info(0x0000, TAG, `setKiaWatermarkImage start.`);
    try {
      let imagePath: string = '/data/service/el2/test_water.png';
      let fd: number = await this.fileGuard.openFile(imagePath);
      let stat: fileIo.Stat = fileIo.statSync(fd);
      let buffer: ArrayBuffer = new ArrayBuffer(stat.size);
      fileIo.readSync(fd, buffer);

      let image: Uint8Array = new Uint8Array(buffer);
      let info: string = new Date().toLocaleString();
      this.fileGuard.setKiaWatermarkImage(image, info).then(() => {
        hilog.info(0x0000, TAG, `Succeeded in setting the watermark image for KIA file.`);
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, TAG,
          `Failed to set the watermark image for Kia file. Code: ${err.code}, message: ${err.message}.`);
      })
    } catch (e) {
      hilog.error(0x0000, TAG, `testSetKiaWaterMarkImage Exception, Code: ${e.code}, message: ${e.message}.`);
    }
  }
}

export default new ScanFileGuard();