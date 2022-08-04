$(document).keydown(function (e) // Disable Tab Key
{
    var keycode1 = (e.keyCode ? e.keyCode : e.which);
    if (keycode1 == 0 || keycode1 == 9) {
        e.preventDefault();
        e.stopPropagation();
    }
});

$(function(){
    function display(bool) {
        if (bool) {
            $(".container").fadeIn();		
        } else { 
            $(".container").fadeOut();
        }
    }
	window.addEventListener('message', function(event) {
		var item = event.data;
		if (item.type === "ui"){
			display(item.status);
			$(".seconds").text("Waiting for players.");
		}

		if (item.type === "arenaName"){
			$(".arenaName").text(item.arenaName);
			let map = item.arenaName.match(/\(([^)]+)\)/);
			if(map!=null){
				$(".map").show();
				$(".map").attr("src","nui://ArenaLobby/html/img/games/map/"+map[1]+".jpg");
				$(".map").error(function () {
					$(this).hide();
				});
			}else{
				$(".map").hide();
			}
		}
		
		if (item.type === "arenaImage"){
			$(".banner").attr("src","nui://ArenaLobby/html/img/games/"+item.arenaImage+".jpg");
		}
		
		if (item.type === "updateTime"){
			$(".seconds").text("Game will start in: "+ item.time +" second.");
		}else if (item.type !== "playerNameList"){
			$(".seconds").text("Waiting for players.");
		}
		
		if (item.type === "playerNameList"){
			$(".players").text("");
            for (var index in item.Names) {
			    $(".players").append("<div class='col-3 mb-4'><img class='avatar' src='"+item.Names[index].avatar+"'> " + item.Names[index].name + "</div>")
			}
			$(".playercount").text(item.Names.length)
		}
	})
});