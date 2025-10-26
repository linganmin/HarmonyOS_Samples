/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 */
#include "fido2_test.h"
#include "OnlineAuthenticationKit/fido2_api.h"
#include "log.h"
#include "fido2_serializer.h"

namespace OHOS {
namespace OnlineAuthenticationKit {

std::int64_t HCTS_ConnectService_getClientCapability()
{
    LOGI("[fido2ndk] start getClientCapability...");
    FIDO2_CapabilityArray* capability = nullptr;
    FIDO2_ErrorCode ret = HMS_FIDO2_getClientCapability(&capability);
    LOGI("[fido2ndk] capability isSupported %{public}d, capability %{public}d", (*capability).capability[0].isSupported, (*capability).capability[1].capability);
    LOGI("[fido2ndk] getClientCapability success...");
    return ret;
}

std::int64_t HCTS_ConnectService_getPlatformAuthenticator()
{
    LOGI("[fido2ndk] start getPlatformAuthenticator...");
    FIDO2_AuthenticatorMetadataArray *authenticators = nullptr;
    FIDO2_ErrorCode ret = HMS_FIDO2_getPlatformAuthenticator(&authenticators);
    LOGI("[fido2ndk] PlatformAuthenticator aaguid %{public}d, uvm %{public}d.", (*authenticators).authenticators[0].aaguid.val[0],(*authenticators).authenticators[1].uvm);
    LOGI("[fido2ndk] getPlatformAuthenticator success...");
    return ret;
}

std::string HCTS_ConnectService_Reg(std::string params)
{
    FIDO2_CredentialCreationOptions options;
    HMS_FIDO2_initCreationOptions(&options);
    LOGI("[fido2ndk] params: %{public}s", params.c_str());
    json optionJson = json::parse(params);
    options = optionJson;
    FIDO2_TokenBinding tokenBinding;
    HMS_FIDO2_initTokenBinding(&tokenBinding);
    char *origin = "https://www.fidotest.com";
    FIDO2_PublicKeyAttestationCredential* publicKeyAttestationCredential;
    FIDO2_ErrorCode ret = HMS_FIDO2_register(options, tokenBinding,origin, &publicKeyAttestationCredential);
    if (ret != FIDO2_SUCCESS) {
        LOGI("[fido2ndk] HMS_FIDO2_register occurred error, ret = %{public}d.", ret);
        return "";
    }
    LOGI("[fido2ndk] HMS_FIDO2_register success!");
    json out_json = *publicKeyAttestationCredential;
    return out_json.dump();
}

std::string HCTS_ConnectService_Auth(std::string params)
{
    FIDO2_CredentialRequestOptions options;
    HMS_FIDO2_initRequestOptions(&options);
    LOGI("[fido2ndk] mediation: %{public}d", options.mediation);
    
    LOGI("[fido2ndk] params: %{public}s", params.c_str());
    json optionJson = json::parse(params);
    options = optionJson;
    LOGI("[fido2ndk] mediation: %{public}d", options.mediation);
    
    FIDO2_TokenBinding tokenBinding;
    HMS_FIDO2_initTokenBinding(&tokenBinding);
    char *origin = "https://www.fidotest.com";
    
    
    FIDO2_PublicKeyAssertionCredential* assertionCredential;
    FIDO2_ErrorCode ret = HMS_FIDO2_authenticate(options, tokenBinding, origin, &assertionCredential);
    if (ret != FIDO2_SUCCESS) {
        LOGI("[fido2ndk] HMS_FIDO2_authenticate occurred error, ret = %{public}d.", ret);
        return "";
    }
    json out_json = *assertionCredential;
    LOGI("[fido2ndk] HMS_FIDO2_authenticate success!");
    return out_json.dump();
}

}; // namespace OnlineAuthenticationKit
}; // namespace OHOS