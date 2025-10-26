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

#ifndef APP_CONFIG_H
#define APP_CONFIG_H

struct AppConfig {
    static AppConfig &GetInstance()
    {
        static AppConfig config_;
        return config_;
    }
    
public:
    bool GetAudioValue();
    void SetAudioValue(bool value);
    
private:
    bool bAudio_ = true;
};

#endif  // APP_CONFIG_H