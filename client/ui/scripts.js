var xboxIndex = 1;
var isXbox = false;

/*
	GameSelect = create new lobby
	GameList = lobby list
*/

function RefreshXboxHover() {
	xboxIndex = 1;

	// Clear hover
	for (let i = 0; i < $(".GameSelect .newGame").length; i++) {
		let button = $(".GameSelect").parent().find(".newGame").eq(i)
		button.removeClass("controller_index-" + (i + 1))
		button.removeClass("xboxHovered")
	}

	// Clear hover
	for (let i = 0; i < $(".GameList .btn").length; i++) {
		let button = $(".GameList").parent().find(".btn").eq(i)
		button.removeClass("controller_index-" + (i + 1))
		button.removeClass("xboxHovered")
	}

	// Create controller hover index
	var index = 0
	for (let i = 0; i < $(".GameSelect .newGame").length; i++) {
		let button = $(".GameSelect").parent().find(".newGame").eq(i)
		if (button.is(":visible")) {
			index += 1
			button.addClass("controller_index-" + index)
		}
	}

	// Create controller hover index
	for (let i = 0; i < $(".GameList .btn").length; i++) {
		let button = $(".GameList").parent().find(".btn").eq(i)
		button.addClass("controller_index-" + (i + 1))
	}

	if (isXbox) {
		$(".controller_index-" + xboxIndex).addClass("xboxHovered");
		$(".ButtonBack").css("opacity", "0.0");
		$(".exit").css("opacity", "0.0");
	} else {
		$(".ButtonBack").css("opacity", "1.0");
		$(".exit").css("opacity", "1.0");
	}

	$('.GameCreate .container').animate({
		scrollTop: 0
	}, 0);
}

function GoBack() {
	if ($(".ButtonBack").is(":visible")) {
		$(".ButtonBack").trigger("click");
	} else {
		$.post(`https://${GetParentResourceName()}/quit`, JSON.stringify({}));
	}
}

// Disable Tab Key
$(document).keydown(function (e) {
	var keycode1 = (e.keyCode ? e.keyCode : e.which);
	if (keycode1 == 0 || keycode1 == 9) {
		e.preventDefault();
		e.stopPropagation();
	}
});

// ESC
$("body").on("keyup", function (key) {
	var closeKeys = [113, 27, 90];
	if (closeKeys.includes(key.which)) {
		GoBack()
	}
});

// Close button
$(".exit").click(function () {
	$.post(`https://${GetParentResourceName()}/quit`, JSON.stringify({}));
});

// Dropdown
$(".GameSelect").on("click", "#selectMap", function () {
	soundClick2 = new Howl({ src: ["./sounds/click2.ogg"], volume: 1.0 });
	soundClick2.play();
});


// CREATE GAME button
$(".GameList").on("click", ".create", function () {
	xboxIndex = 1;

	soundClick = new Howl({ src: ["./sounds/click.ogg"], volume: 1.0 });
	soundClick.play();

	$(".GameLobby").hide();
	$(".GameCreate").show();

	RefreshXboxHover()
});

// Press back
$(".GameCreate").on("click", ".ButtonBack", function () {
	soundClick = new Howl({ src: ["./sounds/click.ogg"], volume: 1.0 });
	soundClick.play();

	$(".GameLobby").show();
	$(".GameCreate").hide();

	RefreshXboxHover()
});

$(".GameSelect").on("click", ".btnQuantity", function () {
	var $button = $(this);
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
	soundClick = new Howl({ src: ["./sounds/click.ogg"], volume: 1.0 });
	soundClick.play();
});

