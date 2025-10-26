/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

// FAQ:如何解决三方包require语句报错
// [Start requireTest]
let test = require("Module/src/test")
// [Start requireTest]

// [Start requireModule]
let module = require("Module")
// [End requireModule]

// [Start Buffer]
import {Buffer} from 'buffer/'
// [End Buffer]