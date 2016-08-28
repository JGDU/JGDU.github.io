---
layout:     post
title:      reactjs 使用ajax 请求网络数据
date:       2016-04-24 15:31:19
author:     haolj
summary:    .
categories: objc
thumbnail: heart
tags:
 - NodeJS
 - reactjs
---



##reactjs 使用ajax 请求网络数据

使用 [`please-ajax`](https://www.npmjs.com/package/please-ajax)

```js
	handleRegister:function(){

		///--数据检查
		var rightful =  this.checkData();
		if (!rightful) {
			return;
		};


		var formData = new FormData();
		formData.append("userName", this.state.account);
		formData.append("userPassWord", this.state.password); 

		this.showLoading(true);
		plz.post('http://localhost:4400/register', formData,{
			success:function (e){
				this.showLoading(false);
				var msg = e['data']['msg'];
				this.setState({dialogText:msg,dialogShow:true});
			}.bind(this),
			error: function (e) {
				this.showLoading(false);
				this.setState({dialogText:'请求出错',dialogShow:true});
			}.bind(this),
		});
	},

```

##1号坑 
``` No 'Access-Control-Allow-Origin' header is present error ```

通过ajax访问服务器是被拒绝,其实是服务端验证问题.

**出坑**:通过中间键设置访问控制: ```Access-Control-Allow-Origin``` 为 所有

```js
app.use(function (req, res, next) {
    // Website you wish to allow to connect
    res.setHeader('Access-Control-Allow-Origin', "*");
    // // Request methods you wish to allow
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE');
    // // Request headers you wish to allow
    res.setHeader('Access-Control-Allow-Headers', 'X-Requested-With,content-type');
    // Set to true if you need the website to include cookies in the requests sent
    // to the API (e.g. in case you use sessions)
    res.setHeader('Access-Control-Allow-Credentials', true);

    // Pass to next layer of middleware
    next();
});

```

##2号坑
 `Uncaught TypeError: this.setState is not a function`

**出坑**:这里要通过bind进行设置 添加`.bind(this)`

导致从这个坑里蹲了很久的原因是 `				this.setState({dialogText:e,dialogShow:true});
`
刚开始这样调用,结果提示无法将objc添加到dialog组件中,原因是dialog中只能添加文本,而e是一个response对象,开始没有注意到这一错误,导致南辕北辙.
