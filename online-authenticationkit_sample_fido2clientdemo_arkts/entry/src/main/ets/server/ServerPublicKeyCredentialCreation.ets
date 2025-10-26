/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 */
import { ServerAuthenticationExtensionsClientOutputs } from './ServerAuthenticationExtensionsClientOutputs';
import { ServerAuthenticatorAttestationResponse } from './ServerAuthenticatorAttestationResponse';

/**
 *The Data Structure Of Server PublicKey Credential Creation.
 */
export class ServerPublicKeyCredentialCreation {
  public rawId: string = '';
  public response: ServerAuthenticatorAttestationResponse = new ServerAuthenticatorAttestationResponse();
  public authenticatorAttachment = '';
  public clientExtensionResults?: ServerAuthenticationExtensionsClientOutputs;
  public type: string = ''
  public id: string = '';

  constructor(rawId?: string, response?: ServerAuthenticatorAttestationResponse, authenticatorAttachment?: string, clientExtensionResults?: ServerAuthenticationExtensionsClientOutputs) {
    if (rawId) {
      this.rawId = rawId;
    }
    if (response) {
      this.response = response;
    }
    if (authenticatorAttachment) {
      this.authenticatorAttachment = authenticatorAttachment;
    }
    if (clientExtensionResults) {
      this.clientExtensionResults = clientExtensionResults;
    }
  }

}