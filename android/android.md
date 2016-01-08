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
		+ singleTop 		若活动在栈顶，则不重新创建
		+ singleTask
		+ singleInstance



