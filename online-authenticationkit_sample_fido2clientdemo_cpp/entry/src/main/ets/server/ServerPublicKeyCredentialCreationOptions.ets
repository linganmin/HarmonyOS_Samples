/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 */
import { ServerPublicKeyCredentialDescriptor } from './ServerPublicKeyCredentialDescriptor';
import { ServerPublicKeyCredentialUserEntity } from './ServerPublicKeyCredentialUserEntity';
import fido2 from '../pages/fido2api';
export class ServerPublicKeyCredentialCreationOptions{

  challenge:string|Uint8Array  = ''
  timeout:number=0
  rp: fido2.PublicKeyCredentialRpEntity = {
    id: '',
    name: ''
  };
  user: ServerPublicKeyCredentialUserEntity = new ServerPublicKeyCredentialUserEntity();
  excludeCredentials?:ServerPublicKeyCredentialDescriptor[] ;
  pubKeyCredParams?: fido2.PublicKeyCredentialParameters[];
  extensions?: Map<string, Object>;
  authenticatorSelection?: fido2.AuthenticatorSelectionCriteria ;
  attestation: fido2.AttestationConveyancePreference = 'none' as fido2.AttestationConveyancePreference;
  attestationFormats = ['packed']
}
