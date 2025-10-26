import type AbilityConstant from "@ohos:app.ability.AbilityConstant";
import UIAbility from "@ohos:app.ability.UIAbility";
import type Want from "@ohos:app.ability.Want";
import hilog from "@ohos:hilog";
import type window from "@ohos:window";
import hiai from "@app:com.huawei.canndemo/entry/entry";
export default class EntryAbility extends UIAbility {
    onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
        let ret = hiai.InitLabels(this.context.resourceManager);
        if (ret == 0) {
            hilog.info(0x0000, 'CANNDemo', 'Succeeded in initing labels');
        }
        else {
            hilog.error(0x0000, 'CANNDemo', 'Failed to init labels');
        }
    }
    onDestroy() {
        // let ret : number = hiai.UnloadModel();  // Unloading a Model
        // if (ret == 0) {
        //   hilog.info(0x0000, 'CANNDemo', 'Succeeded in unloading model');
        // } else {
        //   hilog.error(0x0000, 'CANNDemo', 'Failed to unload model');
        // }
    }
    onWindowStageCreate(windowStage: window.WindowStage) {
        // Main window is created, set main page for this ability
        windowStage.loadContent('pages/Index', (err, data) => {
            if (err.code) {
                hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
                return;
            }
            hilog.info(0x0000, 'testTag', 'Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');
        });
    }
    onWindowStageDestroy() {
        // Main window is destroyed, release UI related resources
        hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
    }
    onForeground() {
        // Ability has brought to foreground
        hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
    }
    onBackground() {
        // Ability has back to background
        hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
    }
}
;
