/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 */

#include <log.h>
#include "fido2_serializer.h"

#define JSON_STRING_TO_CHAR_PTR(j, key, dest) \
    do { \
        if (j.contains(key)) { \
            std::string dataStr = j.at(key).get<std::string>(); \
            char *keyBuf = new char[dataStr.size() + 1]; \
            std::strcpy(keyBuf, dataStr.c_str()); \
            dest = keyBuf; \
        } \
    } while (0)


#define JSON_GET_TO_STRUCT(j, key, field) \
    if (j.contains(key)) { \
        j.at(key).get_to(field); \
    } \


static void InitUint8Buff(Uint8Buff *buff)
{
    buff->length = 0;
    buff->val = NULL;
}

void to_json(json &j, const Uint8Buff &arr)
{
    std::vector<uint8_t> vec(arr.val, arr.val + arr.length);
    for (uint32_t i = 0; i < arr.length; i++) {
        j[std::to_string(i)] = arr.val[i];
    }
}

void to_json(json &j, const FIDO2_CredentialMediationRequirement &meta)
{
    switch (meta) {
        case FIDO2_SILENT:
            j = "silent";
            break;
        case FIDO2_OPTIONAL:
            j = "optional";
            break;
        case FIDO2_CONDITIONAL:
            j = "conditional";
            break;
        case FIDO2_MEDIATION_REQUIRED:
            j = "required";
            break;
        default:
            throw std::runtime_error("Invalid FIDO2_CredentialMediationRequirement value");
    }
}

void to_json(json &j, const FIDO2_PublicKeyCredentialType &meta)
{
    switch (meta) {
        case FIDO2_PUBLIC_KEY:
            j = "public-key";
            break;
        default:
            throw std::runtime_error("Invalid FIDO2_CredentialMediationRequirement value");
    }
}

void to_json(json &j, const FIDO2_UserVerificationRequirement &meta)
{
    switch (meta) {
        case FIDO2_REQUIRED:
            j = "required";
            break;
        case FIDO2_PREFERRED:
            j = "preferred";
            break;
        case FIDO2_DISCOURAGED:
            j = "discouraged";
            break;
        default:
            throw std::runtime_error("Invalid FIDO2_UserVerificationRequirement value");
    }
}

void to_json(json &j, const FIDO2_AuthenticatorAttachment &meta)
{
    switch (meta) {
        case FIDO2_PLATFORM:
            j = "platform";
            break;
        case FIDO2_CROSS_PLATFORM:
            j = "cross-platform";
            break;
        default:
            throw std::runtime_error("Invalid FIDO2_AuthenticatorAttachment value");
    }
}

void to_json(json &j, const FIDO2_AttestationConveyancePreference &meta)
{
    switch (meta) {
        case FIDO2_NONE:
            j = "none";
            break;
        case FIDO2_INDIRECT:
            j = "indirect";
            break;
        case FIDO2_DIRECT:
            j = "direct";
            break;
        case FIDO2_ENTERPRISE:
            j = "enterprise";
            break;
        default:
            throw std::runtime_error("Invalid FIDO2_AttestationConveyancePreference value");
    }
}

void to_json(json &j, const FIDO2_TokenBinding &meta)
{
    j = json();
    if (meta.status != static_cast<FIDO2_TokenBindingStatus>(-1)) {
        switch (meta.status) {
            case FIDO2_PRESENT:
                j["status"] = "present";
                break;
            case FIDO2_SUPPORTED:
                j["status"] = "supported";
                break;
            default:
                throw std::runtime_error("Invalid FIDO2_TokenBindingStatus value");
        }
    }
    if (meta.id != nullptr) {
        j["id"] = meta.id;
    }
}

void to_json(json &j, const FIDO2_PublicKeyCredentialRpEntity &meta)
{
    j = json();
    if (meta.id != nullptr) {
        j["id"] = meta.id;
    }
    if (meta.name != nullptr) {
        j["name"] = meta.name;
    }
}

void to_json(json &j, const FIDO2_PublicKeyCredentialUserEntity &meta)
{
    j = json();
    if (meta.id.val != nullptr) {
        j["id"] = meta.id;
    }
    if (meta.displayName != nullptr) {
        j["displayName"] = meta.displayName;
    }
    if (meta.name != nullptr) {
        j["name"] = meta.name;
    }
}

