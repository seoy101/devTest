/* left dropbox */
var Dropbox = {
	init : function(opt){
		this.option = $.extend({
			"ul" : ".menu_list",
			"opener" : ".gradient_bg"
		},opt);
		this.define();
		this.onhandler();
	},
	define : function(){
		this.menu = $(this.option.ul);
		this.menu.children("li").each(function(i,e){
			var $e = $(e);
			Dropbox.checker($e, $e.hasClass("open"));
		})
	},
	onhandler : function(){
		this.menu.on("click", this.option.opener, function(e){
			var $parent = $(this).parent();
			var bool = $parent.hasClass("open");
			Dropbox.open($parent, bool);
			Dropbox.checker($parent, !bool);
			e.preventDefault();				
		});
	},
	open : function($li,bool){
		if(bool){
			$li.removeClass("open");
			$li.find("input").prop("checked",false);
		} else {
			$li.addClass("open");
		}
	},
	checker : function($li,bool){
		$li.find("input").attr("disable",bool);
	}
}
Dropbox.init();
/* left dropbox end */


var PageIniter = {
	init : function(){
		this.define();
		this.onhandler();
	},
	define : function(){
		this.start = "initialization";
		this.startNum = 0;
		this.chkForm = $("[data-initer=chk_form]");
		this.layer = $("[data-initer=layer]");
		this.pages = this.layer.children("div[data-initer]");
		
		this.btnPrev = $("[data-initer=prev]");
		this.btnNext = $("[data-initer=next]");
	},
	onhandler : function(){
		this.btnPrev.on("click",function(){
			PageIniter.move(PageIniter.getPrevNum(),-1);
		});
		this.btnNext.on("click",function(){
			PageIniter.move(PageIniter.getNextNum(),1);
		});
	},
	setPage : function(){
		var data = PageIniter.chkForm.serializeArray();			
		if(!data.length) {
			alert("하나 이상 체크하세요");
			this.start = "initialization";
			PageIniter.show();
		} else {
			PageIniter.pageArr = [];
			this.startNum = 0;
			$.each(data,function(i,e){
				PageIniter.pageArr.push( PageIniter.pages.filter("[data-initer="+e.value+"]") );
			});
			PageIniter.start = data[0].value;
			PageIniter.show();
		}
		
	},
	getPrevNum : function(){
		return (PageIniter.pageArr.length + this.startNum - 1)%PageIniter.pageArr.length
	},
	getNextNum : function(){
		return (PageIniter.startNum + 1)%PageIniter.pageArr.length
	},
	show : function(){
		PageIniter.pages.removeClass("block").filter("[data-initer="+PageIniter.start+"]").addClass("block").css({"left" : 0});
	},
	move : function(endNum,dir){
		PageIniter.pages.removeClass("block");
		PageIniter.pageArr[PageIniter.startNum].addClass("block").css("left",0);
		if(PageIniter.pageArr.length > 1){
			PageIniter.pageArr[PageIniter.startNum].stop().animate({"left" : dir*-100+"%"},500,function(){
				PageIniter.pageArr[PageIniter.startNum].addClass("block");
			});
			PageIniter.pageArr[endNum].addClass("block").css({"left" : dir*100+"%"}).stop().animate({"left" : "0"},500,function(){
				PageIniter.startNum = endNum;
			});
		}
	}
}
PageIniter.init();



/* forms */
$("form.custom_inp").validator().on("submit",function(e){
	var $this = $(this);
	if (e.isDefaultPrevented()) {
		console.log("validation error");
	} else {
		switch( $this.data("action") ){
			case "initPage" :
				e.preventDefault();
				PageIniter.setPage();
			break;
			case "ajax" : 
				e.preventDefault();
				$.ajax({
					"url" : $this.data("url"),
					"succes" : function(data){
						console.log(data);
					}
				})
			default :
				console.log("submit");
			break
		}
	}
});
