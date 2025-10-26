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

import { hiAppEvent } from '@kit.PerformanceAnalysisKit';
import { PreferencesManager } from '../model/PreferencesManager';
import { BUTTON_TEXT } from '../model/MockData';
import { FaultDataSource } from '../model/DataSource';
import { Logger } from '../log/Logger';


const TAG: string = 'FaultLogger'; // Abnormal Application Page Tag
const DELAY_TIME: number = 3000;

@Entry
@Component
struct ApplicationExceptionView {
  // Initialize the index of the clicked exception event
  @Provide eventIndex: number = -1;

  build() {
    Column() {
      // Scenario description component
      FunctionDescription({
        title: $r('app.string.application_exception_application_fault_title'),
        content: $r('app.string.application_exception_application_fault_description')
      })
      // Abnormal information display component
      FaultArea()
      // Constructing Abnormal Components
      FaultConstruction()
    }
    .padding($r('app.string.ohos_id_card_padding_start'))
    .backgroundColor($r('app.color.ohos_id_color_sub_background'))
    .width($r('app.string.ohos_global_state_dialog_hundred_percent'))
    .height($r('app.string.ohos_global_state_dialog_hundred_percent'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM])
  }
}

@Component
struct FaultArea {
  // Perform bidirectional data binding on the array length of lazy loading data sources
  @StorageLink('faultDataSourceLength') faultDataSourceLength: number = 0;
  // Bidirectional data binding event group, bound to AppStorage. setOrCreate,
  // this variable changes and triggers the getFaultMessage function
  @StorageLink('appEventGroups') @Watch('getFaultMessage') appEventGroups: Array<hiAppEvent.AppEventGroup> = [];
  // Abnormal trigger sign
  @StorageLink('faultSign') faultSign: boolean = false;
  // The index of the clicked abnormal event
  @Consume eventIndex: number;
  // Data source for lazy loading
  @State faultDataSource: FaultDataSource = new FaultDataSource();
  private scroller: Scroller = new Scroller();

  async aboutToAppear() {
    Logger.info(TAG, `aboutToAppear start`);
    // Get Preferences instance
    await PreferencesManager.getPreferences(this.faultDataSource);
    // First, retrieve data from the persistent storage,
    // then add the previous application exception information to the list header,
    // and update the persistent storage
    this.getFaultMessage();
    // Reset appEventGroups in AppStorage to avoid adding duplicate data
    AppStorage.setOrCreate('appEventGroups', []);
  }

  // Obtain application exception information
  async getFaultMessage() {
    Logger.info(TAG, `getAppEventGroups start`);
    if (this.appEventGroups && this.appEventGroups.length > 0) {
      // Traverse event groups
      this.appEventGroups.forEach((eventGroup: hiAppEvent.AppEventGroup) => {
        // Traverse the collection of event objects
        eventGroup.appEventInfos.forEach(async (eventInfo: hiAppEvent.AppEventInfo) => {
          let message: string = '';
          message += `HiAppEvent eventInfo.domain=${eventInfo.domain}\n`
            + `HiAppEvent eventInfo.name=${eventInfo.name}\n`
            + `HiAppEvent eventInfo.eventType=${eventInfo.eventType}\n`
            + `HiAppEvent eventInfo.params.time=${eventInfo.params['time']}\n`
            + `HiAppEvent eventInfo.params.crash_type=${eventInfo.params['crash_type']}\n`
            + `HiAppEvent eventInfo.params.foreground=${eventInfo.params['foreground']}\n`
            + `HiAppEvent eventInfo.params.bundle_version=${eventInfo.params['bundle_version']}\n`
            + `HiAppEvent eventInfo.params.bundle_name=${eventInfo.params['bundle_name']}\n`
            + `HiAppEvent eventInfo.params.exception=${JSON.stringify(eventInfo.params['exception'])}\n`
            + `HiAppEvent eventInfo.params.hilog.size=${eventInfo.params['hilog'].length}\n`;
          // Knowledge point: Storing exception information in the array faultMessage
          this.faultDataSource.pushData(message);
        })
      })
    }
    // Knowledge point: Persisting storage exception information collection
    this.faultDataSource.persistenceStorage();
  }

