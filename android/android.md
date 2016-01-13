# Android
任何开发语言，先走一遍官方的 getting Start


## 第一章
	Linux Kernel -- Libraries -- Application framework -- Applications

	### 四大组件： 
		+ Activity
		+ Service
		+ Broadcast
		+ Content Provider

		四大组件使用前，都需在 AndroidManifest.xml 中注册

		project.properties 通过一行代码指定编译程序时使用的 SDK 版本

		指定主要 Activity :
		<activity
			android:name="com.test.helloworld.HelloWorldActivity"
			android:label="@string/app_name" >
			<intent-filter>
				<action android:name="android.intent.action.MAIN" />
				<category android:name="android.intent.category.LAUNCHER" />
			</intent-filter>
		</activity>

	### 逻辑与视图分离

		res/value/string xml 文件中保存字符串值（防止硬编码，支持国际化）

		两种访问方式：
			+ R.string.key
			+ @string/key

	### LogCat

		Log.v 	-- verbose
		Log.d 	-- debug
		Log.i 	-- info
		Log.w 	-- warn
		Log.e 	-- error

## 第二章 活动 Activity
	
	### 所有的活动都要再 AndroidManifest.xml 中注册才能生效
		<activity
		 android:name=".FirstActivity"
		 android:label="This is FirstActivity" >
		 </activity>
		 ".FirstActivity" == 包名 + ".FirstActivity"

	### 隐藏标题栏，onCreate 中：
		 	requestWindowFeature(Window.FEATURE_NO_TITLE);

	### 使用 Menu
		public boolean onCreateOptionsMenu(Menu menu)
		public boolean onOptionsItemSelected(MenuItem item)

	### 销毁 Acitivity

		finish();
	### intent 

		+ 显式 Intent 
				Intent intent = new Intent(FirstActivity.this, SecondActivity.class);
				startActivity(intent);
		+ 隐式 Intent


		#### 声明活动能响应的 intent
		 <intent-filter> 
			 <action android:name="android.intent.action.VIEW" />
			 <category android:name="android.intent.category.DEFAULT" />
			 <data android:scheme="http" />
		 </intent-filter>

		#### 传递消息
			intent.putExtra("extra_data", data);
			----
			Intent intent = getIntent();
			String data = intent.getStringExtra("extra_data");

			返回数据
			startActivityForResult(intent, requestCode)
			----
			Intent intent = new Intent();
			intent.putExtra("data_return", "Hello FirstActivity");
			setResult(RESULT_OK, intent);
			finish();
			----
			@Override
			protected void onActivityResult(int requestCode, int resultCode, Intent data) {}

	### 活动的生存期

		onCreate()
		onStart()
			不可见 --> 可见
		onResume()
			处于用户交互状态，Task 栈顶
		onPause()
			准备恢复其他活动时，可清理一些占用资源
		onStop()
		onDestroy()
		onRestart()： onStop --> onStart

		#### 活动被回收
			+ onSaveInstanceState(Bundle bundle) 在回收之前调用，以保存临时数据.在 onCreate(Bundle bundle) 中恢复

	### 活动的启动模式
		在 AndroidManifest.xml 中 <activity> 指定 android:launchMode 

		+ standard 			可重复启动同一个活动
		+ singleTop 		若活动在栈顶，则不重新创建，
		+ singleTask 		若活动存在，则不创建
		+ singleInstance 	新的返回栈实例。

	### 最佳实践
		#### 获取当前活动名

		public class BaseActivity extends Activity {
			@Override
			protected void onCreate(Bundle savedInstanceState) {
				super.onCreate(savedInstanceState);
				Log.d("BaseActivity", getClass().getSimpleName());
			}
		}
		#### 随时退出程序

		public class ActivityCollector {
			public static List<Activity> activities = new ArrayList<Activity>();
			public static void addActivity(Activity activity) {
				activities.add(activity);
			}
			public static void removeActivity(Activity activity) {
				activities.remove(activity);
			}
			public static void finishAll() {
				for (Activity activity : activities) {
					if (!activity.isFinishing()) {
						activity.finish();
					}
				}
			}
		}

		#### 将启动活动的方法写到活动类本身
		public class SecondActivity extends BaseActivity {
			public static void actionStart(Context context, String data1, String data2) {
				Intent intent = new Intent(context, SecondActivity.class);
				intent.putExtra("param1", data1);
				intent.putExtra("param2", data2);
				context.startActivity(intent);
			}
			……
		}
