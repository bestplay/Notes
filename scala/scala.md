SCALA笔记
=========

## 第一章

	val 常亮
	var 变量
	七种类型： Byte, Char, Short, Int, Long, Float, Double
	不支持 ++ （like python）, use '+='
	允许定义操作符。

## 第二章 控制结构和函数
	- scala 中 表达式和函数都有值。
		val s = if(x>0) 1 else -1;
		若if,else 两个值类型不同。则使用其二者的公共超类，like Any。
	- scala 的 for ：
		for (i <- 1 to n)
			r = r * i 
		让变量 i 遍历 <- 右边表达式的所有值。i不用指定类型，为集合元素的类型
		scala 没有 break 或 continue 语句。
		for (i <- 1 to 3; i <- 1 to 3 if i != j) print ((10 * i + j) + " ")
		for (i <- 1 to 10) yield i % 3
		for 推导式

	- 函数
		def abs(x: Double) = if (x >= 0) x else -x
		变长参数 def sum(args: Int *) = {}
		val s = sum(1,2,3)
		val s = sum(1 to 3: _*) 解开序列作为参数
	- 过程 （类型为 Unit）
		def box(s:String) {}  // 没有等号
		def box(s:String): Unit = {}
	- lazy
		lazy val words = scala.io.Source.fromFile("./words").mkString
		初始化被推迟到，首次对它的取值
	- 异常
		throw 表达式的类型为 Nothing 
		try {...} catch{...} finally {...}

## 第三章 数组相关操作
	固定长度用 Array, 可变数组用 ArrayBuffer
	用()访问数组元素
	用for(elem <- arr) 遍历数组
	用for(elem <- arr if ...) ... yield ... 将原数组转为新数组

	- 定长数组
		val nums = new Array[Int](10)	初始化为0
		val a = new Array[String](10)	初始化为 null
		val s = Arrary("Hello","world")	提供初始值，不需要new

	- 变长数组 ArrayBuffer
		import scala.collection.mutable.ArrayBuffer

		**未完待续**

## 第四章 映射和元组
	哈希表--映射--键值对--元组
	val scores = Map("Alice" -> 10, "Bob" -> 8)  // 不可变
	val scores = scala.collection.mutable.Map()  // 可变
	scores("Alice"); scores("Alice") = 9;

	- 迭代映射
		for((k,v) <- 映射 ) 处理 k 和 v
		scores.keySet ; scores.values
		for((k,v) <- 映射) yield (v,k)  // 反转映射

	- 已排序映射
		映射：哈希表或者平衡树。
		Scala 给的是 哈希表 实现 映射

		要得到一个不可变的树形映射：
		val scores = scala.collections.immutable.SortedMap("Alice" -> 10, "Fred" -> 7)
		按插入顺序访问所有键，使用 LinkedHashMap
		val months = scala.collection.mutable.LinkedHashMap()

	- 与 Java 的互操作

		**未完待续**

	- 元组 tuple
		val t = (1, 3.14, "Fred")
		Tuple3[Int, Double, java.lang.String]  /  (Int, Double, java.lang.String)

		val second = t._2 	// 访问元组的元素。元组起始位置为 1 非 0
		val (first, second, third) = t 	// 模式匹配获取元组元素

	- 拉链操作
		val a1 = Array("a","b","c")
		val a2 = Array(1,2,3)
		val pairs = a1.zip(a2);  // Array(("a",1),("b",2),("c",3))