void to_json(json &j, const FIDO2_PublicKeyCredentialParameters &meta)
{
    j = json();
    j["type"] = meta.type;
    j["alg"] = meta.alg;
}

void to_json(json &j, const FIDO2_CredentialCreationOptionArray &arr)
{
    std::vector<FIDO2_PublicKeyCredentialParameters> vec(
        arr.pubKeyCredParams, arr.pubKeyCredParams + arr.pubKeyCredParamNum);
    j = json(vec);
}

void to_json(json &j, const FIDO2_AuthenticatorTransportArray &arr)
{
    std::vector<std::string> vec;
    for (uint32_t i = 0; i < arr.transportNum; i++) {
        switch (arr.transports[i]) {
            case FIDO2_USB:
                vec.push_back("usb");
                break;
            case FIDO2_NFC:
                vec.push_back("nfc");
                break;
            case FIDO2_BLE:
                vec.push_back("ble");
                break;
            case FIDO2_SMART_CARD:
                vec.push_back("smart-card");
                break;
            case FIDO2_HYBRID:
                vec.push_back("hybrid");
                break;
            case FIDO2_INTERNAL:
                vec.push_back("internal");
                break;
            default:
                throw std::runtime_error("Invalid FIDO2_AuthenticatorTransport value");
        }
    }
    j = json(vec);
}

void to_json(json &j, const FIDO2_PublicKeyCredentialDescriptor &meta)
{
    j = json();
    j["type"] = meta.type;
    if (meta.id.val != nullptr) {
        j["id"] = meta.id;
    }
    if (meta.transports.transports != nullptr) {
        j["transports"] = meta.transports;
    }
}

void to_json(json &j, const FIDO2_PublicKeyCredentialDescriptorArray &arr)
{
    std::vector<FIDO2_PublicKeyCredentialDescriptor> vec(
        arr.allowCredentials, arr.allowCredentials + arr.allowCredentiallNum);
    j = json(vec);
}

void to_json(json &j, const FIDO2_AuthenticatorSelectionCriteria &meta)
{
    j = json{
        {"requireResidentKey", meta.requireResidentKey}};
    if (meta.residentKey != nullptr) {
        j["residentKey"] = meta.residentKey;
    }
    j["userVerification"] = meta.userVerification;
    j["authenticatorAttachment"] = meta.authenticatorAttachment;
}

void to_json(json &j, const FIDO2_AttestationFormatsArray &arr)
{
    std::vector<char *> vec(
        arr.attestationFormats, arr.attestationFormats + arr.attestationFormatsNum);
    j = json(vec);
}

void to_json(json &j, const FIDO2_PublicKeyCredentialHintArray &arr)
{
    std::vector<std::string> vec;
    for (uint32_t i = 0; i < arr.hintNum; i++) {
        switch (arr.hints[i]) {
            case FIDO2_SECURITY_KEY:
                vec.push_back("security-key");
                break;
            case FIDO2_CLIENT_DEVICE:
                vec.push_back("client-device");
                break;
            case FIDO2_HINT_HYBRID:
                vec.push_back("hybrid");
                break;
            default:
                throw std::runtime_error("Invalid FIDO2_PublicKeyCredentialHintArray value");
        }
    }
    j = json(vec);
}