//?? Listen for NUI Events
window.addEventListener('message', function (event) {
	var item = event.data;

	//?? Open main window
	if (item.message == "show") {
		isXbox = item.withXbox

		soundOpen = new Howl({ src: ["./sounds/open.ogg"], volume: 1.0 });
		soundOpen.play();

		$(".GameLobby").fadeIn(200);

		RefreshXboxHover()
	}

	//?? Close main window
	if (item.message == "hide") {
		$(".GameLobby").fadeOut(200);
		$(".GameCreate").fadeOut(200);
		soundClick2 = new Howl({ src: ["./sounds/click2.ogg"], volume: 1.0 });
		soundClick2.play();
	}

	//?? When ArenaAPI:sendStatus add or remove lobby update .GameList
	if (item.message == "refresh_controller_index") {
		RefreshXboxHover()
	}

	if (item.message == "clear") {
		$(".GameList .ArenaList").remove();
	}

	//?? Hide not started script games
	if (item.message == "hideGame") {
		if (item.isHide) {
			$("." + item.name).attr('style', 'display: none !important');
		} else {
			$("." + item.name).show();
		}
	}

	//?? Add lobby
	if (item.message == "add") {
		let joinButton = `
			<div class="card-footer text-muted text-center">
				<button class="join controller_join btn btn-success" name="` + item.item + `">Join</button>
			</div>`
		if (item.state == "ArenaBusy") {
			joinButton = `
				<div class="card-footer text-muted text-center">
					<button class="controller_join btn btn-danger" name="` + item.item + `">Game Playing</button>
				</div>`
		} else if (item.password !== "") {
			joinButton = `
				<div class="card-footer text-muted text-center">
					<button class="join controller_join btn btn-warning" name="` + item.item + `">Join <i class="fas fa-lock prefix"></i></button>
				</div>`
		}
		let map = item.label.match(/\(([^)]+)\)/);
		if (map != null) {
			map = '<img class="card-img-top map image2" src="./img/games/map/' + map[1] + '.jpg">'
		} else {
			map = '';
		}

		let ImageTag = ""
		if (item.imageUrl && item.imageUrl != "") {
			ImageTag = '<img src="' + item.imageUrl + '" class="card-img-top image1">'
		} else {
			ImageTag = '<img src="./img/games/' + item.image + '.jpg" class="card-img-top image1">'
		}

		var avatarList = "";
		for (const [key, value] of Object.entries(item.PlayerAvatar)) {
			if (value != null && value) {
				avatarList += '<img src=' + value + ' class="avatar">';
			}
		}

		$(".GameList").append(`
			<div class="col-md-4 mb-4 d-flex align-items-stretch ArenaList">
				<div class="card">
					<div class="view-cascade overlay banner parent">
						<div class="IMGcontainer">` + ImageTag + map + `
							<div class="centered">` + item.label + `</div>
						</div>
					</div>
					<div class="card-body card-body-cascade">
						<h5 class="card-title text-info">By: ` + item.ownerName + `</h5>
						<h5 class="card-title text-success">Players: ` + item.players + `</h5>` + avatarList + `
					</div>` + joinButton + `
				</div>
			</div>
		`);
		$(".map").error(function () {
			$(this).hide();
		});
		$(".image1").error(function () {
			$(this).attr("src", './img/games/' + item.image + '.jpg');
		});
	}

	if (item.message === "music_play") {
		soundMainRoom = new Howl({ src: ["./sounds/main_room.ogg"], volume: 0.8, loop: true });
		soundMainRoom.play();
	}

	if (item.message === "music_stop") {
		if (soundMainRoom != null) {
			soundMainRoom.stop();
		}
	}

	//?? Create notification
	if (item.message === "notify") {
		if (item.ArenaImageUrl) {
			$(".notify .banner").attr("src", item.ArenaImageUrl);
		} else {
			$(".notify .banner").attr("src", "./img/games/" + item.gameName + ".jpg");
		}
		if (item.gameLabel) {
			$(".notify .arenaName").text("");
			$(".notify .arenaName").append(item.gameLabel);
		} else {
			$(".notify .arenaName").text(item.gameName);
		}
		$(".notify .ownerName").text(item.ownerName + " created room.");
		$(".notify").fadeIn(200);

		soundCreateRoom = new Howl({ src: ["./sounds/createLobby.ogg"], volume: 1.0 });
		soundCreateRoom.play();

		setTimeout(function () {
			$(".notify").fadeOut(200);
		}, 3000);
	}
});

