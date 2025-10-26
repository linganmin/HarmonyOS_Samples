export const add: (a: number, b: number) => number;

export const mapDemo: (a: string, b: number) => number;

export const addTSFCallback: (a: number, b: number, c: (nativeResult: number) => void) => number;

/**
 * FAQ: Native如何调ArkTS的方法
 */
// [Start native_call_arkts_dts]
export const nativeCallArkTS: (a: object) => number;

// [End native_call_arkts_dts]

export const testFunc: (a: string) => void;