void to_json(json &j, const FIDO2_PublicKeyCredentialCreationOptions &meta)
{
    j = json();
    if (meta.rp.id != nullptr ) {
    }
    j = json{{"rp", meta.rp}, {"user", meta.user}, {"challenge", meta.challenge}, {"pubKeyCredParams", meta.pubKeyCredParams}};
    if (meta.timeout != 0) {
        j["timeout"] = meta.timeout;
    }
    LOGI("fido2ndk excludeCredentials: %{public}d", meta.excludeCredentials.allowCredentiallNum);
    if (meta.excludeCredentials.allowCredentiallNum > 0) {
        j["excludeCredentials"] = meta.excludeCredentials;
    }
    LOGI("fido2ndk excludeCredentials: %{public}d", meta.excludeCredentials.allowCredentiallNum);
    if (meta.authenticatorSelection.requireResidentKey != false) {
        j["authenticatorSelection"] = meta.authenticatorSelection;
    }
    LOGI("fido2ndk excludeCredentials: %{public}d", meta.excludeCredentials.allowCredentiallNum);
    if (meta.hints.hints != nullptr) {
        j["hints"] = meta.hints;
    }
    LOGI("fido2ndk excludeCredentials: %{public}d", meta.excludeCredentials.allowCredentiallNum);
    if (meta.attestation != FIDO2_NONE) {
        j["attestation"] = meta.attestation;
    }
    LOGI("fido2ndk attestationFormatsNum: %{public}d", meta.attestationFormats.attestationFormatsNum);
    if (meta.attestationFormats.attestationFormatsNum > 0) {
        j["attestationFormats"] = meta.attestationFormats;
    }
    LOGI("fido2ndk 1: %{public}d", meta.attestationFormats.attestationFormatsNum);
    if (meta.extensions != nullptr) {
        j["extensions"] = meta.extensions;
    }
}


void to_json(json &j, const FIDO2_CredentialCreationOptions &meta)
{
    j = json();
    switch (meta.mediation) {
        case FIDO2_SILENT:
            j["mediation"] = "silent";
            break;
        case FIDO2_OPTIONAL:
            j["mediation"] = "optional";
            break;
        case FIDO2_CONDITIONAL:
            j["mediation"] = "conditional";
            break;
        case FIDO2_MEDIATION_REQUIRED:
            j["mediation"] = "required";
            break;
        default:
            throw std::runtime_error("Invalid FIDO2_CredentialCreationOptions value");
    }
    j["publicKey"] = meta.publicKey;
}

void to_json(json &j, const FIDO2_PublicKeyCredentialRequestOptions &meta)
{
    j = json();
    if (meta.challenge.val != nullptr) {
        j["challenge"] = meta.challenge;
    }
    if (meta.timeout != 0) {
        j["timeout"] = meta.timeout;
    }
    if (meta.rpId != nullptr) {
        j["rpId"] = meta.rpId;
    }
    if (meta.allowCredentials.allowCredentials != nullptr) {
        j["allowCredentials"] = meta.allowCredentials;
    }
    LOGI("fido2ndk allowCredentials: %{public}d", meta.allowCredentials.allowCredentiallNum);
    if (meta.userVerification != FIDO2_PREFERRED) {
        j["userVerification"] = meta.userVerification;
    }
    if (meta.hints.hints != nullptr) {
        j["hints"] = meta.hints;
    }
    if (meta.extensions != nullptr) {
        j["extensions"] = meta.extensions;
    }
}

void to_json(json &j, const FIDO2_CredentialRequestOptions &meta)
{
    j = json();
    switch (meta.mediation) {
        case FIDO2_SILENT:
            j["mediation"] = "silent";
            break;
        case FIDO2_OPTIONAL:
            j["mediation"] = "optional";
            break;
        case FIDO2_CONDITIONAL:
            j["mediation"] = "conditional";
            break;
        case FIDO2_MEDIATION_REQUIRED:
            j["mediation"] = "required";
            break;
        default:
            throw std::runtime_error("Invalid FIDO2_CredentialRequestOptions value");
    }
    j["publicKey"] = meta.publicKey;
}

void from_json(const json &j, Uint8Buff &arr)
{
    arr.length = j.size();
    LOGI("len: %{public}d", arr.length);
    arr.val = new uint8_t[arr.length];
    for (uint32_t i = 0; i < arr.length; ++i) {
        arr.val[i] = j.at(std::to_string(i)).get<uint8_t>();
    }
}

