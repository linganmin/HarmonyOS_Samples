import { BackupExtensionAbility, BundleVersion } from '@kit.CoreFileKit';
import { Logger } from '../common/util/Logger';

export default class EntryBackupAbility extends BackupExtensionAbility {
  async onBackup() {
    Logger.info('onBackup ok');
    await Promise.resolve();
  }

  async onRestore(bundleVersion: BundleVersion) {
    Logger.info('onRestore ok %{public}s', JSON.stringify(bundleVersion));
    await Promise.resolve();
  }
}