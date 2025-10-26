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
let topHeight = 0;
let bottomHeight = 0;

function setTopHeight(topHeightFromArkTs, bottomHeightFromArkTs) {
	topHeight = topHeightFromArkTs;
	bottomHeight = bottomHeightFromArkTs;
	document.getElementById('nav').style.marginTop = topHeight + 'px';
	document.getElementById('productList').style.paddingBottom = bottomHeightFromArkTs + 56 + 'px';
}

function addProductList() {
	let list = '';
	for (let i = 0; i < productList.length; i++) {
		list += `<li>`;
		list += `<img alt='' src='${productList[i].img}' />`;
		list += '<div>';
		list += `<p id='p1'></p>`;
		list += `<p id='p2'></p>`;
		list += `<span><span>¥</span> ${productList[i].price}</span>`;
		list += '</div>';
		list += '</li>';

		let tmp = document.getElementById('productList');
		tmp.innerHTML = list;
	}
}

function setLanguage(lastLang) {
	if (lastLang.includes('zh')) {
		document.getElementById('nav').innerHTML = '精选好物';
	} else {
		document.getElementById('nav').innerHTML = 'Prime Goods';
	}
}

addProductList();

function jumpDetail(index) {
	window.location.href = 'product_detail.html?index=' + index + '&topHeight=' + topHeight + '&bottomHeight=' +
		bottomHeight;
}