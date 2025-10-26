/*
 * Copyright (c) 2022-2023 Huawei Device Co., Ltd.
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

import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import Http from '../model/http';

AppStorage.setOrCreate('receiveSize', 0);
AppStorage.setOrCreate('totalSize', 0);
AppStorage.setOrCreate('dataLength', 0);

@Entry
@Component
struct setting {
  @State url: string = '';
  @State option?: object = undefined;
  @State flag: number = 1;
  @State keys: string[] = [];
  @State list: number[] = [0];
  @State values: string[] = [];
  @State result: string = '';
  @State method: string = 'GET';
  @State showPage: boolean = false;
  @State resultInfo: string = '';
  @State methods: Array<string> = ['GET', 'HEAD', 'OPTIONS', 'TRACE', 'DELETE', 'POST', 'PUT', 'CONNECT'];
  getUri: string = '';
  getOption?: object;

  @Builder
  MenuBuilder() {
    Column() {
      ForEach(this.methods, (item: string) => {
        Text(item)
          .margin(5)
          .fontSize(16)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.method = item;
          })
        Divider()
          .height(1)
      }, (item: string) => item.toString())
    }
    .width('180vp')
  }

  aboutToAppear() {
    this.url = this.getUri;
    this.option = this.getOption;
    Http.setUrl(this.url);
    let context: Context = this.getUIContext().getHostContext()!;
    try {
      this.resultInfo = context.resourceManager.getStringSync($r('app.string.result').id);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'setting', `getStringSync failed, error code=${err.code}, message=${err.message}`);
    }
    setInterval(() => {
      if (Http.url !== '') {
        this.result = "\r\nThe length of the data received by this callback: " +
        JSON.stringify(AppStorage.get('dataLength') as number) + "\r\n" + "The length of the data received: " +
        JSON.stringify(AppStorage.get('receiveSize') as number) + "\r\n" + "Total length of data: " +
        JSON.stringify(AppStorage.get('totalSize') as number) + "\r\n" + "Percentage: " +
        JSON.stringify(Math.floor((AppStorage.get('receiveSize') as number) /
          (AppStorage.get('totalSize') as number) * 10000) / 100) + '%';
      } else {
        this.result = 'Failed';
      }
    }, 10)
  }

  build() {
    Scroll() {
      Column() {
        if (!this.showPage) {
          Text($r('app.string.configuration'))
            .margin('2%')
            .fontSize(28)

          Row() {
            Text(this.method)
              .width('20%')
              .fontSize(18)
              .textAlign(TextAlign.Center)
              .bindMenu(this.MenuBuilder)
              .margin({
                left: 2,
                right: 4
              })

            TextInput({ placeholder: $r('app.string.web') })
              .width('75%')
              .margin({
                left: 4,
                right: 2
              })
              .enableKeyboardOnFocus(false)
              .onChange((value: string) => {
                this.url = value;
              })
              .id('GET')
          }
          .width('95%')
          .height('10%')

          ForEach(this.list, (item: number, index: number) => {
            Row() {
              Text('Key: ')
                .width('20%')
                .fontSize(18)
                .margin({
                  left: 2,
                  right: 4
                })
                .textAlign(TextAlign.Center)
              TextInput({ placeholder: $r('app.string.key') })
                .width('76%')
                .margin({
                  left: 4,
                  right: 2
                })
                .onChange((value: string) => {
                  this.keys[this.flag - 1] = value;
                })
                .id(`key${index + 1}`)
            }
            .width('95%')
            .height('10%')

            Row() {
              Text('Value: ')
                .width('20%')
                .fontSize(18)
                .margin({
                  left: 2,
                  right: 4
                })
                .textAlign(TextAlign.Center)
              TextInput({ placeholder: $r('app.string.enter_value') })
                .width('75%')
                .margin({
                  left: 4,
                  right: 2
                })
                .onChange((value: string) => {
                  this.values[this.flag -1] = value;
                })
                .id(`value${index + 1}`)
            }
            .width('95%')
            .height('10%')
          }, (item: number) => item.toString())

          Column() {
            Button($r('app.string.add'))
              .margin(10)
              .fontSize(20)
              .width('60%')
              .onClick(() => {
                this.flag += 1;
                this.list = Http.setList(this.list, this.flag);
              })
              .id('add')

            Button($r('app.string.reduce'))
              .margin(10)
              .fontSize(20)
              .width('60%')
              .onClick(() => {
                if (this.flag !== 1) {
                  this.flag -= 1;
                }
                this.list = Http.setList(this.list, this.flag);
              })
              .id('reduce')

            Button($r('app.string.reset'))
              .id('reset')
              .margin(10)
              .fontSize(20)
              .width('60%')
              .onClick(() => {
                this.flag = 1;
                this.list = [0];
              })

            Button($r('app.string.confirm'))
              .margin(10)
              .fontSize(20)
              .width('60%')
              .onClick(async () => {
                Http.setUrl(this.url);
                Http.setMethod(this.method);
                Http.setExtraData(Http.setParameter(this.keys, this.values));
                try {
                  Http.request();
                } catch (err) {
                  this.result = 'Failed';
                }
                this.showPage = !this.showPage;
              })
              .id('submit')

            Button($r('app.string.back'))
              .id('back')
              .margin(10)
              .fontSize(20)
              .width('60%')
              .onClick(() => {
                this.getUIContext().getRouter().replaceUrl({
                  url: 'pages/Index',
                  params: {
                    url: this.url === '' ? Http.url : this.url,
                    option: Http.options
                  }
                })
              })
          }
          .margin({ top: '2%', bottom: '2%' })
          .width('100%')
        } else {
          Text(`${this.resultInfo} ${this.result}`)
            .id(`${this.result === '' || this.result === 'Failed' ? 'failed' : 'succeed'}`)
            .fontSize(20)
            .margin('5%')

          Button($r('app.string.back'))
            .fontSize(25)
            .onClick(() => {
              AppStorage.setOrCreate('receiveData', 0);
              AppStorage.setOrCreate('totalSize', 0);
              AppStorage.setOrCreate('dataLength', 0);
              this.url = '';
              this.flag = 1;
              this.keys = [];
              this.list = [0];
              this.values = [];
              this.result = '';
              this.method = 'GET';
              this.showPage = !this.showPage;
            })
            .id('show_back')
        }
      }
    }
    .width('100%')
    .height('100%')
  }
}

export { setting };