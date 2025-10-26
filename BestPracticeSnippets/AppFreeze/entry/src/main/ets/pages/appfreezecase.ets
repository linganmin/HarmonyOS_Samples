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
/**
 * 最佳实践：应用冻屏优化建议
 */

import fs from '@ohos.file.fs';

@Component
struct ItemType {
    @State xxx1 : number = 1;
    @State xxx2 : number = 2;
    @State themeStyle : string = "xxx";

    build() {}
}

// [Start appfreeze_advise2]
function getForeachKey(item : ItemType) : string {
    // ...
    return `${item.xxx2}${item.xxx2}...${item.themeStyle}`;
} // 这部分逻辑如果较为耗时，执行次数多，总时长就是发生冻屏的耗时操作
// [End appfreeze_advise2]

/**
 * 最佳实践：应用冻屏优化建议
 */

// [Start appfreeze_advise3]
function xxxFunction1(fileUris : string[]): void {
    // ...
    for (const fileuri of fileUris) {
        let file = fs.openSync(fileuri, fs.OpenMode.READ_ONLY);
        // ...
    }
    // ...
} // 如果使用同步操作，需要考虑到容器弱网或无网等极端情况发生
// [End appfreeze_advise3]

// [Start appfreeze_case_3_positive]
async function xxxFunction2(fileUris : string[]) : Promise<void> {
    // ...
    AppStorage.setOrCreate<boolean>('isLoadingPic', true); // 用于页面load效果展示
    for (const fileuri of fileUris) {
        let file = await fs.openSync(fileuri, fs.OpenMode.READ_ONLY); // 改为异步加载
        // ...
    }
    // ...
}
// [End appfreeze_case_3_positive]