## 第三章 UI 开发
	### TextView

		<TextView
			android:id="@+id/text_view"
			android:layout_width="match_parent"
			android:layout_height="wrap_content"
			android:gravity="center"
			android:textSize="24sp"
			android:textColor="#00ff00"
			android:text="This is TextView" />
	### Button

		button = (Button) findViewById(R.id.button);
		button.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
			// 在此处添加逻辑
			}
		});


		=============== 或者 


		public class MainActivity extends Activity implements OnClickListener {
			private Button button;
			@Override
			protected void onCreate(Bundle savedInstanceState) {
				super.onCreate(savedInstanceState);
				setContentView(R.layout.activity_main);
				button = (Button) findViewById(R.id.button);
				button.setOnClickListener(this);
			}
			@Override
			public void onClick(View v) {
				switch (v.getId()) {
					case R.id.button:
					// 在此处添加逻辑
					break;
					default:
					break;
				}
			}
		}

	### EditText

		android:hint = "some tips"  Just like "placeholder" in html.
		android:maxLines="2"

	### ImageView

		android:src="@drawable/ic_launcher"
		imageView.setImageResource(R.drawable.jelly_bean);

	### ProgressBar (android:visibility)

		+ visible 		View.VISIBLE
		+ invisible 	View.INVISIBLE
		+ gone			View.GONE

		"style="?android:attr/progressBarStyleHorizontal"
		android:max="100"
	### AlertDialog

		AlertDialog.Builder dialog = new AlertDialog.Builder(MainActivity.this);

	### ProgressDialog
		ProgressDialog progressDialog = new ProgressDialog(MainActivity.this);

	### 布局

		#### LinearLayout
			android:orientation=vertical/horizontal

			android:layout_gravity
			android:gravity
		#### RelativeLayout
			相对父亲控件
			+ android:layout_centerInParent="true"
			+ android:layout_alignParentRight="true"
 			+ android:layout_alignParentTop="true"

 			相对其他控件
 			+ android:layout_above="@id/button3"
 			+ android:layout_toLeftOf="@id/button3"

 		#### FrameLayout
 			所有控件都位于左上角。

 		#### TableLayout
 			<TableRow>
 				<TextView />
 				<Button />
 			</TableRow>
 		#### 自定义控件
 			##### 引入布局

 				<include layout="@layout/yourlayout" />
 			##### 自定义控件

 				public class TitleLayout extends LinearLayout {
					public TitleLayout(Context context, AttributeSet attrs) {
						super(context, attrs);
						LayoutInflater.from(context).inflate(R.layout.title, this);
						Button titleBack = (Button) findViewById(R.id.title_back);
						Button titleEdit = (Button) findViewById(R.id.title_edit);
						titleBack.setOnClickListener(new OnClickListener() {
							@Override
							public void onClick(View v) {
								((Activity) getContext()).finish();
							}
						});

						titleEdit.setOnClickListener(new OnClickListener() {
							@Override
							public void onClick(View v) {
								Toast.makeText(getContext(), "You clicked Edit button",
								Toast.LENGTH_SHORT).show();
							}
						});
					}
				}

				<com.example.uicustomviews.TitleLayout
				 android:layout_width="match_parent"
				 android:layout_height="wrap_content"
				 >
				</com.example.uicustomviews.TitleLayout>
	### ListView

		+ 允许用户通过手指上下滑动的方式将屏幕外的数据滚动到屏幕内

		+ 通过适配器传入数据

		ArrayAdapter<String> adapter = new ArrayAdapter<String>(MainActivity.this, android.R.layout.simple_list_item_1, data);
		listView.setAdapter(adapter);

		#### 定制 ListView 的界面
			**未完3.5.2**
		#### 提升 ListView 的运行效率
			**未完3.5.3**
		#### ListView 的点击事件
			**未完3.5.4**

	### 单位和尺寸
		float xdpi = getResources().getDisplayMetrics().xdpi;
		float ydpi = getResources().getDisplayMetrics().ydpi;

		控件单位用 dp
		字体单位用 sp

	### 编写界面最佳实践
		#### 制作 Nine-Patch 图片

		#### 编写精美的聊天界面
			**未完3.7.2**