## 第五章 类
	class Counter{
		private var value = 0
		def increment(){ value += 1 }
		def current() = value		
	}
	val myCounter = new Counter   // 或 new Counter()
	myCounter.increment()
	println(myCounter.current)	

	### 关于 getter 和 setter
		getter 和 setter 存在的意义，可以在取值改值是做出设定和限制。

			class Person {
				private var privateAge = 0 

				def age = privateAge
				def age_ = (newValue: Int) {
					if (newValue > privateAge) privateAge = newVAlue;
				}
			}

		scala 对每个字段生成 getter 和 setter 方法。但你可以控制这个过程。
		- 私有字段，则 getter 和 setter 方法也是私有的
		- val 字段，则只有 getter
		- 若声明为 private[this], 则没有 getter 和 setter 方法。
		- private[类名] 给指定类赋予访问权限。当前类或者包含该类的外部类

		JavaBeans 版的 getter 和 setter 方法
		@BeanProperty var name: String = _ 
			- name: String
			- name_ = (newValue: String): Unit
			- getName(): String
			- setName(newValue: String): Unit

	### 辅助构造器
	- 辅助构造器的名称为 this （在java或C++中，构造器的名称和类名相同，但当修改类名时就补台方便了）
	- 每个辅助构造器都必须以一个对先前已定义的其他辅助构造器或者主构造器的调用开始

		class Person {
			private var name = ""
			private var age = 0

			def this(name: String) {	// 一个辅助构造器
				this() // 调用主构造器
				this.name = name
			}

			def this(name: String, age: Int) { // 另一个辅助构造器
				this(name) // 调用前一个辅助构造器
				this.age = age
			}
		}

		构建对象：
			val p1 = new Person // 主构造器
			val p2 = new Person("Fred")  // 第一个辅助构造器
			val p3 = new Person("Fred", 42)  // 第二个辅助构造器

	### 主构造器
		主构造器和类交织在一起。

		class Person(val name: String = "", val age: Int = 0)

		- 若果不带val或var的参数至少被一个方法使用，它被升格为字段，对象私有。
			
			class Person(name: String, age: Int){
				def description = name + " is " + age + " years old"
			}

			字段name和age，等同于 private[this] val 字段的效果

		- 否则该参数不被保存为字段。仅作为被主构造器中代码访问的参数
	
		**主构造器参数**						|	生成的字段 / 方法
		-----------------------------------------------------------------
		name: String 						| 有方法使用时，为对象私有字段
		-----------------------------------------------------------------
		private val/var name:String 		| 私有字段，私有getter/setter
		-----------------------------------------------------------------
		val/var name String 				| 私有字段，公有getter/setter
		-----------------------------------------------------------------
		@BeanProperty val/var name: String 	| 私有字段，公有Scala版和JavaBeans版的getter和setter


		**让主构造器变成私有的**
		
		class Person private(val id: Int){ ... }

		这样就必须通过辅助构造器来构造 Person 对象了。

	### 嵌套类

## 对象
	### 单例对象

	### 半生对象

	### 扩展类或特质的对象

	### apply 方法

	### 应用程序对象

	### 枚举

	**未完待续**

## 包和引入
	**未完待续**

## 继承
	**未完待续**

## 文件和正则表达式
	### 读取行

		scala.io.Source对象的getLines方法

		import scala.io.Source
		val source = Source.fromFile("myfile.txt","UTF-8")

		val lineIterator = source.getLines
		for (l <- lineIterator ) 处理 l
		
		或者你可以对迭代器应用 toArray 或 toBuffer 方法。

		val lines = source.getLines.toArrary

		把整个文件读成一个字符串
		val contents = source.mkString

		用完source 需要 close
	### 读取字符

		for (c <- source ) 处理 c

	### 读取词法单元和数字

		val tokens = source.mkString.split("\\s+")		

	### 从URL或其他源读取
		val source1 = Source.fromURL("http://www.baidu.com","UTF-8")
		val source2 = Source.fromString("Hello, World!")
		val source3 = Source.stdin
	### 读取二进制文件
		Scala没有提供二进制文件方法。需要使用 Java 类库

		val file = new File(filename)
		val in = new FileInputStream(file)
		val bytes = new Array[byte](file.length.toInt)
		in.read(bytes)
		int.close()

	### 写入文本文件
		Scala没有内建写入文件支持，需要使用 java.io.PrintWriter

		val out = new PrintWriter("numbers.txt")
		for(i <- 1 to 100) out.println(i)
		out.close()

	### 访问目录
		手动编写遍历目录下子目录：

		import java.io.File
		def subdirs(dir: File): Iterator[File] = {
			val children = dir.listFiles.filter(_.isDirectory)
			children.toIterator ++ children.toIterator.flatMap(subdirs _)
		}

		for (d <- subdirs(dir)) 处理 d

	### 序列化

		序列化 scala 代码

	### 进程控制
		import sys.process._
		"ls -al .." !
		"ls -al .." #| "grep sec" !
		"ls -al .." #> new File("output.txt") ! 	// 输出重定向到文件
		"ls -al .." #>> new File("output.txt") ! 	// 文件末尾追加
		"grep sec" #< new File("output.txt") !		// 把某个文件的内容作为输入
		"grep Scala" #< new URL("http://www.baidu.com") !	// 重URL重定向作为输入

		p #&& q 		p #|| q 

	### 正则表达式

		scala.util.matching 的 Regex 类
		String 类的r方法构造 正则 Regex 对象。

		val numPattern = "[0-9]+".r
		若包含反斜杠或引号。可使用原始字符串： """..."""
		val wsnumwsPattern = """\s+[0-9]+\s+""".r

		for (matchString <- numPattern.findAllIn("99 bottles, 98 bottles"))
			处理 matchString

		findFirstIn 	// 找到首个匹配项

## 特质
	**未完待续**

## 操作符
	**未完待续**













		

