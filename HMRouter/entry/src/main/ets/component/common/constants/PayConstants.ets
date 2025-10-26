/*
 *   Copyright (c) 2024 Huawei Device Co., Ltd.
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 */

const uiContext: UIContext | undefined = AppStorage.get('uiContext');

export class PayConstants {
  /**
   * Pay card text1.
   */
  static readonly PAY_CARD_TEXT1: string = uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.PAY_CARD_TEXT1').id);
  /**
   * Pay card text2.
   */
  static readonly PAY_CARD_TEXT2: string = uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.PAY_CARD_TEXT2').id);
  /**
   * Pay card text3.
   */
  static readonly PAY_CARD_TEXT3: string = uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.PAY_CARD_TEXT3').id);
  /**
   * Pay card text2.
   */
  static readonly PAY_CARD_BUTTON: string = uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.PAY_CARD_BUTTON').id);
  /**
   * Pay cancel title.
   */
  static readonly PAY_CANCEL_TITLE: string = uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.PAY_CANCEL_TITLE').id);
  /**
   * Pay cancel content.
   */
  static readonly PAY_CANCEL_CONTENT: string = uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.PAY_CANCEL_CONTENT').id);
  /**
   * Pay cancel button1.
   */
  static readonly PAY_CANCEL_BUTTON1: string = uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.PAY_CANCEL_SEE').id);
  /**
   * Pay cancel button2.
   */
  static readonly PAY_CANCEL_BUTTON2: string = uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.PAY_CANCEL_CONFIRM').id);
  /**
   * Pay success title.
   */
  static readonly PAY_SUCCESS_TITLE: string = uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.PAY_SUCCESS_TITLE').id);
  /**
   * Pay success text.
   */
  static readonly PAY_SUCCESS_TEXT: string = uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.PAY_SUCCESS_TEXT').id);
  /**
   * Pay success button text.
   */
  static readonly PAY_SUCCESS_BUTTON: string = uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.PAY_SUCCESS_BUTTON').id);
}