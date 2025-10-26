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
import { hilog } from '@kit.PerformanceAnalysisKit';
const IAP_LOG_DOMIN = 0x0ffe;

export default class Logger {
    prefix: string;

    constructor (module: string) {
        this.prefix = "[WalletKitDemo." + module + "] ";
    }

    log(message, ...args: any[]) {
        hilog.info(IAP_LOG_DOMIN, this.prefix, message, args);
    }

    info(message, ...args: any[]) {
        hilog.info(IAP_LOG_DOMIN, this.prefix, message, args);
    }

    debug(message, ...args: any[]) {
        hilog.debug(IAP_LOG_DOMIN, this.prefix, message, args);
    }

    warn(message, ...args: any[]) {
        hilog.warn(IAP_LOG_DOMIN, this.prefix, message, args);
    }

    error(message, ...args: any[]) {
        hilog.error(IAP_LOG_DOMIN, this.prefix, message, args);
    }

    err(message, ...args: any[]) {
        hilog.error(IAP_LOG_DOMIN, this.prefix, message, args);
    }

    log4Json(message, ...args: any[]) {
        let args4Json = []
        for (let arg of args) {
            args4Json.push(JSON.stringify(arg))
        }
        hilog.debug(IAP_LOG_DOMIN, this.prefix, message + args4Json)
    }

    printJsonObj(obj) {
        var str = JSON.stringify(obj, null, 4);
        for (var i = 0; i < str.length / 512; i++) {
            hilog.debug(IAP_LOG_DOMIN, this.prefix, str.slice(i * 512, (i + 1) * 512));
        }
    }
}
