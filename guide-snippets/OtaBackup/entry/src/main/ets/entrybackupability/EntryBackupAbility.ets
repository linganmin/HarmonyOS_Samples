// [Start backup_service]
import { BackupExtensionAbility, BundleVersion } from '@kit.CoreFileKit';

const TAG = `EntryBackupAbility`;

/**
 * serviceExt进程入口
 */
export default class EntryBackupAbility extends  BackupExtensionAbility {
  async onBackup () {
    console.info(TAG,`onBackup ok`);
    await Promise.resolve();
  }

  /**
   * 数据恢复处理接口。接口是同步接口，其内部所有的异步操作请进行同步等待。
   *
   * @param bundleVersion 版本信息
   */
  async onRestore (bundleVersion : BundleVersion): Promise<void> {
    console.info(TAG, `onRestore ok ${JSON.stringify(bundleVersion)}`);
    //bundleVersion.name的前缀为“0.0.0.0”时，表示终端设备从HarmonyOS升级到HarmonyOS NEXT数据迁移场景
    if (bundleVersion.name.startsWith("0.0.0.0")){
      // 在此处实现终端设备从HarmonyOS 4.x升级到HarmonyOS NEXT后，应用数据的转换和迁移
      // 涉及异步操作请进行同步等待
      console.info(TAG, `HarmonyOS to HarmonyOS NEXT scenario`);
    } else {
      // 在此处实现从HarmonyOS NEXT设备迁移到HarmonyOS NEXT设备后，应用数据的处理。无特殊要求，可以空实现
      // 涉及异步操作请进行同步等待
      console.info(TAG, `Other scenario`);
    }
  }
}
// [End backup_service]