## 第四章 手机平板，碎片 Fragment
	
	right_fragment.xml
	<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
		android:layout_width="match_parent"
		android:layout_height="match_parent"
		android:background="#00ff00"
		android:orientation="vertical" >

		<TextView
			android:layout_width="wrap_content"
			android:layout_height="wrap_content"
			android:layout_gravity="center_horizontal"
			android:textSize="20sp"
			android:text="This is right fragment"
			/>

	</LinearLayout>	

	RightFragment
	public class RightFragment extends Fragment {
		@Override
		public View onCreateView(LayoutInflater inflater, iewGroup container,
		Bundle savedInstanceState) {
			View view = inflater.inflate(R.layout.right_fragment, container, false);
			return view;
		}
	}

	<fragment
	 android:id="@+id/right_fragment"
	 android:name="com.example.fragmenttest.RightFragment"
	 android:layout_width="0dp"
	 android:layout_height="match_parent"
	 android:layout_weight="1" />

	 ### 动态添加碎片
		1. 创建待添加的碎片实例。
		2. 获取到 FragmentManager，在活动中可以直接调用 getFragmentManager()方法得到。
		3. 开启一个事务，通过调用 beginTransaction()方法开启。
		4. 向容器内加入碎片，一般使用 replace()方法实现，需要传入容器的 id 和待添加的碎片实例。
		5. 提交事务，调用 commit()方法来完成。
	
	### 在碎片中模拟返回栈

		transaction.addToBackStack(null);

	### 碎片与活动通信
		+ FragmentManager 提供了一个类似于 findViewById()的方法
		(RightFragment) getFragmentManager().findFragmentById(R.id.right_fragment);
		+ 每个碎片中都可以通过调用 getActivity()方法来得到和当前碎片相关联的活动实例
		
	### 碎片生命周期
		1. onAttach() 		当碎片和活动建立关联的时候调用。
		2. onCreateView() 	为碎片创建视图（加载布局）时调用。
		3. onActivityCreated()
		确保与碎片相关联的活动一定已经创建完毕的时候调用。
		4. onDestroyView()	当与碎片关联的视图被移除的时候调用。
		5. onDetach() 		当碎片和活动解除关联的时候调用。

		onSaveInstanceState() 可再被回收前保存数据到 Bundle
		并，在 onCreate()、onCreateView()和 onActivityCreated()
		中重新得到数据

	### 动态加载布局技巧
		#### 使用限定符
			+ 大小
				small 提供给小屏幕设备的资源
				normal 提供给中等屏幕设备的资源
				large 提供给大屏幕设备的资源
				xlarge 提供给超大屏幕设备的资源
			+ 分辨率
				ldpi 提供给低分辨率设备的资源（120dpi 以下）
				mdpi 提供给中等分辨率设备的资源（120dpi 到 160dpi）
				hdpi 提供给高分辨率设备的资源（160dpi 到 240dpi）
				xhdpi 提供给超高分辨率设备的资源（240dpi 到 320dpi）
			+ 方向
				land 提供给横屏设备的资源
				port 提供给竖屏设备的资源

		#### 最小宽度限定符
			在 res 目录下新建 layout-sw600dp 文件夹
			然后在这个文件夹下新建 activity_main.xml 布局，

			当程序运行在屏幕宽度大于 600dp 的设备上时，会加载 layout-sw600dp/activity_main 布局，当程序运行在屏幕宽度小于 600dp 的设备上时，则仍然加载默认的 layout/activity_main 布局

	### 4.5 碎片的最佳实践——一个简易版的新闻应用

			**未完**

