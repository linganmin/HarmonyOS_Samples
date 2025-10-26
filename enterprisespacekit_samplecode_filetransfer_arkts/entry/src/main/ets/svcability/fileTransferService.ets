/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { fileTransfer } from '@kit.EnterpriseSpaceKit';

const TAG: string = '[fileTransfer]';

class FileTransferService {
  GetAuditInfo() {
    console.info(TAG, 'getAuditInfo');
    const transactionNum: string = "182601";
    try {
      let auditinfo : fileTransfer.AuditInfo = fileTransfer.getAuditInfo(transactionNum);
      console.info(TAG, 'Received getAuditInfo:', auditinfo);
    } catch (err) {
      console.error(TAG, `getAuditInfo error: Code: ${err.code}, message: ${err.message}`);
    }
  }

  SetAuditInfo() {
    console.info(TAG, 'setAuditInfo');
    const transactionNum: string = "182601";
    let testInfo : fileTransfer.AuditInfo = {
      auditId: 'abc',
      userId: '101',
      userName: 'abc',
      time: 1,
      comments: 'abc',
      status: '4'
    };

    try {
      let number: number = fileTransfer.setAuditInfo(transactionNum, testInfo);
      console.info(TAG, 'Received setAuditInfo:', number);
    } catch (err) {
      console.error(TAG, `setAuditInfo error: Code: ${err.code}, message: ${err.message}`);
    }
  }
}

export default new FileTransferService();