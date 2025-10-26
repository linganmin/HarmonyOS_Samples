/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 */

export class ServerPublicKeyCredentialUserEntity{
  public id: string|Uint8Array = ''
  public name: string = ''
  public displayName: string = ''

  constructor(name?: string , id?: string|Uint8Array, displayName?: string) {
    if(id){
      this.id = id
    }
    if(name){
      this.name = name
    }
    if(displayName){
      this.displayName = displayName
    }
  }
}