// [Start listen_memory_change]
import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { LRUCacheUtil } from '../utils/LRUCacheUtil';

export default class EntryAbility extends UIAbility {
  // Monitor the changes in memory
  onMemoryLevel(level: AbilityConstant.MemoryLevel): void {
    // Execute memory management policies according to changes in memory
    if (level === AbilityConstant.MemoryLevel.MEMORY_LEVEL_CRITICAL) {
      console.log('The memory of device is critical, release memory.');
      if (!LRUCacheUtil.getInstance().isEmpty()) {
        LRUCacheUtil.getInstance().clearCache();
      }
    }
  }

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }
};
// [End listen_memory_change]