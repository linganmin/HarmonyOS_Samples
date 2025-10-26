import DefaultCallData from './TypeUtils';
import { voipCall } from '@kit.CallKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

export default class CallDataManager {
  private static sCallDataManager: CallDataManager;
  private callList: Array<DefaultCallData> = [];

  public static getInstance(): CallDataManager {
    if (!CallDataManager.sCallDataManager) {
      CallDataManager.sCallDataManager = new CallDataManager();
    }
    return CallDataManager.sCallDataManager;
  }

  public addCall(callData: DefaultCallData): void {
    let targetObj = this.callList.find((v: DefaultCallData) => v.callId === callData.callId);
    if (!targetObj) {
      this.callList.push(callData);
      hilog.info(0x0000, 'SampleCode', 'addCall: ' + callData.callId + ', callCount: ' + this.callList.length);
    }
  }

  public removeCallById(callId: string): void {
    let index = this.callList.findIndex((v: DefaultCallData) => v.callId === callId);
    if (index === -1) {
      hilog.error(0x0000, 'SampleCode', 'removeCallById call not exist: ' + callId);
      return;
    }
    this.callList.splice(index, 1);
    hilog.info(0x0000, 'SampleCode', 'removeCallById: ' + callId + ', callCount: ' + this.callList.length);
  }

  public getCallById(callId: string): DefaultCallData | undefined {
    return this.callList.find((v: DefaultCallData) => v.callId === callId);
  }

  public getCallCount(): number {
    return this.callList.length;
  }

  public updateCallStateById(callId: string, callState: voipCall.VoipCallState): void {
    let targetObj = this.callList.find((v: DefaultCallData) => v.callId === callId);
    if (targetObj) {
      targetObj.callState = callState;
    } else {
      hilog.error(0x0000, 'SampleCode', 'updateCallStateById call not exist: ' + callId);
    }
  }
}