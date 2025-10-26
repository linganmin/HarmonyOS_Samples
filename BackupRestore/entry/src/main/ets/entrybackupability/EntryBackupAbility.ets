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

import { hilog } from '@kit.PerformanceAnalysisKit';
import { BackupExtensionAbility, BundleVersion } from '@kit.CoreFileKit';
import FileTransferManager from '../restore/fileMigrate/FileTransferManager';
import DbTransferManager from '../restore/db/DbTransferManager';
import SpTransferManager from '../restore/sp/SpTransferManager';

export default class EntryBackupAbility extends BackupExtensionAbility {
  async onBackup() {
    hilog.info(0x0000, 'BackupRestore', 'onBackup ok');
  }

  async onRestore(bundleVersion: BundleVersion) {
    hilog.info(0x0000, 'BackupRestore', `onRestore, bundleVersion = ${JSON.stringify(bundleVersion)}`);
    if (bundleVersion.name === '0.0.0.0') {
      await Promise.all([
        // File migration
        new FileTransferManager().transfer(this.context),

        // Database conversion
        new DbTransferManager().transfer(this.context),

        // Conversion of preferences file
        new SpTransferManager().transfer(this.context)
      ]);
      hilog.info(0x0000, 'BackupRestore', 'onRestore, finish');
    }
  }
}