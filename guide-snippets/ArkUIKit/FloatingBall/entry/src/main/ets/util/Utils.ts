// Utils.ts

import image from '@ohos.multimedia.image';
import { BusinessError } from '@kit.BasicServicesKit';
import { floatingBall } from '@kit.ArkUI';
import { Want } from '@kit.AbilityKit';
import { ContextUtil} from './ContextUtil';

export class Utils {
    public static getRawfilePixelMapSync(path: string): image.PixelMap{
        try{
            const buffer = ContextUtil.context.resourceManager.getRawFileContentSync(path);
            const imageSource: image.ImageSource = image.createImageSource(buffer.buffer as ArrayBuffer);
            console.log(`Get rawfile pixelMap path '${path}' success`);
            return imageSource.createPixelMapSync();
        }catch (e) {
            console.log(`Get rawfile pixelMap path '${path}' failed`, e);
            throw e as Error;
        }
    }

    // 悬浮球启动逻辑
    public static async onClickCreateFloatingBall(floatingBallController: floatingBall.FloatingBallController | undefined,
        template: floatingBall.FloatingBallTemplate,
        onActiveRowChange: (value: number) => void,  // 接收状态更新回调函数
        title: string = "title",
        content: string = "content",
        icon?: image.PixelMap): Promise<void> {
        // 注册 监听点击回调事件
        floatingBallController?.on("click", () => {
            console.info('FloatingBall onClickEvent');
            let want: Want = {
                // 实际使用应替换成你自己的应用包名
                bundleName: "com.example.floatingBall",
                abilityName: "MainAbility"
            }
            // 使用promise异步回调
            floatingBallController?.restoreMainWindow(want)
            .then(() => {
                console.log('Success in restoring FloatingBall main window');
            }).catch((err: BusinessError) => {
                console.log('failed to restore FloatingBall main window. Cause code: ${err.code}, message: ${err.message}');
            })
        })
        // 注册 监听状态变化事件
        floatingBallController?.on('stateChange',
        (state: floatingBall.FloatingBallState) => {
            console.info('FloatingBall stateCange:', state);
            if(state === floatingBall.FloatingBallState.STOPPED){
                floatingBallController?.off("click")
                floatingBallController?.off("stateChange")
                floatingBallController = undefined;
                // 执行状态更新回调
                onActiveRowChange?.(-1);
            }
        })
        // 最后启动山控球
        let startParams: floatingBall.FloatingBallParams = icon? {
            template: template,
            title: title,
            content: content,
            icon: icon
        } : {
            template: template,
            title: title,
            content: content
        }
        try{
            floatingBallController?.startFloatingBall(startParams)
            .then(() => {
                console.log('succeed in starting FloatingBall');
            }).catch((err: BusinessError) => {
                console.error(`failed to start FloatingBall. Cause code: ${err.code}, message: ${err.message}`);
            })
        }catch(e){
            console.error('startFloatingBall Error', e)
        }
    }

// 悬浮球更新逻辑
public static onClickUpdateFloatingBall(floatingBallController: floatingBall.FloatingBallController | undefined,
    template: floatingBall.FloatingBallTemplate,
    title: string = "title",
    content: string = "content",
    icon?: image.PixelMap): void {
        // 更新时给标题、内容 随机使用数字后缀
        let random_string: string = Math.floor(Math.random() * 100).toString();
        let updateParams: floatingBall.FloatingBallParams = icon ? {
            template: template,
            title: title + random_string,
            content: content + random_string,
            icon: icon
        } : {
            template: template,
            title: title + random_string,
            content: content + random_string,
        }
        try{
            floatingBallController?.updateFloatingBall(updateParams).then(() => {
                console.info('Succeed in updating FloatingBall.');
            }).catch((err: BusinessError) => {
                console.error(`failed to update FloatingBall. Cause code: ${err.code}, message: ${err.message}`);
            })
        }catch(e){
            console.error('updateFloatingBall Error:', e)
        }
    }

    // 悬浮球停止逻辑
    public static onClickStopFloatingBall(floatingBallController: floatingBall.FloatingBallController | undefined){
        // stop 是异步流程，需要通过 stateChange 状态回调获取实际删除结果
        floatingBallController?.stopFloatingBall().then(() => {
            console.info('Succeed in stopping FloatingBall.');
        }).catch((err: BusinessError) => {
            console.error(`failed to stop FloatingBall. Cause code: ${err.code}, message: ${err.message}`);
        })
    }
}