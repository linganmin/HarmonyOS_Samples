// [Start http_request_post]
const xhr = new XMLHttpRequest();
xhr.open('POST', 'https://www.example.com/POST?e=f&g=h', true);
xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
xhr.setRequestHeader('ArkWebPostCacheKey', 'KeyX');
xhr.onload = function () {
  if (xhr.status >= 200 && xhr.status < 300) {
    console.log('成功', xhr.responseText);
  } else {
    console.error('请求失败');
  }
}
const formData = new FormData();
formData.append('a', 'x');
formData.append('b', 'y');
xhr.send(formData);
// [End http_request_post]