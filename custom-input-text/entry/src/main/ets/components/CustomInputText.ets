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

import { inputMethod } from '@kit.IMEKit';
import { promptAction } from '@kit.ArkUI';
import { logger } from '../utils/Logger';
import { inputAttribute } from '../utils/InputAttributeInit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const LINE_HEIGHT: number = 20;
const END_FLAG: number = 1000;
const TAG: string = 'CustomInputText';

@Component
export struct CustomInputText {
  @State inputText: string = '';
  @State lastInput: string = '';
  @State selectInput: string = '';
  @State cursorInfo: inputMethod.CursorInfo = { top: 0, left: 0, width: 1, height: 25 };
  @State cursorLeft: number = 0;
  @State cursorIndex: number = 0;
  @State selectIndex: number = 0;
  @State inputWidth: number = 320;
  @Consume @Watch('isAttachedChange') isAttached: boolean;
  @Consume @Watch('isOnChange') isOn: boolean;
  @Consume @Watch('isShowChange') isShow: boolean;
  @Consume @Watch('changeSelection') isChangeSelection: boolean;
  @Consume enterKeyIndex: number;
  @Consume inputTypeIndex: number;
  @Consume selectStart: number;
  @Consume selectEnd: number;
  public inputController: inputMethod.InputMethodController = inputMethod.getController();
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  build() {
    Stack() {
      Row() {
        Text(this.inputText)
          .fontSize(16)
          .fontFamily('sans-serif')
          .id('inputText')
          .lineHeight(LINE_HEIGHT)
          .maxLines(1)
          .constraintSize({ maxWidth: this.inputWidth })
        Text(this.selectInput)
          .fontSize(16)
          .fontFamily('sans-serif')
          .lineHeight(LINE_HEIGHT)
          .id('selectInput')
          .maxLines(1)
          .backgroundColor($r('app.color.select_color'))
        Text(this.lastInput)
          .fontSize(16)
          .fontFamily('sans-serif')
          .lineHeight(LINE_HEIGHT)
          .id('lastInput')
          .maxLines(1)
      }
      .width(this.inputWidth)

      Text('')
        .width(this.cursorInfo.width)
        .height(this.cursorInfo.height)
        .backgroundColor($r('app.color.cursor_color'))
        .margin({ top: 5 })
        .position({ x: this.cursorLeft, y: 0 })
        .onAreaChange((oldArea: Area, newArea: Area) => {
          if (newArea.globalPosition.x as number !== this.cursorInfo.left) {
            this.cursorInfo.left = newArea.globalPosition.x as number;
            this.cursorInfo.top = newArea.position.y as number;
            this.cursorInfo.width = newArea.width as number;
            this.cursorInfo.height = newArea.height as number;
            logger.info(TAG, `cursor change: this.cursorInfo=${JSON.stringify(this.cursorInfo)}`);
            this.inputController.updateCursor(this.cursorInfo);
          }
        })

      Canvas(this.context)
        .width('100%')
        .height(45)
        .onReady(() => {
          let px = this.getUIContext().vp2px(16);
          this.context.font = px + 'px sans-serif';
          this.inputWidth = this.context.width;
        })
    }
    .id('customInputText')
    .width('100%')
    .borderRadius(20)
    .backgroundColor($r('app.color.input_text_background'))
    .padding({ left: 10, right: 10, top: 5, bottom: 5 })
    .height(45)
    .onClick((event?: ClickEvent) => {
      if (event) {
        logger.info(TAG, `click event= ${JSON.stringify(event)}`);
        this.initTextInput(event);
      }
    })
  }

  async initTextInput(event: ClickEvent): Promise<void> {
    try {
      focusControl.requestFocus('customInputText');
      this.inputController.updateAttribute({
        textInputType: inputAttribute.getInputType(this.inputTypeIndex),
        enterKeyType: inputAttribute.getEnterType(this.enterKeyIndex)
      })
      await this.inputController.attach(false, {
        inputAttribute: {
          textInputType: inputAttribute.getInputType(this.inputTypeIndex),
          enterKeyType: inputAttribute.getEnterType(this.enterKeyIndex)
        }
      });
      this.inputController.showTextInput();
      this.isAttached = true;
      this.isShow = true;
      this.isOn = true;
      this.calculateCursor(event.x);
    } catch (error) {
      hilog.error(0x0000, TAG, `initTextInput catch error, code: ${error.code}, message: ${error.message}`);
    }
  }

  async isAttachedChange(): Promise<void> {
    try {
      if (this.isAttached) {
        focusControl.requestFocus('customInputText');
        await this.inputController.attach(false, {
          inputAttribute: {
            textInputType: inputAttribute.getInputType(this.inputTypeIndex),
            enterKeyType: inputAttribute.getEnterType(this.enterKeyIndex)
          }
        });
      } else {
        this.detach();
      }
    } catch (error) {
      hilog.error(0x0000, TAG, `isAttachedChange catch error, code: ${error.code}, message: ${error.message}`);
    }
  }

