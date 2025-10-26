/**
 * FAQ:多so相互依赖场景下如何解耦
 */
// [Start demo_so]
// index.d.ts
export const add: (a: number, b: number, path: string) => number;
export const sub: (a: number, b: number, path: string) => number;
// [End demo_so]