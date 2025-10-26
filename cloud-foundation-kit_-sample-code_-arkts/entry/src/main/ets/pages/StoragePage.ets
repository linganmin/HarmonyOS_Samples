/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

import { cloudStorage } from '@kit.CloudFoundationKit';
import { BusinessError, request } from '@kit.BasicServicesKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { GlobalContext } from '../common/GlobalContext';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Common } from '../common/Common';

const DOMAIN = 0x0000;
const TAG = 'StoragePage';
let UI: StoragePage;

@Entry
@Component
struct StoragePage {
  @State showMessage: string = '';
  @State uploadFileName: string = '';

  aboutToAppear(): void {
    UI = this;
  }

  build() {
    Column() {
      Navigation()
        .title($r('app.string.cloud_storage_title'))
        .height('50vp')
        .width('100%')
        .margin({ bottom: 10 })
        .titleMode(NavigationTitleMode.Mini)
      Row() {
        Column() {
          this.newButton(Common.getStringByNameSync('cloudStorage_btn1'),
            this.uploadFileWithAPI);
          this.newButton(Common.getStringByNameSync('cloudStorage_btn2'),
            this.downloadFileWithAPI);
          this.newButton(Common.getStringByNameSync('cloudStorage_btn3'),
            this.deleteFile);
          this.newButton(Common.getStringByNameSync('cloudStorage_btn4'),
            this.getDownloadURL);
          this.newButton(Common.getStringByNameSync('cloudStorage_btn5'),
            this.list);
          this.newButton(Common.getStringByNameSync('cloudStorage_btn6'),
            this.getMetadata);
          this.newButton(Common.getStringByNameSync('cloudStorage_btn7'),
            this.setMetadata);
        }
      }.height('80%').width('98%');

      // eslint-disable-next-line @performance/hp-arkui-reduce-view-nest-level
      Row() {
        Text('messages:').fontSize(12).fontWeight(FontWeight.Bold).align(Alignment.BottomStart).width('100%');
      };

      Row() {
        TextArea({ text: this.showMessage })
          .fontSize(10)
          .align(Alignment.TopStart)
          .width('100%')
          .height('100%')
          .borderRadius(2)
          .backgroundColor('#fff3efef')
          .maxLines(1000)
      }.height('18%');
    }
  }

  @Builder
  newButton(title: string, action: () => void) {
    Row() {
      Button(title, { type: ButtonType.Normal })
        .borderRadius(4)
        .width('100%')
        .height(40)
        .onClick(() => {
          this.showMessage = '';
          try {
            action();
          } catch (e) {
            UI.printMessage(e.message);
            UI.printMessage(e.code);
            UI.printMessage(e.stack);
          }
        })
    }

    Row() {
    }.margin({ bottom: 4 })
  }

  printMessage(message: string) {
    UI.showMessage = UI.showMessage.concat(message + '\n');
  }