## 广播机制
	+ 标准广播
	+ 有序广播（可被截断）

	### 注册广播
		+ 动态注册 在代码中注册
		+ 静态注册 在 AndroidManifest.xml 中注册

		新建一个继承自 BroadcastReceiver 的类，重写 onReceive()

		public class MainActivity extends Activity {
			private IntentFilter intentFilter;
			private NetworkChangeReceiver networkChangeReceiver;
			@Override
			protected void onCreate(Bundle savedInstanceState) {
				super.onCreate(savedInstanceState);
				setContentView(R.layout.activity_main);
				intentFilter = new IntentFilter();
				intentFilter.addAction("android.net.conn.CONNECTIVITY_CHANGE");
				networkChangeReceiver = new NetworkChangeReceiver();
				registerReceiver(networkChangeReceiver, intentFilter);
			}
			intentFilter = new IntentFilter();
			intentFilter.addAction("android.net.conn.CONNECTIVITY_CHANGE");
			networkChangeReceiver = new NetworkChangeReceiver();
			registerReceiver(networkChangeReceiver, intentFilter);

			@Override
			protected void onDestroy() {
				super.onDestroy();
				unregisterReceiver(networkChangeReceiver);
			}
			class NetworkChangeReceiver extends BroadcastReceiver {
				@Override
				public void onReceive(Context context, Intent intent) {
					Toast.makeText(context, "network changes",
					Toast.LENGTH_SHORT).show();
				}
			}
		}

	### 静态注册实现开机启动

		<receiver android:name=".BootCompleteReceiver" >
			<intent-filter>
				<action android:name="android.intent.action.BOOT_COMPLETED" />
			</intent-filter>
		</receiver>

	### 发送自定义广播

		+ sendBroadcast(intent);
		+ sendOrderedBroadcast(intent, null);
			根据优先级<intent-filter android:priority="100" >接收
			abortBroadcast(); 终止传递
	### 本地广播
		private LocalReceiver localReceiver;
		private LocalBroadcastManager localBroadcastManager;

## 第六章 数据存储持久化

	### 文件存储

	### SharedPreferences 存储 （XML）

	### SQLite 数据库存储

		db.beginTransaction(); // 开启事务
		db.setTransactionSuccessful(); // 事务已经执行成功
		db.endTransaction(); // 结束事务

## 第七章 跨程序共享数据，内容提供器 Content Provider
	
	### 访问其他程序中的数据
		ContentResolver
		URI:
			content://com.example.app.provider/table1
			content://com.example.app.provider/table2
	### 创建内容提供器的步骤 ContentProvider

		重写 ContentProvider 六个方法：
		public class MyProvider extends ContentProvider {
			@Override
			public boolean onCreate() {
				return false;
			}
			@Override
			public Cursor query(Uri uri, String[] projection, String selection,	String[] selectionArgs, String sortOrder) {
				return null;
			}
			@Override
			public Uri insert(Uri uri, ContentValues values) {
				return null;
			}
			@Override
			public int update(Uri uri, ContentValues values, String selection,	String[] selectionArgs) {
				return 0;
			}
			@Override
			public int delete(Uri uri, String selection, String[] selectionArgs) {
				return 0;
			}
			@Override
			public String getType(Uri uri) {
				return null;
			}
		}

		1. *：表示匹配任意长度的任意字符
		2. #：表示匹配任意长度的数字

		uriMatcher = new UriMatcher(UriMatcher.NO_MATCH);
		uriMatcher.addURI("com.example.app.provider", "table1", TABLE1_DIR);

		#### getType
			1. 必须以 vnd 开头。
			2. 如果内容 URI 以路径结尾，则后接 android.cursor.dir/，如果内容 URI 以 id 结尾，则后接 android.cursor.item/。
			3. 最后接上 vnd.<authority>.<path>。

			vnd.android.cursor.dir/vnd.com.example.app.provider.table1

			重写 getType()
			@Override
			public String getType(Uri uri) {
				switch (uriMatcher.match(uri)) {
					case TABLE1_DIR:
						return "vnd.android.cursor.dir/vnd.com.example.app.provider.table1";
					case TABLE1_ITEM:
						return "vnd.android.cursor.item/vnd.com.example.app.provider.table1";
					case TABLE2_DIR:
						return "vnd.android.cursor.dir/vnd.com.example.app.provider.table2";
					case TABLE2_ITEM:
						return "vnd.android.cursor.item/vnd.com.example.app.provider.table2";
					default:
					break;
				}
				return null;
			}

		#### 实现跨程序数据共享

			**未完7.3.2**