  isShowChange(): void {
    try {
      if (this.isShow) {
        inputMethod.getController().showTextInput();
      } else {
        inputMethod.getController().hideTextInput();
      }
    } catch (error) {
      hilog.error(0x0000, TAG, `isShowChange catch error, code: ${error.code}, message: ${error.message}`);
    }
  }

  isOnChange(): void {
    if (this.isOn) {
      this.initListener();
    } else {
      this.off();
    }
  }

  changeSelection(): void {
    if (this.isChangeSelection) {
      let message = this.inputText + this.selectInput + this.lastInput;
      if (this.selectStart <= this.selectEnd) {
        this.selectIndex = this.selectStart;
        this.cursorIndex = this.selectEnd;
      }
      if (this.selectStart > this.selectEnd) {
        this.selectIndex = this.selectEnd;
        this.cursorIndex = this.selectStart;
      }
      if (this.cursorIndex > message.length) {
        this.cursorIndex = message.length;
      }
      this.inputText = message.substring(0, this.selectIndex);
      this.selectInput = message.substring(this.selectIndex, this.cursorIndex);
      this.lastInput = message.substring(this.cursorIndex, message.length);
      let cursorText = this.inputText + this.selectInput;
      this.cursorLeft = this.context.measureText(cursorText).width;
      this.isChangeSelection = false;
    }
  }

  async detach(): Promise<void> {
    try {
      logger.info(TAG, `detach`);
      await this.off();
      this.isOn = false;
      this.isShow = false;
      this.inputController.detach();
    } catch (error) {
      hilog.error(0x0000, TAG, `detach catch error, code: ${error.code}, message: ${error.message}`);
    }
  }

  async off(): Promise<void> {
    logger.info(TAG, `off`);
    this.inputController.off('insertText');
    this.inputController.off('deleteLeft');
    this.inputController.off('deleteRight');
    this.inputController.off('moveCursor');
    this.inputController.off('selectByMovement');
    this.inputController.off('selectByRange');
    this.inputController.off('sendFunctionKey')
    this.inputController.off('handleExtendAction');
    this.inputController.off('sendKeyboardStatus');
  }

