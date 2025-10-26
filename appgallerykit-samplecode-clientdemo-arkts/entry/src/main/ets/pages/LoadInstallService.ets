import { moduleInstallManager } from '@kit.AppGalleryKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import type { common } from '@kit.AbilityKit';
import { BusinessError, Callback } from '@kit.BasicServicesKit';


interface moduleListItem {
  name: string;
  des: string | Resource;
}

@Entry
@Component
export struct LoadInstallService {
  private bundleName: string = 'com.example.appgallery.kit.demo';
  @State selectModules: Array<string> = [];
  @State replyMsg: string = '';
  @State showReplyMsg: string | Resource= '';
  @State cancelReplyMsg: string | Resource = '';
  @State addLoading: boolean = false;
  @State curTaskId: string = '';
  @State curTaskStatus: number = -1;
  @State allInstalledModules: string = '';
  @State radioCheckIndex: number = 0;
  @State msg: string = '';
  @State onListeningResult: string = '';
  @State offListeningResult: string = '';
  @State progressTotalValue: number = 0;
  @State progressValue: number = 0;
  @BuilderParam AModulelibComponent: Function;
  @State countTotal: number = 0;
  @State isShow: boolean = false;
  private moduleList: Array<moduleListItem> = [
    {
      name: 'commonHap',
      des: $r('app.string.commonHap')
    },
    {
      name: 'AModulelib',
      des: $r('app.string.AModulelib')
    },
    {
      name: 'BModulelib',
      des: $r('app.string.BModulelib')
    },
    {
      name: 'XModulelib',
      des: $r('app.string.XModulelib')
    },
    {
      name: 'commonLibrary',
      des: $r('app.string.commonLibrary')
    }];
  scroller: Scroller = new Scroller();

  private showToastInfo(msg: string | Resource) {
    this.getUIContext().getPromptAction().showToast({
      message: msg,
      duration: 2000
    });
  }

  /**
   * 1. View the module information.
   */
  private getModuleInstanceInfo() {
    try {
      const name: string = this.moduleList[this.radioCheckIndex].name;
      hilog.info(0, 'InstantDownload', 'getModuleInstanceInfo name=' + name);
      const result: moduleInstallManager.InstalledModule = moduleInstallManager.getInstalledModule(name);
      this.allInstalledModules = JSON.stringify(result);
      hilog.info(0, 'InstantDownload', 'getModuleInstanceInfo success=' + this.allInstalledModules);
      this.showToastInfo(result?.installStatus === moduleInstallManager.InstallStatus.INSTALLED ?
      $r('app.string.moduleInstalled', name) : $r('app.string.moduleNotInstalled', name));
    } catch (error) {
      hilog.error(0, 'InstantDownload', `getModuleInstanceInfo error.code is ${error.code}, message is ${error.message}`);
    }
  }