FIDO2_ClientCapability capability_from_string(const std::string& str) {
    if (str == "conditionalCreate") return FIDO2_CONDITIONAL_CREATE;
    if (str == "conditionalGet") return FIDO2_CONDITIONAL_GET;
    if (str == "hybridTransport") return FIDO2_HYBRID_TRANSPORT;
    if (str == "passkeyPlatformAuthenticator") return FIDO2_PASSKEY_PLATFORM_AUTHENTICATOR;
    if (str == "userVerifyingPlatformAuthenticator") return FIDO2_USER_VERIFYING_PLATFORM_AUTHENTICATOR;
    if (str == "relatedOrigins") return FIDO2_RELATED_ORIGINS;
    if (str == "signalAllAcceptedCredentials") return FIDO2_SIGNAL_ALL_ACCEPTED_CREDENTIALS;
    if (str == "signalCurrentUserDetails") return FIDO2_SIGNAL_CURRENT_USER_DETAILS;
    if (str == "signalUnknownCredential") return FIDO2_SIGNAL_UNKNOWN_CREDENTIAL;
    if (str == "extension:uvi") return FIDO2_EXTENSION_UVI;
    throw std::runtime_error("Invalid FIDO2_ClientCapability key: " + str);
}
void from_json(const nlohmann::json& j, FIDO2_CapabilityArray& arr) {
    arr.number = j.size();
    arr.capability = new FIDO2_Capability[arr.number];
    uint32_t idx = 0;
    for (auto it = j.begin(); it != j.end(); ++it, ++idx) {
        arr.capability[idx].capability = capability_from_string(it.key());
        arr.capability[idx].isSupported = it.value().get<bool>();
    }
}

void from_json(const json &j, FIDO2_AuthenticatorAttachment &meta)
{
    LOGI("from_json FIDO2_AuthenticatorAttachment 1");
    std::string authenticatorAttachment = j.get<std::string>();
    LOGI("authenticatorAttachment :%{public}s", authenticatorAttachment.c_str());
    if (authenticatorAttachment == "platform") {
        meta = FIDO2_PLATFORM;
    } else if (authenticatorAttachment == "cross-platform") {
        meta = FIDO2_CROSS_PLATFORM;
    } else {
        throw std::runtime_error("Invalid FIDO2_AuthenticatorAttachment value");
    }
}

 void from_json(const json &j, FIDO2_Uvm &uvm)
 {
     int value = j.get<int>();
     switch (value) {
         case 2:
             uvm = FIDO2_UVM_FINGERPRINT;
             break;
         case 4:
             uvm = FIDO2_UVM_PIN;
             break;
         case 16:
             uvm = FIDO2_UVM_FACEPRINT;
             break;
         default:
             throw std::runtime_error("Invalid FIDO2_Uvm value");
     }
 }

void from_json(const json &j, FIDO2_AuthenticatorMetadata &meta)
{
    JSON_GET_TO_STRUCT(j, "aaguid", meta.aaguid);
    JSON_GET_TO_STRUCT(j, "uvm", meta.uvm);
    JSON_GET_TO_STRUCT(j, "isAvailable", meta.isAvailable);
}

void from_json(const json &j, FIDO2_AuthenticatorMetadataArray &arr)
{
    arr.number = j.size();
    arr.authenticators = new FIDO2_AuthenticatorMetadata[arr.number];
    const auto &json_array = j;
    for (uint32_t i = 0; i < arr.number; ++i) {
        json_array[i].get_to(arr.authenticators[i]);
    }
}

void from_json(const json &j, FIDO2_AuthenticatorTransport &meta)
{
    std::string value = j.get<std::string>();
    LOGI("from_json FIDO2_AuthenticatorTransport %{public}s", value.c_str());
    if (value == "usb") {
        meta = FIDO2_USB;
    } else if (value == "nfc") {
        meta = FIDO2_NFC;
    } else if (value == "ble") {
        meta = FIDO2_BLE;
    } else if (value == "smart-card") {
        meta = FIDO2_SMART_CARD;
    } else if (value == "hybrid") {
        meta = FIDO2_HYBRID;
    } else if (value == "internal") {
        meta = FIDO2_INTERNAL;
    } else {
        throw std::runtime_error("Invalid FIDO2_AuthenticatorTransport value");
    }
}

void from_json(const json &j, FIDO2_CredentialMediationRequirement &meta)
{
    std::string value = j.get<std::string>();
    LOGI("from_json FIDO2_CredentialMediationRequirement %{public}s", value.c_str());
    if (value == "slient") {
        meta = FIDO2_SILENT;
    } else if (value == "optional") {
        meta = FIDO2_OPTIONAL;
    } else if (value == "conditional") {
        meta = FIDO2_CONDITIONAL;
    } else if (value == "required") {
        meta = FIDO2_MEDIATION_REQUIRED;
    } else {
        throw std::runtime_error("Invalid FIDO2_CredentialMediationRequirement value");
    }
}

