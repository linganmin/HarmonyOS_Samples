/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
import { rpc } from '@kit.IPCKit';

/**
 * Remote RPC object provided by the wallet app as the server to the walletKit
 * Callback interface for the wallet service
 */
export class ICCECallBack extends rpc.RemoteObject {
  constructor() {
    super('ICCECallBack');
  }

  // This method is automatically called when there is a request from the client
  async onRemoteMessageRequest(code: number, data: rpc.MessageSequence, reply: rpc.MessageSequence,
    option: rpc.MessageOption): Promise<boolean> {
    console.info(`onRemoteMessageRequest code is ${code}`);

    // Validate data input parameters
    if (!data) {
      console.info('onRemoteMessageRequest data is null');
      return true;
    }

    if (code === 1) {
      let codeInt = data.readInt();
      console.info(`onRemoteMessageRequest code is ${codeInt}`);
      AppStorage.setOrCreate<string>('ICCEData', codeInt.toString())
      reply.writeInt(122);
      return true;
    }

    return true;
  }
}

