/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 */
export class ServerAuthenticatorAssertionResponse{
  public clientDataJSON: string = '';
  public authenticatorData: string = '';
  public signature: string = '';
  public userHandle: string = '';
}