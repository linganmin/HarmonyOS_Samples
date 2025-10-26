// [Start detail_js]
// index.js
import router from '@ohos.router';

export default {
    clickAction() {
        router.replaceUrl({
            uri: 'pages/details/details'
        });
    }
};
// [End detail_js]