  /**
   * 2. Request incremental loading.
   */
  private handleFetchModules() {
    try {
      this.addLoading = true;
      this.curTaskId = '';
      hilog.info(0, 'InstantDownload', 'handleFetchModules start');
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      const moduleInstallProvider: moduleInstallManager.ModuleInstallProvider =
        new moduleInstallManager.ModuleInstallProvider();
      const moduleInstallRequest: moduleInstallManager.ModuleInstallRequest =
        moduleInstallProvider.createModuleInstallRequest(context);
      if (!moduleInstallRequest) {
        hilog.error(0, 'InstantDownload', 'moduleInstallRequest is empty');
        this.showToastInfo($r('app.string.fetchModuleException'));
        this.addLoading = false;
        return;
      }
      this.selectModules.forEach(item => {
        const rtnCode: number = moduleInstallRequest.addModule(item);
        this.msg += `${item} add ${rtnCode === moduleInstallManager.ReturnCode.SUCCESS ? 'success' : 'fail'} `
      })

      moduleInstallManager.fetchModules(moduleInstallRequest)
        .then((data: moduleInstallManager.ModuleInstallSessionState) => {
          if (data?.code === moduleInstallManager.RequestErrorCode.SUCCESS) {
            this.showToastInfo($r('app.string.fetchModuleSuccess'));
          } else if (data?.code === moduleInstallManager.RequestErrorCode.DOWNLOAD_WAIT_WIFI) {
            this.showToastInfo($r('app.string.fetchModuleWaitWifi'));
          } else {
            this.showToastInfo($r('app.string.fetchModuleFailed'));
          }

          this.curTaskId = data?.taskId || '';
          hilog.info(0, 'InstantDownload', 'fetchModules success data=' + JSON.stringify(data));
          this.replyMsg = JSON.stringify(data);
          if (data?.taskStatus !== undefined &&
            data?.code === moduleInstallManager.RequestErrorCode.DOWNLOAD_WAIT_WIFI) {
            this.curTaskStatus =
              data?.taskStatus === moduleInstallManager.TaskStatus.DOWNLOAD_WAIT_WIFI ? 0 : -1;
            if (this.curTaskId && (this.curTaskStatus === 0)) {
              this.handleShowCellularDataConfirmation();
            }
          } else {
            this.curTaskStatus = -1;
          }
          this.addLoading = false;
        })
        .catch((error: BusinessError) => {
          this.showToastInfo($r('app.string.fetchModuleFailed'));
          hilog.error(0, 'InstantDownload', `fetchModules error.code is ${error.code}, message is ${error.message}`);
          this.addLoading = false;
        })
    } catch (error) {
      this.showToastInfo($r('app.string.fetchModuleFailed'));
      this.addLoading = false;
      hilog.error(0, 'InstantDownload', `handleFetchModules error.code is ${error.code}, message is ${error.message}`);
    }
  }

  /**
   * 3. Cancel a download task.
   */
  private cancelTask() {
    try {
      if (!this.curTaskId) {
        this.showToastInfo($r('app.string.taskIdNotExist'));
        return;
      }
      const result: moduleInstallManager.ReturnCode = moduleInstallManager.cancelTask(this.curTaskId);
      this.cancelReplyMsg = result === moduleInstallManager.ReturnCode.SUCCESS ? $r('app.string.success') : $r('app.string.failed');
      this.showToastInfo($r('app.string.cancelTaskResult', this.cancelReplyMsg));
    } catch (error) {
      hilog.error(0, 'InstantDownload', `cancelTask error.code is ${error.code}, message is ${error.message}`);
      this.showToastInfo($r('app.string.cancelTaskException'));
    }
  }

  /**
   * 4. Display a mobile data reminder.
   */
  private handleShowCellularDataConfirmation() {
    try {
      if (!this.curTaskId) {
        this.showToastInfo($r('app.string.taskIdNotExist'));
        return;
      }
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      const result: moduleInstallManager.ReturnCode = moduleInstallManager.showCellularDataConfirmation(context,
        this.curTaskId);
      this.showReplyMsg = result === moduleInstallManager.ReturnCode.SUCCESS ? $r('app.string.success') : $r('app.string.failed');
      this.showToastInfo($r('app.string.showCellularDataConfirmationResult', this.showReplyMsg));
    } catch (error) {
      this.showToastInfo($r('app.string.ShowCellularDataConfirmationException'));
      hilog.error(0, 'InstantDownload', `handleShowCellularDataConfirmation error.code is ${error.code}, message is ${error.message}`);
    }
  }

  /**
   *  5. Monitor the download progress.
   */
  private onListening() {
    try {
      moduleInstallManager.on('moduleInstallStatus', (data: moduleInstallManager.ModuleInstallSessionState) => {
        hilog.info(0, 'InstantDownload', 'onListening success data=' + JSON.stringify(data));
        this.curTaskId = data?.taskId || '';
        this.onListeningResult = `${JSON.stringify(data)}`;
        this.progressTotalValue = data?.totalSize || 0;
        this.progressValue = data?.downloadedSize || 0;
        let result = data?.code === moduleInstallManager.RequestErrorCode.SUCCESS ? $r('app.string.success') : $r('app.string.failed');
        this.showToastInfo($r('app.string.onResult', result));
      }, 30 * 60)
    } catch (error) {
      this.showToastInfo($r('app.string.onListeningException'));
      hilog.error(0, 'InstantDownload', `onListening error.code is ${error.code}, message is ${error.message}`);
    }
  }

