[TOC]

# 网页特效

## 元素偏移量 offset 系列

offset 翻译过来就是偏移量，我们使用offset系列相关属性可以**动态的**得到该元素的位置（偏移）、大小等。

- 获得元素距离带有定位父元素的位置
- 可以获取元素自身的宽度和高度
- 注意：返回的数值不带单位

offset 系列常用属性:

| offset 系列属性      | 作用                                                         |
| -------------------- | ------------------------------------------------------------ |
| element.offsetParent | 返回作为该元素带有定位的父级元素如果父级都没有定位则返回body |
| element.offsetTop    | 返回元素相对带有定位父元素上方的偏移                         |
| element.offsetLeft   | 返回元素相对带有定位父元素左边框的偏移                       |
| element.offsetWidth  | 返回自身包括padding、边框、内容区的宽度，返回数值不带单位    |
| element.offsetHeight | 返回自身包括padding、边框、内容区的高度，返回数值不带单位    |

### offset 和 style 区别

| offset      | style                                                         |
| -------------------- | ------------------------------------------------------------ |
| offset 可以得到任意样式表中的样式值 | style 只能得到行内样式表中的样式值 |
| offset 系列获得的数值没有单位    | style.width 获得的是带有单位的字符串           |
| offsetWidth 包含 padding + border + width   | style.width 获得不包括padding + border的值    |
| offsetWidth 等属性是只读属性，只能获取不能修改  | style.width 是可读写属性，可以获取也可以赋值  |
| 我们想要获取元素的大小位置，用 offset 更合适 |想要给元素更改值，用style 改变    |

### 案例：获取鼠标在盒子里的位置

#### 案例分析：

- 我们在盒子里面移动鼠标，想要获取鼠标距离盒子左边和上面的距离
- 首先得到鼠标在页面中的坐标（ｅ．ｐａｇｅＸ　和　ｅ．ｐａｇｅＹ）
- 其次得到盒子在页面中的距离（ｂｏｘ．ｏｆｆｓｅｔＬｅｆｔ　和　ｂｏｘ．ｏｆｆｓｅｔＴｏｐ）
- 用鼠标距离页面的坐标减去盒子和页面边框的距离，就是鼠标在盒子里的坐标

```html
<div class="box"></div>
<script>
    var box = document.querySelector('.box');
    box.addEventListener('mousemove', function(e) {
        var x = e.pageX - this.offsetLeft;
        var y = e.pageY - this.offsetTop;
        box.innerHTML = ('X坐标是' + x + '；Y坐标是' + y);
    });
</script>
```

### 案例：拖动模态框

#### 案例要求：

- 点击弹出层，会弹出模态框，并且显示灰色半透明测遮挡层
- 点击关闭按钮，可以关闭模态框，并且同时关闭灰色半透明遮挡层
- 鼠标放到模态框最上面一行，可以按住鼠标拖动模态框在页面中移动
- 鼠标松开，模态框停止移动

#### 案例分析：

- 点击弹出层，模态框和遮挡层就会显示出来 display:block
- 点击关闭按钮，模态框和遮挡层就会隐藏起来 display:none
- 在页面中拖拽的原理：鼠标按下并移动，之后松开鼠标，出发事件：鼠标按下 mousedown  鼠标移动 mousemove  鼠标松开  mouseup
- 鼠标按下触发的事件源是最上面的一行，就是 id 为 title 
- 鼠标的坐标减去鼠标在盒子内的坐标，才是模态框真正的坐标

### 案例：京东放大镜效果

#### 案例要求：

- 真个案例可以分为三个功能模块
- 鼠标经过小图片盒子，黄色的遮挡层和大图片盒子显示，离开隐藏两个盒子
- 黄色的遮挡层跟随鼠标
- 移动黄色遮挡层，大图片跟随移动功能

#### 案例分析：

- 黄色的遮挡层跟随鼠标功能。
- 把鼠标坐标给遮挡层不合适。因为遮挡层坐标以父盒子为准。
	- 首先是获得鼠标在盒子的坐标。
	- 之后把数值给遮挡层做为left和top值。
	- 此时用到鼠标移动事件，但是还是在小图片盒子内移动。
	- 发现，遮挡层位置不对，需要再减去盒子自身高度和宽度的一半。
	- 遮挡层不能超出小图片盒子范围。
		- 如果小于零，就把坐标设置为0
		- 如果大于遮挡层最大的移动距离，就把坐标设置为最大的移动距离
		- 遮挡层的最大移动距离：小图片盒子宽度减去遮挡层盒子宽度
- 大图片移动距离=遮挡层移动距离 * 大图片最大移动距离 / 遮挡层最大移动距离

## 元素可视区 client 系列

client 翻译过来就是客户端，我们使用 client 系列的相关属性来获取元素可是去的相关信息。通过 client 系列的相关属性可以动态的得到该元素的边框大小、元素大小等。

| client 系列属性      | 作用                                                         |
| -------------------- | ------------------------------------------------------------ |
| element.clientTop    | 返回元素上边框的大小      |
| element.clientLeft   | 返回元素左边框的大小      |
| element.clientWidth  | 返回自身包括padding、内容区的宽度，不含边框，返回数值不带单位    |
| element.clientHeight | 返回自身包括padding、内容区的高度，不含边框，返回数值不带单位    |

## 立即执行函数

不需要调用，立马能够自己执行的函数。
立即执行函数的作用就是独立创建了一个作用域，避免了命名冲突的问题。

### 写法

`(function() {})()` 或者 `(function(){}())`。






更新到p111