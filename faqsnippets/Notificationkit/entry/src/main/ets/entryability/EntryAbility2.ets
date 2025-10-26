/*
* FAQ:如何让事件只在一个UIAbility实例中传递
 */

// [Start EventHubTransfer]
import { UIAbility } from '@kit.AbilityKit';

export default class EntryAbility extends UIAbility {
  onForeground() {
    this.context.eventHub.on('myEvent', this.eventFunc);
    // result：
    // eventFunc is called,undefined,undefined
    this.context.eventHub.emit('myEvent');
    // result：
    // eventFunc is called,1,undefined
    this.context.eventHub.emit('myEvent', 1);
    // result：
    // eventFunc is called,1,2
    this.context.eventHub.emit('myEvent', 1, 2);
  }

  eventFunc(argOne: number, argTwo: number) {
    console.log(`eventFunc is called, ${argOne}, ${argTwo}`);
  }
}
// [End EventHubTransfer]