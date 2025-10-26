/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 */
import { ServerPublicKeyCredentialDescriptor } from './ServerPublicKeyCredentialDescriptor';

export class ServerPublicKeyCredentialRequestOptions{
  public challenge: string|Uint8Array = '';
  public timeout?: number;
  public rpId?: string;
  public allowCredentials?: ServerPublicKeyCredentialDescriptor[] = [];
  public userVerification?: string  = 'preferred';
  public extensions?: Map<string, Object> ;
}