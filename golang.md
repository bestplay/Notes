Golang 笔记
============

## 2.2 基础

### new make 

new 仅仅分配空间，置零，返回指针

	var i int 
	&i
	===>
	new(int)

make 创建 slice map channel，返回值

### array
	
	a := [2]int{1,2}

	a := [...]int{1,2}

### slice 

	s := []byte{'a','b'}

	s := make([]int,5,10)

### map 
	
	m := make(map[string]int)

### 返回局部变量

go 中，局部变量在函数返回后仍被使用，则从 Heap 中分配内存，而不是 Stack 中。

### map 不是线程安全，并发时，需要 mutex lock

## 2.3 流程和函数

可以使用 goto 但请小心

break continue 均可配合标号使用

	for k,v := range map{
		fmt.Println(k,v)
	}

switch case 类型必须相同，默认自带 break, 使用 fallthrough 强制不跳出

函数可以有多个返回值

变参 func myfunc(arg ...int){}. 其中 arg 是一个 slice

### defer
	
多个 defer 按照**逆序**执行

### 函数作为值，类型

type testInt func(int) bool

func filter(slice []int, f testInt) []int{}

或者不限定函数类型，将函数作为变量传递。

func abc(f func()){}

### Panic 和 Recover

panic 逐级终止程序，但 defer 正常执行

recover 只能在 defer 中调用，捕获到 panic 的值，并恢复

	func throwsPanic(f func()) (b bool) {
		defer func() {
			if x := recover(); x != nil {
				b = true
			}
		}()
		f() //执行函数f，如果f中出现了panic，那么就可以恢复回来
		return
	}

### main 和 init 函数

都没有参数和返回值

init 可应用于所有的包。const->var->init()->main()

### import 

相对路径（不推荐）

绝对路径

省略包名（调用时）

	import(
		. "fmt" 			// 省略包名
		ctx "context" 		// 别名
		_ "mymysql/godrv" 	// 不使用包的函数，而调用 init()
	)

## 2.4 struct 类型

	type person struct {
		name string
		age int
	}

	var P person
	P.name = ""

	P := new(person)
	P := person{age:24, name:"Tom"}
	P := person{"Tom", 25}

### struct 匿名字段
	
	当匿名字段为 struct 时，引入所有字段

	相同字段名，最外层优先
	
## 2.5 面向对象

附属在类型上的 method (可用于通过 type struct 等自定义的类型)
	
	func (r ReceiverType) funcName(parameters) (results)

虽然method的名字一模一样，但是如果接收者不一样，那么method就不一样

method里面可以访问接收者的字段

Receiver 可以传值，或者传指针。(指针可以改变 Receiver 的值)

如果匿名字段实现了 method, 包含它的也可以调用这个 method

重写 method 覆盖(同匿名字段的覆盖)

## 2.6 interface (duck-typing)

任意类型都实现了空 interface (interface{})

	fmt.Println

		type Stringer interface {
		 String() string
		}

### 判断类型

Comma-ok 断言

	value, ok = element.(T) 	// element 是 interface 变量
	value, ok := element.(int)

switch 测试

	switch value := element.(type) {
		case int:
			fmt.Printf("list[%d] is an int and its value is %d\n", index, value)
		case string:
			fmt.Printf("list[%d] is a string and its value is %s\n", index, value)
		case Person:
			fmt.Printf("list[%d] is a Person and its value is %s\n", index, value)
		default:
			fmt.Println("list[%d] is of a different type", index)
	}

### 内嵌 interface (类似struct的匿名字段)

### 反射 reflect (待完善)

	t := reflect.TypeOf(i)    //得到类型的元数据,通过t我们能获取类型定义里面的所有元素
	v := reflect.ValueOf(i)   //得到实际的值，通过v我们获取存储在里面的值，还可以去改变值

## 2.7 并发 gorouting

	chan T          // 可以接收和发送类型为 T 的数据
	chan<- float64  // 只可以用来发送 float64 类型的数据
	<-chan int      // 只可以用来接收 int 类型的数据

### 无缓冲channels
	
无缓冲的 channel 发送和接收都是阻塞的，除非另一端已经准备好。(用作同步)

	ci := make(chan int)
	cs := make(chan string)
	cf := make(chan interface{})
	
	ch <- v    // 发送v到channel ch.
	v := <-ch  // 从ch中接收数据，并赋值给v

### Buffered Channels

	ch:= make(chan bool, 4)

### Range 和 Close

	// 像操作 slice / map 一样操作 channel。(直到chan被显式关闭)
	for i := range ch {
		fmt.Println(i)
	}

	// 在生产者的地方 close(chan)，而不是消费的地方

	close 用于没有数据发送，或者显式结束 range 循环

	close 后，不可写入，但可读取剩下的值，直到为空

	v, ok := <-ch 测试channel是否被关闭

### select 

select默认是阻塞的，只有当监听的channel中有发送或接收可以进行时才会运行

	select {
		case i := <-c:
			// use i
		default:
			// 当c阻塞的时候执行这里
	}


	select {
		case v := <- c:
			println(v)
		case <- time.After(5 * time.Second): 	// 超时
			println("timeout")
			o <- true
			break
	}

### runtime goroutine

runtime 包中有几个处理 goroutine 的函数
	
	- Goexit 		退出当前goroutine, defer 还会执行
	- Gosched 		让出CPU
	- NumCPU
	- NumGoroutine
	- GOMAXPROCS

## 3.2 搭建 Web 服务
	func sayhelloName(w http.ResponseWriter, r *http.Request) {}
	
	func main() {
		http.HandleFunc("/", sayhelloName) //设置访问的路由
		err := http.ListenAndServe(":9090", nil) //设置监听的端口
		if err != nil {
			log.Fatal("ListenAndServe: ", err)
		}
	}
## 3.3 http 包

- 创建Listen Socket, 监听指定的端口, 等待客户端请求到来。

- Listen Socket接受客户端的请求, 得到Client Socket, 接下来通过Client Socket与客户端通信。

- 处理客户端的请求, 首先从Client Socket读取HTTP请求的协议头, 如果是POST方法, 还可能要读取客户端提交的数据, 然后交给相应的handler处理请求, handler处理完毕准备好客户端需要的数据, 通过Client Socket写给客户端。

## 3.4 http 包详解

	package main

	import (
		"fmt"
		"net/http"
	)

	type MyMux struct {
	}

	func (p *MyMux) ServeHTTP(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path == "/" {
			sayhelloName(w, r)
			return
		}
		http.NotFound(w, r)
		return
	}

	func sayhelloName(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Hello myroute!")
	}

	func main() {
		mux := &MyMux{}
		http.ListenAndServe(":9090", mux)
	}

## 4 表单













## TODO 

	- GC 
	- docker
	- sync
	- chan
	- select
	- .type
	- 反射 reflect
	- 线程安全

