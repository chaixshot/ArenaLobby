var controller_index = 1;
var withXbox = false;

$(document).keydown(function (e) // Disable Tab Key
{
    var keycode1 = (e.keyCode ? e.keyCode : e.which);
    if (keycode1 == 0 || keycode1 == 9) {
        e.preventDefault();
        e.stopPropagation();
    }
});

$("body").on("keyup", function(key){
	var closeKeys = [113, 27, 90];
	if (closeKeys.includes(key.which)) {
		$.post(`https://${GetParentResourceName()}/quit`, JSON.stringify({}));
	}
});

$(".exit").click(function(){
    $.post(`https://${GetParentResourceName()}/quit`, JSON.stringify({}));
});

function ClearGameList(){
	$( ".GameList" ).empty();
	$( ".GameList" ).append(
	'<div class="col-md-4 mb-4 d-flex align-items-stretch">'+
		'<div class="card">'+
			'<div class="view view-cascade overlay banner">'+
				'<img src="./img/games/newgame.jpg" class="card-img-top">'+
			'</div>'+
			'<div class="card-body card-body-cascade">'+
				'<buttton class="create btn btn-default btn-lg text-white controller_index controller_index-1">Create Game</buttton>'+
			'</div>'+
		'</div>'+
	'</div>');
}
// Listen for NUI Events
window.addEventListener('message', function (event) {
	var item = event.data;
	// Open & Close main window
	if (item.message == "show") {
		soundOpen = new Howl({src: ["./sounds/open.ogg"], volume: 1.0});
		soundOpen.play();
		if (item.clear == true){
			ClearGameList();
		}
		$(".GameLobby").fadeIn();
		
		withXbox = item.withXbox
		controller_index = 1;
		for (let i = 0; i < $(".GameSelect .newgame").length; i++) {
		  $(".GameSelect").parent().find(".newgame").eq(i).removeClass("controller_index-"+(i+1))
		}
		for (let i = 0; i < $(".GameList .btn").length; i++) {
		  $(".GameList").parent().find(".btn").eq(i).addClass("controller_index-"+(i+1))
		}
		if(withXbox){
			$(".controller_index-"+controller_index).addClass("controllerHovered");
			$(".ButtonBack").hide();
			$(".exit").hide();
		}else{
			$(".ButtonBack").show();
			$(".exit").show();
		}
	}

	if (item.message == "hide") {
		$(".GameLobby").fadeOut();
		$(".GameCreate").fadeOut();
		soundClick2 = new Howl({src: ["./sounds/click2.ogg"], volume: 1.0});
		soundClick2.play();
	}
	
	if (item.message == "clear"){
		ClearGameList();
	}
	if (item.message == "hidegame"){
		$("."+item.name).remove();
		if(item.name=="DarkRP_Racing"){
			$(".DarkRP_CreateRacing").remove();
		}
	}
	if (item.message == "add"){
		let joinCount = $(".controller_join").length+2
		let joinbutton = '<div class="card-footer text-muted text-center">' +
									'<button class="join controller_join btn btn-success controller_index-'+joinCount+'" name="' + item.item + '">Join</button>' +
								  '</div>'
		if(item.state=="ArenaBusy"){
			joinbutton = '<div class="card-footer text-muted text-center">' +
									'<button class="controller_join btn btn-danger controller_index-'+joinCount+'" name="' + item.item + '">Game Playing</button>' +
								  '</div>'
		}else if(item.password!==""){
			joinbutton = '<div class="card-footer text-muted text-center">' +
									'<button class="join controller_join btn btn-warning controller_index-'+joinCount+'" name="' + item.item + '">Join <i class="fas fa-lock prefix"></i></button>' +
								  '</div>'
		}
		let map = item.label.match(/\(([^)]+)\)/);
		if(map!=null){
			map = '<img class="card-img-top map image2" src="./img/games/map/'+map[1]+'.jpg">'
		}else{
			map = '';
		}
		
		let ImageTag = ""
		if(item.imageUrl && item.imageUrl != ""){
			ImageTag = '<img src="'+item.imageUrl+'" class="card-img-top image1">'
		}else{
			ImageTag = '<img src="./img/games/' + item.image + '.jpg" class="card-img-top image1">'
		}
		
		var avatraList = "";
		for (const [key, value] of Object.entries(item.PlayerAvatar)) {
			if(value != null && value){
				avatraList += "<img src="+value+" class='avatar'>";
			}
		}
		
		$( ".GameList" ).append(
		'<div class="col-md-4 mb-4 d-flex align-items-stretch-4">' +
			'<div class="card">' +
				'<div class="view-cascade overlay banner parent">' +
					'<div class="IMGcontainer ">'+
						ImageTag+
						map+
						'<div class="centered">' + item.label + '</div>'+
					'</div>'+
				'</div>' +
				'<div class="card-body card-body-cascade">' +
					'<h5 class="card-title text-info">By: ' + item.ownername + '</h5>' +
					'<h5 class="card-title text-success">Players: ' + item.players + '</h5>' +avatraList+
				'</div>' +
				joinbutton
				 +
			'</div>' +
		'</div>');
		$(".map").error(function () {
			$(this).hide();
		});
	}
	if (item.message === "playsound_MainRoom"){
		soundMainRoom = new Howl({src: ["./sounds/main_room.ogg"], volume: 0.8, loop:true});
		soundMainRoom.play();
	}
	if (item.message === "stopsound_MainRoom"){
		soundMainRoom.stop();
	}
	
	if (item.message === "notify"){
		$(".notify .arenaName").text(item.gamename);
		$(".notify .banner").attr("src","./img/games/"+item.gamename+".jpg");
		$(".notify .arenaName").text(item.gameLabel);
		$(".notify .ownername").text(item.ownername+" created room.");
		$(".notify").fadeIn();
		soundCreateRoom = new Howl({src: ["./sounds/createlobby.ogg"], volume: 1.0});
		soundCreateRoom.play();
		setTimeout(function() { 
			$(".notify").fadeOut();
		}, 3000);
	}
});