  build() {
    List({ scroller:this.scroller }) {
      // Add a judgment, if the number of information in the set of abnormal information is greater than 0, traverse the abnormal information
      if (this.faultDataSourceLength > 0) {
        LazyForEach(this.faultDataSource, (message: string) => {
          ListItem() {
            Text(message)
              .textAlign(TextAlign.Start)
          }
        }, (item: string) => item)
      } else {
        ListItem() {
          // Respond to specified information based on the index of the clicked event
          Text(this.eventIndex === 0 ? $r('app.string.application_exception_crash_event_message') :
            (this.eventIndex === 1 ? $r('app.string.application_exception_freeze_event_message') :
              (this.faultSign ? $r('app.string.application_exception_data_delay_toast') :
              $r('app.string.application_exception_no_message'))))
        }
      }
    }
    .width($r('app.string.ohos_global_state_dialog_hundred_percent'))
    .height($r('app.string.ohos_id_elements_list_high'))
    .borderRadius($r('app.string.ohos_id_corner_radius_default_m'))
    .padding($r('app.string.ohos_id_card_padding_start'))
    .margin({ top: $r('app.string.ohos_id_elements_margin_vertical_l') })
    .backgroundColor(Color.White)
  }
}

@Component
struct FaultConstruction {
  // The index of the clicked abnormal event
  @Consume eventIndex: number;
  // Perform bidirectional data binding on the array length of lazy loading data sources
  @StorageLink('faultDataSourceLength') faultDataSourceLength: number = 0;
  // Abnormal trigger sign
  @StorageLink('faultSign') faultSign: boolean = false;

  handleOperate(index: number) {
    switch (index) {
      case 0:
      // Note: This is a deliberately constructed bug
      // Construct an APP-CRASH scenario in the button click function to trigger an application crash event
        const result: object = JSON.parse('');
        break;
      case 1:
      // Note: This is a deliberately constructed bug
      // Construct an APP-FREEZE scenario in the button click function,
      // trigger the application freeze event, and execute an infinite loop after 500ms
        while (true) {
        }
      default:
        break;
    }
  }

  build() {
    Stack() {
      Column(){
        ForEach(BUTTON_TEXT, (item: string, index: number) => {
          Button(item)
            .type(ButtonType.Capsule)
            .size({ width: $r('app.string.ohos_global_state_dialog_hundred_percent') })
            .borderRadius($r('app.string.ohos_id_corner_radius_default_m'))
            .margin({ top: $r('app.string.ohos_id_button_margin_top') })
            .onClick(() => {
              // Abnormal trigger sign
              this.faultSign = true;
              PreferencesManager.putFaultSign();
              // When clicking on an exception, clear the page information data
              // and display the exception description information.
              // To control the display of page information data,
              // this variable needs to be set to 0
              this.faultDataSourceLength = 0;
              // Update the index of clicked abnormal events
              this.eventIndex = index;
              // Execute system crash operation after 3s
              setTimeout(() => {
                this.handleOperate(index);
              }, DELAY_TIME);
            })
        }, (item: string) => JSON.stringify(item))
      }
      .width($r('app.string.ohos_global_state_dialog_hundred_percent'))
    }
    .width($r('app.string.ohos_global_state_dialog_hundred_percent'))
    .margin({ bottom: $r('app.string.ohos_id_button_margin_bottom')})
    .align(Alignment.Bottom)
    .flexGrow(1)
  }
}

@Component
struct FunctionDescription {
  private title: ResourceStr = '';
  private content: ResourceStr = '';

  build() {
    Column() {
      Row() {
        Text(this.title)
          .fontSize($r('app.string.ohos_id_text_size_headline'))
          .fontWeight(FontWeight.Medium)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
      }
      .width($r('app.string.ohos_global_state_dialog_hundred_percent'))
      .margin({ bottom: $r('app.string.ohos_id_elements_margin_vertical_m') })
      Row() {
        Text(this.content)
          .wordBreak(WordBreak.NORMAL)
      }
      .width($r('app.string.ohos_global_state_dialog_hundred_percent'))
    }
    .width($r('app.string.ohos_global_state_dialog_hundred_percent'))
    .padding($r('app.string.ohos_id_card_padding_start'))
  }
}