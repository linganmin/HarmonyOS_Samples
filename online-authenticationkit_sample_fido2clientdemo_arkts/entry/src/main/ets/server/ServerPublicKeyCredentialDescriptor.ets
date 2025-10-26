/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 */

/**
 *The Data Structure Of Server PublicKey Credential Descriptor.
 */
export class ServerPublicKeyCredentialDescriptor {
  public type: string = '';
  public id: string | Uint8Array = '';
  public transports?: string[] | undefined;

  constructor(type?: string, id?: string, transports?: Array<string>) {
    if (transports) {
      this.transports = transports;
    }
    if (type) {
      this.type = type;
    }
    if (id) {
      this.id = id;
    }
  }

}