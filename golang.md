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

## TODO 

## openstack docker



## 其他计算机基础



### GC 

#### 引用计数回收算法 (简单有效)

不再需要 ==> 没有其他对象引用到它。

引用数为0则回收。

类似 linux 文件系统的 硬链接

**无法处理循环引用** IE 6，7

计数器消耗资源

主动放弃引用，打破循环引用

Python 以引用计数为主，标记、分代为辅。

#### 标记清除算法 Mark-Sweep法 (stop the world 避免程序状态被改变)

golang 1.5 以前使用

==> 对象是否可以获得，从根对象开始定期找所有引用的对象。

2012 现代浏览器都使用此算法。

#### 三色增量标记 Mark-Sweep法改进版 并发GC算法

可以在程序执行的同时进行收集

缺点：垃圾产生速度大于收集速度时，会垃圾越来越多

golang 1.5、1.6



#### 分代收集 GC 

也是 Mark-Sweep法的改进。


弱代假说，年轻的对象通常死得快

- 小阀值 		-- 触发0代收集 
		(使用复制算法[切尼算法]，年老代使用标记清除算法[标记压缩])
- 较大阀值 	-- 触发1代
- 更大阀值 	-- 触发2代


#### 复制收集

适用于在大量对象中，只有小部分存活的情况

将存活的对象复制到另外的空间中







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

内核态拥有最高特权。用户态不能使用危险操作。
	
用户态切换到内核态（系统调用，异常，外围设备中断）

都相当于执行了一个中断响应的过程，因为系统调用实际上最终是中断机制实现的


### 进程 线程 协程 协程实现方式

最初是多进程，上下文切换开销大，资源不共享，进程间通信。

后来发明多线程，进程内共享资源，上下文切换开销小。进程是线程的容器。

但一个线程挂掉，整个进程也会挂掉。

协程通过在线程中实现调度，避免了陷入内核级别的上下文切换造成的性能损失，进而突破了线程在IO上的性能瓶颈。

协程比线程要出现得早，在1963年首次提出, 但没有流行开来。


- 进程是系统进行资源分配和调度的一个独立单位。每个进程都有自己的独立内存空间，不同进程通过进程间通信来通信

- 线程是进程的一个实体,是CPU调度和分派的基本单位,它是比进程更小的能独立运行的基本单位，共享所属进程的资源，地址空间 Linux 2.6 开始支持多线程

- 协程是一种用户态的轻量级线程，协程的调度完全由用户控制。协程拥有自己的寄存器上下文和栈。

主动释放 CPU，或者由调度器管理(优先级等，阻塞就绪运行)

协程切换不过就是保存寄存器+跳转到另一个函数的半中间

#### golang 协程的实现原理

goroutine就是一段代码，一个函数入口，以及在堆上为其分配的一个堆栈。所以它非常廉价

goroutine是协作式调度的，如果goroutine会执行很长时间，而且不是通过等待读取或写入channel的数据来同步的话，就需要主动调用Gosched()来让出CPU



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

#### select	对多路同步I/O进行轮询

（1）每次调用select，都需要把fd集合从用户态拷贝到内核态，这个开销在fd很多时会很大

（2）同时每次调用select都需要在内核遍历传递进来的所有fd，这个开销在fd很多时也很大

（3）select支持的文件描述符数量太小了，默认是1024，可以改

#### poll(没有最大描述符限制)	I/O多路转换，同样是轮询

数据在传输过程中需要在应用程序地址空间和内核进行多次数据拷贝操作

#### epoll (select/poll 增强版，基于 callback)

- 没有最大文件描述符限制
- 不使用轮询，活跃的fd调 callback,跟总fd无关
- mmap 内存映射，内核和用户空间共享一块内存


**epoll 在 fd 剧增时，不会出现 select/poll 的线性性能下降**

epoll 适用于 连接数多 空闲连接多, fd 越多, epoll 优势越大

////////////////////// TODO


#### 进程间通信
- 管道
	
	命名管道，可无亲缘进程间通信
- 信号
- 消息队列
- 信号量
	
	信号量为0则代表资源不可访问。为1则代表允许一个线程访问。

	mutex 锁(互斥体) 相当于二值信号量。

	自旋锁 (一直循环检查是否释放锁)

- 内存共享
- 套接字
	
	同一机器进程间通信，不同机器进程间通信

	使用 protocol ip port 来唯一标识。

	1. TCP Stream Sockets 面向连接，保证数据分发，包间没有边界(粘包)

	2. UDP Datagram Sockets 无连接，不保证分发



### 进程切换

	从一个进程的运行转到另一个进程上运行，这个过程中经过下面这些变化：
	1. 保存处理机上下文，包括程序计数器和其他寄存器。
	2. 更新PCB(进程控制块)信息。
	3. 把进程的PCB移入相应的队列，如就绪、在某事件阻塞等队列。
	4. 选择另一个进程执行，并更新其PCB。
	5. 更新内存管理的数据结构。
	6. 恢复处理机上下文。


### 并发模型 CSP 等等
- 线程与锁并发模型
- actor 模型
	
	actor 之间通过消息通信，邮箱

- 函数式编程

- 通讯顺序进程（CSP）
	
	类似 actor 
	比 actor 灵活，每个 actor 和其邮箱紧密结合。
	CSP 的 channel 是第一对象，独立地创建，写入和读取
	
- 数据并行



