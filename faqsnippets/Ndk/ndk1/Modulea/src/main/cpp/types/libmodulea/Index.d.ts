/**
 * FAQ:如何通过多个xxx.d.ts文件导出Native侧接口
 */
// [Start index_sub]
export {sub} from './index1'
export const add: (a: number, b: number) => number;
// [End index_sub]