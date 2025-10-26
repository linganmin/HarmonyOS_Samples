// [Start import_nested_error]
// Numbers.ets
export const One: number = 1;

// ...
// Multi-layer export nested here *

// Utils.ets
export * from './Numbers';

// SecondPage.ets
export * from './Utils';

// Index.ets
import * from './SecondPage';
// [End import_nested_error]

// [Start import_nested]
// Numbers.ets
export const One: number = 1;

// Index.ets
import { One } from './Numbers';
// [End import_nested]

// [Start reduced_import_error]
// Index.ets
import * as nm from '../utils/Numbers'; // The import * method is not recommended
hilog.info(0x0000, 'testTag', '%{public}d', nm.One); // Only the variable One is used here
// Numbers.ets
export const One: number = 1;
export const Two: number = 2;
// ...
// 100,000 pieces of data are omitted here
// [End reduced_import_error]

// [Start reduced_import]
// Index.ets
import { One } as nm from '../utils/Numbers'; // It is recommended to reference variables on demand
hilog.info(0x0000, 'testTag', '%{public}d', One); // Only the variable One is used here
// Numbers.ets
export const One: number = 1;
export const Two: number = 2;
// ...
// 100,000 pieces of data are omitted here
// [End reduced_import]

// [Start hdc_shell]
hdc shell param set persist.ark.properties 0x200105c
hdc shell reboot
// [End hdc_shell]