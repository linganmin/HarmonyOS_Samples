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
import testNapi from 'libentry.so';
import { common } from '@kit.AbilityKit';
import { GoodItem } from '../model/GoodModel'
import { listBuilder } from './GoodsList'
import { FileConstants } from '../common/constant/FileConstants'

@Entry
@Component
struct Index {
  @Provide('goodList') goodList: GoodItem[] = [];
  @Provide('id') dialogIdValue: number = 0;
  @Provide('name') dialogNameValue: string = '';
  @Provide('price') dialogPriceValue: number = 0;
  @Provide('isHoverText') isHoverText: Array<boolean> = new Array<boolean>(100).fill(false);
  @State isShow: boolean = false;
  @State selectName: string = '';
  @State selectPrice: string = '';
  @Provide('selectIndex1') selectIndex1: boolean = false;
  @Provide('selectIndex2') selectIndex2: boolean = false;
  private selectedGoodName: string = '';
  private selectedGoodPrice: number = 0;
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  updateDataFromRDB() {
    let resultObjects = testNapi.searchRDB() as object[];
    this.goodList.length = 0;
    for (let i: number = 0; i < resultObjects.length; i++) {
      this.goodList.push(new GoodItem(resultObjects[i]['id'], resultObjects[i]['name'], resultObjects[i]['price']));
    }
    this.selectedGoodName = '';
    this.selectedGoodPrice = 0;
  }

  aboutToAppear(): void {
    let databaseDir = this.context.getApplicationContext().databaseDir;
    testNapi.initRDB(databaseDir);
    this.updateDataFromRDB();
  }

  @Builder
  sheetBuilder() {
    Column() {
      Row() {
        Text($r('app.string.goodname'))
          .width($r('app.float.goodname_width'))
          .height($r('app.float.goodname_height'))
          .fontSize($r('app.float.label3_font_size'))
          .fontWeight(FileConstants.FONT_WEIGHT_500)
          .lineHeight(FileConstants.LINE_HEIGHT_21)
          .margin({
            left: $r('app.float.margin_16'),
            right: $r('app.float.margin_35'),
            top: $r('app.float.margin_9_half'),
            bottom: $r('app.float.margin_9_half')
          })
        Select([{ value: $r('app.string.mate60') }, { value: $r('app.string.mate60pro') },
          { value: $r('app.string.mate40') }, { value: $r('app.string.mate40pro') }])
          .width($r('app.float.select_width1'))
          .height($r('app.float.select_height1'))
          .backgroundColor($r('app.color.whiteColor'))
          .margin({
            right: $r('app.float.margin_16'), top: $r('app.float.margin_8'),
            bottom: $r('app.float.margin_8')
          })
          .onSelect((index: number) => {
            this.dialogNameValue = FileConstants.GOOD_TYPE[index];
          })
      }
      .width($r('app.float.frame_width'))
      .height($r('app.float.row_height1'))
      .margin({ bottom: $r('app.float.margin_8') })

      Row() {
        Text($r('app.string.goodprice'))
          .width($r('app.float.text_width1'))
          .height($r('app.float.text_height1'))
          .fontSize($r('app.float.label3_font_size'))
          .textAlign(TextAlign.Start)
          .margin({ left: $r('app.float.margin_16'), right: $r('app.float.margin_12') })
        TextInput()
          .width($r('app.float.textinput_width'))
          .height($r('app.float.textinput_height2'))
          .enableKeyboardOnFocus(false)
          .type(InputType.Number)
          .onChange((value: string) => {
            this.dialogPriceValue = Number(value);
          })
      }
      .width($r('app.float.frame_width'))
      .height($r('app.float.row_height2'))

      Button($r('app.string.submit'))
        .onClick(() => {
          this.isShow = false;
          if (this.dialogNameValue != '' && this.dialogPriceValue != 0) {
            testNapi.addRDB(this.dialogNameValue, this.dialogPriceValue);
          }
          this.dialogNameValue = '';
          this.dialogPriceValue = 0;
          this.selectIndex1 = true;
          this.selectIndex2 = true;
          this.updateDataFromRDB();
        })
        .fontSize($r('app.float.form_font_size'))
        .fontWeight(FileConstants.FONT_WEIGHT_500)
        .width($r('app.float.button_width2'))
        .height($r('app.float.button_height'))
        .margin({ left: $r('app.float.margin_16'), top: $r('app.float.margin_16') })
        .padding({
          left: $r('app.float.padding_16'),
          right: $r('app.float.padding_16'),
          top: $r('app.float.padding_9'),
          bottom: $r('app.float.padding_9')
        })
    }
    .width($r('app.float.frame_width'))
    .height(FileConstants.FULL_PERCENT)
  }