  /**
   *   6. Cancel the download progress listener.
   */
  private offListening() {
    try {
      moduleInstallManager.off('moduleInstallStatus', (data: moduleInstallManager.ModuleInstallSessionState) => {
        hilog.info(0, 'InstantDownload', 'offListening success data=' + JSON.stringify(data));
        this.offListeningResult = `${JSON.stringify(data)}`;
        let result = data?.code === moduleInstallManager.RequestErrorCode.SUCCESS ? $r('app.string.success') : $r('app.string.failed');
        this.showToastInfo($r('app.string.offResult', result));
      })
    } catch (error) {
      this.showToastInfo($r('app.string.offListeningException'));
      hilog.error(0, 'InstantDownload', `offListening error.code is ${error.code}, message is ${error.message}`);
    }
  }

  /**
   *  7. Reset:
   */
  private reset() {
    this.replyMsg = '';
    this.showReplyMsg = '';
    this.cancelReplyMsg = '';
    this.curTaskId = '';
    this.addLoading = false;
    this.allInstalledModules = '';
    this.radioCheckIndex = 0;
    this.msg = '';
    this.onListeningResult = '';
    this.offListeningResult = '';
    this.progressTotalValue = 0;
    this.progressValue = 0;
    this.curTaskStatus = -1;
    this.showToastInfo($r('app.string.resetSucceeded'));
  }

  /**
   * Check whether the AModulelib package has been loaded.
   *
   * @param successCallBack Callback.
   */
  private initAModulelib(successCallBack: Callback<void>): void {
    try {
      const result: moduleInstallManager.InstalledModule = moduleInstallManager.getInstalledModule('AModulelib');
      if (result?.installStatus === moduleInstallManager.InstallStatus.INSTALLED) {
        hilog.info(0, 'InstantDownload', 'AModulelib installed');
        successCallBack && successCallBack();
      } else {
        // AModulelib has not been installed. Call fetchModules to download AModulelib.
        hilog.info(0, 'InstantDownload', 'AModulelib not installed');
        this.fetchModule('AModulelib', successCallBack)
      }
    } catch (error) {
      hilog.error(0, 'InstantDownload', `initAModulelib error.code is ${error.code}, message is ${error.message}`);
    }
  }

  /**
   * Load the specified package.
   *
   * @param moduleName Name of the installation package to be loaded.
   * @param successCallBack Callback.
   */
  private fetchModule(moduleName: string, successCallBack: Callback<void>) {
    try {
      hilog.info(0, 'InstantDownload', 'fetchModule start');
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      const moduleInstallProvider: moduleInstallManager.ModuleInstallProvider =
        new moduleInstallManager.ModuleInstallProvider();
      const moduleInstallRequest: moduleInstallManager.ModuleInstallRequest =
        moduleInstallProvider.createModuleInstallRequest(context);
      if (!moduleInstallRequest) {
        hilog.error(0, 'InstantDownload', 'moduleInstallRequest is empty');
        return;
      }
      moduleInstallRequest.addModule(moduleName);
      moduleInstallManager.fetchModules(moduleInstallRequest)
        .then((data: moduleInstallManager.ModuleInstallSessionState) => {
          hilog.info(0, 'InstantDownload', 'fetchModule result:' + JSON.stringify(data));
          if (data?.taskStatus !== undefined &&
            data?.code === moduleInstallManager.RequestErrorCode.SUCCESS) {
            successCallBack && successCallBack();
          } else {
            hilog.info(0, 'InstantDownload', 'fetchModule failure');
          }
        })
        .catch((error: BusinessError) => {
          hilog.error(0, 'InstantDownload', `fetchModule error.code is ${error.code}, message is ${error.message}`);
        })
    } catch (error) {
      hilog.error(0, 'InstantDownload', `fetchModule error.code is ${error.code}, message is ${error.message}`);
    }
  }

  @Builder
  TitleTemp(title: string | Resource) {
    Text(title)
      .width('100%')
      .height(48)
      .lineHeight(48)
      .fontSize(16)
      .fontWeight(FontWeight.Medium)
      .margin({ bottom: 6 })
  }

