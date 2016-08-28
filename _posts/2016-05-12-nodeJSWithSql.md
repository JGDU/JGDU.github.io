---
layout:     post
title:      Node.js 结合 mysql 实现注册登陆
date:       2016-04-24 15:31:19
author:     haolj
summary:    .
categories: objc
thumbnail: heart
tags:
 - NodeJS
 - mysql
---


##NodeJS 结合 mysql 实现注册登陆
注: 本文为学习笔记,不足之处欢迎指出.


###开始前准备

+ 关于mysql的安装:[https://lvwenhan.com/mac/379.html](https://lvwenhan.com/mac/379.html)
+ mysqladmin命令详解:[http://auskangaroo.blog.51cto.com/740826/577687](http://auskangaroo.blog.51cto.com/740826/577687)

```js
///app.js

var mysql = require('mysql');

//数据库的连接 
var db = mysql.createConnection({
	host:'localhost',
	user:'root',
	password:'lj123',
	database:'sheeps',
});
```



创建表

```js

///DataBaseManager.js , 这里的db就是上面链接的db
exports.createTables = function(db){

	db.query(
		"CREATE TABLE  IF NOT EXISTS UserAC ("
	  +"UserName text NOT NULL,"
	  +"UserPassWord text NOT NULL,"
	  +"Salt text NOT NULL,"
	  +"UserID int(11) NOT NULL AUTO_INCREMENT,"
	  +"PRIMARY KEY (UserID)"
	  +")",
		function (err){
			console.log('用户验证表创建情况: ');
			if (err) {
				console.log (err);
				console.log('失败');
			}else{
				console.log('成功');
			}
		}
	);
};
```


添加一条用户数据

```js
///DataBaseManager.js

//添加一条用户验证信息
exports.addAUserForUserAC= function(db,userName,userPassWord,salt,handleErr,handleSuc){

	db.query(
		"INSERT INTO UserAC"
		+"(UserName,UserPassWord,Salt) VALUES (?,?,?) ",
		[userName,userPassWord,salt],
		function(err){
			if (err) {
				handleErr(err);
			}else{
				handleSuc();
			}
		}
	);
};

```

查看用户是否存在

```js
exports.findUserFromUsrAC=function(db,userName,userID,handleErr,handleSuc){

	if (userName) {

		db.query(
		"SELECT * FROM UserAC WHERE "
		+"UserName=?",
		[userName],
		function(err,data){
			if (err) {
				handleErr(err);
			}else{
				handleSuc(data);
			}
		});
		return
	};

	if (userID) {
		
		db.query(
		"SELECT * FROM UserAC WHERE "
		+"UserID=?",
		[userID],
		function(err,data){
			if (err) {
				handleErr(err);
			}else{
				handleSuc(data);
			}
		});
		return
	};

}
```


以上是注册的数据库操作(DataBaseManager.js): 检查用户是否存在, 插入数据.


在用户控制器(UserController.js)中调用上述数据库的方法,
检查用户是否存在,然后决定是否插入数据.

```js


var dataBaseManager = require('./DataBaseManager');

var register = function(db,userName,userPW,handlerErr,handlerSuc){

	dataBaseManager.addAUserForUserAC(db,userName,userPW,'salt1',
	function(err){
		handlerErr(err,'注册失败');
		// res.send(outPut.formatter(1,err,null,'注册失败'));
	},
	function(){
		handlerSuc(null,'注册成功');
		// res.send(outPut.formatter(1,null,'','注册成功'));
	});
};

exports.register=function(db,userName,userPW,handlerErr,handlerSuc){

	//检查用户是否存在
	dataBaseManager.findUserFromUsrAC(db,userName,null,function(err){
		handlerErr(err,'用户查找失败');
	},function(data){

		if (data.length!=0) {
			handlerErr(null,'用户已经存在');
			// res.send(outPut.formatter(0,'用户已经存在',null,'用户已经存在'));
		}else{
			register(db,userName,userPW,handlerErr,handlerSuc);
		}
	});

}

```

在app.js中调用用户控制器中的注册方法

```js

var userController = require('./controller/UserController');
...

app.post('/register',function(req,res){

	var userName= req.body.userName;
	var userPW = req.body.userPassWord;
	userController.register(db,userName,userPW,function(err,msg){
		res.send(outPut.formatter(0,err,null,msg));
	},function(data,msg){
		res.send(outPut.formatter(1,null,data,msg));
	});
})
```




登陆同理

```js
exports.loginUser=function(db,userName,userPW,handlerErr,handlerSuc){
	//检查用户是否存在
	dataBaseManager.findUserFromUsrAC(db,userName,null,function(err){
		handlerErr(err,'用户查找失败');
	},function(data){

		if (data.length!=0) {
			var user = data[0];
			var passWordRightful = (user['UserPassWord']==userPW);
			if (passWordRightful) {
				handlerSuc(null,'登陆成功');
			}else{
				handlerErr(null,'密码错误');
			}
			// res.send(outPut.formatter(0,'用户已经存在',null,'用户已经存在'));
		}else{
			handlerErr(null,'用户不存在');
		}
	});
};

```

这样就简单实现了用户的注册和登陆功能,没有加密,保存的是明文,显然是很不科学的,下面我们进行加密操作

**brcypt** 是一个跨平台文件加密工具

调用它的genSalt 可以生成指定位数的盐,
然后调用brcypt的hash()方法可以对密码和盐进行哈希处理.


```js

var register=function(db,userName,userPW,handlerErr,handlerSuc){

	bcrypt.genSalt(12, function(err, salt) {
		if (err) {
			handlerErr(err,'生产盐失败');
			return;
		};

    	bcrypt.hash(userPW, salt, function(err, hash) {

    		if (err) {
    			handlerErr(err,'添加盐失败');
    			return;
    		};
			dataBaseManager.addAUserForUserAC(db,userName,hash,salt,
			function(err){
				handlerErr(err,'注册失败');
				// res.send(outPut.formatter(1,err,null,'注册失败'));
			},
			function(){
				handlerSuc(null,'注册成功');
				// res.send(outPut.formatter(1,null,'','注册成功'));
			});
    	});
	});

};


```


登陆后验证密码
```js

var checkUserPW=function(userPW,user,unlawfulHandler,lawfulHandler){

	bcrypt.hash(userPW, user['Salt'], function(err, hash) {

	   if (err) {
	   	handlerErr(err,'检查失败');
	   	return;
	   };

	   if (user['UserPassWord']==hash) {
	   	lawfulHandler();
	   }else{
	   	unlawfulHandler();
	   }
	});
};

```