## 第八章 手机多媒体
	### 通知 NotificationManager
		NotificationManager manager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);

		**未完**
	### 接收和发送短信
		**未完**
	### 调用摄像头和相册
		**未完**
	### 播放多媒体文件
		+ 播放音频
		+ 播放视频
		**未完**

## 第九章 服务
	### Android 多线程编程
		+ 方式一，继承：
			class MyThread extends Thread {
				@Override
				public void run() {
					// 处理具体的逻辑
				}
			}

			new MyThread().start();
		+ 方式二，实现 Runnable 接口
			class MyThread implements Runnable {
				@Override
				public void run() {
					// 处理具体的逻辑
				}
			}

			MyThread myThread = new MyThread();
			new Thread(myThread).start();	
		+ 方式三，匿名类：
			new Thread(new Runnable() {
				@Override
				public void run() {
					// 处理具体的逻辑
				}
			}).start();
		#### 在子线程中更新 UI
			和许多其他的 GUI 库一样，Android 的 UI 也是线程不安全的。也就是说，如果想要更新应用程序里的 UI 元素，则必须在主线程中进行，否则就会出现异常。

			**利用异步消息实现**

			public class MainActivity extends Activity implements OnClickListener {
				public static final int UPDATE_TEXT = 1;
				private TextView text;
				private Button changeText;
				private Handler handler = new Handler() {
					public void handleMessage(Message msg) {
						switch (msg.what) {
							case UPDATE_TEXT:
								// 在这里可以进行UI操作
								text.setText("Nice to meet you");
							break;
							default:
							break;
						}
					}
				};
				……
				@Override
				public void onClick(View v) {
					switch (v.getId()) {
						case R.id.change_text:
							new Thread(new Runnable() {
								@Override
								public void run() {
									Message message = new Message();
									message.what = UPDATE_TEXT;
									handler.sendMessage(message); // 将Message对象发送出去
								}
							}).start();
						break;
						default:
						break;
					}
				}
			}
		#### 解析异步消息处理机制

			1. Message
			2. Handler
			3. MessageQueue
			4. Looper

		#### 使用 AsyncTask

			为了更加方便我们在子线程中对 UI 进行操作，Android 还提供了另外一些好用的工具，AsyncTask 就是其中之一。

			**未完**
	### 服务的基本用法

		public class MyService extends Service {
			@Override
			public IBinder onBind(Intent intent) {
				return null;
			}
			@Override
			public void onCreate() {
				super.onCreate();
			}
			@Override
			public int onStartCommand(Intent intent, int flags, int startId) {
				return super.onStartCommand(intent, flags, startId);
			}
			@Override
			public void onDestroy() {
				super.onDestroy();
			}
		}

		在 AndroidManifest.xml 中注册：

		<application
			android:allowBackup="true"
			android:icon="@drawable/ic_launcher"
			android:label="@string/app_name"
			android:theme="@style/AppTheme" >
			……
			<service android:name=".MyService" >
			</service>
		</application>

		#### 使用 Intent 启动和停止服务
			Intent startIntent = new Intent(this, MyService.class);
			startService(startIntent); // 启动服务

			Intent stopIntent = new Intent(this, MyService.class);
			stopService(stopIntent); // 停止服务

			在 MyService 的任何一个位置调用 stopSelf()方法，停止服务

		#### 活动和服务进行通信
			**未完**

		#### 使用前台服务，防止被回收 
			startForeground

		#### 使用 IntentService

			将服务处理逻辑放到子线程中：

			@Override
			public int onStartCommand(Intent intent, int flags, int startId) {
				new Thread(new Runnable() {
					@Override
					public void run() {
						// 处理具体的逻辑

						// stopSelf(); 执行完退出，不然服务会一直运行
					}
				}).start();
				return super.onStartCommand(intent, flags, startId);
			}

			Android 提供 IntentService 类
				**未完，IntentService**
	
	### 后台执行定时任务
		- Java API 提供 Timer 类 （受到休眠影响）
		- Android 的 Alarm 机制
		**未完9.6**