$(".GameList").on("click", ".join", function() {
	var $button = $(this);
	var $name = $button.attr('name')
	$.post(`https://${GetParentResourceName()}/quit`, JSON.stringify({}));
	$.post(`https://${GetParentResourceName()}/join`, JSON.stringify({
		item: $name,
	}));
	soundJoinRoom = new Howl({src: ["./sounds/joinroom.ogg"], volume: 1.0});
	soundJoinRoom.play();
});

$('.GameSelect select').on('change', function() {
	$("."+this.name+" .image2").attr("src", "./img/games/map/"+this.value+".jpg");
});
	
$(".GameSelect").on("click", ".newgame", function() {
	var $button = $(this);
	var $gamename = $button.attr('name')
	var $gameLabel = $button.parent().parent().find(".centered").text()
	var $password = $button.parent().parent().find("#password").val()
	var $option1 = $button.parent().parent().find("#option1").val()
	var $option2 = $button.parent().parent().find("#option2").val()
	var $option3 = $button.parent().parent().find("#option3").val()
	var $option4 = $button.parent().parent().find("#option4").val()
	var $option5 = $button.parent().parent().find("#option5").val()
	var $option6 = $button.parent().parent().find("#option6").val()
	if($option1!="" && $option2!="" && $option3!="" && $option4!="" && $option5!="" && $option6!=""){
		$.post(`https://${GetParentResourceName()}/quit`, JSON.stringify({}));
		$.post(`https://${GetParentResourceName()}/create`, JSON.stringify({
			password: $password,
			gamename: $gamename,
			gameLabel: $gameLabel,
			option1: $option1,
			option2: $option2,
			option3: $option3,
			option4: $option4,
			option5: $option5,
			option6: $option6,
		}));
		soundCreateRoom = new Howl({src: ["./sounds/createroom.ogg"], volume: 1.0});
		soundCreateRoom.play();
	}
});

$(".GameSelect").on("click", "#selectmap", function() {
	soundClick2 = new Howl({src: ["./sounds/click2.ogg"], volume: 1.0});
	soundClick2.play();
});