  build() {
    Column() {
      Scroll(this.scroller) {
        Column() {
          Column() {
            this.TitleTemp($r('app.string.introduction'))
            Text($r('app.string.ModuleInstallIntroduction', this.bundleName))
              .width('100%')
              .fontSize(14)
              .fontColor($r('sys.color.ohos_id_color_text_hint'))
            Divider().strokeWidth(1).margin({ bottom: 0, top: 10 })
          }

          Column() {
            Column() {
              this.TitleTemp($r('app.string.moduleInformation'))
              Text($r('app.string.resultMsg', this.allInstalledModules))
                .fontSize(14)
                .fontColor($r('sys.color.ohos_id_color_text_hint'))
                .width('100%')
            }.margin({ bottom: 20 })

            ForEach(this.moduleList, (item: moduleListItem, index: number) => {
              Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
                Radio({ value: item.name, group: 'radioGroup' })
                  .checked(this.radioCheckIndex === index)
                  .onChange((isChecked: boolean) => {
                    if (isChecked) {
                      this.radioCheckIndex = index;
                    }
                  })
                Text(item.des).fontSize(14).lineHeight(20).fontColor('#182431').fontWeight(500)
              }
            })

            Button($r('app.string.QueryModule', this.moduleList[this.radioCheckIndex].name))
              .height(34)
              .fontSize(14)
              .margin({ top: 10 })
              .onClick(() => {
                this.getModuleInstanceInfo();
              })
            Divider().strokeWidth(1).margin({ bottom: 20, top: 20 })
          }
          .width('100%')


          Column() {
            Column() {
              this.TitleTemp($r('app.string.fetchModules'))
              Text($r('app.string.resultMsg', this.replyMsg))
                .width('100%')
                .fontSize(14)
                .fontColor($r('sys.color.ohos_id_color_text_hint'))
            }.width('100%').margin({ top: 10 })

            Column() {
              Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
                CheckboxGroup({ group: 'checkboxGroup' })
                  .selectedColor('#007DFF')
                  .onChange((itemName: CheckboxGroupResult) => {
                    this.selectModules = itemName?.name || [];
                  })
                Text($r('app.string.selectModules'))
                  .fontSize(14)
                  .lineHeight(20)
                  .fontColor('#182431')
                  .fontWeight(500)
              }

              ForEach(this.moduleList, (item: moduleListItem, index: number) => {
                Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
                  Checkbox({ name: item.name, group: 'checkboxGroup' })
                    .selectedColor('#007DFF')
                  Text(item.des).fontSize(14).lineHeight(20).fontColor('#182431').fontWeight(500)
                }.margin({ left: 36 })
              })
            }
            .width('100%')

            Column() {
              Button() {
                Row() {
                  Text($r('app.string.fetchModuleButton', this.selectModules.join(',')))
                    .fontSize(14)
                    .fontColor(0xffffff)
                    .minFontSize('6sp')
                  LoadingProgress()
                    .width(20)
                    .height(20)
                    .margin({ left: 12 })
                    .color(0xFFFFFF)
                    .visibility(this.addLoading ? Visibility.Visible : Visibility.None)
                }.alignItems(VerticalAlign.Center)
              }
              .height(34)
              .enabled(!this.addLoading)
              .backgroundColor(0x317aff)
              .padding({ left: 15, right: 15 })
              .margin({ top: 10 })
              .onClick(() => {
                this.msg = '';
                if (this.selectModules.length) {
                  this.handleFetchModules();
                } else {
                  this.showToastInfo($r('app.string.moduleEmpty'));
                }
              })
            }

            Divider().strokeWidth(1).margin({ bottom: 0, top: 20 })
          }

          Column() {
            Column() {
              this.TitleTemp($r('app.string.registerListen'))
              Text($r('app.string.resultMsg', this.onListeningResult))
                .width('100%')
                .fontSize(14)
                .fontColor($r('sys.color.ohos_id_color_text_hint')).margin({ bottom: 15 })
              Progress({ value: 0, total: this.progressTotalValue, type: ProgressType.Ring })
                .width(100).height(100).value(this.progressValue)
                .style({ strokeWidth: 15 }) // Set the stroke width to 15.0 vp.
            }
            .margin({ bottom: 20 })

            Button($r('app.string.startListen'))
              .height(34)
              .fontSize(14)
              .onClick(() => {
                this.onListening();
              })
            Divider().strokeWidth(1).margin({ bottom: 0, top: 20 })
          }

          Column() {
            Column() {
              this.TitleTemp($r('app.string.cancelRegisterListen'))
              Text($r('app.string.resultMsg', this.offListeningResult))
                .width('100%')
                .fontSize(14)
                .fontColor($r('sys.color.ohos_id_color_text_hint'))
            }.margin({ bottom: 20 })

            Button($r('app.string.cancelListen'))
              .height(34)
              .fontSize(14)
              .onClick(() => {
                this.offListening();
              })
            Divider().strokeWidth(1).margin({ bottom: 0, top: 20 })
          }

          Column() {
            Column() {
              this.TitleTemp($r('app.string.DisplayDialogReminder'))
              Text($r('app.string.resultMsg', this.showReplyMsg))
                .width('100%')
                .fontSize(14)
                .fontColor($r('sys.color.ohos_id_color_text_hint'))
            }.margin({ bottom: 20 })

            Button($r('app.string.dialogReminder'))
              .height(34)
              .enabled(!!(this.curTaskId && (this.curTaskStatus === 0)))
              .fontSize(14)
              .onClick(() => {
                this.handleShowCellularDataConfirmation();
              })
            Divider().strokeWidth(1).margin({ bottom: 0, top: 20 })
          }

          Column() {
            Column() {
              this.TitleTemp($r('app.string.cancelDownloadTask'))
              Text($r('app.string.resultMsg', this.cancelReplyMsg))
                .width('100%')
                .fontSize(14)
                .fontColor($r('sys.color.ohos_id_color_text_hint'))
            }.margin({ bottom: 20 })

            Button($r('app.string.cancelTaskId', this.curTaskId))
              .enabled(!!this.curTaskId)
              .height(34)
              .fontSize(14)
              .onClick(() => {
                this.cancelTask();
              })
            Divider().strokeWidth(1).margin({ bottom: 0, top: 20 })
          }

          Column() {
            Button($r('app.string.invokeButton', this.countTotal || ''))
              .onClick(() => {
                this.initAModulelib(() => {
                  // In the project path, run the command on the console:ohpm install
                  import('amodulelib').then((ns: ESObject) => {
                    this.countTotal = ns.add(3, 6);
                  }).catch((error: BusinessError) => {
                    hilog.error(0, 'InstantDownload',`add error.code is ${error.code}, message is ${error.message}`);
                  })
                })
              }).margin({
              top: 20, bottom: 20
            });

            Button($r('app.string.invokeToast'))
              .onClick(() => {
                this.initAModulelib(() => {
                  // In the project path, run the command on the console:ohpm install
                  import('amodulelib').then((ns: ESObject) => {
                    this.AModulelibComponent = ns.showDateComponent;
                    this.isShow = true;
                  }).catch((error: BusinessError) => {
                    hilog.error(0, 'InstantDownload', `showDateComponent error.code is ${error.code}, message is ${error.message}`);
                  })
                })
              }).margin({
              top: 20, bottom: 20
            });
            if (this.isShow) {
              this.AModulelibComponent()
            }
            Divider().strokeWidth(1).margin({ bottom: 0, top: 20 })
          }

          Column() {
            Button($r('app.string.reset'))
              .height(34)
              .fontSize(14)
              .onClick(() => {
                this.getUIContext().showAlertDialog({
                  title: $r('app.string.information'),
                  message: $r('app.string.message'),
                  autoCancel: true,
                  alignment: DialogAlignment.Bottom,
                  buttonDirection: DialogButtonDirection.HORIZONTAL,
                  buttons: [
                    {
                      value: $r('app.string.confirm'),
                      action: () => {
                        this.reset();
                      }
                    }],
                  cancel: () => {
                    console.info('Closed callbacks')
                  }
                })
              })
          }
          .margin({ top: 20 })
        }
      }
      .scrollBar(BarState.Off) // The scrollbar is always displayed.
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}