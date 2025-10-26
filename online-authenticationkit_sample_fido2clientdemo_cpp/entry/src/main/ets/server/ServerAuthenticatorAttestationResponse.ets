/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 */
export class ServerAuthenticatorAttestationResponse{
  public attestationObject: string = '';
  public clientDataJSON: string = '';
  public transports?: string[] | undefined ;

  constructor(attestationObject?: string, clientDataJSON?: string,transports?: string[]) {
    if(attestationObject){
      this.attestationObject = attestationObject;
    }
    if(clientDataJSON){
      this.clientDataJSON = clientDataJSON;
    }
    if(transports){
      this.transports = transports;
    }
  }
}