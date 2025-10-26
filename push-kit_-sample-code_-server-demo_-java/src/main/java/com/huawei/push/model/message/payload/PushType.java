/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2024. All rights reserved.
 *
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

package com.huawei.push.model.message.payload;

/**
 * PushType.
 */
public enum PushType {
    ALERT(0), FORM(1), EXTENSION(2), LIVE_VIEW(7), VOIP(10);

    private final int val;

    PushType(int val) {
        this.val = val;
    }

    public int getVal() {
        return val;
    }
}