void from_json(const json &j, FIDO2_AuthenticatorTransportArray &arr)
{
    arr.transportNum = j.size();
    LOGI("transportNum: %{public}d", arr.transportNum);
    arr.transports = new FIDO2_AuthenticatorTransport[arr.transportNum];
    const auto &json_array = j;
    for (uint32_t i = 0; i < arr.transportNum; ++i) {
        json_array[i].get_to(arr.transports[i]);
    }
    LOGI("transportNum down");
}

void from_json(const json &j, FIDO2_AuthenticatorAttestationResponse &meta)
{
    JSON_GET_TO_STRUCT(j, "attestationObject", meta.attestationObject);
    JSON_GET_TO_STRUCT(j, "clientDataJson", meta.clientDataJson);
    JSON_GET_TO_STRUCT(j, "publicKey", meta.publicKey);
    JSON_GET_TO_STRUCT(j, "authenticatorData", meta.authenticatorData);
    JSON_GET_TO_STRUCT(j, "publicKeyAlgorithm", meta.publicKeyAlgorithm);
    JSON_GET_TO_STRUCT(j, "transports", meta.transports);
}

void from_json(const json &j, AuthenticationExtensionsClientOutputs &meta)
{
    meta.placeholder = nullptr;
}

void from_json(const json &j, FIDO2_PublicKeyAttestationCredential &meta)
{
    InitUint8Buff(&(meta.rawId));
    InitUint8Buff(&(meta.response.attestationObject));
    InitUint8Buff(&(meta.response.clientDataJson));
    InitUint8Buff(&(meta.response.publicKey));
    InitUint8Buff(&(meta.response.authenticatorData));
    meta.response.transports.transports = nullptr;
    meta.response.transports.transportNum = 0;
    meta.authenticatorAttachment = FIDO2_PLATFORM;
    meta.id = nullptr;
    meta.type = nullptr;
    meta.clientExtensionResults.placeholder = nullptr;

    JSON_GET_TO_STRUCT(j, "rawId", meta.rawId);
    JSON_GET_TO_STRUCT(j, "response", meta.response);
    JSON_GET_TO_STRUCT(j, "authenticatorAttachment", meta.authenticatorAttachment);
    LOGI("id done");

    JSON_STRING_TO_CHAR_PTR(j, "id", meta.id);
    LOGI("type 0");
    JSON_STRING_TO_CHAR_PTR(j, "type", meta.type);
    LOGI("type done");
}

void from_json(const json &j, FIDO2_AuthenticatorResponse &meta)
{
    JSON_GET_TO_STRUCT(j, "authenticatorData", meta.authenticatorData);
    JSON_GET_TO_STRUCT(j, "signature", meta.signature);
    JSON_GET_TO_STRUCT(j, "userHandle", meta.userHandle);
    JSON_GET_TO_STRUCT(j, "clientDataJson", meta.clientDataJson);
}

void from_json(const json &j, FIDO2_PublicKeyAssertionCredential &meta)
{
    InitUint8Buff(&(meta.rawId));
    meta.id = nullptr;
    meta.type = nullptr;
    InitUint8Buff(&(meta.response.authenticatorData));
    InitUint8Buff(&(meta.response.clientDataJson));
    InitUint8Buff(&(meta.response.signature));
    InitUint8Buff(&(meta.response.userHandle));

    meta.clientExtensionResults.placeholder = nullptr;
    JSON_GET_TO_STRUCT(j, "rawId", meta.rawId);
    JSON_GET_TO_STRUCT(j, "response", meta.response);
    JSON_GET_TO_STRUCT(j, "authenticatorAttachment", meta.authenticatorAttachment);

    JSON_STRING_TO_CHAR_PTR(j, "id", meta.id);
    JSON_STRING_TO_CHAR_PTR(j, "type", meta.type);
}


void from_json(const json &j, FIDO2_PublicKeyCredentialUserEntity &meta)
{
    j["id"].get_to(meta.id);
    JSON_STRING_TO_CHAR_PTR(j, "displayName", meta.displayName);
    JSON_STRING_TO_CHAR_PTR(j, "name", meta.name);
}