  uploadFile() {
    let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE; // Set the media file type to IMAGE.
    photoSelectOptions.maxSelectNumber = 1; // Set the maximum number of media files that can be selected.
    let photoViewPicker = new photoAccessHelper.PhotoViewPicker();
    photoViewPicker.select(photoSelectOptions).then((photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
      let fileUri: string = photoSelectResult.photoUris[0];
      UI.printMessage(`pick image ${fileUri}`);
      let imgName = fileUri.split('/').pop() as string;
      UI.uploadFileName = imgName;
      UI.printMessage(`imgName ${imgName}`);
      let dstPath = GlobalContext.getContext().cacheDir + '/' + imgName;
      UI.printMessage(`dstPath ${dstPath}`);

      // Copy the file to the cache directory.
      try {
        let srcFile = fs.openSync(fileUri);
        let dstFile = fs.openSync(dstPath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
        fs.copyFileSync(srcFile.fd, dstFile.fd);
        fs.closeSync(srcFile);
        fs.closeSync(dstFile);
      } catch (err) {
        hilog.error(DOMAIN, TAG, `Failed to do fs operation, code: ${err.code}, message: ${err.message}`);
      }

      let uploadConfig: request.UploadConfig = {
        url: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/hello-ry8zu/' + UI.uploadFileName,
        header: {
          'User-Agent': 'CloudStorageHarmonySDKClient'
        },
        method: 'PUT',
        files: [{
          filename: imgName,
          name: imgName,
          uri: 'internal://cache/' + imgName,
          type: ''
        }],
        data: [{ name: 'files', value: 'files' }],
      };
      request.uploadFile(GlobalContext.getContext(), uploadConfig)
        .then((task: request.UploadTask) => {
          task.on('progress', (uploadedSize: number, totalSize: number) => {
            UI.printMessage(`on progress uploadedSize: ${uploadedSize} totalSize: ${totalSize}`);
          });

          task.on('complete', (taskState: Array<request.TaskState>) => {
            taskState.forEach((item: request.TaskState) => {
              UI.printMessage(`on complete: ${JSON.stringify(item)}`);
              if (item.responseCode === 0) {
                UI.printMessage(`upload success`);
              }
            });
          });
          task.on('fail', (taskState: Array<request.TaskState>) => {
            taskState.forEach((item: request.TaskState) => {
              UI.printMessage(`on fail: ${JSON.stringify(item)}`);
            });
          });
        }).catch((error: Error) => {
        UI.printMessage('uploadFile error' + error);
        UI.printMessage(`uploadFile err.stack = ${error.stack}`);
      });
    }).catch((err: BusinessError) => {
      hilog.error(DOMAIN, TAG, `Failed to pick photo view, code: ${err.code}, message: ${err.message}`);
    })
  }

  async downloadFile() {
    let cloudPath = UI.uploadFileName;
    UI.printMessage(`downloadFile cloudPath ${cloudPath}`);
    let fileDir = GlobalContext.getContext().filesDir;
    let localPath = fileDir + '/' + cloudPath;
    UI.printMessage(`downloadFile localPath ${localPath}`);
    try {
      let isFileExist = await fs.access(localPath);
      if (isFileExist) {
        UI.printMessage(`file exist, delete it first`);
        await fs.unlink(localPath);
      }
    } catch (e) {
      UI.printMessage(`file access: ${JSON.stringify(e)}`);
    }

    try {
      request.downloadFile(GlobalContext.getContext(), {
        url: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/hello-ry8zu/' + cloudPath,
        header: {
          'User-Agent': 'CloudStorageHarmonySDKClient'
        },
        filePath: localPath
      }).then((task: request.DownloadTask) => {
        task.on('progress', (receivedSize: number, totalSize: number) => {
          UI.printMessage(`on download progress receivedSize: ${receivedSize} totalSize: ${totalSize}`);
        });

        task.on('complete', () => {
          UI.printMessage(`on download complete: success`);
          // View the file list.
          this.listDir(fileDir);
        });
        task.on('fail', () => {
          UI.printMessage(`on download complete: fail`);
        });
      }).catch((err: BusinessError) => {
        hilog.error(DOMAIN, TAG, `Failed to download file, code: ${err.code}, message: ${err.message}`);
      });
    } catch (error) {
      UI.printMessage('downloadFile error' + error);
      UI.printMessage(`downloadFile err.stack = ${error.stack}`);
    }
  }

  uploadFileWithTask() {
    let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE; // Set the media file type to IMAGE.
    photoSelectOptions.maxSelectNumber = 1; // Set the maximum number of media files that can be selected.
    let photoViewPicker = new photoAccessHelper.PhotoViewPicker();
    photoViewPicker.select(photoSelectOptions).then((photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
      let fileUri: string = photoSelectResult.photoUris[0];
      UI.printMessage(`pick image ${fileUri}`);
      let imgName = fileUri.split('/').pop() as string;
      UI.uploadFileName = imgName;
      UI.printMessage(`imgName ${imgName}`);
      let cacheFile = `${Date.now()}_${imgName}`;
      let dstPath = GlobalContext.getContext().cacheDir + '/' + cacheFile;
      UI.printMessage(`dstPath ${dstPath}`);

      try { // Copy the file to the cache directory.
        let srcFile = fs.openSync(fileUri);
        let dstFile = fs.openSync(dstPath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
        fs.copyFileSync(srcFile.fd, dstFile.fd);
        fs.closeSync(srcFile);
        fs.closeSync(dstFile);
      } catch (e) {
        UI.printMessage(`copy file failed ${e.message}`);
        UI.printMessage(`copy file failed ${e.stack}`);
      }

      let uploadConfig: request.agent.Config = {
        title: `upload title`,
        description: 'upload description',
        mode: request.agent.Mode.FOREGROUND,
        action: request.agent.Action.UPLOAD,
        url: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/hello-ry8zu/' + UI.uploadFileName,
        method: 'PUT',
        headers: {
          'User-Agent': 'CloudStorageHarmonySDKClient'
        },
        data: [{
          name: imgName,
          value: {
            path: cacheFile
          }
        }]
      };

      request.agent.create(GlobalContext.getContext(), uploadConfig)
        .then((task: request.agent.Task) => {
          task.on('progress', (progress) => {
            UI.printMessage(`on progress ${JSON.stringify(progress)}`);
          });
          task.on('completed', (progress) => {
            UI.printMessage(`on completed ${JSON.stringify(progress)}`);
          });
          task.on('failed', (progress) => {
            UI.printMessage(`on failed ${JSON.stringify(progress)}`);
          });
          task.start((err: BusinessError) => {
            if (err) {
              UI.printMessage(`Failed to start the uploadFileWithTask task, Code: ${err.code}, message: ${err.message}`);
            } else {
              UI.printMessage(`Succeeded in starting a uploadFileWithTask task.`);
            }
          });
        }).catch((error: Error) => {
        UI.printMessage('uploadFile error' + error);
        UI.printMessage(`uploadFile err.stack = ${error.stack}`);
      });
    }).catch((err: BusinessError) => {
      hilog.error(DOMAIN, TAG, `Failed to pick photo view, code: ${err.code}, message: ${err.message}`);
    })
  }

  uploadFileWithAPI() {
    UI.printMessage(`upload file with api`);
    let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    photoSelectOptions.maxSelectNumber = 1; // Set the maximum number of media files that can be selected.
    let photoViewPicker = new photoAccessHelper.PhotoViewPicker();
    photoViewPicker.select(photoSelectOptions).then((photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
      let fileUri = photoSelectResult.photoUris[0];
      UI.printMessage(`pick file ${fileUri}`);
      let fileName = fileUri.split('/').pop() as string;
      UI.uploadFileName = fileName;
      UI.printMessage(`file name ${fileName}`);
      let cacheFile = `${Date.now()}_${fileName}`;
      UI.printMessage(`cacheFile ${cacheFile}`);
      let cacheFilePath = GlobalContext.getContext().cacheDir + '/' + cacheFile;

      try {
        // Copy the selected file to the cache directory.
        let srcFile = fs.openSync(fileUri);
        let dstFile = fs.openSync(cacheFilePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
        fs.copyFileSync(srcFile.fd, dstFile.fd);
        fs.closeSync(srcFile);
        fs.closeSync(dstFile);

        // Use the API of Cloud Storage to upload the file.
        cloudStorage.bucket().uploadFile(GlobalContext.getContext(), {
          localPath: cacheFile,
          cloudPath: UI.uploadFileName,
          mode: request.agent.Mode.BACKGROUND
        })
          .then((task: request.agent.Task) => {
            task.on('progress', (progress) => {
              UI.printMessage(`on progress ${JSON.stringify(progress)}`);
            });
            task.on('completed', (progress) => {
              UI.printMessage(`on completed ${JSON.stringify(progress)}`);
              // Delete the file in the cache directory when the task is complete.
              fs.unlink(cacheFilePath).catch((err: BusinessError) => {
                hilog.error(DOMAIN, TAG, `Failed to unlink file, code: ${err.code}, message: ${err.message}`);
              });
              UI.printMessage(`delete cache file ${cacheFilePath}`);
            });
            task.on('failed', (progress) => {
              UI.printMessage(`on failed ${JSON.stringify(progress)}`);
              fs.unlink(cacheFilePath).catch((err: BusinessError) => {
                hilog.error(DOMAIN, TAG, `Failed to unlink file, code: ${err.code}, message: ${err.message}`);
              });
              UI.printMessage(`delete cache file ${cacheFilePath}`);
            });
            // Start the task.
            task.start((err: BusinessError) => {
              if (err) {
                UI.printMessage(`Failed to start the uploadFileWithTask task, Code: ${err.code}, message: ${err.message}`);
              } else {
                UI.printMessage(`Succeeded in starting a uploadFileWithTask task.`);
              }
            });
          })
          .catch((error: BusinessError) => {
            UI.printMessage('uploadFile error' + error);
            UI.printMessage(`uploadFile err.stack = ${error.stack}`);
          });
      } catch (e) {
        UI.printMessage(`uploadFile failed ${e.message}`);
        UI.printMessage(`uploadFile file failed ${e.stack}`);
      }
    }).catch((err: BusinessError) => {
      hilog.error(DOMAIN, TAG, `Failed to pick photo view, code: ${err.code}, message: ${err.message}`);
    })
  }

  async downloadFileWithTask() {
    let cloudPath = UI.uploadFileName;
    UI.printMessage(`downloadFile cloudPath ${cloudPath}`);
    let fileDir = GlobalContext.getContext().cacheDir;

    try {
      let downloadConfig: request.agent.Config = {
        action: request.agent.Action.DOWNLOAD,
        url: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/hello-ry8zu/' + cloudPath,
        headers: {
          'User-Agent': 'CloudStorageHarmonySDKClient'
        },
        saveas: `./${Date.now()}_` + UI.uploadFileName,
        overwrite: true
      };

      request.agent.create(GlobalContext.getContext(), downloadConfig)
        .then((task: request.agent.Task) => {
          task.on('progress', (progress) => {
            UI.printMessage(`on progress ${JSON.stringify(progress)} `);
          });
          task.on('completed', (progress) => {
            UI.printMessage(`on completed ${JSON.stringify(progress)} `);
            UI.listDir(fileDir);
          });
          task.on('failed', (progress) => {
            UI.printMessage(`on failed ${JSON.stringify(progress)} `);
          });
          task.start((err: BusinessError) => {
            if (err) {
              UI.printMessage(`Failed to start the uploadFileWithTask task, Code: ${err.code}, message: ${err.message}`);
            } else {
              UI.printMessage(`Succeeded in creating a downloadFileWithTask task. result: ${task.tid}`);
            }
          });
        }).catch((error: Error) => {
        UI.printMessage('downloadFile error' + error);
        UI.printMessage(`downloadFile err.stack = ${error.stack}`);
      });
    } catch (error) {
      UI.printMessage('downloadFile error' + error);
      UI.printMessage(`downloadFile err.stack = ${error.stack}`);
    }
  }

  downloadFileWithAPI() {
    cloudStorage.bucket().downloadFile(GlobalContext.getContext(), {
      localPath: `./${Date.now()}_` + UI.uploadFileName,
      cloudPath: UI.uploadFileName
    })
      .then((task: request.agent.Task) => {
        task.on('progress', (progress) => {
          UI.printMessage(`on progress ${JSON.stringify(progress)} `);
        });
        task.on('completed', (progress) => {
          UI.printMessage(`on completed ${JSON.stringify(progress)} `);
          UI.listDir(GlobalContext.getContext().cacheDir);
        });
        task.on('failed', (progress) => {
          UI.printMessage(`on failed ${JSON.stringify(progress)} `);
        });
        task.start((err: BusinessError) => {
          if (err) {
            UI.printMessage(`Failed to start the downloadFileWithTask task, Code: ${err.code}, message: ${err.message}`);
          } else {
            UI.printMessage(`Succeeded in starting a downloadFileWithTask task. result: ${task.tid}`);
          }
        });
      }).catch((error: Error) => {
      UI.printMessage('downloadFile error' + error);
      UI.printMessage(`downloadFile err.stack = ${error.stack}`);
    });
  }

  getMetadata() {
    let bucket: cloudStorage.StorageBucket = cloudStorage.bucket();
    bucket.getMetadata(UI.uploadFileName).then((result: cloudStorage.Metadata) => {
      UI.printMessage('promise bucket.getMetadata end  ' + JSON.stringify(result));
      let time: Date = result.createTime;
      UI.printMessage('printMessage time ' + time);
      UI.printMessage('time ' + time.getTime());
    }).catch((err: Object) => {
      UI.printMessage('promise bucket.getMetadata error' + err);
    });
    bucket.getMetadata(UI.uploadFileName, (error: BusinessError, result: cloudStorage.Metadata) => {
      if (error) {
        UI.printMessage(`callback bucket.getMetadata err = ${error.stack}`);
      } else {
        UI.printMessage('callback bucket.getMetadata end  ' + JSON.stringify(result));
      }
    });
  }

  setMetadata() {
    let bucket: cloudStorage.StorageBucket = cloudStorage.bucket();
    UI.printMessage('promise setMetadata  cloudPath: ' + UI.uploadFileName);
    bucket.setMetadata(UI.uploadFileName, {
      customMetadata: {
        key1: 'value1',
        key2: 'value2'
      }
    }).then((result: Object) => {
      UI.printMessage('promise bucket.setMetadata end  ' + JSON.stringify(result));
    }).catch((err: BusinessError) => {
      UI.printMessage('promise bucket.setMetadata error' + err);
      UI.printMessage(`promise bucket.setMetadata err.stack = ${err.stack}`);
    });
    bucket.setMetadata(UI.uploadFileName, {
      customMetadata: {
        key1: 'value1',
        key2: 'value2'
      }
    },
      (error: BusinessError, result: Object) => {
        if (error) {
          UI.printMessage(`callback bucket.setMetadata error:` + error);
          UI.printMessage(`callback bucket.setMetadata error.code: ` + error.code);
          UI.printMessage(`callback bucket.setMetadata err.stack ${error.stack}`);
        } else {
          UI.printMessage('callback bucket.setMetadata end  ' + JSON.stringify(result));
        }
      });
  }

  list() {
    UI.printMessage('bucket.list start');
    let bucket: cloudStorage.StorageBucket = cloudStorage.bucket();
    UI.printMessage('bucket.list  bucket=  ' + bucket);
    bucket.list('').then((result: Object) => {
      UI.printMessage('promise bucket.list end  ' + JSON.stringify(result));
    }).catch((err: BusinessError) => {
      UI.printMessage('promise bucket.list error' + err);
      UI.printMessage(`callback bucket.setMetadata error:` + err.stack);
    });
    bucket.list('', {
      maxResults: 1,
    }).then((result: Object) => {
      UI.printMessage('promise bucket.list end' + JSON.stringify(result));
    }).catch((err: BusinessError) => {
      UI.printMessage('promise bucket.list err' + err);
      UI.printMessage(`callback bucket.setMetadata error:` + err.stack);
    });

  }

  deleteFile() {
    let bucket: cloudStorage.StorageBucket = cloudStorage.bucket();
    bucket.deleteFile(UI.uploadFileName).then(() => {
      UI.printMessage('promise deleteFile end');
    }).catch((err: BusinessError) => {
      UI.printMessage('promise deleteFile err' + err);
      UI.printMessage(`promise deleteFile err = ${err.stack}`);
    });
    bucket.deleteFile(UI.uploadFileName, (err: BusinessError) => {
      if (err) {
        UI.printMessage('callback deleteFile err' + err);
        UI.printMessage(`callback deleteFile err = ${err.stack}`);
      } else {
        UI.printMessage('callback deleteFile end');
      }
    });
  }

  getDownloadURL() {
    let bucket: cloudStorage.StorageBucket = cloudStorage.bucket();
    bucket.getDownloadURL(UI.uploadFileName).then((downloadURL: string) => {
      UI.printMessage(`promise getDownloadURL: ${downloadURL}`);
    }).catch((reason: BusinessError) => {
      UI.printMessage('promise getDownloadURL failed : ' + reason.message);
      UI.printMessage('promise getDownloadURL failed : ' + JSON.stringify(reason));
      UI.printMessage(`promise getDownloadURL err = ${reason.stack}`);
    });
    bucket.getDownloadURL(UI.uploadFileName, (error: BusinessError, downloadURL: string) => {
      if (error) {
        UI.printMessage('callback getDownloadURL failed : ' + error.message);
        UI.printMessage('callback getDownloadURL failed : ' + JSON.stringify(error));
        UI.printMessage(`callback getDownloadURL err = ${error.stack}`);
      } else {
        UI.printMessage('callback getDownloadURL : ' + downloadURL);
      }
    });
  }

  private listDir(fileDir: string) {
    try {
      let files = fs.listFileSync(fileDir, {
        recursion: false,
        listNum: 0,
        filter: {
          suffix: ['.png', '.jpg', '.txt'],
          fileSizeOver: 0, // The file size is greater than or equal to 0.
        },
      });
      UI.printMessage(`list files in directory:`);
      for (let i = 0; i < files.length; i++) {
        UI.printMessage(`${files[i]}`);
      }
    } catch (err) {
      hilog.error(DOMAIN, TAG, `Failed to list file, code: ${err.code}, message: ${err.message}`);
    }
  }
}
