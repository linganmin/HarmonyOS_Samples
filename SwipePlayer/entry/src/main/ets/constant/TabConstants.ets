/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

export class TabConstant {
  /**
   * Tabs information above
   */
  static getTopTab(uiContext: UIContext): Array<string> {
    return [
      uiContext.getHostContext()?.resourceManager.getStringSync($r('app.string.TOP_TAB_CONCERN')) || '',
      uiContext.getHostContext()?.resourceManager.getStringSync($r('app.string.TOP_TAB_RECOMMEND')) || ''
    ];
  }

  /**
   * Upper tabs font size
   */
  static readonly TOP_TAB_FONT_SIZE: Array<number> = [18, 24];

  /**
   * Tabs information below
   */
  static getTab(uiContext: UIContext): Array<string> {
    return [
      uiContext.getHostContext()?.resourceManager.getStringSync($r('app.string.TAB_HOME')) || '',
      uiContext.getHostContext()?.resourceManager.getStringSync($r('app.string.TAB_FRIENDS')) || '',
      uiContext.getHostContext()?.resourceManager.getStringSync($r('app.string.TAB_PUBLISH')) || '',
      uiContext.getHostContext()?.resourceManager.getStringSync($r('app.string.TAB_MESSAGE')) || '',
      uiContext.getHostContext()?.resourceManager.getStringSync($r('app.string.TAB_MINE')) || ''
    ];
  }

  /**
   * Tabs icon below
   */
  static readonly TAB_ICON: Resource = $r('app.media.add');
  /**
   * Tabs icon width below
   */
  static readonly TAB_ICON_WIDTH: number = 32;
  /**
   * Tabs spacing
   */
  static readonly TAB_MARGIN_OR_PADDING: number[] = [20, 24];
}