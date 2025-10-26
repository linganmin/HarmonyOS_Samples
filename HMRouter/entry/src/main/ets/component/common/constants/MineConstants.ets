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

export class MineConstants{
  /**
   * Mine page title.
   */
  static readonly MINE_TITLE: string = uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.MINE_TITLE').id);
  /**
   * Mine page text1.
   */
  static readonly MINE_TEXT1: string = uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.MINE_TEXT1').id);
  /**
   * Mine page text2.
   */
  static readonly MINE_TEXT2: string = uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.MINE_TEXT2').id);
  /**
   * Mine animation settings page content.
   */
  static readonly MINE_ANIMATION_CONTENT: string = uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.MINE_ANIMATION_CONTENT').id);
  /**
   * Mine page animation type1.
   */
  static readonly MINE_ANIMATION_TYPE1: string = uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.MINE_ANIMATION_TYPE1').id);
  /**
   * Mine page animation type2.
   */
  static readonly MINE_ANIMATION_TYPE2: string = uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.MINE_ANIMATION_TYPE2').id);
  /**
   * Mine page animation type3.
   */
  static readonly MINE_ANIMATION_TYPE3: string = uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.MINE_ANIMATION_TYPE3').id);
  /**
   * Personalized transition animation page title.
   */
  static readonly PERSONALIZED_ANIMATION_TITLE: string = uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.PERSONALIZED_ANIMATION_TITLE').id);
  /**
   * Personalized transition animation type1.
   */
  static readonly PERSONALIZED_ANIMATION_TYPE1: string = uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.PERSONALIZED_ANIMATION_TYPE1').id);
  /**
   * Personalized transition animation type2.
   */
  static readonly PERSONALIZED_ANIMATION_TYPE2: string = uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.PERSONALIZED_ANIMATION_TYPE2').id);
  /**
   * Personalized transition animation type3.
   */
  static readonly PERSONALIZED_ANIMATION_TYPE3: string = uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.PERSONALIZED_ANIMATION_TYPE3').id);
  /**
   * Mine page button text.
   */
  static readonly MINE_BUTTON_TEXT: string = uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.MINE_BUTTON_TEXT').id);
  /**
   * Mine page user name.
   */
  static readonly MINE_NAME: string = uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.MINE_NAME').id);
  /**
   * Mine log out page title.
   */
  static readonly MINE_LOG_OUT_TITLE: string = uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.MINE_LOG_OUT_TITLE').id);
  /**
   * Mine log out page text.
   */
  static readonly MINE_LOG_OUT_TEXT: string = uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.MINE_LOG_OUT_TEXT').id);
  /**
   * Mine log out page button text.
   */
  static readonly MINE_LOG_OUT_BUTTON: string = uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.MINE_LOG_OUT_BUTTON').id);
  /**
   * Exit login title.
   */
  static readonly EXIT_LOGIN_TITLE: string = uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.EXIT_LOGIN_TITLE').id);
  /**
   * Exit login content.
   */
  static readonly EXIT_LOGIN_CONTENT: string = uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.EXIT_LOGIN_CONTENT').id);
  /**
   * Exit login left button.
   */
  static readonly EXIT_LOGIN_LEFT_BUTTON: string = uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.EXIT_LOGIN_LEFT_BUTTON').id);
  /**
   * Exit login right button.
   */
  static readonly EXIT_LOGIN_RIGHT_BUTTON: string = uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.EXIT_LOGIN_RIGHT_BUTTON').id);
}