/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { buffer, util } from '@kit.ArkTS';
import KVStore from '../common/utils/KVStore';
import { KVStoreType } from '../viewmodel/KVStoreType';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Extend(Text)
function tableStyle() {
  .maxLines(1)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
  .fontSize(14)
  .fontWeight(400)
  .fontColor('#e6000000')
  .lineHeight(20)
  .textAlign(TextAlign.Center)
}

@Extend(Text)
function tableHeaderStyle() {
  .fontSize(18)
  .fontWeight(700)
  .fontColor($r('sys.color.mask_secondary'))
  .height(37)
  .textAlign(TextAlign.Center)
}

@Component
export struct ReadWrite {
  @StorageLink('isInsetShow') isInsetShow: boolean = false;
  @StorageLink('isEditShow') isEditShow: boolean = false;
  @StorageLink('editData') editData: KVStoreType | undefined = undefined;
  @StorageLink('kvStoreAll') kvStoreAll: KVStoreType[] = [];
  @StorageLink('kvStore') kvStore: KVStore | undefined = undefined;
  @State text: string = 'number';
  @State index: number = 0;
  private inputKey: string = '';
  private inputValue: Uint8Array | string | number | boolean = '';
  UIContext = this.getUIContext();

  @Builder
  menuBuilder(kvStore: KVStoreType) {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
      Column() {
        Row() {
          SymbolGlyph($r('sys.symbol.square_and_pencil_fill'))
            .fontSize(24)
            .margin({ right: 8 })
          Text($r('app.string.edit'))
            .fontSize(16)
            .fontWeight(500)
            .lineHeight(21)
            .fontColor('#e6000000')
        }
        .width('100%')
        .height(30)
        .justifyContent(FlexAlign.Start)
        .align(Alignment.Center)
        .onClick(() => {
          this.isEditShow = true;
          this.editData = kvStore;
          if (kvStore.type === 'Uint8Array') {
            let uint8Array: Uint8Array = this.editData.value as Uint8Array;
            let textDecoderOptions: util.TextDecoderOptions = {
              fatal: false,
              ignoreBOM: true
            };
            let decodeToStringOptions: util.DecodeToStringOptions = {
              stream: false
            };
            let textDecoder = util.TextDecoder.create('utf-8', textDecoderOptions);
            let retStr = textDecoder.decodeToString(uint8Array, decodeToStringOptions);
            this.editData.value = retStr.slice(1, -1);
          }
          this.text = this.editData.type;
          switch (this.editData.type) {
            case 'number':
              this.index = 0;
              break;
            case 'string':
              this.index = 1;
              break;
            case 'boolean':
              this.index = 2;
              break;
            case 'Uint8Array':
              this.index = 3;
              break;
            default:
              break;
          }
        })

        Divider()
          .height(10)
          .width('100%')
          .color('#0d000000')

        Row() {
          SymbolGlyph($r('sys.symbol.trash_fill'))
            .fontSize(24)
            .margin({ right: 8 })
          Text($r('app.string.delete'))
            .fontSize(16)
            .fontWeight(500)
            .lineHeight(21)
            .fontColor('#e6000000')
        }
        .width('100%')
        .height(30)
        .justifyContent(FlexAlign.Start)
        .align(Alignment.Center)
        .onClick(async () => {
          this.kvStore?.delete(kvStore.key)
          setTimeout(async () => {
            await this.kvStore?.getAll().then((data: KVStoreType[]) => {
              this.kvStoreAll = data;
            });
          }, 200)
        })
      }
      .padding({
        top: 4,
        bottom: 4,
        left: 16,
        right: 16
      })
      .height(80)
    }
    .width(224)
  }

  @Builder
  insertBindSheet(editData?: KVStoreType | undefined) {
    Column() {
      Text(editData ? $r('app.string.edit_type') : $r('app.string.new_type'))
        .width('100%')
        .fontSize(16)
        .fontWeight(500)
        .lineHeight(37)
        .padding({
          left: 16,
          right: 16
        })

      Select([{ value: 'number' },
        { value: 'string' },
        { value: 'boolean' },
        { value: 'Uint8Array' }])
        .selected(this.index)
        .value(this.text)
        .font({
          size: 16,
          weight: 500
        })
        .fontColor($r('sys.color.font_primary'))
        .selectedOptionFont({
          size: 16,
          weight: 500
        })
        .optionFont({
          size: 16,
          weight: 500
        })
        .space(8)
        .width('100%')
        .arrowPosition(ArrowPosition.END)
        .menuAlign(MenuAlignType.START, { dx: 0, dy: 0 })
        .optionWidth(200)
        .optionHeight(300)
        .onSelect((index: number, text?: string) => {
          this.index = index;
          if (text) {
            this.text = text;
          }
        })

      Text($r('app.string.table_header_key'))
        .width('100%')
        .fontSize(16)
        .fontWeight(500)
        .lineHeight(37)
        .padding({
          left: 16,
          right: 16
        })
      TextInput({ placeholder: editData?.key })
        .width('100%')
        .enabled(editData ? false : true)
        .onChange((value) => {
          this.inputKey = value;
        })

      Text($r('app.string.table_header_value'))
        .width('100%')
        .fontSize(16)
        .fontWeight(500)
        .lineHeight(37)
        .padding({
          left: 16,
          right: 16
        })
      if (this.text === 'number') {
        TextInput({ placeholder: '', text: editData ? editData.value.toString() : '' })
          .type(InputType.Number)
          .width('100%')
          .onChange((value: string) => {
            this.inputValue = value;
          })
      } else if (this.text === 'boolean') {
        Column() {
          Row() {
            Radio({ value: 'true', group: 'radioGroup' })
              .checked(editData && editData.value === true ? true : false)
              .height(20)
              .width(20)
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.inputValue = true;
                }
              })
            Text('true')
              .fontSize(16)
              .margin({ right: 50 })
          }
          .width('100%')
          .padding({ left: 12 })
          .justifyContent(FlexAlign.Start)

          Row() {
            Radio({ value: 'false', group: 'radioGroup' })
              .checked(editData && editData.value === false ? true : false)
              .height(20)
              .width(20)
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.inputValue = false;
                }
              })
            Text('false')
              .fontSize(16)
          }
          .width('100%')
          .padding({ left: 12 })
          .justifyContent(FlexAlign.Start)
        }
        .width('100%')
      } else {
        TextInput({ placeholder: '', text: editData ? editData.value.toString() : '' })
          .width('100%')
          .onChange((value) => {
            this.inputValue = value;
          })
      }

      Button($r('app.string.submit'))
        .width('100%')
        .height(40)
        .margin({
          top: 16,
          bottom: 16
        })
        .fontSize(16)
        .backgroundColor('#0A59F7')
        .fontWeight(FontWeight.Medium)
        .onClick(async () => {
          let newArray: Uint8Array | undefined = undefined;
          if (this.text === 'number') {
            this.inputValue = Number(this.inputValue);
          } else if (this.text === 'Uint8Array') {
            newArray = new Uint8Array(buffer.from(JSON.stringify(this.inputValue), 'utf-8').buffer);
          }
          await this.kvStore?.put(editData ? editData.key : this.inputKey, newArray ? newArray : this.inputValue);
          setTimeout(async () => {
            await this.kvStore?.getAll().then((data) => {
              this.kvStoreAll = data;
            });
            this.isInsetShow = false;
            this.isEditShow = false;
            this.editData = undefined;
          }, 200);
        })
    }
    .height('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({
      left: 16,
      right: 16,
      bottom: 16
    })
    .borderRadius(10)
  }

  async aboutToAppear() {
    await this.kvStore?.getAll().then((data) => {
      this.kvStoreAll = data;
    });
  }

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Column() {
            Row() {
              Text($r('app.string.table_header_key'))
                .width(50)
                .tableHeaderStyle()
              Text($r('app.string.table_header_value'))
                .width(80)
                .tableHeaderStyle()
              Text($r('app.string.table_header_type'))
                .width(76)
                .tableHeaderStyle()
              Text($r('app.string.table_header_operate'))
                .width(40)
                .tableHeaderStyle()
            }
            .padding({ right: 11 })
            .width('100%')
            .height(44)
            .justifyContent(FlexAlign.SpaceBetween)

            Divider()
              .padding({
                left: 11,
                right: 11
              })
              .width('100%')
              .color('#0d000000')

            Column() {
              ForEach(this.kvStoreAll, (kvStore: KVStoreType) => {
                Row() {
                  Text(kvStore.key)
                    .width(50)
                    .tableStyle()
                  Text(kvStore.value.toString())
                    .width(80)
                    .tableStyle()
                  Text(kvStore.type)
                    .width(76)
                    .tableStyle()
                  SymbolGlyph($r('sys.symbol.dot_grid_1x2'))
                    .fontSize(20)
                    .fontColor(['#99000000'])
                    .bindMenu(this.menuBuilder(kvStore))
                    .width(40)
                    .height(20)
                }
                .margin({
                  top: 8,
                  bottom: 12
                })
                .width('100%')
                .height(20)
                .justifyContent(FlexAlign.SpaceBetween)
              }, (kvStore: KVStoreType) => JSON.stringify(kvStore))
            }
            .width('100%')
            .bindSheet(this.isEditShow, this.insertBindSheet(this.editData), {
              height: 440,
              title: { title: $r('app.string.edit_title') },
              onDisappear: async () => {
                if (this.text === 'Uint8Array') {
                  let newArray = new Uint8Array(buffer.from(JSON.stringify(this.inputValue), 'utf-8').buffer);
                  this.editData!.value = newArray;
                }
                this.isEditShow = false;
                this.editData = undefined;
              }
            })
          }
          .padding(12)
          .width('100%')
          .borderRadius(12)
          .backgroundColor(Color.White)
        }
        .borderRadius(12)
        .align(Alignment.TopStart)
        .scrollBar(BarState.Auto)
        .height('90%')

        Column() {
          Button($r('app.string.new'))
            .width('100%')
            .onClick(() => {
              this.isInsetShow = true;
              this.text = 'number';
              this.index = 0;
            })
            .bindSheet(this.isInsetShow, this.insertBindSheet(), {
              height: 440,
              title: { title: $r('app.string.new_title') },
              onDisappear: () => {
                this.isInsetShow = false;
              }
            })
        }
        .width('100%')
      }
      .padding(16)
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .height('100%')
    .title(this.getString($r('app.string.destination_title').id))
    .backgroundColor('#F1F3F5')
  }

  getString(id: number): string {
    try {
      return this.UIContext.getHostContext()?.resourceManager.getStringSync(id) ?? '';
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'ReadWrite', `getStringSync failed, error code=${err.code}, message=${err.code}`);
      return '';
    }
  }
}