   //NAV-FIX
        $(document).ready(function() {
	var s = $(".sticker");
	var pos = s.position();					   
	$(window).scroll(function() {
		var windowpos = $(window).scrollTop();
		if (windowpos >= pos.top & windowpos <=20000) {
			s.addClass("stick");
		} else {
			s.removeClass("stick");	
		}
	});
});
        //ITEM-NAV CURSO
            $(document).ready(function() {
	var s = $(".curso-all");
	var x = $(".i-curso");
	var b = $(".i-sobre");
	var pos = s.position();					   
	$(window).scroll(function() {
		var windowpos = $(window).scrollTop();
		if (windowpos >= pos.top & windowpos <=20000) {
			x.addClass("nav-item-active");
			b.removeClass("nav-item-active");
		} else {
			x.removeClass("nav-item-active");
            b.addClass("nav-item-active");
		}
	});
});
      
  //ITEM-NAV CURSO
            $(document).ready(function() {
	var s = $(".curso-all");
	var ss = $(".pre-row");
	var sss = $(".prof-row");
	var ssss = $(".faq");

	var x = $(".i-curso");
	var b = $(".i-como");
	var c = $(".i-inst");
	var d = $(".i-faq");

	var pos = s.position();					   
	var poss = ss.position();					   
	var posss = sss.position();					   
	var possss = ssss.position();					   
	$(window).scroll(function() {
		var windowpos = $(window).scrollTop();
		if (windowpos >= pos.top & windowpos <=20000) {
			x.addClass("nav-item-active");
			b.removeClass("nav-item-active");
		} else {
			x.removeClass("nav-item-active");
            b.addClass("nav-item-active");
		}
	var windowpos = $(window).scrollTop();
		if (windowpos >= poss.top & windowpos <=20000) {
			b.addClass("nav-item-active");
			x.removeClass("nav-item-active");
		} else {
			b.removeClass("nav-item-active");
            
		}
        	var windowpos = $(window).scrollTop();
		if (windowpos >= posss.top & windowpos <=20000) {
			c.addClass("nav-item-active");
			b.removeClass("nav-item-active");
		} else {
			c.removeClass("nav-item-active");
            
		}
	  	var windowpos = $(window).scrollTop();
		if (windowpos >= possss.top & windowpos <=20000) {
			d.addClass("nav-item-active");
			c.removeClass("nav-item-active");
		} else {
			d.removeClass("nav-item-active");
            
		}
	
	
    
    });
});
      
 

    
   
 //SMOOTH SCROOL
$(document).ready(function(){

  $("a").on('click', function(event) {
      
    if (this.hash !== "") {
      event.preventDefault();

      var hash = this.hash;

      $('html, body').animate({
        scrollTop: $(hash).offset().top
      }, 800, function(){

        window.location.hash = hash;
      });
    } 
  });
});