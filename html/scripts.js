$(document).keydown(function (e) // Disable Tab Key
{
    var keycode1 = (e.keyCode ? e.keyCode : e.which);
    if (keycode1 == 0 || keycode1 == 9) {
        e.preventDefault();
        e.stopPropagation();
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
				'<img src="nui://ArenaLobby/html/img/games/newgame.jpg" class="card-img-top">'+
			'</div>'+
			'<div class="card-body card-body-cascade">'+
				'<a class="create btn btn-default btn-lg">Create Game</a>'+
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
	if (item.message == "add"){
		let joinbutton = '<div class="card-footer text-muted text-center">' +
									'<div class="join btn btn-success" name="' + item.item + '">Join</div>' +
								  '</div>'
		if(item.state=="ArenaBusy"){
			joinbutton = '<div class="card-footer text-muted text-center">' +
									'<div class="btn btn-danger" name="' + item.item + '">Game Playing</div>' +
								  '</div>'
		}else if(item.password!=""){
			joinbutton = '<div class="card-footer text-muted text-center">' +
									'<div class="join btn btn-warning" name="' + item.item + '">Join <i class="fas fa-lock prefix"></i></div>' +
								  '</div>'
		}
		let map = item.label.match(/\(([^)]+)\)/);
		if(map!=null){
			map = '<img class="card-img-top map image2" src="nui://ArenaLobby/html/img/games/map/'+map[1]+'.jpg">'
		}else{
			map = '';
		}
		$( ".GameList" ).append(
		'<div class="col-md-4 mb-4 d-flex align-items-stretch-4">' +
			'<div class="card">' +
				'<div class="view-cascade overlay banner parent">' +
					'<div class="IMGcontainer ">'+
						'<img src="nui://ArenaLobby/html/img/games/' + item.image + '.jpg" class="card-img-top image1">' +
						map+
						'<div class="centered">' + item.label + '</div>'+
					'</div>'+
				'</div>' +
				'<div class="card-body card-body-cascade">' +
					'<h5 class="card-title text-info">By: ' + item.ownername + '</h5>' +
					'<h5 class="card-title text-success">Players: ' + item.players + '</h5>' +
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
		$(".notify .banner").attr("src","nui://ArenaLobby/html/img/games/"+item.gamename+".jpg");
		$(".notify .arenaName").text(item.gameLabel);
		$(".notify .ownername").text(item.ownername+" created room.");
		$(".notify").fadeIn();
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
	$("."+this.name+" .image2").attr("src", "nui://ArenaLobby/html/img/games/map/"+this.value+".jpg");
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
});

$(".GameCreate").on("click", ".ButtonBack", function() {
	soundClick = new Howl({src: ["./sounds/click.ogg"], volume: 1.0});
	soundClick.play();
	$(".GameLobby").fadeIn();
	$(".GameCreate").fadeOut();
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