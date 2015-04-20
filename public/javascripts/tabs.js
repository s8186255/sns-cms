/***************************/
//@Author: Adrian "yEnS" Mato Gondelle & Ivan Guardado Castro
//@website: www.yensdesign.com
//@email: yensamg@gmail.com
//@license: Feel free to use it, but keep this credits please!					
/***************************/

$(document).ready(function(){
  $(".menu > li").click(function(e){
    switch(e.target.id){
      case "topics":
        //change status & style menu
        $("#topics").addClass("active");
        $("#infos").removeClass("active");
        $("#new-info").removeClass("active");
        $("#personal").removeClass("active");
        //display selected division, hide others
        $("div.topics").fadeIn();
        $("div.infos").css("display", "none");
        $("div.new-info").css("display", "none");
        $("div.personal").css("display", "none");
        break;
      case "infos":
        //change status & style menu
        $("#topics").removeClass("active");
        $("#infos").addClass("active");
        $("#new-info").removeClass("active");
        $("#personal").removeClass("active");
        //display selected division, hide others
        $("div.topics").css("display", "none");
        $("div.infos").fadeIn();
        $("div.new-info").css("display", "none");
        $("div.personal").css("display", "none");
        break;
      case "new-info":
        //change status & style menu
        $("#topics").removeClass("active");
        $("#infos").removeClass("active");
        $("#new-info").addClass("active");
        $("#personal").removeClass("active");
        //display selected division, hide others
        $("div.topics").css("display", "none");
        $("div.infos").css("display", "none");
        $("div.new-info").fadeIn();
        $("div.personal").css("display", "none");
        break;
      case "personal":
        //change status & style menu
        $("#topics").removeClass("active");
        $("#infos").removeClass("active");
        $("#new-info").removeClass("active");
        $("#personal").addClass("active");
        //display selected division, hide others
        $("div.topics").css("display", "none");
        $("div.infos").css("display", "none");
        $("div.new-info").css("display", "none");
        $("div.personal").fadeIn();
        break;
    }
    //alert(e.target.id);
    return false;
  });
});