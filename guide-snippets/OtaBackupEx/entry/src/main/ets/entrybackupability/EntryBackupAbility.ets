// [Start backup_service_ex]
import { BackupExtensionAbility, BundleVersion } from '@kit.CoreFileKit';

const TAG = `BackupExtensionAbility`;

interface ErrorInfo {
  type: string,
  errorCode: number,
  errorInfo: string
}

interface DetailInfo {
  type: string,
  detail: string
}

export default class EntryBackupAbility extends BackupExtensionAbility {
  async onBackup() {
    console.info(TAG, 'onBackup ok');
  }

  async onRestoreEx(bundleVersion: BundleVersion, restoreInfo: string): Promise<string> {
    console.info(TAG, `onRestoreEx ok ${JSON.stringify(bundleVersion)}`);
    let errorInfo: ErrorInfo = {
      type: "ErrorInfo",
      errorCode: 0,
      errorInfo: "app diy error info"
    }
    if (bundleVersion.name.startsWith("0.0.0.0")){
      // 在此处实现终端设备从HarmonyOS 4.x到HarmonyOS NEXT的应用数据处理。
      // 涉及异步操作请进行同步等待
      console.info(TAG, `HarmonyOS to HarmonyOS NEXT scenario`);

      // 如果升级场景与克隆场景没有差异化数据处理诉求，此处可以忽略。
      if (this.IsOtaScenario(restoreInfo)) {
        // 在此处实现终端设备从HarmonyOS 4.x到HarmonyOS NEXT升级场景的特有数据处理。无特殊要求，此处可以忽略。
        console.info(TAG, `Ota Scenario`)
      } else {
        // 在此处实现终端设备从HarmonyOS 4.x到HarmonyOS NEXT克隆场景的特有数据处理。无特殊要求，此处可以忽略。
        console.info(TAG, `Clone Scenario`)
      }
    } else {
      // 在此处实现从HarmonyOS NEXT设备迁移到HarmonyOS NEXT设备后，应用数据的处理。无特殊要求，可以空实现。
      // 涉及异步操作请进行同步等待
      console.info(TAG, `Other scenario`);
    }
    return JSON.stringify(errorInfo);
  }

  /**
   * 判断是否是升级场景
   * @param restoreInfo 预留字段，应用恢复过程中需要的扩展参数
   * @returns 升级场景返回true，否则返回false
   */
  IsOtaScenario(restoreInfo: string): boolean {
    let details:Array<DetailInfo> = JSON.parse(restoreInfo);
    return details.some((detailInfo) => {
      //设备从HarmonyOS 4.x升级到HarmonyOS NEXT/5.0.x场景判断条件
      return detailInfo.type == 'isSameDevice' && detailInfo.detail == 'true';
    });
  }
}
// [End backup_service_ex]