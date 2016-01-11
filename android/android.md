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

## 第四章 手机平板，碎片
	



















