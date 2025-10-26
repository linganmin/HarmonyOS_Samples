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
export default class CommonConstants {
  /**
   * Height or Width is 100%.
   */
  static readonly FULL_PARENT: string = '100%';
  /**
   * Duration of toast dialog box is 2000ms.
   */
  static readonly TOAST_DURATION: number = 2000;
  /**
   * total number of Grid data is 2000.
   */
  static readonly GRID_TOTAL_DATA: number = 2000;
  /**
   * The font weight of button is 500.
   */
  static readonly BUTTON_FONT_WEIGHT: number = 500;
  /**
   * The font weight of text is 500.
   */
  static readonly TEXT_FONT_WEIGHT: number = 500;
  /**
   * The opacity of text is 500.
   */
  static readonly TEXT_OPACITY: number = 0.6;
  /**
   * The font size of button is 16vp.
   */
  static readonly BUTTON_FONT_SIZE: number = 16;
  /**
   * The font size of text is 16vp.
   */
  static readonly TEXT_FONT_SIZE: number = 16;
  /**
   * The font height of text is 80vp.
   */
  static readonly TEXT_FONT_HEIGHT: number = 80;
  /**
   * The font size of title is 16vp.
   */
  static readonly TITLE_FONT_SIZE: number = 30;
  /**
   * Scroll to the specified index, value is 1900.
   */
  static readonly TARGET_INDEX: number = 1900;
  /**
   * Space of list is 18.
   */
  static readonly LIST_SPACE: number = 18;
  /**
   * The content of text.
   */
  static readonly CONTENT: string = 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
  /**
   * taskId of ArkTS performance Tagging is 1.
   */
  static readonly TASK_ID: number = 1;
  /**
   * task name of ArkTS performance Tagging is ArkTSPerfTag.
   */
  static readonly TASK_NAME: string = 'ArkTSPerfTag';
  /**
   * taskId of component_cb performance Tagging is 3.
   */
  static readonly COMPONENT_CB_TASK_ID: number = 3;
  /**
   * task name of component_cb performance Tagging is ComponentCBPerfTag.
   */
  static readonly COMPONENT_TASK_NAME: string = 'ComponentCBPerfTag';
  /**
   * taskId of lifecyclePerfTag is 4.
   */
  static readonly LIFECYCLE_TASK_ID: number = 4;
  /**
   * task name of lifecycle performance Tagging is LifeCyclePerfTag.
   */
  static readonly LIFECYCLE_TASK_NAME: string = 'LifeCyclePerfTag';
  /**
   * The total number of terms in the Fibonacci sequence. value is 20.
   */
  static readonly FIB_VALUE: number = 20;
  /**
   * ArkTS Performance tagging Page name is ArkTSPerfTag Page.
   */
  static readonly ARK_TS_PERF_TAG_PAGE: string = 'ArkTSPerfTag Page';
  /**
   * Native Performance tagging Page name is NativePerfTag Page.
   */
  static readonly NATIVE_PERF_TAG_PAGE: string = 'NativePerfTag Page';
  /**
   * LifeCycle Performance tagging Page name is LifeCyclePerfTag Page.
   */
  static readonly LIFECYCLE_PERF_TAG_PAGE: string = 'LifeCyclePerfTag Page';
  /**
   * Component Callback Performance tagging Page name is ComponentCBPerfTag Page.
   */
  static readonly COMPONENT_CB_PERF_TAG_PAGE: string = 'ComponentCBPerfTag Page';
}