  build() {
    Column() {
      Text($r('app.string.rdb'))
        .fontSize($r('app.float.label1_font_size'))
        .fontWeight(FileConstants.FONT_WEIGHT_700)
        .fontColor($r('app.color.backColor'))
        .lineHeight(FileConstants.LINE_HEIGHT_40)
        .textAlign(TextAlign.Start)
        .width(FileConstants.PERCENT_95)
        .backgroundColor($r('app.color.whiteColor'))
        .margin({ top: $r('app.float.margin_64') })
        .padding({
          left: $r('app.float.padding_12'),
          top: $r('app.float.padding_8'),
          bottom: $r('app.float.padding_8'),
          right: $r('app.float.padding_20')
        })
        .height($r('app.float.text_height2'))

      Column() {
        Text($r('app.string.capi'))
          .fontSize($r('app.float.label2_font_size'))
          .fontWeight(FileConstants.FONT_WEIGHT_700)
          .align(Alignment.Start)
          .width(FileConstants.PERCENT_87)
          .height($r('app.float.text_height3'))
          .padding({ top: $r('app.float.padding_18'), bottom: $r('app.float.padding_8') })
        Row() {
          Select([{ value: this.selectIndex1 ? $r('app.string.list_goodname') : $r('app.string.list_mate60') },
            { value: this.selectIndex1 ? $r('app.string.list_goodname') : $r('app.string.list_mate40') }])
            .font({ size: $r('app.float.select_font_size'), weight: FileConstants.FONT_WEIGHT_500 })
            .value($r('app.string.list_goodname'))
            .width(FileConstants.PERCENT_35)
            .height($r('app.float.select_height2'))
            .padding({
              left: FileConstants.PERCENT_9,
              top: $r('app.float.padding_9_half'),
              bottom: $r('app.float.padding_9_half'),
              right: $r('app.float.padding_8')
            })
            .margin({
              right: FileConstants.PERCENT_11, top: $r('app.float.margin_30'),
              bottom: $r('app.float.margin_12')
            })
            .backgroundColor(FileConstants.BUTTON_BACKGROUND_COLOR)
            .optionWidth($r('app.float.option1_width'))
            .onClick(() => {
              this.selectIndex1 = false;
            })
            .onSelect((index: number) => {
              this.selectedGoodName = index == 0 ? FileConstants.MATE60 : FileConstants.MATE40;
              let resultObjects = testNapi.searchFiltered(this.selectedGoodName, this.selectedGoodPrice) as object[];
              this.goodList.length = 0;
              for (let i: number = 0; i < resultObjects.length; i++) {
                this.goodList.push(new GoodItem(resultObjects[i]['id'], resultObjects[i]['name'],
                  resultObjects[i]['price']));
              }
            })
          Select([{ value: this.selectIndex2 ? $r('app.string.list_goodname') : $r('app.string.list_greater') },
            { value: this.selectIndex2 ? $r('app.string.list_goodname') : $r('app.string.list_lesser') }])
            .font({ size: $r('app.float.select_font_size'), weight: FileConstants.FONT_WEIGHT_500 })
            .value($r('app.string.sellprice'))
            .width(FileConstants.PERCENT_35)
            .height($r('app.float.select_height2'))
            .padding({
              left: FileConstants.PERCENT_9,
              top: $r('app.float.padding_9_half'),
              bottom: $r('app.float.padding_9_half'),
              right: $r('app.float.padding_8')
            })
            .margin({
              right: FileConstants.PERCENT_7, top: $r('app.float.margin_30'),
              bottom: $r('app.float.margin_12')
            })
            .backgroundColor(FileConstants.BUTTON_BACKGROUND_COLOR)
            .optionWidth($r('app.float.option2_width'))
            .onClick(() => {
              this.selectIndex2 = false;
            })
            .onSelect((index: number) => {
              this.selectedGoodPrice = index == 0 ? FileConstants.COMPARE_PRICE1 : FileConstants.COMPARE_PRICE2;
              let resultObjects = testNapi.searchFiltered(this.selectedGoodName, this.selectedGoodPrice) as object[]
              this.goodList.length = 0;
              for (let i: number = 0; i < resultObjects.length; i++) {
                this.goodList.push(new GoodItem(resultObjects[i]['id'], resultObjects[i]['name'],
                  resultObjects[i]['price']));
              }
            })
          Button() {
            Image($r('app.media.ic_public_rotate'))
              .width($r('app.float.image_width'))
              .height($r('app.float.image_width'))
          }
          .margin({ top: $r('app.float.margin_30'), bottom: $r('app.float.margin_12') })
          .height($r('app.float.button_height'))
          .width($r('app.float.button_width1'))
          .backgroundColor(FileConstants.BUTTON_BACKGROUND_COLOR)
          .onClick(() => {
            this.selectIndex1 = true;
            this.selectIndex2 = true;
            this.updateDataFromRDB();
          })
        }
        .height($r('app.float.row_height3'))
        .width(FileConstants.PERCENT_91)

        listBuilder()
      }
      .height($r('app.float.column_height'))
      .width(FileConstants.FULL_PERCENT)
      .backgroundColor($r('app.color.whiteColor'))

      Button($r('app.string.add'))
        .fontWeight(FileConstants.FONT_WEIGHT_500)
        .fontSize($r('app.float.form_font_size'))
        .width(FileConstants.PERCENT_87)
        .height($r('app.float.button_height'))
        .margin({ top: $r('app.float.margin_24'), bottom: $r('app.float.margin_16') })
        .padding({
          left: $r('app.float.padding_16'),
          right: $r('app.float.padding_16'),
          top: $r('app.float.padding_9'),
          bottom: $r('app.float.padding_9')
        })
        .bindSheet($$this.isShow, this.sheetBuilder(), {
          height: $r('app.float.bindsheet_height'),
          backgroundColor: $r('app.color.whiteColor'),
          title: { title: $r('app.string.addgoodinfo') },
          onDisappear: () => {
            this.isShow = false;
          }
        })
        .onClick(() => {
          this.isShow = true;
        })
    }
    .backgroundColor($r('app.color.whiteColor'))
    .height(FileConstants.FULL_PERCENT)
    .width(FileConstants.FULL_PERCENT)
  }
}
