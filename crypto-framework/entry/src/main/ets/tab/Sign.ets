/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

import Logger from '../util/Logger';
import { picker } from '@kit.CoreFileKit';
import { CryptoOperation } from '../cryptoframework/CryptoOperation';
import TextFileManager from '../textfilemanager/TextFileManager';

const TAG: string = '[Crypto_Framework]';

@Component
export struct Sign {
  @State keyFileName: string = '';
  @State keyFileUri: string = '';
  @State textFileUri: string = '';
  @State textFileName: string = '';
  @State keyString: string = '';
  @State cipherText: string = '';
  @State plainText: string = '';
  @State message: string = '';
  @State signFileUri: string = '';
  @State createKeyUri: string = '';
  private CryptoOperation: CryptoOperation = new CryptoOperation();

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column() {
        GridRow() {
          GridCol({ span: { xs: 12, sm: 12, md: 12, lg: 12 } }) {
            Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
              List() {
                ListItem() {
                  Row() {
                    Text($r('app.string.open_file'))
                      .fontSize(16)
                      .textAlign(TextAlign.Start)
                      .lineHeight(22)

                    Blank()

                    Text(this.textFileName === '' ? $r('app.string.please_choose') : this.textFileName)
                      .fontSize(14)
                      .textAlign(TextAlign.Start)
                      .lineHeight(19)

                    Image($r('app.media.right_arrow'))
                      .height('19vp')
                      .width('10vp')
                      .margin({ left: 9, right: 9, top: 6, bottom: 6 })
                  }
                  .backgroundColor(0xFFFFFF)
                  .width('100%')
                  .height('52vp')
                  .padding({ top: 4, left: 12, right: 12 })
                }.onClick(() => {
                  this.selectTextFileAndRead();
                })

                ListItem() {
                  Row() {
                    Text($r('app.string.select_key_file'))
                      .fontSize(16)
                      .textAlign(TextAlign.Start)
                      .lineHeight(22)

                    Blank()

                    Text(this.keyFileName === '' ? $r('app.string.please_choose') : this.keyFileName)
                      .fontSize(14)
                      .textAlign(TextAlign.Start)
                      .lineHeight(19)

                    Image($r('app.media.right_arrow'))
                      .height('19vp')
                      .width('10vp')
                      .margin({ left: 9, right: 9, top: 6, bottom: 6 })
                  }
                  .backgroundColor(0xFFFFFF)
                  .width('100%')
                  .height('48vp')
                  .padding({ left: 12, right: 12 })
                }.onClick(() => {
                  this.selectRsaKeyFileAndRead();
                })
              }
              .width('100%')
              .height('100%')
              .borderRadius(16)
            }
          }
        }
        .height('100vp')
        .margin({ left: 12, right: 12, bottom: 12 })

