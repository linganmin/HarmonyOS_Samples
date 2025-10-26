// Attention: This is the counterexample file

// [Start export_multi_levels]
// main: Hap import har file
import { one } from '@har/Index'

// har/Index.ets （one level）
export * from './InnerIndex'
export * from './Utils'
export * from './Logs'
export * from './Service'
export * from './Common'
export * from './Feature'

// InnerIndex.ets (two level)
export * from './ThirdIndex'
export { two } from 'Temp'
export * from './Utils'
export * from './Logs'
export * from './Service'

// ...more level

// LastIndex.ets (N level)
export * from './Utils';
export { three } from 'Temp'
export * from './Numbers'

// Numbers.ets
export const One: number = 1;
// [End export_multi_levels]

// [Start export_one_level]
// main: Hap import har file
import { one } from '@har/Index'

// har/Index.ets
export * from './Numbers' // only one level

// Numbers.ets
export const one: number = 1;
// [End export_one_level]

// [Start multi_star_export]
// main.ets
import { one } from '@har/Index';

// @har/Index.ets
export * from './Numbers'
export * from './Utils'
export * from './Logs'
export * from './Service'
export * from './Common'
export * from './Feature'

// Numbers.ets
export const one : number = 1;
// [End multi_star_export]

// [Start name_export]
// main.ets
import { one } from '@har/Index';

// @har/Index.ets
export { one }  from '../Numbers'  // use named export
export * from './Utils'
export * from './Logs'
export * from './Service'
export * from './Common'
export * from './Feature'

// Numbers.ets
export const one: number = 1;
// [End name_export]