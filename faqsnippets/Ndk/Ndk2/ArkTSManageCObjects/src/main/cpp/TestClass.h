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
/**
 * FAQ: 如何在ArkTS侧管理Native侧的C++对象
 */
#ifndef MYAPPLICATION_TESTCLASS_H
#define MYAPPLICATION_TESTCLASS_H
// [Start test_class_manager_h]
class TestClass { 
public: 
    int GetValue() { 
        return this->value; 
    } 
    void SetValue(int value) { 
        this->value = value; 
    } 
private: 
    int value = 999; 
};
// [End test_class_manager_h]
#endif //MYAPPLICATION_TESTCLASS_H
