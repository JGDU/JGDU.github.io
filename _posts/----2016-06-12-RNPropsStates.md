---
layout:     post
title:     React Native Props与State
date:       2016-06-12 15:31:19
author:     haolj
summary:    .
categories: React Native
thumbnail: heart
tags:
 - mind
 - think
---


React Native Props与State之前要看看
RN中的声明组件的声明周期

  ![RN生命周期]({{site.url}} /source/RNLifeCycle.jpg)
  
  

Props 改变(在外部)的时候 会调用组件的Render()


\< mmma b={{this.satate.b}} > \</mmma>


想要改变一个组件的动画状态,

方案1:通过这只props 然后改变props对应的值
方案2:通过内部使用state关联,调用方法改变内部的state
不提倡方案3: 使用props 然后内部state接收外部props,然后在componentWillReaciveProps()中赋值给state
总之,如果使用props,就使用props,state 就是用方法调用,最好不要是用方案3
