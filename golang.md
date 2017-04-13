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


### GC 

Transaction Oriented Collector (TOC) 

空间换时间，拷贝空间，复制存活对象，删除整块旧空间

- 在编译期就指出很大一部分对象的生命周期

- 分代 GC
	
让年轻对象更快更容易回收，降低全局 GC 压力。

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


### 线程安全

	原子性，可见性，多线程操作相同资源

### 死锁

产生死锁四个必要条件

- 互斥条件 			（不可能破坏）
- 不可抢占条件		（实现困难，降低性能）
- 占有且申请条件 	（降低性能）
- 循环等待条件

银行家算法

在实际的操作系统中往往采用死锁的检测与恢复方法来排除死锁（借助外力，交警指挥）



## Golang 注意点

- 自增语句是语句而不是表达式， j = i++ 非法，--i 也非法
- map的迭代顺序并不确定（有意为之，可防止利用哈希碰撞进行拒绝服务攻击）


## 什么时候用 error 什么时候用 panic

## TODO 

## openstack docker



## 其他计算机基础

### tcp 三次握手过程

6 种标示位：SYN(synchronus建立联机) ACK(acknowledgement确认) PSH(push) FIN(finish) RST(reset) URG(urgent紧急)

	// seq 顺序号码，acknum 确认号码, xx和yy随机产生
	syn=1,seqA=xx. => 			(SYN_SEND)
	<= syn=1,ack=1,acknum=seqA+1,seqB=yy  (SYN_RECV)
	ack=1,acknum=seqB+1. => 	(ESTABLISHED)

### tcp 四次挥手

	FIN => (一方告知没有数据可以结束)
	<= ACK (另一方表示了解，但需要等待我准备好)
	<= FIN (另一方也可以结束了)
	ACK =>

### 操作系统 内核态 用户态

#### 硬中断 软中断
	
用户态切换到内核态（系统调用，异常，外围设备中断）

都相当于执行了一个中断响应的过程，因为系统调用实际上最终是中断机制实现的

#### 通信
- 管道
- 消息队列
- 信号量
- 内存共享
- 套接字

### 进程 线程 协程 协程实现方式

协程切换不过就是保存寄存器+跳转到另一个函数的半中间

### IO 模式


- 阻塞 I/O（blocking IO）
- 非阻塞 I/O（nonblocking IO）
- I/O 多路复用（ IO multiplexing）
- 信号驱动 I/O（ signal driven IO）
- 异步 I/O（asynchronous IO）

blocking IO的特点就是在IO执行的两个阶段都被block了。

nonblocking IO的特点是用户进程需要不断的主动询问kernel数据好了没有。

I/O 多路复用 或叫 事件驱动IO（ IO multiplexing）(select, poll, epoll)
和阻塞IO 类似，甚至更差，但可以同时处理多个 IO

异步 I/O
完成之后，kernel会给用户进程发送一个signal，告诉它read操作完成了

### select poll epoll IO多路复用

本质上都是同步I/O，因为他们都需要在读写事件就绪后自己负责进行读写，也就是说这个读写过程是阻塞的

就绪态 运行态 阻塞态

select	对多路同步I/O进行轮询

	调用后select函数会阻塞，直到有描述符就绪（有数据 可读、可写、或者有except），或者超时（timeout指定等待时间，如果立即返回设为null即可），函数返回。当select函数返回后，可以通过遍历fdset，来找到就绪的描述符


（1）每次调用select，都需要把fd集合从用户态拷贝到内核态，这个开销在fd很多时会很大

（2）同时每次调用select都需要在内核遍历传递进来的所有fd，这个开销在fd很多时也很大

（3）select支持的文件描述符数量太小了，默认是1024，可以改

poll(没有最大描述符限制)	I/O多路转换

select，poll实现需要自己不断轮询所有fd集合，直到设备就绪，期间可能要睡眠和唤醒多次交替。而epoll其实也需要调用epoll_wait不断轮询就绪链表，期间也可能多次睡眠和唤醒交替，但是它是设备就绪时，调用回调函数，把就绪fd放入就绪链表中，并唤醒在epoll_wait中进入睡眠的进程。虽然都要睡眠和交替，但是select和poll在“醒着”的时候要遍历整个fd集合，而epoll在“醒着”的时候只要判断一下就绪链表是否为空就行了，这节省了大量的CPU时间。这就是回调机制带来的性能提升。

select，poll每次调用都要把fd集合从用户态往内核态拷贝一次，并且要把current往设备等待队列中挂一次，而epoll只要一次拷贝，而且把current往等待队列上挂也只挂一次（在epoll_wait的开始，注意这里的等待队列并不是设备等待队列，只是一个epoll内部定义的等待队列）。这也能节省不少的开销。

缓存 I/O 的缺点：
数据在传输过程中需要在应用程序地址空间和内核进行多次数据拷贝操作

epoll (select/poll 增强版)

- 没有最大文件描述符限制
- 不使用轮询，活跃的fd调 callback,跟总fd无关
- mmap 内存映射，内核和用户空间共享一块内存

epoll 在 fd 剧增时，不会出现 select/poll 的线性性能下降

epoll 适用于 连接数多 空闲连接多


### 进程切换

	从一个进程的运行转到另一个进程上运行，这个过程中经过下面这些变化：
	1. 保存处理机上下文，包括程序计数器和其他寄存器。
	2. 更新PCB信息。
	3. 把进程的PCB移入相应的队列，如就绪、在某事件阻塞等队列。
	4. 选择另一个进程执行，并更新其PCB。
	5. 更新内存管理的数据结构。
	6. 恢复处理机上下文。

### 信号量

### 数据库 索引实现方式 B-tree （磁盘 IO 次数，利用预读，一整页）

### 并发模型 CSP 等等

### 分页内存管理 内存映射