        GridRow() {
          GridCol({ span: { xs: 12, sm: 12, md: 12, lg: 12 } }) {
            Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
              Column() {
                Row() {
                  Text($r('app.string.text_context'))
                    .fontSize(16)
                    .textAlign(TextAlign.Start)
                    .fontWeight(500)
                    .lineHeight(22)
                }
                .padding({ left: 12, right: 12 })
                .width('100%')
                .height('48vp')

                Row() {
                  Text() {
                    Span(this.plainText)
                      .fontSize(16)
                      .fontWeight(400)
                      .fontColor('#182431')
                  }.textAlign(TextAlign.Start)
                }
                .padding({ left: 12, right: 12, bottom: 4 })
                .width('100%')
                .height('52vp')
              }
              .borderRadius(16)
              .width('100%')
              .height('100')
              .backgroundColor(0xFFFFFF)
            }
          }
        }
        .height('100vp')
        .margin({ left: 12, right: 12, bottom: 12 })

        Column() {
          GridRow() {
            GridCol({ span: { xs: 12, sm: 12, md: 12, lg: 12 } }) {
              Column() {
                Button() {
                  Text($r('app.string.generate_rsa_key_randomly')).fontSize(16).fontWeight(500)
                    .lineHeight(22)
                    .fontColor('#FFFFFF')
                }
                .id('encryptRsaGenKey')
                .borderRadius(20)
                .type(ButtonType.Capsule)
                .width('100%')
                .height('40vp')
                .margin({ bottom: 16 })
                .backgroundColor('#007DFF')
                .onClick(() => {
                  this.genRsaKey();
                });

                Button() {
                  Text($r('app.string.sign')).fontSize(16).fontWeight(500)
                    .lineHeight(22)
                    .fontColor('#FFFFFF')
                }
                .borderRadius(20)
                .id('signBtn')
                .type(ButtonType.Capsule)
                .margin({ left: 24, right: 24 })
                .width('100%')
                .height('40vp')
                .backgroundColor('#007DFF')
                .onClick(() => {
                  if (this.textFileUri === '' || this.keyFileUri === '') {
                    try {
                      this.getUIContext().getPromptAction().showToast({
                        message: $r('app.string.null_message')
                      });
                    } catch (err) {
                      console.error(`Show toast failed, code is ${err}, message is ${err.message}`);
                    }
                  } else {
                    this.signFunc();
                  }
                });
              }
            }
          }.margin({ left: 24, right: 24 })
        }.width('100%').height('412vp').justifyContent(FlexAlign.End)
      }
      .width('100%')
      .height('100%')
    }
  }

  async selectRsaKeyFileAndRead() {
    let documentSelectOptions = new picker.DocumentSelectOptions();
    documentSelectOptions.fileSuffixFilters = ['.txt'];
    documentSelectOptions.maxSelectNumber = 1;
    let uri: string = '';
    let documentViewPicker = new picker.DocumentViewPicker();
    await documentViewPicker.select(documentSelectOptions).then((documentSelectResult: Array<string>) => {
      uri = documentSelectResult[0];
      console.info('documentViewPicker.select to text file succeed and uris are:' + uri);
    }).catch((err: Error) => {
      console.error(`Invoke documentViewPicker.select failed, code is ${err}, message is ${err.message}`);
    })
    this.keyFileUri = uri;
    // Get the file name of the key document file.
    await TextFileManager.readTextFile(this.keyFileUri);
    this.keyFileName = TextFileManager.getName();
    this.keyString = TextFileManager.getString();
  }

  async selectTextFileAndRead() {
    let documentSelectOptions = new picker.DocumentSelectOptions();
    documentSelectOptions.fileSuffixFilters = ['.txt'];
    documentSelectOptions.maxSelectNumber = 1;
    let uri: string = '';
    let documentViewPicker = new picker.DocumentViewPicker();
    await documentViewPicker.select(documentSelectOptions).then((documentSelectResult: Array<string>) => {
      uri = documentSelectResult[0];
      console.info('documentViewPicker.select to text file succeed and uris are:' + uri);
    }).catch((err: Error) => {
      console.error(`Invoke documentViewPicker.select failed, code is ${err}, message is ${err.message}`);
    })
    // Gets the URI of the document file.
    this.textFileUri = uri;
    // Get the file name of the document file.
    await TextFileManager.readTextFile(this.textFileUri);
    this.textFileName = TextFileManager.getName();
    this.plainText = TextFileManager.getString();
  }

  async createTextFileAndWrite() {
    let documentSaveOptions = new picker.DocumentSaveOptions();
    documentSaveOptions.newFileNames = ['signText.txt'];
    let documentPicker = new picker.DocumentViewPicker();
    let documentSaveResult = await documentPicker.save(documentSaveOptions);
    this.signFileUri = documentSaveResult[0];
    await TextFileManager.writeTextFile(this.signFileUri, this.cipherText);
  }

  async createKeyFileAndWrite() {
    let documentSaveOptions = new picker.DocumentSaveOptions();
    documentSaveOptions.newFileNames = ['rsaKey.txt'];
    let documentPicker = new picker.DocumentViewPicker();
    try {
      let documentSaveResult = await documentPicker.save(documentSaveOptions);
      this.createKeyUri = documentSaveResult[0];
      await TextFileManager.writeTextFile(this.createKeyUri, this.keyString);
    } catch (error) {
      Logger.error(TAG, `save key failed, ${error}`);
    }

  }

  async signFunc() {
    if (this.plainText === '' || this.keyFileUri === '') {
      try {
        this.getUIContext().getPromptAction().showToast({
          message: $r('app.string.null_message')
        });
      } catch (err) {
        console.error(`Show toast failed, code is ${err}, message is ${err.message}`);
      }
      return;
    }
    try {
      this.cipherText = await this.CryptoOperation.rsaConvertAndSign(this.keyString, this.plainText);
    } catch (error) {
      Logger.error(TAG, `sign failed, ${error}`);
      try {
        this.getUIContext().getPromptAction().showToast({
          message: $r('app.string.sign_fail')
        });
      } catch (err) {
        console.error(`Show toast failed, code is ${err}, message is ${err.message}`);
      }
    }
    if (this.cipherText === '' || this.cipherText === null || this.cipherText === undefined) {
      try {
        this.getUIContext().getPromptAction().showToast({
          message: $r('app.string.sign_fail')
        });
      } catch (err) {
        console.error(`Show toast failed, code is ${err}, message is ${err.message}`);
      }
      return;
    } else {
      await this.createTextFileAndWrite();
    }
    if (this.signFileUri === '' || typeof (this.signFileUri) === 'undefined') {
      try {
        this.getUIContext().getPromptAction().showToast({
          message: $r('app.string.sign_fail')
        });
      } catch (err) {
        console.error(`Show toast failed, code is ${err}, message is ${err.message}`);
      }
    } else {
      try {
        this.getUIContext().getPromptAction().showToast({
          message: $r('app.string.sign_success')
        });
      } catch (err) {
        console.error(`Show toast failed, code is ${err}, message is ${err.message}`);
      }
    }
  }

  async genRsaKey() {
    try {
      this.getUIContext().getPromptAction().showToast({
        message: $r('app.string.slow_rsa_key_gen')
      });
      this.keyString = await this.CryptoOperation.generateRsaKey();
    } catch (error) {
      Logger.error(TAG, `gen rsa key failed, ${error}`);
    }
    if (this.keyString === '' || typeof (this.keyString) === 'undefined') {
      try {
        this.getUIContext().getPromptAction().showToast({
          message: $r('app.string.gen_key_fail')
        });
      } catch (err) {
        console.error(`Show toast failed, code is ${err}, message is ${err.message}`);
      }
      return;
    } else {
      try {
        await this.createKeyFileAndWrite();
      } catch (error) {
        Logger.error(TAG, `write rsa key failed, ${error}`);
      }
    }
    if (this.createKeyUri === '' || typeof (this.createKeyUri) === 'undefined') {
      try {
        this.getUIContext().getPromptAction().showToast({
          message: $r('app.string.gen_key_fail')
        });
      } catch (err) {
        console.error(`Show toast failed, code is ${err}, message is ${err.message}`);
      }
    } else {
      try {
        this.getUIContext().getPromptAction().showToast({
          message: $r('app.string.gen_key_success')
        });
      } catch (err) {
        console.error(`Show toast failed, code is ${err}, message is ${err.message}`);
      }
    }
  }
}
