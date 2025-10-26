import type resourceManager from '@ohos.resourceManager';

export const create: (resourceManager: resourceManager.ResourceManager, dpi: number,
  predictionMode: number) => void;

export const destroy: () => void;

export const disablePrediction: () => void;
export const enablePrediction: () => void;

export const onBackground: () => void;
export const onForeground: () => void;