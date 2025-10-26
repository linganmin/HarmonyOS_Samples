/*
 * Copyright (c) 2024-2025 Huawei Device Co., Ltd.
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
import { BusinessError } from '@kit.BasicServicesKit'

@Entry
@Component
struct MainPage {
  build() {
    Flex({ direction: FlexDirection.Column }) {
      Text('RCP')
        .fontSize(36)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.black'))
        .height(48)
        .width('80%')
        .margin({ top: '7.2%', left: '5%' })
      List() {
        this.ItemView('BaseAddress', this.getBaseAddress)
        this.ItemView('TimeOut', this.getTimeout)
        this.ItemView('TransferRange', this.getTransferRange)
        this.ItemView('Interceptor', this.getInterceptor)
        this.ItemView('UploadFile', this.getUploadFile)
        this.ItemView('Certificate', this.getCertificate)
      }.width('100%')
      .height('100%')

    }
  }

  @Builder
  ItemView(text: string, onClick: () => void) {
    ListItem() {
      Column() {
        Button(text, { type: ButtonType.Normal })
          .width('90%')
          .margin(10)
          .padding(20)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .backgroundColor('#0A59F7')
          .borderRadius(24)
          .onClick(onClick)
      }
      .width('100%')
    }
  }

  private getTimeout = () => {
    this.getUIContext().getRouter().pushUrl({ url: 'pages/TimeOut' }).catch((err: BusinessError) => {
      console.error(`pushUrl error: ${JSON.stringify(err)}`);
    });
  }
  private getTransferRange = () => {
    this.getUIContext().getRouter().pushUrl({ url: 'pages/TransferRange' }).catch((err: BusinessError) => {
      console.error(`pushUrl error: ${JSON.stringify(err)}`);
    });
  }
  private getBaseAddress = () => {
    this.getUIContext().getRouter().pushUrl({ url: 'pages/BaseAddress' }).catch((err: BusinessError) => {
      console.error(`pushUrl error: ${JSON.stringify(err)}`);
    });
  }
  private getInterceptor = () => {
    this.getUIContext().getRouter().pushUrl({ url: 'pages/Interceptor' }).catch((err: BusinessError) => {
      console.error(`pushUrl error: ${JSON.stringify(err)}`);
    });
  }
  private getUploadFile = () => {
    this.getUIContext().getRouter().pushUrl({ url: 'pages/UploadFile' }).catch((err: BusinessError) => {
      console.error(`pushUrl error: ${JSON.stringify(err)}`);
    });
  }
  private getCertificate = () => {
    this.getUIContext().getRouter().pushUrl({ url: 'pages/Certificate' }).catch((err: BusinessError) => {
      console.error(`pushUrl error: ${JSON.stringify(err)}`);
    });
  }
}