---
layout:     post
title:     我的iOS架构之道
author:     haolj
summary:    .
categories: objc
thumbnail: heart
tags:
 - design patterns
 - viper
 - mvc
 - mvvm
---



##编程之初 - 有序却无序
最初参加工作,觉得架构就是代码的文件夹布局.自认为了解MVC,却被苹果的ViewController绕的头晕.自以为有一套正确的编程模式,其实却是一套枷锁而已.
##启发 - 设计模式的学习
后来买了几本设计模式的书,最初的一本《iOS编程之道》已经丢在13号线地铁上了,不过的确收获颇多.但是因为讲的太通用,反而不能很快很好地应用到实际编程中.另一本不错的是《HeaderFirst设计模式》.
##尝试改变 - mvvm
了解到MVVM得时候,已经是15年了,通过协议通讯,职责分明,在项目的一个中间版本中使用过.

角色主要分为__View__,__ViewModel__,__Model__

它给我的最重要的启发是:苹果的ViewController 并不是传统意义的controller,而是containerViewController(拥有一个容器视图的控制器),我发现以前读的那些书,那些设计模式,好像忽然一下通了.
 
##回去 - mvc
我发现自己以前对mvc的理解是不正确的,尝试着用新的想法做了一些东西.那种感觉真的很棒.非严格意义上, UIViewController 是对屏幕旋转,摇晃等操作的统一处理的场所.而非传统控制器的功能,任何视图都可以对应一个自己的控制器.(后来理解为模块化编程)

##新的尝试 - viper的实践
viper - v i p e r

视图 交互者 呈现者 视图 和 路由

学习关于viper相关的时候,真的费了很大的力气,读了很多英文文章,看了许多点评,因为好奇心太强,往往忽略了事情本身的缺点.我真正使用viper的时候其实并没有真正理解它.一段时间过后,他的缺点开始暴露出来,类太多,事件流跳转频繁,关联复杂.他的好处也很多,协议通信,模块化开发,单一职能.



##头脑过热后的思考

模块化开发

没错,因为对模块化开发没有足够多的理解,错误的以为Viper是每一个控制器对应一套 v ,i, p, e, r, 所以导致了类的爆炸.

通知中心为例子

思路一: 每个页面有自己的一套viper, 每个页面都是一个模块 ,就导致了viper的类太多,单个功能太少.管理成本增加.

思路二: 几个页面公用一个presenter,wireframe,interactor,复杂度太高.

思路三: 先无视操作,只注重跳转,那么会用到wireFrame 和 UIViewController,UITabbaVC,UIPageVC,UINavgationVC等系统控制器
通过wireFrame和系统视图控制器可以很好的跳转.

展示

添加视图,传统的MVC中View被一个继承自NSObject
的控制器所持有,并且在控制器中被创建,此时如果View需要更换的话可能比较麻烦,viper把该控制器分为了 view 和 presenter 彼此遵循协议.而不进行强制关联.

数据

添加数据,请求数据和本地数据读取使用Interactor
交互器在应用中代表着一个独立的用例。交互器中的工作应当独立与任何用户界面.所以一个Interactor不应该对应一个界面,他有可能对应多个界面,甚至一个界面的一个组件.


现在理想的结构如下

UIViewController对wireframe持有,并且持有一个Presenter,因为UIViewController也有一个View. presenter对interactor持有 .

wireframe还可能提供给UIViewController其他的 presenter ,暂时成为 presenter2 被一个View持有 , 该View 也被wireframe 创建 
并且与presenter2关联, view将会被添加到UIViewController 的View上.