### 分页内存管理 内存映射

#### 页面置换算法

- FIFO 先进先出
- OPT(MIN)算法

选未来最远将使用的页淘汰，是一种最优的方案，可以证明缺页数最小。

可惜，MIN需要知道将来发生的事，只能在理论中存在，实际不可应用。

- LRU(Least-Recently-Used)算法

用过去的历史预测将来，选最近最长时间没有使用的页淘汰(也称最近最少使用)。

LRU准确实现：计数器法，页码栈法。

由于代价较高，通常不使用准确实现，而是采用近似实现，例如Clock算法。

- 时钟（Clock）页面置换算法

页表循环链表，指针指向最老页，若标记为0，则换出到硬盘

若标记为1，则标记置0，指针下移。


内存抖动现象：页面的频繁更换，导致整个系统效率急剧下降，这个现象称为内存抖动（或颠簸）。抖动一般是内存分配算法不好，内存太小引或者程序的算法不佳引起的。

Belady现象：对有的页面置换算法，页错误率可能会随着分配帧数增加而增加。

FIFO会产生Belady异常。

栈式算法无Belady异常，LRU，LFU（最不经常使用），OPT都属于栈式算法。



### 树 数据库 索引实现方式 B-tree （磁盘 IO 次数，利用预读，一整页）

- 哈弗曼树(最优二叉树) ：

比如传输数据中包含 5 中字母 abcde。

用于不等长编码，用路径表示编码，频率越高的对象，放在路径越小的地方。

比如左分支为0，右分支为1. 对应字母用根节点到叶子的路径表示编码

- 平衡二叉树(对二叉排序树改进)

保持平衡，防止效率变低。

- B树(数据库索引) 平衡树

如果要发挥磁盘的全部特性，软件需要满足的技术特点：一次读取或写入固定大小的一块数据，并尽可能减少随机查找这个操作的次数（因为随机查找意味着随机寻道）

一次读写固定大小一整块数据，数组？

一种是数组满了就复制到新数组

另一种是数组大小不变，但增加数组个数 -- B 树的核心思路

查找定位数据IO 操作相对较少

1. 树高低  2. 数组 每个node都是一个数组

B 树节点有x个关键字，则其子节点有 x+1 个。

	#define m 1024
	struct BTNode;
	typedef struct BTNode *PBTNode;
	typedef struct BTNode *BTree;
	typedef struct BTNode *PBTree;
	struct BTNode {
		int keyNum; 		// 实际关键字个数，keyNum<m
		PBTNode parent; 	// 指向父节点
		PBTNode *ptr; 		// 子树指针向量 ：ptr[0]...ptr[keyNum]
		KeyType *key; 		// 关键字向量：key[0]...key[keyNum-1]
	}

- B+树

**所有的叶子节点包含所有的关键字信息。**

其他非叶子节点，仅含子树最大或最小关键字。可看做索引。


- R 树 (把B树扩展到了多维空间)

用矩形范围表示索引。




- 红黑树 R-B Tree

2-3-4树，(有2,3,4个子女的 B 树)

二叉查找树的基础上增加着色，使其保持相对平衡。时间复杂度最坏为 logn

1. 每个结点要么是红的要么是黑的。  

2. 根结点是黑的。  

3. 每个叶结点（叶结点即指树尾端NIL指针或NULL结点）都是黑的。  

4. 如果一个结点是红的，那么它的两个儿子都是黑的。  

5. 对于任意结点而言，其到叶结点树尾端NIL指针的每条路径都包含相同数目的黑节点 

左旋 右旋


## 实现守护进程(linux 服务: httpd, crond, mysqld)

守护进程脱离 shell 终端。不被终端打断，不在终端显示执行过程的信息。

启动它的父进程的运行环境隔离开来

- 创建子进程，父进程退出

	子进程变为孤儿进程，由 init 进程作为父进程收养。

- 子进程创建新的会话

	子进程便复制了原父进程的进程控制块（PCB），
	相应地继承了一些信息，包括会话、进程组、控制终端等信息

	需要调用 setsid 函数使子进程完全摆脱父进程的环境

	**进程组**：
	**会话**：

- 改变当前目录为根目录

	调用 chdir 函数切换到根目录
	原因：进程运行过程中，当前目录所在的文件系统是不能卸载的。

- 重设文件权限掩码

	子进程继承父进程的文件操作权限，umask 设置文件权限掩码。

- 关闭文件描述符

	由于守护进程脱离了终端运行，因此标准输入、标准输出、标准错误输出这3个文件描述符也要关闭

### 守护进程日志实现

	调用 openlog syslog closelog 等函数，
	linux 守护进程 **syslogd** 负责接收日志





# 七周七并发

并行计算和分布式计算

## 多处理器并行

- 共享内存多处理器系统(单机)
- 分布式内存的多处理器系统(多机，突破单机瓶颈/容错)

## 七个模型

### 线程与锁

	很多不足，**但它是其他模型的技术基础**

### 函数式编程
	
	抛弃可变状态

	没有可变状态，不使用锁就可以安全的访问

	不会由共享可变状态带来的种种问题


### Clojure 之道-分离标识与状态

### Actor

### 通信顺序进程
	
	CSP 与 actor 模型很相似，两者都基于消息传递。
	不过 CSP 侧重传递的通道，actor 侧重两端的实体。

### 数据级并行

### Lambda 架构