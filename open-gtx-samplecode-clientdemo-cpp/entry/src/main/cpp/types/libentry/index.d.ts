import resourceManager from "@ohos.resourceManager"

export const Create: (resourceManager: resourceManager.ResourceManager, dpi: number) => void

export const Destroy: () => void

export const DisablePrediction: () => void
export const EnablePrediction: () => void

export const SwitchMode: (index: number) => void
export const SwitchTargetFPS: (index: number) => void
export const SwitchSceneID: (index: number) => void

export const OnBackground: () => void
export const OnForeground: () => void