$(".GameList").on("click", ".join", function () {
	var $button = $(this);
	var $name = $button.attr('name')
	$.post(`https://${GetParentResourceName()}/quit`, JSON.stringify({}));
	$.post(`https://${GetParentResourceName()}/join`, JSON.stringify({
		item: $name,
	}));
	soundJoinRoom = new Howl({ src: ["./sounds/joinRoom.ogg"], volume: 1.0 });
	soundJoinRoom.play();
});

$('.GameSelect select').on('change', function () {
	$("." + this.name + " .image2").attr("src", "./img/games/map/" + this.value + ".jpg");
});

$(".GameSelect").on("click", ".newGame", function () {
	var $button = $(this);
	var $gameName = $button.attr('name')
	var $gameLabel = $button.parent().parent().find(".centered").text()
	var $password = $button.parent().parent().find("#password").val()
	var $option1 = $button.parent().parent().find("#option1").val()
	var $option2 = $button.parent().parent().find("#option2").val()
	var $option3 = $button.parent().parent().find("#option3").val()
	var $option4 = $button.parent().parent().find("#option4").val()
	var $option5 = $button.parent().parent().find("#option5").val()
	var $option6 = $button.parent().parent().find("#option6").val()

	if ($option1 != "" && $option2 != "" && $option3 != "" && $option4 != "" && $option5 != "" && $option6 != "") {
		$.post(`https://${GetParentResourceName()}/quit`, JSON.stringify({}));
		$.post(`https://${GetParentResourceName()}/create`, JSON.stringify({
			password: $password,
			gameName: $gameName,
			gameLabel: $gameLabel,
			option1: $option1,
			option2: $option2,
			option3: $option3,
			option4: $option4,
			option5: $option5,
			option6: $option6,
		}));
		soundCreateRoom = new Howl({ src: ["./sounds/createRoom.ogg"], volume: 1.0 });
		soundCreateRoom.play();
	}
});

//?? Xbox control
window.addEventListener('message', function (event) {
	var item = event.data;

	if (item.message == "control_right") {
		if ($(".controller_index-" + (xboxIndex + 1)).length !== 0) {
			$(".controller_index-" + (xboxIndex)).removeClass("xboxHovered");
			xboxIndex += 1
			$(".controller_index-" + (xboxIndex)).addClass("xboxHovered");

			var container = $('.GameCreate .container');
			var scrollTo = $(".controller_index-" + (xboxIndex));
			var position = scrollTo.offset().top - container.offset().top + container.scrollTop();
			container.animate({
				scrollTop: position - 800
			}, 100);

			soundClick = new Howl({ src: ["./sounds/click.ogg"], volume: 1.0 });
			soundClick.play();
		}
	}

	if (item.message == "control_left") {
		if ($(".controller_index-" + (xboxIndex - 1)).length !== 0) {
			$(".controller_index-" + (xboxIndex)).removeClass("xboxHovered");
			xboxIndex -= 1
			$(".controller_index-" + (xboxIndex)).addClass("xboxHovered");

			var container = $('.GameCreate .container');
			var scrollTo = $(".controller_index-" + (xboxIndex));
			var position = scrollTo.offset().top - container.offset().top + container.scrollTop();
			container.animate({
				scrollTop: position - 800
			}, 100);

			soundClick = new Howl({ src: ["./sounds/click.ogg"], volume: 1.0 });
			soundClick.play();
		}
	}

	if (item.message == "control_a") {
		$(".controller_index-" + xboxIndex).trigger("click");
	}

	if (item.message == "control_b") {
		GoBack()
	}
});