  initListener(): void {
    try {
      this.inputController.on('insertText', (text: string) => {
        logger.info(TAG, `insertText, text: ${text}`);
        if ((this.cursorLeft + this.context.measureText(text).width + this.context.measureText(this.lastInput)
          .width) > this.context.width) {
          return;
        }
        this.inputText += text;
        this.cursorIndex = this.inputText.length;
        this.selectIndex = this.cursorIndex;
        this.selectInput = '';
        this.cursorLeft = this.context.measureText(this.inputText).width;
      })
      this.inputController.on('deleteRight', (length: number) => {
        let message = this.inputText + this.selectInput + this.lastInput;
        if (this.cursorIndex < message.length) {
          this.selectIndex = this.cursorIndex;
          this.selectInput = '';
          let deleteIndex = this.cursorIndex + length;
          if (deleteIndex > message.length) {
            deleteIndex = message.length;
          }
          this.lastInput = message.substring(this.cursorIndex + length, message.length);
        }
      })
      this.inputController.on('deleteLeft', (length: number) => {
        this.inputText = this.inputText.substring(0, this.inputText.length - length);
        this.cursorIndex = this.inputText.length;
        this.selectIndex = this.cursorIndex;
        this.cursorLeft = this.context.measureText(this.inputText).width;
      })
      this.inputController.on('moveCursor', (direction: inputMethod.Direction) => {
        logger.info(TAG, `Succeeded in moveCursor, direction: ${direction}`);
        let message = this.inputText + this.selectInput + this.lastInput;
        this.selectInput = '';
        if (direction === inputMethod.Direction.CURSOR_UP) {
          this.cursorIndex = 0;
        }
        if (direction === inputMethod.Direction.CURSOR_DOWN) {
          this.cursorIndex = message.length;
        }
        if (direction === inputMethod.Direction.CURSOR_LEFT) {
          this.cursorIndex--;
        }
        if (direction === inputMethod.Direction.CURSOR_RIGHT) {
          if (this.cursorIndex < message.length) {
            this.cursorIndex++;
          }
        }
        this.selectIndex = this.cursorIndex;
        this.inputText = message.substring(0, this.cursorIndex);
        this.lastInput = message.substring(this.cursorIndex, message.length);
        this.cursorLeft = this.context.measureText(this.inputText).width;
      });
      this.inputController.on('selectByMovement', (movement: inputMethod.Movement) => {
        logger.info(TAG, `Succeeded in selectByMovement, direction: ${movement.direction}`);
        let message = this.inputText + this.selectInput + this.lastInput;
        if (movement.direction === inputMethod.Direction.CURSOR_UP) {
          this.selectIndex = 0;
        }
        if (movement.direction === inputMethod.Direction.CURSOR_LEFT) {
          if (this.selectIndex > 0) {
            this.selectIndex--;
          }
        }
        if (movement.direction === inputMethod.Direction.CURSOR_RIGHT) {
          if (this.selectIndex < message.length) {
            this.selectIndex++;
          }
        }
        if (movement.direction === inputMethod.Direction.CURSOR_DOWN) {
          this.selectIndex = message.length;
        }
        if (this.selectIndex > this.cursorIndex) {
          this.inputText = message.substring(0, this.cursorIndex);
          this.selectInput = message.substring(this.cursorIndex, this.selectIndex);
          this.lastInput = message.substring(this.selectIndex, message.length);
        } else {
          this.inputText = message.substring(0, this.selectIndex);
          this.selectInput = message.substring(this.selectIndex, this.cursorIndex);
          this.lastInput = message.substring(this.cursorIndex, message.length);
        }
      });
      this.inputController.on('selectByRange', (range: inputMethod.Range) => {
        logger.info(TAG, `selectByRange this.range: ${JSON.stringify(range)}`);
        let message = this.inputText + this.selectInput + this.lastInput;
        if (range.start === 0 && range.end === 0) {
          this.cursorIndex = 0;
          let message = this.inputText + this.selectInput + this.lastInput;
          this.selectInput = '';
          this.selectIndex = this.cursorIndex;
          this.inputText = message.substring(0, this.cursorIndex);
          this.lastInput = message.substring(this.cursorIndex, message.length);
          this.cursorLeft = this.context.measureText(this.inputText).width;
        } else if (range.end > range.start) {
          if (range.end === END_FLAG) {
            this.lastInput = '';
            this.selectIndex = message.length;
            this.inputText = message.substring(0, this.cursorIndex);
            this.selectInput = message.substring(this.cursorIndex, this.selectIndex);
          } else {
            this.selectIndex = 0;
            this.inputText = ''
            this.selectInput = message.substring(0, this.cursorIndex);
            this.lastInput = message.substring(this.cursorIndex, message.length);
          }
        } else {
          this.cursorIndex = message.length;
          this.selectIndex = this.cursorIndex;
          this.inputText = message.substring(0, this.cursorIndex);
          this.lastInput = message.substring(this.cursorIndex, message.length);
          this.cursorLeft = this.context.measureText(this.inputText).width;
        }
        logger.info(TAG, `selectByRange this.selectInput: ${this.selectInput}`);
      })
      this.inputController.on('sendFunctionKey', (enterKey: inputMethod.FunctionKey) => {
        this.getUIContext().getPromptAction().showToast({
          message: `enterKey Clicked ${enterKey.enterKeyType.toString()}`,
          bottom: 500
        });
      })
      this.inputController.on('sendKeyboardStatus', (keyBoardStatus: inputMethod.KeyboardStatus) => {
        logger.info(TAG, `sendKeyboardStatus keyBoardStatus: ${keyBoardStatus}`);
      });
      this.inputController.on('handleExtendAction', (action: inputMethod.ExtendAction) => {
        if (action === inputMethod.ExtendAction.SELECT_ALL) {
          let message = this.inputText + this.selectInput + this.lastInput;
          this.cursorIndex = message.length;
          this.selectIndex = 0;
          this.inputText = ''
          this.selectInput = message.substring(0, this.cursorIndex);
          this.lastInput = '';
          this.cursorLeft = this.context.measureText(this.selectInput).width;
        }
      })
    } catch (error) {
      hilog.error(0x0000, TAG, `initListener catch error, code: ${error.code}, message: ${error.message}`);
    }
  }

  calculateCursor(x: number): void {
    let message = this.inputText + this.selectInput + this.lastInput;
    let charWidth = this.context.measureText(message).width / message.length;
    this.cursorIndex = Math.floor(x / charWidth);
    if (this.cursorIndex < 0) {
      this.cursorIndex = 0;
      this.inputText = '';
      this.lastInput = message;
    } else if (this.cursorIndex > message.length) {
      this.cursorIndex = message.length;
      this.inputText = message;
      this.lastInput = '';
    } else {
      this.inputText = message.substring(0, this.cursorIndex);
      this.lastInput = message.substring(this.cursorIndex, message.length);
    }
    this.selectIndex = this.cursorIndex;
    this.selectInput = '';
    this.cursorLeft = this.context.measureText(message.substring(0, this.cursorIndex)).width;
  }
}