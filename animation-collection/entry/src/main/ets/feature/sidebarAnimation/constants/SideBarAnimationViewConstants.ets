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
import { BusinessError } from "@kit.BasicServicesKit";
import { hilog } from "@kit.PerformanceAnalysisKit";

const context = AppStorage.get('context') as UIContext;

export class SideBarAnimationViewConstants {
  /**
   * Sidebar animation duration.
   */
  static readonly SIDEBAR_ANIMATION_DURATION: number = 500;
  /**
   * Sidebar animation duration.
   */
  static readonly SIDEBAR_WIDTH: number = 200;
  /**
   * Sidebar animation duration.
   */
  static readonly INPUT_BOX_HEIGHT: number = 200;
  /**
   * Sidebar animation duration.
   */
  static readonly GROUP_NAME_FONT_WEIGHT: number = 16;
  /**
   * Sidebar animation duration.
   */
  static readonly MEMBER_COUNT: number = 10;
  /**
   * Sidebar animation duration.
   */
  static readonly SIDEBAR_OPACITY_SHOW: number = 1;
  /**
   * Sidebar animation duration.
   */
  static readonly SIDEBAR_OPACITY_HIDDEN: number = 0;
  /**
   * Sidebar animation duration.
   */
  static readonly SIDEBAR_IS_SHOW_BUTTON: boolean = false;
  /**
   * Sidebar animation duration.
   */
  static readonly SIDEBAR_IS_BUTTON_AUTORESIZE: boolean = true;
  /**
   * Sidebar animation duration.
   */
  static readonly SIDEBAR_IS_AUTO_HIDE: boolean = false;
  /**
   * Sidebar animation duration.
   */
  static readonly HEAD_ICON_SIZE: number = 50;
  /**
   * Sidebar animation duration.
   */
  static readonly HEAD_ICON_BORDER_RADIUS: number = 25;
  /**
   * Sidebar animation duration.
   */
  static readonly SIDEBAR_BUTTON_HEIGHT: number = 40;
  /**
   * Sidebar animation duration.
   */
  static readonly SIDEBAR_BUTTON_WIDTH: number = 20;
  /**
   * Sidebar animation duration.
   */
  static readonly SIDEBAR_BUTTON_RADIUS: number = 6;
  /**
   * Sidebar animation duration.
   */
  static readonly BACK_BTN_X: number = -10;
  /**
   * Sidebar animation duration.
   */
  static readonly BACK_BTN_Y: number = -10;
  /**
   * Sidebar animation duration.
   */
  static readonly BACK_BTN_RESPONSE_WIDTH: number = 40;
  /**
   * Sidebar animation duration.
   */
  static readonly BACK_BTN_RESPONSE_HEIGHT: number = 60;
  /**
   * Sidebar animation duration.
   */
  static readonly SIDEBAR_MEMBER_LIST_HEAD_ICON_SIZE: number = 40;
  /**
   * Sidebar animation duration.
   */
  static readonly SIDEBAR_MEMBER_LIST_HEAD_ICON_RADIUS: number = 20;
  /**
   * Sidebar animation duration.
   */
  static readonly SIDEBAR_MEMBER_LIST_NAME_HEIGHT: number = 20;
  /**
   * Sidebar animation duration.
   */
  static readonly SIDEBAR_ANIMATION: string = 'SideBarAnimation';
  /**
   * Sidebar animation duration.
   */
  static readonly SENDER_INFO: string = 'Author 2024-02-25 14:30';
  /**
   * Sidebar animation duration.
   */
  static readonly BTN_SEND_MSG: string = '发送';
  /**
   * Sidebar animation duration.
   */
  static readonly MEMBER: string = '成员';
  /**
   * Sidebar animation duration.
   */
  static readonly NOT_IMPLEMENT_PROMPT: string = '仅供UI展示';
  /**
   * Sidebar animation duration.
   */
  static readonly CASE_DESCRIPTION: string = this.resourceToString($r('app.string.case_description'));
  /**
   * Sidebar animation duration.
   */
  static readonly MESSAGE_MAX_WIDTH: string = 'calc(100% - 50vp)';
  /**
   * Sidebar animation duration.
   */
  static readonly GROUP_NAME: string = this.resourceToString($r('app.string.group_name'));

  static resourceToString(resource: Resource): string {
    let result = '';
    try {
      result = context.getHostContext()!.resourceManager.getStringSync(resource.id);
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0000, 'SideBarAnimationViewConstants',
        `getStringSync failed. error code=${error.code}, message=${error.message}`);
    }
    return result;
  }
}