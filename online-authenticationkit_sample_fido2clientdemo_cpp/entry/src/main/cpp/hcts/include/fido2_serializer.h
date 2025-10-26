/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * Description: This file contains the functions about fido2.
 */

#ifndef FIDO2_SERIALIZER_H
#define FIDO2_SERIALIZER_H

#include "OnlineAuthenticationKit/fido2_api.h"
#include "nlohmann/json.hpp"
using json = nlohmann::json;

void to_json(json &j, const FIDO2_TokenBinding &p);
void to_json(json& j, const FIDO2_CredentialCreationOptions& p);
void to_json(json &j, const FIDO2_CredentialRequestOptions &p);
void from_json(const json &j, FIDO2_CapabilityArray &arr);
void from_json(const json &j, FIDO2_AuthenticatorMetadataArray &arr);
void from_json(const json &j, FIDO2_PublicKeyAttestationCredential &meta);
void from_json(const json &j, FIDO2_PublicKeyAssertionCredential &meta);
void from_json(const json &j, FIDO2_CredentialCreationOptions &meta);
void from_json(const json &j, FIDO2_CredentialRequestOptions &meta);
void to_json(json &j, const FIDO2_PublicKeyAttestationCredential &meta);
void to_json(json &j, const FIDO2_PublicKeyAssertionCredential &meta);

#endif // FIDO2_SERIALIZER_H