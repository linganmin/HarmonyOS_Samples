/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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

import { promptAction, UIContext } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import AbilityContextController from '../feature/AbilityContextController'
import { PublicTitleBar } from './component/PublicTitleBar'

@Entry
@Component
struct AbilityContextPage {
  private appContext: common.UIAbilityContext = this.getUIContext().getHostContext()! as common.UIAbilityContext;
  private abilityContext: AbilityContextController = new AbilityContextController(this.appContext, this.getUIContext());

  build() {
    Column() {
      PublicTitleBar({ textName: $r('app.string.ability_context_page') })
      Scroll() {
        Column() {
          Button($r('app.string.start_ability'))
            .fancy(() => {
              this.abilityContext.startAbility();
            })
          Button($r('app.string.start_ability_forResult'))
            .fancy(() => {
              this.abilityContext.startAbilityForResult();
            })
          Button($r('app.string.terminate_self'))
            .fancy(() => {
              this.abilityContext.terminateSelf();
            })
          Button($r('app.string.terminate_self_with_result'))
            .fancy(() => {
              this.abilityContext.terminateSelfWithResult();
            })
          Button($r('app.string.request_permissions_from_user'))
            .fancy(() => {
              this.abilityContext.requestPermissionsFromUser();
            })
          Button($r('app.string.set_mission_label'))
            .fancy(() => {
              this.abilityContext.setMissionLabel();
            })
          Button($r('app.string.is_terminating'))
            .fancy(() => {
              this.abilityContext.isTerminating();
            })

          // Indicates the configuration information about a capability,
          // which corresponds to the getAbilityInfo() method of the FA model.
          Button($r('app.string.ability_info'))
            .fancy(() => {
              this.appContext.abilityInfo;
              this.getUIContext().getPromptAction().showToast({
                message: `${JSON.stringify(this.appContext.abilityInfo)}`
              });
            })

          // Indicates the configuration information about a module,
          // corresponding to the getHapModuleInfo() method of the FA model.
          Button($r('app.string.current_hap_module_info'))
            .fancy(() => {
              this.appContext.currentHapModuleInfo;
              this.getUIContext().getPromptAction().showToast({
                message: `${JSON.stringify(this.appContext.currentHapModuleInfo)}`
              });
            })

          // Indicates configuration information.
          Button($r('app.string.config'))
            .fancy(() => {
              this.appContext.config;
              this.getUIContext().getPromptAction().showToast({
                message: `${JSON.stringify(this.appContext.config)}`
              });
            })

          // Indicates the ability to access application resources.
          Button($r('app.string.resource_manager'))
            .fancy(() => {
              this.appContext.resourceManager;
              this.getUIContext().getPromptAction().showToast({
                message: `${JSON.stringify(this.appContext.resourceManager)}`
              });
            })

          // Indicates configuration information about the application.
          Button($r('app.string.application_info'))
            .fancy(() => {
              this.appContext.applicationInfo;
              this.getUIContext().getPromptAction().showToast({
                message: `${JSON.stringify(this.appContext.applicationInfo)}`
              });
            })

          // Indicates the application cache directory, which corresponds to
          // the getCacheDir() method in appContext of the FA model.
          Button($r('app.string.cache_dir'))
            .fancy(() => {
              this.appContext.cacheDir;
              this.getUIContext().getPromptAction().showToast({
                message: `${JSON.stringify(this.appContext.cacheDir)}`
              });
            })

          // Indicates the application temporary directory.
          Button($r('app.string.temp_dir'))
            .fancy(() => {
              this.appContext.tempDir;
              this.getUIContext().getPromptAction().showToast({
                message: `${JSON.stringify(this.appContext.tempDir)}`
              });
            })

          // Indicates the application file directory, corresponding to the getFilesDir() method of the FA model.
          Button($r('app.string.files_dir'))
            .fancy(() => {
              this.appContext.filesDir;
              this.getUIContext().getPromptAction().showToast({
                message: `${JSON.stringify(this.appContext.filesDir)}`
              });
            })

          // Indicates the application database directory.
          Button($r('app.string.database_dir'))
            .fancy(() => {
              this.appContext.databaseDir;
              this.getUIContext().getPromptAction().showToast({
                message: `${JSON.stringify(this.appContext.databaseDir)}`
              });
            })

          // Indicates the application preference directory.
          Button($r('app.string.preferences_dir'))
            .fancy(() => {
              this.appContext.preferencesDir;
              this.getUIContext().getPromptAction().showToast({
                message: `${JSON.stringify(this.appContext.preferencesDir)}`
              });
            })

          // Indicates the directory of the application distribution file,
          // which corresponds to the getOrCreateDistributedDir() method of the FA model.
          Button($r('app.string.distributed_files_dir'))
            .fancy(() => {
              this.appContext.distributedFilesDir;
              this.getUIContext().getPromptAction().showToast({
                message: `${JSON.stringify(this.appContext.distributedFilesDir)}`
              });
            })

          // Indicates the screen orientation of the current device. Corresponding to getDisplayOrientation() of FA
          Button($r('app.string.direction'))
            .fancy(() => {
              this.appContext.config.direction;
              this.getUIContext().getPromptAction().showToast({
                message: `${JSON.stringify(this.appContext.config.direction)}`
              });
            })

          // Indicates the file area.
          Button($r('app.string.area'))
            .fancy(() => {
              this.appContext.area;
              this.getUIContext().getPromptAction().showToast({
                message: `${JSON.stringify(this.appContext.area)}`
              });
            })

          // Indicates whether the context is FA mode or phase mode.
          Button($r('app.string.stage_mode'))
            .fancy(() => {
              this.appContext.stageMode;
              this.getUIContext().getPromptAction().showToast({
                message: `${JSON.stringify(this.appContext.stageMode)}`
              });
            })

          // Obtains application context information,
          // which corresponds to the getApplicationContext() method of the FA model.
          Button($r('app.string.get_application_context'))
            .fancy(() => {
              this.appContext.getApplicationContext();
              this.getUIContext().getPromptAction().showToast({
                message: `${JSON.stringify(this.appContext.getApplicationContext())}`
              });
            })

          // Obtains the bundle name of the current ability, corresponding to getBundleName() of the FA model.
          Button($r('app.string.bundle_name'))
            .fancy(() => {
              this.appContext.abilityInfo.bundleName;
              this.getUIContext().getPromptAction().showToast({
                message: `${JSON.stringify(this.appContext.abilityInfo.bundleName)}`
              });
            })

          // Obtains information about the current process, including the process name,
          // corresponding to getProcessInfo() of the FA model.
          Button($r('app.string.description_id'))
            .fancy(() => {
              this.appContext.abilityInfo.descriptionId;
              this.getUIContext().getPromptAction().showToast({
                message: `${JSON.stringify(this.appContext.abilityInfo.descriptionId)}`
              });
            })

          // Obtains information about the current process,
          // including the process ID, corresponding to getProcessInfo() of the FA model.
          Button($r('app.string.name'))
            .fancy(() => {
              this.appContext.abilityInfo.name;
              this.getUIContext().getPromptAction().showToast({
                message: `${JSON.stringify(this.appContext.abilityInfo.name)}`
              });
            })
        }
        .width('100%')
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
    .padding({ left: '3%', right: '3%' })
  }

  aboutToAppear() {
    this.appContext = this.getUIContext().getHostContext()! as common.UIAbilityContext;
    this.abilityContext = new AbilityContextController(this.appContext, this.getUIContext());
  }
}

@Extend(Button)
function fancy(click: (event?: ClickEvent) => void) {
  .width('60%')
  .height(40)
  .align(Alignment.Center)
  .margin({ top: 30 })
  .onClick(click)
}