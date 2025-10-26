import { voipCall } from '@kit.CallKit';

export default class DefaultCallData {
  public callId: string = '';
  public callState: voipCall.VoipCallState = -1;
  public callType: voipCall.VoipCallType = voipCall.VoipCallType.VOIP_CALL_VOICE;
  public startTime?: number = -1;
  public isVoiceAnswerSupported?: boolean = true;
}
