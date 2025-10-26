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

export class LoginConstants {
  /**
   * Login title.
   */
  static readonly LOGIN_TEXT: string = uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.LOGIN_TITLE').id);
  /**
   * Login TextInput placeholder1.
   */
  static readonly LOGIN_PLACEHOLDER1: string =
    uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.LOGIN_PLACEHOLDER1').id);
  /**
   * Login TextInput placeholder2.
   */
  static readonly LOGIN_PLACEHOLDER2: string =
    uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.LOGIN_PLACEHOLDER2').id);
  /**
   * Login TextInput1 text.
   */
  static readonly LOGIN_INPUT_TEXT: string =
    uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.LOGIN_INPUT_TEXT').id);
  /**
   * Login button.
   */
  static readonly LOGIN_BUTTON: string = uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.LOGIN_BUTTON').id);
  /**
   * Login show toast.
   */
  static readonly LOGIN_TOAST: string = uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.LOGIN_TOAST').id);
  /**
   * Privacy dialog title.
   */
  static readonly PRIVACY_DIALOG_TITLE: string =
    uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.PRIVACY_DIALOG_TITLE').id);
  /**
   * Privacy dialog text1.
   */
  static readonly PRIVACY_DIALOG_TEXT1: string =
    uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.PRIVACY_DIALOG_TEXT1').id);
  /**
   * Privacy dialog text2.
   */
  static readonly PRIVACY_DIALOG_TEXT2: string =
    uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.PRIVACY_DIALOG_TEXT2').id);
  /**
   * Privacy dialog text3.
   */
  static readonly PRIVACY_DIALOG_TEXT3: string =
    uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.PRIVACY_DIALOG_TEXT3').id);
  /**
   * Privacy dialog text4.
   */
  static readonly PRIVACY_DIALOG_TEXT4: string =
    uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.PRIVACY_DIALOG_TEXT4').id);
  /**
   * Privacy dialog left button.
   */
  static readonly PRIVACY_DIALOG_LEFT_BUTTON: string =
    uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.PRIVACY_DIALOG_LEFT_BUTTON').id);
  /**
   * Privacy dialog right button.
   */
  static readonly PRIVACY_DIALOG_RIGHT_BUTTON: string =
    uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.PRIVACY_DIALOG_RIGHT_BUTTON').id);
  /**
   * Privacy detail title.
   */
  static readonly PRIVACY_DETAIL_TITLE: string =
    uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.PRIVACY_DETAIL_TITLE').id);
  /**
   * Privacy detail text1.
   */
  static readonly PRIVACY_DETAIL_TEXT1: string =
    uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.PRIVACY_DETAIL_TEXT1').id);
  /**
   * Privacy detail text2.
   */
  static readonly PRIVACY_DETAIL_TEXT2: string =
    uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.PRIVACY_DETAIL_TEXT2').id);
  /**
   * Privacy detail text3.
   */
  static readonly PRIVACY_DETAIL_TEXT3: string =
    uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.PRIVACY_DETAIL_TEXT3').id);
  /**
   * Privacy detail text4.
   */
  static readonly PRIVACY_DETAIL_TEXT4: string =
    uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.PRIVACY_DETAIL_TEXT4').id);
  /**
   * Privacy detail content.
   */
  static readonly PRIVACY_DETAIL_INFO: string[] =
    [uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.PRIVACY_DETAIL_ITEM_TEXT1').id),
      uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.PRIVACY_DETAIL_ITEM_TEXT2').id),
      uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.PRIVACY_DETAIL_ITEM_TEXT3').id),
      uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.PRIVACY_DETAIL_ITEM_TEXT4').id),
      uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.PRIVACY_DETAIL_ITEM_TEXT5').id),
      uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.PRIVACY_DETAIL_ITEM_TEXT6').id),
      uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.PRIVACY_DETAIL_ITEM_TEXT7').id),
      uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.PRIVACY_DETAIL_ITEM_TEXT8').id),
      uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.PRIVACY_DETAIL_ITEM_TEXT9').id)];
}