## 第十章 网络技术
	### HttpURLConnection

		GET:
			URL url = new URL("http://www.baidu.com");
			HttpURLConnection connection = (HttpURLConnection) url.openConnection();
			connection.setRequestMethod("GET");
			connection.setConnectTimeout(8000);
			connection.setReadTimeout(8000);
			InputStream in = connection.getInputStream();
			connection.disconnect();

		POST:
			connection.setRequestMethod("POST");
			DataOutputStream out = new DataOutputStream(connection.getOutputStream());
			out.writeBytes("username=admin&password=123456");
	
	### HttpClient

		GET:
			HttpClient httpClient = new DefaultHttpClient();
			HttpGet httpGet = new HttpGet("http://www.baidu.com");
			httpClient.execute(httpGet);

		POST:
			HttpPost httpPost = new HttpPost("http://www.baidu.com");
			List<NameValuePair> params = new ArrayList<NameValuePair>();
			params.add(new BasicNameValuePair("username", "admin"));
			params.add(new BasicNameValuePair("password", "123456"));
			UrlEncodedFormEntity entity = new UrlEncodedFormEntity(params, "utf-8");
			httpPost.setEntity(entity);

			httpClient.execute(httpPost);


		RESPONSE:
			if (httpResponse.getStatusLine().getStatusCode() == 200) {
				// 请求和响应都成功了
				HttpEntity entity = httpResponse.getEntity();
				String response = EntityUtils.toString(entity, "utf-8");
				// 通过 message->handler 使主进程更新UI
			}

	### 解析 XML 格式数据
		- Pull

			XmlPullParserFactory factory = XmlPullParserFactory.newInstance();
			XmlPullParser xmlPullParser = factory.newPullParser();
			xmlPullParser.setInput(new StringReader(xmlData));
		- SAX

			SAXParserFactory factory = SAXParserFactory.newInstance();
			XMLReader xmlReader = factory.newSAXParser().getXMLReader();
		- DOM
	### 解析 JSON 
		- 使用 JSONObject
			JSONArray jsonArray = new JSONArray(jsonData);
			JSONObject jsonObject = jsonArray.getJSONObject(i);
		- 使用 GSON （google开源项目，需添加包）
			Gson gson = new Gson();
			Person person = gson.fromJson(jsonData, Person.class);
			
			如果是 JSON 数组，则需要传入 TypeToken
			List<Person> people = gson.fromJson(jsonData, new TypeToken<List<Person>>(){}.getType());

	### 网络编程最佳实践，提出公共 http 请求代码

		public interface HttpCallbackListener {
			void onFinish(String response);
			void onError(Exception e);
		}

		public class HttpUtil {
			public static void sendHttpRequest(final String address, final HttpCallbackListener listener){
			
				new Thread(new Runnable(){
					HttpURLConnection connection = null;
					try {
						URL url = new URL(address);
						connection = (HttpURLConnection) url.openConnection();
						connection.setRequestMethod("GET");
						connection.setConnectTimeout(8000);
						connection.setReadTimeout(8000);
						connection.setDoInput(true);
						connection.setDoOutput(true);
						InputStream in = connection.getInputStream();
						BufferedReader reader = new BufferedReader(new InputStreamReader(in));
						StringBuilder response = new StringBuilder();
						String line;
						while ((line = reader.readLine()) != null) {
							response.append(line);
						}
						if(listener != null){
							// callback onFinish()
							listener.onFinish(response.toString());
						}
					} catch (Exception e) {
						if(listener != null){
							// callback onError()
							listener.onError(e);
						}
					} finally {
						if (connection != null) {
							connection.disconnect();
						}
					}

				}).start();
			}
		}

		String address = "http://www.baidu.com";
		HttpUtil.sendHttpRequest(address, new HttpCallbackListener(){
			@Override
			public void onFinish(String response){
				// handle response
			}

			@Override
			public void onError(Exception e){
				// handle exception
			}
		});
		
		注意耗时操作问题。利用 Java 的回调机制

		注意，onFinish()方法和 onError()方法最终还是在子线程中运行的，因此我们不可以在这里执行任何的 UI 操作，如果需要根据返回的结果来更新 UI，则仍然要使用上一章中我们学习的异步消息处理机制。

