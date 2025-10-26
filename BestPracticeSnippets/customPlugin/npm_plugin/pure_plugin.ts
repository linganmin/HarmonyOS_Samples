/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

// [Start custom_plugin]
import fs from 'fs';

interface OhPackage {
  name: string;
  version: number;
  description: string;
  author: string;
}

export function renameHarTask(str?: string) {
  return {
    pluginId: 'RenameHarTaskID',
    apply(pluginContext) {
      pluginContext.registerTask({
        // Write custom tasks
        name: 'renameHarTask',
        run: (taskContext) => {
          // Read oh-package.json5 and parse the version
          const packageFile = taskContext.modulePath + '\\oh-package.json5';
          let fileContent = fs.readFileSync(packageFile, 'utf8');
          const content: OhPackage = JSON.parse(fileContent);
          const version = content.version;
          const author = content.author;
          const sourceFile =
            taskContext.modulePath + '\\build\\default\\outputs\\default\\' + taskContext.moduleName + '.har';
          const targetPath = taskContext.modulePath + '\\build\\default\\outputs\\target\\';
          const targetFile = targetPath
            + taskContext.moduleName + '-' + version + '-' + author + '.har';

          // Create Directory
          fs.mkdir(targetPath, { recursive: true }, (err) => {
            if (err) {
              throw err;
            }
            // Move and modify product file names
            fs.rename(sourceFile, targetFile, (err) => {
            });
          });
        },
        // Confirm custom task insertion position
        dependencies: ['default@PackageHar'],
        postDependencies: ['assembleHar']
      })
    }
  }
}
// [End custom_plugin]