void from_json(const json &j, FIDO2_PublicKeyCredentialRpEntity &meta)
{
    JSON_STRING_TO_CHAR_PTR(j, "id", meta.id);
    JSON_STRING_TO_CHAR_PTR(j, "name", meta.name);
}

void from_json(const json &j, FIDO2_PublicKeyCredentialParameters &meta)
{
    if (j["type"] == "public-key") {
        meta.type = FIDO2_PUBLIC_KEY;
    }
    j["alg"].get_to(meta.alg);
}

void from_json(const json &j, FIDO2_CredentialCreationOptionArray &arr)
{
    arr.pubKeyCredParamNum = j.size();
    arr.pubKeyCredParams = new FIDO2_PublicKeyCredentialParameters[arr.pubKeyCredParamNum];
    const auto &json_array = j;
    for (uint32_t i = 0; i < arr.pubKeyCredParamNum; ++i) {
        json_array[i].get_to(arr.pubKeyCredParams[i]);
    }
}

void from_json(const json &j, FIDO2_PublicKeyCredentialDescriptor &meta)
{
    if (j["type"] == "public-key") {
        meta.type = FIDO2_PUBLIC_KEY;
    }
    j["id"].get_to(meta.id);
    j["transports"].get_to(meta.transports);
}

void from_json(const json &j, FIDO2_PublicKeyCredentialDescriptorArray &arr)
{
    arr.allowCredentiallNum = j.size();
    arr.allowCredentials = new FIDO2_PublicKeyCredentialDescriptor[arr.allowCredentiallNum];
    const auto &json_array = j;
    for (uint32_t i = 0; i < arr.allowCredentiallNum; ++i) {
        json_array[i].get_to(arr.allowCredentials[i]);
    }
}

void from_json(const json &j, FIDO2_UserVerificationRequirement &meta)
{
    std::string value = j.get<std::string>();
    if (value == "required") {
        meta = FIDO2_REQUIRED;
    } else if (value == "preferred") {
        meta = FIDO2_PREFERRED;
    } else if (value == "discourage") {
        meta = FIDO2_DISCOURAGED;
    } else {
        throw std::runtime_error("Invalid FIDO2_ClientCapability value");
    }
}

void from_json(const json &j, FIDO2_AuthenticatorSelectionCriteria &meta)
{
    if (j.contains("residentKey")) {
        JSON_STRING_TO_CHAR_PTR(j, "residentKey", meta.residentKey);
    }
    j["requireResidentKey"].get_to(meta.requireResidentKey);
    j["authenticatorAttachment"].get_to(meta.authenticatorAttachment);
    j["userVerification"].get_to(meta.userVerification);
}

void from_json(const json &j, FIDO2_PublicKeyCredentialHint &meta)
{
    std::string value = j.get<std::string>();
    if (value == "security-key") {
        meta = FIDO2_SECURITY_KEY;
    } else if (value == "client-device") {
        meta = FIDO2_CLIENT_DEVICE;
    } else if (value == "hybrid") {
        meta = FIDO2_HINT_HYBRID;
    } else {
        throw std::runtime_error("Invalid FIDO2_ClientCapability value");
    }
}

void from_json(const json &j, FIDO2_PublicKeyCredentialHintArray &arr)
{
    arr.hintNum = j.size();
    arr.hints = new FIDO2_PublicKeyCredentialHint[arr.hintNum];
    const auto &json_array = j;
    for (uint32_t i = 0; i < arr.hintNum; ++i) {
        json_array[i].get_to(arr.hints[i]);
    }
}

void from_json(const json &j, FIDO2_AttestationFormatsArray &arr)
{
    arr.attestationFormatsNum = j.size();
    arr.attestationFormats = new char* [arr.attestationFormatsNum];
    for (uint32_t i = 0; i < arr.attestationFormatsNum; ++i) {
        std::string ext = j["attestationFormats"][i].get<std::string>();
        arr.attestationFormats[i] = new char[ext.size() + 1];
        strcpy(arr.attestationFormats[i], ext.c_str());
    }
}

void from_json(const json &j, FIDO2_AttestationConveyancePreference &meta)
{
    std::string value = j.get<std::string>();
    if (value == "none") {
        meta = FIDO2_NONE;
    } else if (value == "indirect") {
        meta = FIDO2_INDIRECT;
    } else if (value == "direct") {
        meta = FIDO2_DIRECT;
    } else if (value == "enterprise") {
        meta = FIDO2_ENTERPRISE;
    } else {
        throw std::runtime_error("Invalid FIDO2_ClientCapability value");
    }
}

