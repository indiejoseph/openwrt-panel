$(window).ready(function() {

	var loadSetting = function() {
		$.ajax({
			type: 'get',
			dataType: 'json',
			url: '/db/settings.json',
			contentType: 'application/json; charset=utf-8',
			success: function(data) {

				var $template = $("#template");
				var $actions = $("#actions");
				var html = $template[0].innerHTML;
				var $li, v, i, n, b;

				window.settings = data.settings;
				$actions.html("");

				if(typeof(data.settings.buttons) != "undefined") {
					for(i = 0; i < data.settings.buttons.length; i++) {
						b = data.settings.buttons[i];
						v = b.value;
						n = b.name;
						$li = $("<li>").html(html);

						$('.input-button', $li).val(n);
						$('.input-value', $li).val(v);
						$actions.append($li);
					}
				}
			},
			error: function (data, err) {
				alert('Cannot load the setting file');
				//console.log(err);
			}
		});
	}

	$("#addButton").submit(function() {
		var n = $("#but-name").val();
		var v = $("#but-value").val();

		if(!n || !v) {
			alert("Button name or value cannot be empty");
			return false;
		}

		window.settings.buttons.push({
			name: n,
			value: v
		});

		$.ajax({
			type: 'post',
			dataType: 'json',
			processData: false,
			url: '/cgi-bin/create_button',
			data: JSON.stringify(window.settings),
			contentType: 'application/json; charset=utf-8',
			success: function(data) {
				console.log(data);
			}
		});

		loadSetting();

		return false;
	});

	loadSetting();

});