$(".GameList").on("click", ".create", function() {
	$(".GameLobby").fadeOut();
	$(".GameCreate").fadeIn();
	soundClick = new Howl({src: ["./sounds/click.ogg"], volume: 1.0});
	soundClick.play();
	
	for (let i = 0; i < $(".GameList .btn").length; i++) {
	  $(".GameList").parent().find(".btn").eq(i).removeClass("controller_index-"+(i+1))
	}
	for (let i = 0; i < $(".GameSelect .newgame").length; i++) {
	  $(".GameSelect").parent().find(".newgame").eq(i).addClass("controller_index-"+(i+1))
	}

	controller_index = 1;
	if(withXbox){
		$(".controller_index-"+controller_index).addClass("controllerHovered");
	}
});

$(".GameCreate").on("click", ".ButtonBack", function() {
	soundClick = new Howl({src: ["./sounds/click.ogg"], volume: 1.0});
	soundClick.play();
	$(".GameLobby").fadeIn();
	$(".GameCreate").fadeOut();
	
	controller_index = 1;
	for (let i = 0; i < $(".GameSelect .newgame").length; i++) {
	  $(".GameSelect").parent().find(".newgame").eq(i).removeClass("controller_index-"+(i+1))
	}
	for (let i = 0; i < $(".GameList .btn").length; i++) {
	  $(".GameList").parent().find(".btn").eq(i).addClass("controller_index-"+(i+1))
	}
	if(withXbox){
		$(".controller_index-"+controller_index).addClass("controllerHovered");
	}
});

$(".GameSelect").on("click", ".btnquantity", function() {
	var $button = $(this);
	var $name = $button.attr('name')
	var oldValue = $button.parent().find(".number").val();
	if ($button.get(0).id == "plus") {
		var newVal = parseFloat(oldValue) + 1;
	} else {
		if (oldValue > 1) {
			var newVal = parseFloat(oldValue) - 1;
		} else {
			newVal = 1;
		}
	}
	$button.parent().find(".number").val(newVal);
	soundClick = new Howl({src: ["./sounds/click.ogg"], volume: 1.0});
	soundClick.play();
});

window.addEventListener('message', function (event) {
	var item = event.data;

	if (item.message == "control_right") {
		if($(".controller_index-"+(controller_index+1)).length !== 0){
			controller_index += 1
			$(".controller_index-"+(controller_index)).addClass("controllerHovered");
			$(".controller_index-"+(controller_index-1)).removeClass("controllerHovered");
			
			var container = $('.GameCreate .container');
			var scrollTo = $(".controller_index-"+(controller_index));
			var position = scrollTo.offset().top - container.offset().top  + container.scrollTop();
			container.animate({
					scrollTop: position-800
			}, 300);
			
			soundClick = new Howl({src: ["./sounds/click.ogg"], volume: 1.0});
			soundClick.play();
		}
	}
	
	if (item.message == "control_left") {
		if($(".controller_index-"+(controller_index-1)).length !== 0){
			controller_index -= 1
			$(".controller_index-"+(controller_index)).addClass("controllerHovered");
			$(".controller_index-"+(controller_index+1)).removeClass("controllerHovered");
			
			var container = $('.GameCreate .container');
			var scrollTo = $(".controller_index-"+(controller_index));
			var position = scrollTo.offset().top - container.offset().top  + container.scrollTop();
			container.animate({
					scrollTop: position-800
			}, 300);
			
			soundClick = new Howl({src: ["./sounds/click.ogg"], volume: 1.0});
			soundClick.play();
		}
	}
	
	if (item.message == "control_a") {
		var selector = document.getElementsByName('DarkRP_Racing');
		$(".controller_index-"+controller_index).trigger("click");
	}
	
	if (item.message == "control_b") {
		if($(".ButtonBack").offset().top !== 0){
			soundClick = new Howl({src: ["./sounds/click.ogg"], volume: 1.0});
			soundClick.play();
			$(".GameLobby").fadeIn();
			$(".GameCreate").fadeOut();
			
			controller_index = 1;
			for (let i = 0; i < $(".GameSelect .newgame").length; i++) {
			  $(".GameSelect").parent().find(".newgame").eq(i).removeClass("controller_index-"+(i+1))
			}
			for (let i = 0; i < $(".GameList .btn").length; i++) {
			  $(".GameList").parent().find(".btn").eq(i).addClass("controller_index-"+(i+1))
			}
			$(".controller_index-"+controller_index).addClass("controllerHovered");
		} else{
			$.post(`https://${GetParentResourceName()}/quit`, JSON.stringify({}));
		}
	}
});