void from_json(const json &j, FIDO2_PublicKeyCredentialCreationOptions &meta)
{
    JSON_GET_TO_STRUCT(j, "rp", meta.rp);
    JSON_GET_TO_STRUCT(j, "user", meta.user);
    JSON_GET_TO_STRUCT(j, "challenge", meta.challenge);
    JSON_GET_TO_STRUCT(j, "pubKeyCredParams", meta.pubKeyCredParams);
    JSON_GET_TO_STRUCT(j, "timeout", meta.timeout);
    JSON_GET_TO_STRUCT(j, "excludeCredentials", meta.excludeCredentials);
    JSON_GET_TO_STRUCT(j, "authenticatorSelection", meta.authenticatorSelection);
    if (j.contains("hints")) {
        j["hints"].get_to(meta.hints);
    }
    JSON_GET_TO_STRUCT(j, "attestation", meta.attestation);
    if (j.contains("attestationFormats")) {
        j["attestationFormats"].get_to(meta.attestationFormats);
    }
}

void from_json(const json &j, FIDO2_CredentialCreationOptions &meta)
{
    JSON_GET_TO_STRUCT(j, "mediation", meta.mediation);
    JSON_GET_TO_STRUCT(j, "publicKey", meta.publicKey);
}

void from_json(const json &j, FIDO2_PublicKeyCredentialRequestOptions &meta)
{
    JSON_GET_TO_STRUCT(j, "challenge", meta.challenge);
    JSON_GET_TO_STRUCT(j, "timeout", meta.timeout);
    JSON_STRING_TO_CHAR_PTR(j, "rpId", meta.rpId);
    JSON_GET_TO_STRUCT(j, "allowCredentials", meta.allowCredentials);
    j["timeout"].get_to(meta.timeout);
    JSON_GET_TO_STRUCT(j, "userVerification", meta.userVerification);
    JSON_GET_TO_STRUCT(j, "hints", meta.hints);
}

void from_json(const json &j, FIDO2_CredentialRequestOptions &meta)
{
    JSON_GET_TO_STRUCT(j, "mediation", meta.mediation);
    JSON_GET_TO_STRUCT(j, "publicKey", meta.publicKey);
}

void to_json(json &j, const FIDO2_AuthenticatorAttestationResponse &meta)
{
    j = json();
    j["attestationObject"] = meta.attestationObject;
    j["clientDataJson"] = meta.clientDataJson;
    j["publicKey"] = meta.publicKey;
    j["authenticatorData"] = meta.authenticatorData;
    j["publicKeyAlgorithm"] = meta.publicKeyAlgorithm;
    j["transports"] = meta.transports;
}

void to_json(json &j, const AuthenticationExtensionsClientOutputs &meta)
{
    if (meta.placeholder == nullptr) {
        LOGI("fido2ndk placeholder NULL");
        j = json::object();
    }
}

void to_json(json &j, const FIDO2_PublicKeyAttestationCredential &meta)
{
    j = json();
    j["rawId"] = meta.rawId;
    j["response"] = meta.response;
    j["authenticatorAttachment"] = meta.authenticatorAttachment;
    j["id"] = meta.id;
    j["type"] = meta.type;
    j["clientExtensionResults"] = meta.clientExtensionResults;
}

void to_json(json &j, const FIDO2_AuthenticatorResponse &meta)
{
    j = json();
    j["signature"] = meta.signature;
    j["clientDataJson"] = meta.clientDataJson;
    j["userHandle"] = meta.userHandle;
    j["authenticatorData"] = meta.authenticatorData;
}

void to_json(json &j, const FIDO2_PublicKeyAssertionCredential &meta)
{
    j = json();
    j["rawId"] = meta.rawId;
    j["response"] = meta.response;
    j["authenticatorAttachment"] = meta.authenticatorAttachment;
    if (meta.id != nullptr){
        j["id"] = meta.id;
    }
    if (meta.type != nullptr) {
        j["type"] = meta.type;
    }
    j["clientExtensionResults"] = meta.clientExtensionResults;
}

