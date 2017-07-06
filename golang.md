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
(这三个类型，属于隐式引用类型，占用空间少，基本不需要使用指针来传递)

### array
	
	a := [2]int{1,2}

	a := [...]int{1,2}

### slice 

	s := []byte{'a','b'}

	s := make([]int,5,10)

	使用 unsafe.Pointer 可以进行 cgo 中内存块，和 slice 的转换

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
	
	func login(w http.ResponseWriter, r *http.Request) {
		r.ParseForm()       //解析url传递的参数，对于POST则解析响应包的主体（request body）
		fmt.Println("method:", r.Method) //获取请求的方法
		if r.Method == "GET" {
			t, _ := template.ParseFiles("login.gtpl")
			log.Println(t.Execute(w, nil))
		} else {
			//请求的是登陆数据，那么执行登陆的逻辑判断
			fmt.Println("username:", r.Form["username"])
			fmt.Println("password:", r.Form["password"])
		}
	}

### 4.2 验证表单

- 空值：r.Form.Get()
- 数字：getint,err := strconv.Atoi(r.Form.Get("age"))

	if m, _ := regexp.MatchString("^[0-9]+$", r.Form.Get("age")); !m {
		return false
	}

- 中文

	m, _ := regexp.MatchString("^\\p{Han}+$", r.Form.Get("realname"))

- 英文 "^[a-zA-Z]+$"
- 电子邮件 `^([\w\.\_]{2,10})@(\w{1,}).([a-z]{2,4})$`
- 手机号码 `^(1[3|4|5|8][0-9]\d{4,8})$`

### 4.3 预防跨站脚本
- 验证所有输入
- 处理所有输出

	func HTMLEscape(w io.Writer, b []byte) //把b进行转义之后写到w
	func HTMLEscapeString(s string) string //转义s之后返回结果字符串
	func HTMLEscaper(args ...interface{}) string //支持多个参数一起转义，返回结果字符串

### 4.4 防止重复提交

- 存session中的隐藏字段
- js 禁用按钮

### 4.5 文件上传

	application/x-www-form-urlencoded   表示在发送前编码所有字符（默认）
	multipart/form-data	  不对字符编码。在使用包含文件上传控件的表单时，必须使用该值。
	text/plain	  空格转换为 "+" 加号，但不对特殊字符编码。

## 5 数据库（略）

## 6 session和数据存储

每个访客唯一标识 sessionID (存 cookies 或者 url 传递)

	cookie, _ := r.Cookie("username")
	fmt.Fprint(w, cookie)

	for _, cookie := range r.Cookies() {
		fmt.Fprint(w, cookie.Name)
	}

## 7 文本处理

## 8 web 服务 （REST、SOAP）


### context 包
	
goroutine 之间的信息传递，以及 goroutine 树的控制，终止退出。

异步的终止，比如 http 请求的终止。

	<- ctx.Done() // 使用 select 监听这个消息，决定程序退出。

- 不要把 Context 存在一个结构体当中，显式地传入函数。Context 变量需要作为第一个参数使用
- context.TODO 替代 nil



### mutex or channel
	
建议不用共享内存方式，而是用 chan 通信来共享。

- 使用 sync 包来共享内存，同步加锁

.Mutex 和 .RWMutex （读锁时，可读不可写，其他和互斥锁相同）

sync.Pool

sync.Once

sync.WaitGroup

sync.Cond



- 使用 chan 来通信


### GDB 调试（显示代码以及行号，断点，单步调试）

### golang pprof / linux pref

### sync
	
	sync.WaitGroup

## go 支持闭包

- Go语言支持闭包
- Go语言能通过escape analyze识别出变量的作用域，自动将变量在堆上分配。将闭包环境变量在堆上分配是Go实现闭包的基础。
- 返回闭包时并不是单纯返回一个函数，而是返回了一个结构体，记录下函数返回地址和引用的环境中的变量地址。


## Golang 注意点

- 自增语句是语句而不是表达式， j = i++ 非法，--i 也非法
- map的迭代顺序并不确定（有意为之，可防止利用哈希碰撞进行拒绝服务攻击）

布尔类型是false，整型是0，字符串是""，而指针，函数，interface，slice，channel和map的零值都是nil。


## 什么时候用 error 什么时候用 panic

错误指的是可能出现问题的地方出现了问题,意料之中。

异常是意料之外，**错误是业务过程的一部分，而异常不是 。**

异常 Panic：

	空指针引用
	下标越界
	除数为0
	不应该出现的分支，比如default
	输入不应该引起函数错误

在程序开发阶段，坚持速错,使用 panic 强制中断，尽快修复

嵌套过深，使用 panic 便于传递错误。


#### 关于 json

- Use json.Decoder if your data is coming from an io.Reader stream, or you need to decode multiple values from a stream of data.

- Use json.Unmarshal if you already have the JSON data in memory.