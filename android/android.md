# Android

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



