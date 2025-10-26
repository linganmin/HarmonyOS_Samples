/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 */
import { ServerAuthenticationExtensionsClientOutputs } from './ServerAuthenticationExtensionsClientOutputs';
import { ServerAuthenticatorAssertionResponse } from './ServerAuthenticatorAssertionResponse';

/**
 *The Data Structure Of Server PublicKey Credential Request.
 */
export class ServerPublicKeyCredentialRequest {
  public rawId: string = '';
  public authenticatorAttachment = '';
  public response: ServerAuthenticatorAssertionResponse = new ServerAuthenticatorAssertionResponse();
  public clientExtensionResults?: ServerAuthenticationExtensionsClientOutputs;
  public id: string = '';
  public type: string = '';

}