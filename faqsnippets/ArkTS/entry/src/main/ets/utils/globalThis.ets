/*
* FAQ:ArkTS中globalThis无法使用该如何替换
*/

// [Start globalThis1]
import { common } from '@kit.AbilityKit';

// Construct singleton objects
export class GlobalThis {
  private constructor() {};
  private static instance: GlobalThis;
  private _uiContexts = new Map<string, common.UIAbilityContext>();
  private value = '';

  public static getInstance(): GlobalThis {
    if (!GlobalThis.instance) {
      GlobalThis.instance = new GlobalThis();
    }
    return GlobalThis.instance;
  }

  getContext(key: string): common.UIAbilityContext | undefined {
    return this._uiContexts.get(key);
  }

  setContext(key: string, value: common.UIAbilityContext): void {
    this._uiContexts.set(key, value);
  }

  setValue(value:string){
    this.value = value
  }

  getValue():string{
    return this.value;
  }
}
// [End globalThis1]