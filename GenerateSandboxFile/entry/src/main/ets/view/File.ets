/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { common } from '@kit.AbilityKit';
import { fileIo as fs, ListFileOptions } from '@kit.CoreFileKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Component
export struct File {
  @State fileList: string = '';
  @State preferenceList: string = '';
  @State rdbList: string = '';
  @State kvStoreList: string = '';

  aboutToAppear() {
    let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    let filesDir = context.filesDir;
    let listFileOption: ListFileOptions = {
      recursion: true,
      listNum: 0,
      filter: {
        suffix: ['.png', '.jpg', '.txt'],
        displayName: ['test*'],
        fileSizeOver: 0,
        lastModifiedAfter: new Date(0).getTime()
      }
    };
    try {
      let files = fs.listFileSync(filesDir, listFileOption);
      for (let i = 0; i < files.length; i++) {
        this.fileList = JSON.stringify(files[i])
      }
    } catch (e) {
      hilog.info(0x0000, 'GenerateSandboxFile', `listFileSync error ${JSON.stringify(e)}`);
    }

    let preferencesDir = context.preferencesDir;
    let listPreferencesOption: ListFileOptions = {
      recursion: true,
      listNum: 0,
      filter: {
        // suffix: [],
        displayName: ['myStore*'],
        fileSizeOver: 0,
        lastModifiedAfter: new Date(0).getTime()
      }
    };
    try {
      let preferences = fs.listFileSync(preferencesDir, listPreferencesOption);
      for (let i = 0; i < preferences.length; i++) {
        this.preferenceList = JSON.stringify(preferences[i])
      }
    } catch (e) {
      hilog.info(0x0000, 'GenerateSandboxFile', `listFileSync error ${JSON.stringify(e)}`);
    }

    let rdbDir = context.databaseDir;
    let listRdbOption: ListFileOptions = {
      recursion: true,
      listNum: 0,
      filter: {
        suffix: ['.db'],
        displayName: ['RdbTest*'],
        fileSizeOver: 0,
        lastModifiedAfter: new Date(0).getTime()
      }
    };
    try {
      let rdb = fs.listFileSync(rdbDir, listRdbOption);
      for (let i = 0; i < rdb.length; i++) {
        this.rdbList = JSON.stringify(rdb[i])
      }
    } catch (e) {
      hilog.info(0x0000, 'GenerateSandboxFile', `listFileSync error ${JSON.stringify(e)}`);
    }

    let kvStoreDir = context.databaseDir;
    let listKvStoreOption: ListFileOptions = {
      recursion: true,
      listNum: 0,
      filter: {
        suffix: ['.db'],
        displayName: ['gen_natural_store*'],
        fileSizeOver: 0,
        lastModifiedAfter: new Date(0).getTime()
      }
    };
    try {
      let kvStores = fs.listFileSync(kvStoreDir, listKvStoreOption);
      for (let i = 0; i < kvStores.length; i++) {
        this.kvStoreList = JSON.stringify(kvStores[i])
      }
    } catch (e) {
      hilog.info(0x0000, 'GenerateSandboxFile', `listFileSync error ${JSON.stringify(e)}`);
    }
  }

  build() {
    NavDestination() {
      Flex({ direction: FlexDirection.Row }) {
        Column({ space: 12 }) {
          Text($r('app.string.txt1'))
            .width('100%')
            .padding({ left: '16', top: '8' })
            .fontWeight(FontWeight.Medium)
            .fontSize(18)

          TextArea({ text: this.fileList })
            .textAlign(TextAlign.Start)
            .margin({ left: '16', right: '16' })

          Text($r('app.string.txt2'))
            .textAlign(TextAlign.Start)
            .width('100%')
            .padding({ left: '16' })
            .fontWeight(FontWeight.Medium)
            .fontSize(18)

          TextArea({ text: this.preferenceList })
            .textAlign(TextAlign.Start)
            .margin({ left: '16', right: '16' })

          Text($r('app.string.txt3'))
            .textAlign(TextAlign.Start)
            .width('100%')
            .padding({ left: '16' })
            .fontWeight(FontWeight.Medium)
            .fontSize(18)

          TextArea({ text: this.rdbList })
            .textAlign(TextAlign.Start)
            .margin({ left: '16', right: '16' })

          Text($r('app.string.txt4'))
            .textAlign(TextAlign.Start)
            .width('100%')
            .padding({ left: '16' })
            .fontWeight(FontWeight.Medium)
            .fontSize(18)

          TextArea({ text: this.kvStoreList })
            .textAlign(TextAlign.Start)
            .margin({ left: '16', right: '16' })
            .enableAutoFill(true)
        }
      }
    }
    .title($r('app.string.tab3'))
  }
}