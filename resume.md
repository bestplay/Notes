# Who am i

My name is Lu Wei, or Wayne as English name. I was born in 1989.

In 2012, i graduated from Chengdu University of Information Technology where i studied Computer Science.

I love new tech, love github, keep eyes on AI and love my baby(i got a daughter in 2013 :)).

And i can get familiar with any new tech in a week.

# Experience

## C/C++

  **In 2012**, i work for Chinasoft International(ICS&S) as my first job.
  And about half a year later, i quit for some private reason(too young too simple).

## Font-End web development

  **2013-2014**, I joined in Chengdu YiMing Technology Co., Ltd as Font-End web developer, using **HTML CSS Javascript**.

  Developing websites for both laptop and mobile phones.

  Yes, i tried **Bootstrap**. It is great. Using media query to make responsive websites and be friendly with mobile devices.

## Back-End web development

  **Now**, i am working for FIH(Chengdu)Communication Technology Co.,Ltd as **Back-End or full stack developer**.

#### Node.js Web server

  Develop and maintain web servers in **Nodejs**, and using **PostgreSQL, Redis**.
  
  This is my major work. 
  
  We use pure Nodejs with some Modules to connect DBs and some light-weight Modules like Async.
  
  Yes, I like Node.js better than hate it, even if some times it sucked.
  
  There is a thing. 
  
  When I using Nodejs to make a HTTP request. It doesn't return anything or throw any error in a bad network.
  
  Because it's default request timeout is never timeout. (I didn't use three-part modules like [Request](https://github.com/request/request) because of some reason or maybe i missed something)
  
  You need to [set a timeout manually](https://nodejs.org/api/http.html#http_request_settimeout_timeout_callback).
  
  And I made a "Request.js" as my request module by myself and it worked very well,
  
  which can set a proxy, access some websites of Apple and upload files.
  

#### Desktop Client to diagnostics recycling IPhones (base on Node-Webkit)
  I propose my superior to use **Node-Webkit** to build Desktop Clients for Recycling IPhones project, instead of outsourcing.

  And It works.


  When it start, it will start **listening USB** device changes in a child process.

  At the same time it will **check updates** from server.
  It will auto download patches and finish update to new version when it restarted just like the way of **Chrome**.

  When an IPhone is added via USB, it will auto **test the hardware status**.
  And **check FMI and guaranty** from Apple's website.

  Then user/operator need to do some visual check.

  After that it will send all results about this phone to server to get **assessment price** of it.
  
  

  - It communicates with both server and web font end by http/https or websocket.

    Yes, we tried **socket.io**. Using Nodejs's "cluster" with multiple processors, it will get a mess.

    And i found some workarounds like tracing the session by any identity or using Redis.

    Finally, we dropped it. Because our applications is not necessary to make it Real-time. And HTTP is fine.  

  - It can also talk to Apps installed in IPhones via USB using TCP socket connections(multiple phones model).

    We build an App run in IPhones to provide a TCP server.

    And then Node-Webkit Client connect to the TCP server via USB cable with some open source tools.

  - Auto incremental update.

    Every release installation file is more than 50MB.

    But it can only download less than 200KB patches files to finish updating from an old release to the newest one.

    To approach that, I used Rsync & Courgette.

    I compiled the source code of **chromium**, and get the Courgette tool which can compare binary code and make patches by disassembling.

    And I write a launcher for it in **C++**(Windows).

    The launcher will read the recent version's path in a specific file and launch the real program.

    Each time it finished update, it will update the path in the file and delete the old release.

  - USB device detection(plug/unplug) wrote in C++ using Windows system API from MSDN.

  - Communicates with Font-End by websocket for reason of separation.
    
    Because we planed to make it deloyed in Raspberry Pi using Nodejs as diagnosticsing server and browser as Client, without Node-Webkit. In order to make a handheld device. And I proved it to be reachable. 

  - IPhones testing (multiple phones model for factory / single model for shop). 
    Using [libimobiledevice](https://github.com/libimobiledevice/libimobiledevice) to diagnostics IPhones.

    And run these tools in Node.js child process. 
    
    Also do well with the child processes management. using Tree-kill or Windows comand "taskkill"(I tried both).

  - **Print doc and barcode** without using the browser's features.

    The requirement is printing from HTML in background.

    I use **C++ (Windows)** to develop a command line tool to print images in background.

    First, i use html2canvas to get a base64 image from our Font-End web page.

    Then send the image file to a printer via my print.exe tool.

    print.exe also provide scanning printers. also it is able to choose a printer to print.
  - Be able to **set proxy for users** in different env.

    In my Node-Webkit Client, there is two parts of code, **Nodejs** code and Font-End code run in browser both need to set proxy in different ways.

    Users can set proxy once and it will work both.

#### Android development

  I got familiar with Android development in a week.(When we were lack of Android developer)
  And developed an App for Android. Access to Facebook Whatapp and so on via OAuth.
  And provide some Javascript API for webview.

#### Tools for workmates

  **Python** sublime text plugin and Nodejs command line tool for my workmates to replace hardcode, saved lot of time.

  In order to make the three-part source code we bought from other company which wrote in PHP to I18N.

  I developed some tools my workmates to replace hardcode.

  Python plugin for sublime text Editor. it can Regex match the hardcode words and auto open the files they located.

  And it will suggest different replacements, like `<?php echo replaced-hardcode ?>` or just `echo` while inner a PHP label.

#### Recently

  Using three-part source code writing in **PHP** (our company bought it) to build a website for India oriented e-commerce platform.

  Access Facebook and twitter by OAuth to login or share links and pictures.

  Develop and design API for Font-End in PHP.

## Other project

- DDNS

  Developed and deployed a program in Node.js on my Raspberry Pi in my house.
  
  To make my home's local network dynamic IP address auto update to my DDNS.

  So that, i can access my local network from outside.

  Or use my Proxy Server running on the **Raspberry Pi** anywhere.
  
  And while my network router get sucked with too many traffic, 
  
  it will try to ping some famous Host like google.com to make sure.
  
  Then it will send a Http request to reboot the router.
 
  And it worked like a charm.


  [Here is the code](https://github.com/bestplay/ddnsAsync)

- Proxy

  Developed a proxy service in my Raspberry Pi using GAE to break GFW(you don't live in China, you will never understand..).

  This is the free and best solution so far.

  I used [Shadowsocks](https://github.com/shadowsocks/shadowsocks) and pay $5 for [Digitalocean's VPS](https://www.digitalocean.com/) before.

  And cloned Shadowsocks' source code have a look into **Python**.

- Auto refresh resumes

  Develop a robot in by Raspberry Pi to auto login 51job dot com and update my resumes.
  
  It was write in Nodejs. And it can auto parse the HTTP headers(set-cookies), and save the cookies. 
  
  It act just like i login the website with browsers manually.
  
  Yes, i know there is a Module like [cookie-parser](https://github.com/expressjs/cookie-parser). But i just can do it, why not.

- develop a Teris game using **Assembly language** (Assembly maltreats me thousands of times, i make it as first lover.)

  It can play just as the Teris game.

  *Words from the Big-Bang:*

  *"Why are you doing this?"*

  *"Because we can"*

  [Here is the code](https://github.com/bestplay/myprj/blob/master/asm/tetris.asm)



I have learned so many things in my work. Not only tech skills, but also social skills.

Thanks for these great companies i have worked for.


# Next

- Improve my English  
- Try Golang
- Do more sports

----------
*Ignore the words below ...*
# Why

Why am i talking about these tiny or maybe useless project?

Because every great thing consist of little steps.

And live and learn.

What do we live for?

Who knows..

Em, whatever..

*"Talk is cheap, show me the code."*
