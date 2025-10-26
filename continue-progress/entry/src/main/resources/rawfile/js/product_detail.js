let productList = [{
		'id': 1,
		'img': 'imgs/ic_1.png',
		'price': 4488
	},
	{
		'id': 2,
		'img': 'imgs/ic_2.png',
		'price': 4488
	},
	{
		'id': 3,
		'img': 'imgs/ic_3.png',
		'price': 4488
	},
	{
		'id': 4,
		'img': 'imgs/ic_4.png',
		'price': 4488
	},
	{
		'id': 5,
		'img': 'imgs/ic_5.png',
		'price': 4488
	},
	{
		'id': 6,
		'img': 'imgs/ic_6.png',
		'price': 4488
	},
	{
		'id': 7,
		'img': 'imgs/ic_7.png',
		'price': 4488
	},
	{
		'id': 8,
		'img': 'imgs/ic_8.png',
		'price': 4488
	},
	{
		'id': 9,
		'img': 'imgs/ic_9.png',
		'price': 4488
	},
	{
		'id': 10,
		'img': 'imgs/ic_10.png',
		'price': 4488
	},
	{
		'id': 11,
		'img': 'imgs/ic_11.png',
		'price': 4488
	},
	{
		'id': 12,
		'img': 'imgs/ic_12.png',
		'price': 4488
	},
	{
		'id': 13,
		'img': 'imgs/ic_13.png',
		'price': 4488
	},
	{
		'id': 14,
		'img': 'imgs/ic_14.png',
		'price': 4488
	},
	{
		'id': 15,
		'img': 'imgs/ic_15.png',
		'price': 4488
	}
];

let urlSearchParams = new URLSearchParams(window.location.search);
let productIndex = urlSearchParams.get('index');
let topHeight = urlSearchParams.get('topHeight');
let bottomHeight = urlSearchParams.get('bottomHeight');
let productDetail = productList[productIndex];
let swiperStr = '<div class="imgDiv"><img alt="" class="showing" src="' + productDetail.img + '" /></div>';
for (let i = 0; i < 4; i++) {
	swiperStr += '<div class="imgDiv"><img alt="" src="imgs/ic_' + ((productDetail.id + i) % 6 + 1) + '.png" /></div>';
}

document.getElementById('swiper').innerHTML = swiperStr;
document.getElementById('price').innerHTML = '<span>¥ </span>' + productDetail.price;

if (window.screen.width >= 840) {
	document.getElementById('product-desc').style.paddingTop = Number.parseInt(topHeight) + 'px';
} else {
	document.getElementById('slider').style.paddingTop = topHeight + 'px';
}


const itemCount = 5; 
let currentIndex = 0;
const slider = document.querySelector('#swiper');

let sliderItems = slider.getElementsByClassName('imgDiv');

let firstItem = sliderItems[0].cloneNode(true);
let lastItem = sliderItems[sliderItems.length - 1].cloneNode(true);
slider.appendChild(firstItem);
slider.prepend(lastItem);

if (window.screen.width > 600 && window.screen.width < 840) {
	slider.style.transform = `translateX(-25%)`;
}
function autoScroll() {
	let sliderItemWidth = sliderItems[0].offsetWidth;
	currentIndex++;
	debugger;

	if (slider.clientWidth > 600 && slider.clientWidth < 840) {
		slider.style.transform = `translateX(-${currentIndex * 50 + 25}%)`;
	} else {
		slider.style.transform = `translateX(-${currentIndex * sliderItemWidth}px)`;
	}

	if (currentIndex === itemCount) {
		setTimeout(() => {
			slider.style.transition = 'none'; 
			slider.style.transform = 'translateX(0)';
			currentIndex = 0;
			void slider.offsetWidth;
			slider.style.transition = 'transform 0.5s ease-in-out';
		}, 500);
	}
}

setInterval(autoScroll, 2000);

window.addEventListener('resize', () => {
	document.getElementById('product-desc').style.paddingTop = Number.parseInt(topHeight) + 'px';
});

function orderConfirm() {
	arkTSFunObj.jumpOrderConfirm(JSON.stringify(productDetail));
}

function setLanguage(lastLang) {
	if (lastLang.includes('zh')) {
		document.getElementById('btn-to-buy').innerHTML = '购买';
	} else {
		document.getElementById('btn-add-cart').innerHTML = 'Add to Cart';
		document.getElementById('btn-to-buy').innerHTML = 'Buy';
	}
}