## 第十一章 定位 基于位置的服务
	### LocationManager 的基本用法
		LocationManager locationManager = (LocationManager) getSystemService(Context.LOCATION_SERVICE);

		Android 中的三种位置提供器：
			GPS_PROVIDER、NETWORK_PROVIDER 和 PASSIVE_PROVIDER。

		String provider = LocationManager.NETWORK_PROVIDER;
		Location location = locationManager.getLastKnownLocation(provider);

		检查可用位置提供器：
			List<String> providerList = locationManager.getProviders(true);
		获取位置改变信息：
		locationManager.requestLocationUpdates()

		**未完**
	### 反向地理编码 看懂位置信息
		- Geocoding API 由 Google 提供的 API
		- 百度地图
		**未完**

## 第十二章 Android 使用传感器
	### 光照传感器
		SensorManager senserManager = (SensorManager)
		getSystemService(Context.SENSOR_SERVICE);
		// 获得指定类型的传感器
		Sensor sensor = senserManager.getDefaultSensor(Sensor.TYPE_LIGHT);

		// 监听传感器输出 SensorEventListener 接口
		SensorEventListener listener = new SensorEventListener() {
			@Override
			public void onAccuracyChanged(Sensor sensor, int accuracy) {
			}
			@Override
			public void onSensorChanged(SensorEvent event) {
			}
		};

		// 注册监听器
		senserManager.registerListener(listener, senser, SensorManager.SENSOR_DELAY_NORMAL);

		// 退出时释放资源
		sensorManager.unregisterListener(listener);

	### 加速传感器
		Sensor sensor = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);

	### 方向传感器
		Sensor.TYPE_ORIENTATION

## 第十三章 高级技巧
	### 全局获取 Context 

		public class MyApplication extends Application {
			private static Context context;
			@Override
			public void onCreate() {
				context = getApplicationContext();
			}
			public static Context getContext() {
				return context;
			}
		}
		// 在 AndroidManifest.xml 中指定初始化 MyApplication 类
		<application
			android:name="com.example.networktest.MyApplication"
			…… >
			……
		</application>
	### 使用 Intent 传递对象
		// Intent 传递数据
		Intent intent = new Intent(FirstActivity.this, SecondActivity.class);
		intent.putExtra("string_data", "hello");
		intent.putExtra("int_data", 100);
		startActivity(intent);
		// 接收数据
		getIntent().getStringExtra("string_data");
		getIntent().getIntExtra("int_data", 0);

		- Serializable 接口
			// Person 类实现 Serializable 接口
			public class Person implements Serializable{
				private String name;
				private int age;
				public String getName() {
					return name;
				}
				public void setName(String name) {
					this.name = name;
				}
				public int getAge() {
					return age;
				}
				public void setAge(int age) {
					this.age = age;
				}
			}

			// 发送 person 对象
			Person person = new Person();
			person.setName("Tom");
			person.setAge(20);
			Intent intent = new Intent(FirstActivity.this, SecondActivity.class);
			intent.putExtra("person_data", person);
			startActivity(intent);

			// 接收 person 对象
			Person person = (Person) getIntent().getSerializableExtra("person_data");

		- Parcelable 方式（将对象分解为 Intent 所支持的类型）
			**未完**

	### 定制自己的日志工具

		// 定义 LogUtil 类
		public class LogUtil {
			public static final int VERBOSE = 1;
			public static final int DEBUG = 2;
			public static final int INFO = 3;
			public static final int WARN = 4;
			public static final int ERROR = 5;
			public static final int NOTHING = 6;
			public static final int LEVEL = VERBOSE;
			public static void v(String tag, String msg) {
				if (LEVEL <= VERBOSE) {
					Log.v(tag, msg);
				}
			}
			public static void d(String tag, String msg) {
				if (LEVEL <= DEBUG) {
					Log.d(tag, msg);
				}
			}
			public static void i(String tag, String msg) {
				if (LEVEL <= INFO) {
					Log.i(tag, msg);
				}
			}
			public static void w(String tag, String msg) {
				if (LEVEL <= WARN) {
					Log.w(tag, msg);
				}
			}
			public static void e(String tag, String msg) {
				if (LEVEL <= ERROR) {
					Log.e(tag, msg);
				}
			}
		}

	### 调试 Android 程序

	### 编写测试用例

## 第十四章 实战

## 第十五章 发布应用到 Google Play















