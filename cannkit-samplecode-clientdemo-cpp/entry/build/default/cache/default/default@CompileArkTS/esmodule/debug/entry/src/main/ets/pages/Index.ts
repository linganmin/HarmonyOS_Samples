if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface ImageForClassificationDisplay_Params {
    messageClickPredict?: string;
    messageForNext?: string;
    imageToBeClassified?: Resource;
    imagesList?: Resource[];
    index?: number;
    firstResult?: string;
    secondResult?: string;
    thirdResult?: string;
}
interface PageTitleDisplay_Params {
    message?: string;
}
interface Index_Params {
}
import hilog from "@ohos:hilog";
import image from "@ohos:multimedia.image";
import fileUri from "@ohos:file.fileuri";
import picker from "@ohos:file.picker";
import fs from "@ohos:file.fs";
import type common from "@ohos:app.ability.common";
import hiai from "@app:com.huawei.canndemo/entry/entry";
class Index extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: Index_Params) {
    }
    updateStateVars(params: Index_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
    }
    aboutToBeDeleted() {
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 16 });
            Column.alignItems(HorizontalAlign.Center);
        }, Column);
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let componentCall = new PageTitleDisplay(this, {}, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/Index.ets", line: 29, col: 7 });
                    ViewPU.create(componentCall);
                    let paramsLambda = () => {
                        return {};
                    };
                    componentCall.paramsGenerator_ = paramsLambda;
                }
                else {
                    this.updateStateVarsOfChildByElmtId(elmtId, {});
                }
            }, { name: "PageTitleDisplay" });
        }
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let componentCall = new ImageForClassificationDisplay(this, {}, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/Index.ets", line: 30, col: 7 });
                    ViewPU.create(componentCall);
                    let paramsLambda = () => {
                        return {};
                    };
                    componentCall.paramsGenerator_ = paramsLambda;
                }
                else {
                    this.updateStateVarsOfChildByElmtId(elmtId, {});
                }
            }, { name: "ImageForClassificationDisplay" });
        }
        Column.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
    static getEntryName(): string {
        return "Index";
    }
}
class PageTitleDisplay extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__message = new ObservedPropertySimplePU('CANN Classification DEMO', this, "message");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: PageTitleDisplay_Params) {
        if (params.message !== undefined) {
            this.message = params.message;
        }
    }
    updateStateVars(params: PageTitleDisplay_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__message.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__message.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __message: ObservedPropertySimplePU<string>;
    get message() {
        return this.__message.get();
    }
    set message(newValue: string) {
        this.__message.set(newValue);
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 16 });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.message);
            Text.fontSize(24);
            Text.height('6%');
            Text.fontWeight(FontWeight.Bold);
            Text.fontFamily('HarmonyOS-Sans');
        }, Text);
        Text.pop();
        Column.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
}
class ImageForClassificationDisplay extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__messageClickPredict = new ObservedPropertySimplePU("Click for classification", this, "messageClickPredict");
        this.__messageForNext = new ObservedPropertySimplePU("Click for next image", this, "messageForNext");
        this.__imageToBeClassified = new ObservedPropertyObjectPU({ "id": 16777223, "type": 20000, params: [], "bundleName": "com.huawei.canndemo", "moduleName": "entry" }, this, "imageToBeClassified");
        this.__imagesList = new ObservedPropertyObjectPU([{ "id": 16777223, "type": 20000, params: [], "bundleName": "com.huawei.canndemo", "moduleName": "entry" }, { "id": 16777222, "type": 20000, params: [], "bundleName": "com.huawei.canndemo", "moduleName": "entry" }], this, "imagesList");
        this.__index = new ObservedPropertySimplePU(0, this, "index");
        this.__firstResult = new ObservedPropertySimplePU('', this, "firstResult");
        this.__secondResult = new ObservedPropertySimplePU('', this, "secondResult");
        this.__thirdResult = new ObservedPropertySimplePU('', this, "thirdResult");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: ImageForClassificationDisplay_Params) {
        if (params.messageClickPredict !== undefined) {
            this.messageClickPredict = params.messageClickPredict;
        }
        if (params.messageForNext !== undefined) {
            this.messageForNext = params.messageForNext;
        }
        if (params.imageToBeClassified !== undefined) {
            this.imageToBeClassified = params.imageToBeClassified;
        }
        if (params.imagesList !== undefined) {
            this.imagesList = params.imagesList;
        }
        if (params.index !== undefined) {
            this.index = params.index;
        }
        if (params.firstResult !== undefined) {
            this.firstResult = params.firstResult;
        }
        if (params.secondResult !== undefined) {
            this.secondResult = params.secondResult;
        }
        if (params.thirdResult !== undefined) {
            this.thirdResult = params.thirdResult;
        }
    }
    updateStateVars(params: ImageForClassificationDisplay_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__messageClickPredict.purgeDependencyOnElmtId(rmElmtId);
        this.__messageForNext.purgeDependencyOnElmtId(rmElmtId);
        this.__imageToBeClassified.purgeDependencyOnElmtId(rmElmtId);
        this.__imagesList.purgeDependencyOnElmtId(rmElmtId);
        this.__index.purgeDependencyOnElmtId(rmElmtId);
        this.__firstResult.purgeDependencyOnElmtId(rmElmtId);
        this.__secondResult.purgeDependencyOnElmtId(rmElmtId);
        this.__thirdResult.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__messageClickPredict.aboutToBeDeleted();
        this.__messageForNext.aboutToBeDeleted();
        this.__imageToBeClassified.aboutToBeDeleted();
        this.__imagesList.aboutToBeDeleted();
        this.__index.aboutToBeDeleted();
        this.__firstResult.aboutToBeDeleted();
        this.__secondResult.aboutToBeDeleted();
        this.__thirdResult.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __messageClickPredict: ObservedPropertySimplePU<string>;
    get messageClickPredict() {
        return this.__messageClickPredict.get();
    }
    set messageClickPredict(newValue: string) {
        this.__messageClickPredict.set(newValue);
    }
    private __messageForNext: ObservedPropertySimplePU<string>;
    get messageForNext() {
        return this.__messageForNext.get();
    }
    set messageForNext(newValue: string) {
        this.__messageForNext.set(newValue);
    }
    private __imageToBeClassified: ObservedPropertyObjectPU<Resource>;
    get imageToBeClassified() {
        return this.__imageToBeClassified.get();
    }
    set imageToBeClassified(newValue: Resource) {
        this.__imageToBeClassified.set(newValue);
    }
    private __imagesList: ObservedPropertyObjectPU<Resource[]>;
    get imagesList() {
        return this.__imagesList.get();
    }
    set imagesList(newValue: Resource[]) {
        this.__imagesList.set(newValue);
    }
    private __index: ObservedPropertySimplePU<number>;
    get index() {
        return this.__index.get();
    }
    set index(newValue: number) {
        this.__index.set(newValue);
    }
    private __firstResult: ObservedPropertySimplePU<string>;
    get firstResult() {
        return this.__firstResult.get();
    }
    set firstResult(newValue: string) {
        this.__firstResult.set(newValue);
    }
    private __secondResult: ObservedPropertySimplePU<string>;
    get secondResult() {
        return this.__secondResult.get();
    }
    set secondResult(newValue: string) {
        this.__secondResult.set(newValue);
    }
    private __thirdResult: ObservedPropertySimplePU<string>;
    get thirdResult() {
        return this.__thirdResult.get();
    }
    set thirdResult(newValue: string) {
        this.__thirdResult.set(newValue);
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel(this.messageClickPredict);
            Button.type(ButtonType.Normal);
            Button.borderRadius(16);
            Button.backgroundColor("#0A59F7");
            Button.margin({ left: 16, right: 8 });
            Button.fontWeight(FontWeight.Regular);
            Button.fontFamily('HarmonyOS-Sans');
            Button.fontSize(14);
            Button.width('90%');
            Button.height('7%');
            Button.padding('1%');
            Button.layoutWeight(1);
            Button.onClick(() => {
                const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
                context.resourceManager.getMediaContent(this.imageToBeClassified.id).then(value => {
                    let uri: string = '';
                    const documentViewPicker = new picker.DocumentViewPicker(context);
                    const documentSaveOptions = new picker.DocumentSaveOptions();
                    documentSaveOptions.pickerMode = picker.DocumentPickerMode.DOWNLOAD;
                    hilog.info(0x0000, 'CANNDemo', 'start in load model.');
                    documentViewPicker.save(documentSaveOptions).then((documentDir: Array<string>) => {
                        uri = documentDir[0];
                        let buf = new ArrayBuffer(value.length);
                        let tempBuffer = new Uint8Array(buf);
                        for (let i = 0; i < value.length; i++) {
                            tempBuffer[i] = value[i];
                        }
                        const imageSource = image.createImageSource(buf);
                        // Set the image format to BGRA_8888.
                        imageSource.createPixelMap({ desiredPixelFormat: image.PixelMapFormat.BGRA_8888 })
                            .then(async (pixelMapObj) => {
                            let width = 0;
                            let height = 0;
                            await pixelMapObj.getImageInfo().then(async (info) => {
                                width = info.size.width;
                                height = info.size.height;
                            });
                            // Zoom the image to 227 * 227
                            await pixelMapObj.scale(227 / width, 227 / height);
                            // Adjust the image back to the correct
                            await pixelMapObj.rotate(270.0);
                            await pixelMapObj.flip(false, true);
                            pixelMapObj.getImageInfo().then(info => {
                                let resizeH = info.size.height;
                                let resizeW = info.size.width;
                                const readBuffer = new ArrayBuffer(pixelMapObj.getPixelBytesNumber());
                                pixelMapObj.readPixelsToBuffer(readBuffer, (err, res) => {
                                    if (err) {
                                        hilog.error(0x0000, 'CANNDemo', 'Failed to read image pixel data');
                                        return;
                                    }
                                    else {
                                        let dataArray = new Uint8Array(readBuffer);
                                        let len1 = 227;
                                        let len2 = 227;
                                        let len3 = 4;
                                        let pixelArray: Array<Array<Uint8Array>> = new Array<Array<Uint8Array>>(len1);
                                        for (let i = 0; i < len1; ++i) {
                                            pixelArray[i] = new Array<Uint8Array>(len2);
                                            for (let j = 0; j < len2; ++j) {
                                                pixelArray[i][j] = new Uint8Array(len3);
                                                for (let k = 0; k < len3; ++k) {
                                                    pixelArray[i][j][k] = dataArray[i * len2 * len3 + j * len3 + k];
                                                }
                                            }
                                        }
                                        // Sets the input BGR channel value.
                                        let channel = 3;
                                        const color = new ArrayBuffer(channel * resizeW * resizeH);
                                        let inputData = new Uint8Array(color);
                                        for (let i = 0; i < resizeW; i++) {
                                            for (let j = 0; j < resizeH; j++) {
                                                let bIndex = (i * resizeW) + j;
                                                let gIndex = bIndex + (resizeW * resizeH);
                                                let rIndex = gIndex + (resizeW * resizeH);
                                                inputData[bIndex] = pixelArray[j][i][0];
                                                inputData[gIndex] = pixelArray[j][i][1];
                                                inputData[rIndex] = pixelArray[j][i][2];
                                            }
                                        }
                                        let ret: number = hiai.LoadModel(context.resourceManager); // Loading a Model
                                        if (ret == 0) {
                                            hilog.info(0x0000, 'CANNDemo', 'Succeeded in loading model');
                                        }
                                        else {
                                            hilog.error(0x0000, 'CANNDemo', 'Failed to load model');
                                            return;
                                        }
                                        // Initialize input and output data.
                                        ret = hiai.InitIOTensors(inputData);
                                        if (ret != 0) {
                                            hilog.error(0x0000, 'CANNDemo', 'Failed to init IOTensors.');
                                            return;
                                        }
                                        hilog.info(0x0000, 'CANNDemo', 'Succeeded in initing IOTensors.');
                                        // Model Inference
                                        ret = hiai.RunModel();
                                        if (ret != 0) {
                                            hilog.error(0x0000, 'CANNDemo', 'Failed to run model.');
                                            return;
                                        }
                                        hilog.info(0x0000, 'CANNDemo', 'Successed in running model.');
                                        // Get model Output
                                        let classificationResult = hiai.GetResult();
                                        this.firstResult = classificationResult[0];
                                        this.secondResult = classificationResult[1];
                                        this.thirdResult = classificationResult[2];
                                        ret = hiai.UnloadModel(); // Unloading a Model
                                        if (ret == 0) {
                                            hilog.info(0x0000, 'CANNDemo', 'Succeeded in unloading model');
                                        }
                                        else {
                                            hilog.error(0x0000, 'CANNDemo', 'Failed to unload model');
                                        }
                                        let descPath = new fileUri.FileUri(uri).path;
                                        // let srcPath = getContext().filesDir;
                                        let hostContent = this.getUIContext().getHostContext() as common.UIAbilityContext;
                                        let srcPath = hostContent.filesDir;
                                        hilog.info(0x0000, 'CANNDemo_copy', '%{public}s.', srcPath.toString());
                                        fs.moveDirSync(srcPath, descPath, 2);
                                        hilog.info(0x0000, 'CANNDemo', 'Done.');
                                    }
                                });
                            });
                        });
                    });
                });
            });
        }, Button);
        Button.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel(this.messageForNext);
            Button.type(ButtonType.Normal);
            Button.borderRadius(16);
            Button.backgroundColor("#0A59F7");
            Button.margin({ left: 8, right: 16 });
            Button.fontWeight(FontWeight.Regular);
            Button.fontFamily('HarmonyOS-Sans');
            Button.fontSize(14);
            Button.width('90%');
            Button.height('7%');
            Button.padding('1%');
            Button.layoutWeight(1);
            Button.onClick(() => {
                this.index++;
                this.firstResult = '';
                this.secondResult = '';
                this.thirdResult = '';
                if (this.index >= this.imagesList.length) {
                    this.index = 0;
                }
                this.imageToBeClassified = this.imagesList[this.index];
            });
        }, Button);
        Button.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Image.create(this.imageToBeClassified);
            Image.width('90%');
            Image.height('50%');
            Image.objectFit(ImageFit.Contain);
            Image.id('detectImage');
        }, Image);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.firstResult);
            Text.textAlign(TextAlign.Start);
            Text.fontSize(14);
            Text.fontColor(0x000000);
            Text.padding('2%');
            Text.width('90%');
            Text.height('5%');
            Text.backgroundColor(Color.White);
            Text.borderRadius(16);
            Text.margin({ left: 16, right: 16 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.secondResult);
            Text.textAlign(TextAlign.Start);
            Text.fontSize(14);
            Text.fontColor(0x000000);
            Text.padding('2%');
            Text.width('90%');
            Text.height('5%');
            Text.backgroundColor(Color.White);
            Text.borderRadius(16);
            Text.margin({ left: 16, right: 16 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.thirdResult);
            Text.textAlign(TextAlign.Start);
            Text.fontSize(14);
            Text.fontColor(0x000000);
            Text.padding('2%');
            Text.width('90%');
            Text.height('5%');
            Text.backgroundColor(Color.White);
            Text.borderRadius(16);
            Text.margin({ left: 16, right: 16 });
        }, Text);
        Text.pop();
        Column.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
}
registerNamedRoute(() => new Index(undefined, {}), "", { bundleName: "com.huawei.canndemo", moduleName: "entry", pagePath: "pages/Index", pageFullPath: "entry/src/main/ets/pages/Index", integratedHsp: "false", moduleType: "followWithHap" });
