

function getContent(cb){
  var http = require("http");
  var url = "http://www.sckcd.com/Barcode/6901028085984.html";
  http.get(url,function(res){
    var data = "";
    res.on('data',function(d){
      data += d;
    });
    res.on('end',function(){
      // console.log(data);
      cb(data);
    })
  });
}


// query from  http://www.sckcd.com/Barcode/6901668053893.html
function parseInfo(html){
  var nameReg = /名称：<\/span><span id="ctl00_ContentPlaceHolder1_lblName">([^<]+)<\/span><\/dd><\/dl>/;
  var codeReg = /商品条码：<\/span><span id="ctl00_ContentPlaceHolder1_lblBarcode">([0-9]+)<\/span><\/dd>/;
  var sizeReg = /规格：<\/span><span id="ctl00_ContentPlaceHolder1_lblSpec">([^<]+)<\/span><\/dd>/;

  var n = html.match(nameReg)[1];

  var c = html.match(codeReg)[1];

  var s = html.match(sizeReg)[1];

  var info = { barcode: c, name: n, size: s };

  console.log(info);

}



// test

getContent(function(d){
  console.log(" Web page size: " + d.length);
  parseInfo(d);
});
