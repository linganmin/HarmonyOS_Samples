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
 * 最佳实践：应用安全编码实践
 * 场景三十三：建议应用软件应包含的签名信息需要真实有效错误示例
 */
// [Start sign_info_error]
10-11 17:51:53 WARN  - Missing parameter: outproof
10-11 17:51:53 INFO  - Find Hap Signing Block success, version: 3, block count: 2
10-11 17:51:54 INFO  - +++++++++++++++++++++++++++certificate #0 +++++++++++++++++++++++++++++++
10-11 17:51:54 INFO  - Subject: C=CN, O=Organization, OU=Unit, CN=ide_demo_app // CN字段无法标识开发组织
10-11 17:51:54 INFO  - Issuer: CN=OpenHarmony Application CA, OU=OpenHarmony Team, O=OpenHarmony, C=CN  
// [End sign_info_error]
/**
 * 最佳实践：应用安全编码实践
 * 场景三十二：建议应用软件应包含的签名信息需要真实有效
 */
// [Start sign_info]
10-11 17:51:54 INFO  - Issuer: CN=OpenHarmony Application CA, OU=OpenHarmony Team, O=OpenHarmony, C=CN  
10-11 17:52:21 WARN  - Missing parameter: outproof
10-11 17:52:21 INFO  - Find Hap Signing Block success, version: 3, block count: 2
10-11 17:52:21 INFO  - +++++++++++++++++++++++++++certificate #0 +++++++++++++++++++++++++++++++
10-11 17:52:21 INFO  - Subject: CN=应用名称, OU=开发者组织/公司/部门, O=开发者组织/公司/部门, C=CN // CN字段标识开发组织
// [End sign_info]