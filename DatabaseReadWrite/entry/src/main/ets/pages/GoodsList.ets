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
import { GoodItem } from '../model/GoodModel'
import { FileConstants } from '../common/constant/FileConstants'

@Component
export struct listBuilder {
  @Consume('goodList') goodList: GoodItem[];
  @Consume('id') dialogIdValue: number;
  @Consume('name') dialogNameValue: string;
  @Consume('price') dialogPriceValue: number;
  @Consume('isHoverText') isHoverText: boolean[];
  @Consume('selectIndex1') selectIndex1: boolean;
  @Consume('selectIndex2') selectIndex2: boolean;
  private scrollerForList: Scroller = new Scroller();

  updateDataFromRDB() {
    let resultObjects = testNapi.searchRDB() as object[];
    this.goodList.length = 0;
    for (let i: number = 0; i < resultObjects.length; i++) {
      this.goodList.push(new GoodItem(resultObjects[i]['id'], resultObjects[i]['name'], resultObjects[i]['price']));
    }
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
          .value(this.dialogNameValue)
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
          .fontWeight(FileConstants.FONT_WEIGHT_500)
          .width($r('app.float.text_width1'))
          .height($r('app.float.text_height1'))
          .fontSize($r('app.float.label3_font_size'))
          .textAlign(TextAlign.Start)
          .margin({ left: $r('app.float.margin_16'), right: $r('app.float.margin_12') })
        TextInput({ text: String(this.dialogPriceValue) })
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
        .onClick(() => {
          this.isHoverText.fill(false);
          if (this.dialogNameValue != '' && this.dialogPriceValue != 0) {
            testNapi.changeRDB(this.dialogIdValue, this.dialogNameValue, this.dialogPriceValue);
          }
          this.dialogNameValue = '';
          this.dialogPriceValue = 0;
          this.selectIndex1 = true;
          this.selectIndex2 = true;
          this.updateDataFromRDB();
        })
    }
    .width($r('app.float.frame_width'))
    .height(FileConstants.FULL_PERCENT)
  }

  build() {
    List({ scroller: this.scrollerForList }) {
      ForEach(this.goodList, (item: GoodItem, idx: number) => {
        ListItem() {
          Row() {
            Text(item.name)
              .textAlign(TextAlign.Center)
              .fontSize($r('app.float.form_font_size'))
              .lineHeight(FileConstants.LINE_HEIGHT_21)
              .fontWeight(FileConstants.FONT_WEIGHT_500)
              .height($r('app.float.textitem_height2'))
              .width(FileConstants.PERCENT_30)
              .margin({ bottom: $r('app.float.margin_2'), right: FileConstants.PERCENT_23 })

            Text("¥" + item.price)
              .textAlign(TextAlign.Center)
              .fontSize($r('app.float.price_font_size'))
              .lineHeight(FileConstants.LINE_HEIGHT_21)
              .fontWeight(FileConstants.FONT_WEIGHT_400)
              .fontColor($r('app.color.backColor'))
              .width(FileConstants.PERCENT_23)
              .height($r('app.float.textinput_height1'))
              .margin({
                bottom: $r('app.float.margin_12'),
                right: FileConstants.PERCENT_2,
                top: $r('app.float.margin_12')
              })

            Button() {
              Image($r('app.media.ic_public_edit'))
                .width($r('app.float.image_width'))
                .height($r('app.float.image_width'))
            }
            .margin({ right: FileConstants.PERCENT_3 })
            .height($r('app.float.button_height'))
            .width($r('app.float.button_width1'))
            .backgroundColor(FileConstants.BUTTON_BACKGROUND_COLOR)
            .bindSheet(this.isHoverText[idx], this.sheetBuilder(), {
              height: $r('app.float.bindsheet_height'),
              backgroundColor: Color.White,
              title: { title: $r('app.string.changeinfo') },
              onDisappear: () => {
                this.isHoverText.fill(false);
              }
            })
            .onClick(() => {
              this.isHoverText[idx] = true;
              this.dialogIdValue = item.id;
              this.dialogNameValue = item.name;
              this.dialogPriceValue = item.price;
            })

            Button() {
              Image($r('app.media.ic_public_delete'))
                .width($r('app.float.image_width'))
                .height($r('app.float.image_width'))
            }
            .margin({ right: $r('app.float.margin_12') })
            .height($r('app.float.button_height'))
            .width($r('app.float.button_width1'))
            .backgroundColor(FileConstants.BUTTON_BACKGROUND_COLOR)
            .onClick(() => {
              testNapi.deleteRDB(item.id);
              this.updateDataFromRDB();
            })
          }
          .padding({ left: $r('app.float.padding_12') })
          .backgroundColor($r('app.color.whiteColor'))
          .borderRadius($r('app.float.border_radius'))
          .width(FileConstants.PERCENT_87)
          .height($r('app.float.row_height4'))
          .margin({ left: FileConstants.PERCENT_3 })
        }
      },)
    }
    .width(FileConstants.FULL_PERCENT)
    .height($r('app.float.list_height4'))
    .edgeEffect(EdgeEffect.None)
    .scrollBar(BarState.Off)
    .nestedScroll({
      scrollForward: NestedScrollMode.PARENT_FIRST,
      scrollBackward: NestedScrollMode.SELF_FIRST
    })
  }
}