import { moduleInstallManager } from '@kit.StoreKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { promptAction } from '@kit.ArkUI';
import type { common } from '@kit.AbilityKit';
import { BusinessError, Callback } from '@kit.BasicServicesKit';


interface moduleListItem {
  name: string;
  des: string;
}

@Entry
@Component
export struct LoadInstallService {
  private bundleName: string = 'com.example.store.kit.demo';
  @State selectModules: Array<string> = [];
  @State replyMsg: string = '';
  @State showReplyMsg: string = '';
  @State cancelReplyMsg: string = '';
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
      des: 'Common HAP'
    },
    {
      name: 'AModulelib',
      des: 'Incremental module A (greater than 10 MB)'
    },
    {
      name: 'BModulelib',
      des: 'Incremental module B'
    },
    {
      name: 'XModulelib',
      des: 'Incremental module X (a fake one that does not really exist)'
    },
    {
      name: 'commonLibrary',
      des: 'Basic common library package (installed)'
    }];
  scroller: Scroller = new Scroller();

  private showToastInfo(msg: string) {
    promptAction.showToast({
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
        `The ${name} module has been installed.` : 'The ${name} module has not been installed.');
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
      const context = getContext(this) as common.UIAbilityContext;
      const moduleInstallProvider: moduleInstallManager.ModuleInstallProvider =
        new moduleInstallManager.ModuleInstallProvider();
      const moduleInstallRequest: moduleInstallManager.ModuleInstallRequest =
        moduleInstallProvider.createModuleInstallRequest(context);
      if (!moduleInstallRequest) {
        hilog.error(0, 'InstantDownload', 'moduleInstallRequest is empty');
        this.showToastInfo('An exception occurred during the instance loading request.');
        this.addLoading = false;
        return;
      }
      this.selectModules.forEach(item => {
        const rtnCode: number = moduleInstallRequest.addModule(item);
        this.msg += `${item} add ${rtnCode === moduleInstallManager.ReturnCode.SUCCESS ? 'success' : 'fail'} `
      })

      moduleInstallManager.fetchModules(moduleInstallRequest)
        .then((data: moduleInstallManager.ModuleInstallSessionState) => {
          this.showToastInfo(`Result of the loading reuqest: ${data?.code === moduleInstallManager.RequestErrorCode.SUCCESS ?
            'successful' : 'failed'}}`);
          this.curTaskId = data?.taskId || '';
          hilog.info(0, 'InstantDownload', 'fetchModules success data=' + JSON.stringify(data));
          this.replyMsg = JSON.stringify(data);
          if (data?.taskStatus !== undefined &&
            data?.code === moduleInstallManager.RequestErrorCode.SUCCESS) {
            this.curTaskStatus =
              data?.taskStatus === moduleInstallManager.TaskStatus.DOWNLOAD_WAIT_WIFI ? 0 : -1;
          } else {
            this.curTaskStatus = -1;
          }
          this.addLoading = false;
        })
        .catch((error: BusinessError) => {
          this.showToastInfo(`Loading request failed.`);
          hilog.error(0, 'InstantDownload', `fetchModules error.code is ${error.code}, message is ${error.message}`);
          this.addLoading = false;
        })
    } catch (error) {
      this.showToastInfo(`An exception occurred during the loading request.`);
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
        this.showToastInfo('The task ID does not exist.');
        return;
      }
      const result: moduleInstallManager.ReturnCode = moduleInstallManager.cancelTask(this.curTaskId);
      this.cancelReplyMsg = result === moduleInstallManager.ReturnCode.SUCCESS ? 'successful' : 'failed';
      this.showToastInfo(`Result of canceling the download task: ${this.cancelReplyMsg}`);
    } catch (error) {
      hilog.error(0, 'InstantDownload', `cancelTask error.code is ${error.code}, message is ${error.message}`);
      this.showToastInfo(`An exception occurred during the cancellation of the download task.`);
    }
  }

  /**
   * 4. Display a mobile data reminder.
   */
  private handleShowCellularDataConfirmation() {
    try {
      if (!this.curTaskId) {
        this.showToastInfo('The task ID does not exist.');
        return;
      }
      const context = getContext(this) as common.UIAbilityContext;
      const result: moduleInstallManager.ReturnCode = moduleInstallManager.showCellularDataConfirmation(context,
        this.curTaskId);
      this.showReplyMsg = result === moduleInstallManager.ReturnCode.SUCCESS ? 'successful' : 'failed';
      this.showToastInfo(`Result of displaying a mobile data reminder: ${this.showReplyMsg}`);
    } catch (error) {
      this.showToastInfo(`An exception occurred during the display of a mobile data reminder.`);
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
        this.showToastInfo(`Result of registering a progress listener: ${data?.code === moduleInstallManager.RequestErrorCode.SUCCESS ?
          'successful' : 'failed'}`);
      }, 30 * 60)
    } catch (error) {
      this.showToastInfo(`An exception occurred during the registration of a progress listener.`);
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
        this.showToastInfo(`Result of canceling the progress listener: ${data?.code === moduleInstallManager.RequestErrorCode.SUCCESS ?
          'successful' : 'failed'}`);
      })
    } catch (error) {
      this.showToastInfo(`An exception occurred during the cancellation of a progress listener.`);
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
    this.showToastInfo(`重置成功`);
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
      const context = getContext(this) as common.UIAbilityContext;
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
  TitleTemp(title: string) {
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
            this.TitleTemp('Introduction')
            Text(`This app (name: incrementally installed module; package name: ${this.bundleName})contains five modules, including two HAP modules: entry and commonHap, and three HSP modules: AModulelib, BModulelib, and commonLibrary. Additionally, a fake module XModulelib is constructed.`)
              .width('100%')
              .fontSize(14)
              .fontColor($r('sys.color.ohos_id_color_text_hint'))
            Divider().strokeWidth(1).margin({ bottom: 0, top: 10 })
          }

          Column() {
            Column() {
              this.TitleTemp('Information about currently installed modules')
              Text(`Installation result: ${this.allInstalledModules}`)
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

            Button(`Query installation information of module ${this.moduleList[this.radioCheckIndex].name}`)
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
              this.TitleTemp('Request module loading')
              Text(`结果：${this.replyMsg}`)
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
                Text('Select all incremental modules')
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
                  Text(`Request to load module ${this.selectModules.join(',')}`)
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
                  this.showToastInfo('The incremental module to be installed cannot be empty.');
                }
              })
            }

            Divider().strokeWidth(1).margin({ bottom: 0, top: 20 })
          }

          Column() {
            Column() {
              this.TitleTemp('Register a progress listener')
              Text(`Result: ${this.onListeningResult}`)
                .width('100%')
                .fontSize(14)
                .fontColor($r('sys.color.ohos_id_color_text_hint')).margin({ bottom: 15 })
              Progress({ value: 0, total: this.progressTotalValue, type: ProgressType.Ring })
                .width(100).height(100).value(this.progressValue)
                .style({ strokeWidth: 15 }) // Set the stroke width to 15.0 vp.
            }
            .margin({ bottom: 20 })

            Button(`Register progress listener`)
              .height(34)
              .fontSize(14)
              .onClick(() => {
                this.onListening();
              })
            Divider().strokeWidth(1).margin({ bottom: 0, top: 20 })
          }

          Column() {
            Column() {
              this.TitleTemp('Cancel a progress listener')
              Text(`结果：${this.offListeningResult}`)
                .width('100%')
                .fontSize(14)
                .fontColor($r('sys.color.ohos_id_color_text_hint'))
            }.margin({ bottom: 20 })

            Button(`Cancel progress listener`)
              .height(34)
              .fontSize(14)
              .onClick(() => {
                this.offListening();
              })
            Divider().strokeWidth(1).margin({ bottom: 0, top: 20 })
          }

          Column() {
            Column() {
              this.TitleTemp('Display a mobile data reminder')
              Text(`Result: ${this.showReplyMsg}`)
                .width('100%')
                .fontSize(14)
                .fontColor($r('sys.color.ohos_id_color_text_hint'))
            }.margin({ bottom: 20 })

            Button(`Display mobile data reminder`)
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
              this.TitleTemp('Cancel a download task')
              Text(`Result: ${this.cancelReplyMsg}`)
                .width('100%')
                .fontSize(14)
                .fontColor($r('sys.color.ohos_id_color_text_hint'))
            }.margin({ bottom: 20 })

            Button(`Cancel download task (taskId=${this.curTaskId})`)
              .enabled(!!this.curTaskId)
              .height(34)
              .fontSize(14)
              .onClick(() => {
                this.cancelTask();
              })
            Divider().strokeWidth(1).margin({ bottom: 0, top: 20 })
          }

          Column() {
            Button(`Call the add function in the incremental module: 3+6=${this.countTotal || ''}`)
              .onClick(() => {
                this.initAModulelib(() => {
                  import('AModulelib').then((ns: ESObject) => {
                    this.countTotal = ns.add(3, 6);
                  }).catch((error: BusinessError) => {
                    hilog.error(0, 'InstantDownload',`add error.code is ${error.code}, message is ${error.message}`);
                  })
                })
              }).margin({
              top: 20, bottom: 20
            });

            Button(`Call showDateComponent in the incremental module`)
              .onClick(() => {
                this.initAModulelib(() => {
                  import('AModulelib').then((ns: ESObject) => {
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
            Button(`Reset`)
              .height(34)
              .fontSize(14)
              .onClick(() => {
                AlertDialog.show({
                  title: 'Information',
                  message: 'Are you sure you want to reset the information? ',
                  autoCancel: true,
                  alignment: DialogAlignment.Bottom,
                  buttonDirection: DialogButtonDirection.HORIZONTAL,
                  buttons: [
                    {
                      value: 'OK',
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