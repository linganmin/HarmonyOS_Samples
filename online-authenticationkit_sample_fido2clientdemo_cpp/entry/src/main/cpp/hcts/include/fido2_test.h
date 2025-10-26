/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 */

#ifndef FIDO2_TEST_H
#define FIDO2_TEST_H

#include <cstdint>
#include <string>

namespace OHOS {
namespace OnlineAuthenticationKit {

//int32_t HCTS_ConnectService();
std::int64_t HCTS_ConnectService_getClientCapability();
std::int64_t HCTS_ConnectService_getPlatformAuthenticator();
std::string HCTS_ConnectService_Reg(std::string params);
std::string HCTS_ConnectService_Auth(std::string params);


}; // namespace FG
}; // namespace OHOS

#endif // FIDO2_TEST_H
